import deflate_tables as dt





def lzss_encode(bytestring, conf, verbose=False):
    # get_symbol_and_offset_bits_from_LL_table(3)
    lzss_bitstream = ''

    literals_and_length_symbols = []
    distance_symbols = []

    basic_encoded = []
    encoded = []
    history = []

    i = 0

    while i < len(bytestring):
        # if (i % 500 == 0):
            # print(f'progress: {round(100 * i / len(bytestring), 1)}%')

        distance = 0
        length = 1

        """
        anything in 
        bytestring[i: i + future_size]
        
        is found in 
        bytestring[i - history_size: i]
        
        ?
        """

        found_something = False
        cat_counter = 0
        cats_found = 0

        if (len(history) > 0):

            # consider search lengths of decreasing sizes.
            for search_len in range(conf['future_size'], conf['min_search_len'] - 1, -1):

                # our search term always starts from current step i
                search_term = bytestring[i: i + search_len]

                # make sure the history has enough literals in the first place
                if (len(history) >= search_len):

                    # to make sure the breaks have done their job
                    assert found_something == False

                    # identify the starting points of search in the history
                    # go backward; go farther bach in the history
                    # we favor matches in more recent history; it gives us shorter `distance` which require less bits



                    # assuming history size is larger than the input byte stream:
                    deepest_index_in_the_history = 0

                    # assuming history size can be smaller than the input byte stream:
                    # deepest_index_in_the_history = max(0, i - conf['history_size'])




                    history_start_search_idx_list = list(range(i - search_len, deepest_index_in_the_history - 1, -1))

                    for history_start_search_idx in history_start_search_idx_list:

                        """
                        check to see if you have a match
                        if there is a match, we are not done yet
                        
                        we have to check to CAT situation; it is of higher priority
                        if the match was found on the most recent chunk of the history
                        which means that the starting point of the search in the history
                        is equal to i - search_len, then we want to look into the future to see if
                        there are even more occurrences of the search term (CAT example).
                        """

                        if (bytestring[history_start_search_idx: history_start_search_idx + search_len] == search_term):


                            # print(f'i: {i}, search_len:{search_len}, history_start_search_idx_list:{history_start_search_idx}, search_term:{search_term}')
                            # continue


                            found_something = True
                            distance = i - history_start_search_idx
                            length = search_len

                            """
                            a CAT scanner can look through all the future (of course respecting the length limitation)
                            to activate a CAT scanner the found match must have been immediately placed before the current time
                            in other words, we activate a CAT scanner only if we find a match right behind us
                            
                            we want to keep min_search_len relatively small because we do not want to miss the CATs
                            if we have found cats, we need to reset the length before counting the cats.
                            """
                            if (history_start_search_idx == i - search_len and search_len > 1):
                                # print(f"CAT possibility at {i} bytestring[i]:{bytestring[i]}   CAT posibility")

                                cat_counter = 0
                                cats_count = 0
                                while cat_counter * search_len <= conf['future_size']:
                                    # cat candidate is from the future
                                    cat_candidate = bytestring[
                                                    i + cat_counter * search_len: i + (cat_counter + 1) * search_len]

                                    if (cat_candidate == search_term):
                                        if verbose: print(
                                            f"\t\tCAT confirmed:      cat_counter:{cat_counter}    bytestring[i]: {bytestring[i]}        cat_candidate:{cat_candidate}")

                                        if ((cats_count + 1) * search_len) <= dt.max_lenght:

                                            cats_count = cats_count + 1
                                            length = cats_count * search_len
                                        else:
                                            if verbose: print("\t\tcan't add more cats because of length_bits")
                                            break

                                    else:
                                        # if 1: print(f"\t\tcollected {cats_count} the cats")

                                        break

                                    cat_counter = cat_counter + 1

                                # print(f" found {cats_count} CAT cases of {search_term}")

                                if (cats_count >= 1):
                                    if verbose: print("\t\tCATs collected")
                                    cats_found = 1

                            break

                    if found_something:
                        break

        # building the lzss bitstream

        """
        if we did not find anything, lzss only writes the literal preceded by the zero bit flag
        if we found a dog then we need to check if it is worth back-referencing to it
        """

        do_the_back_referenc = (length >= conf['mlwbr']) and found_something

        if (not do_the_back_referenc and cats_found):
            if verbose:  print(f"\t\t___but we won't do the back reference. length: {length} cats_count:{cats_count}")

        if (do_the_back_referenc):

            length_info = dt.get_symbol_and_offset_bits_from_LL_table(length)
            distance_info = dt.get_symbol_and_offset_bits_from_distance_table(distance=distance)

            literals_and_length_symbols.append(length_info['symbol'])
            distance_symbols.append(distance_info['symbol'])

            encoded.append([
                length_info['symbol'],
                length_info['offset_bits'],
                distance_info['symbol'],
                distance_info['offset_bits']
            ])

            basic_encoded.append([distance, length])

            # if verbose:  print(f'{i}\t[{distance}:{length}]:\t bytestring[i]: {bytestring[i]}, \t\t{"".join(history)}')
            if verbose:  print(f'{i}\t[{distance}:{length}]:\t byte: {bytestring[i]}')

            # print(f'{i}\t[length:{length} distance:{distance}:]')
            # print(f"{i}\t[{length_info['symbol']}, {length_info['offset_bits']}, {distance_info['symbol']}, {distance_info['offset_bits']}]")


        else:

            literals_and_length_symbols.append(bytestring[i])

            encoded.append([bytestring[i]])

            basic_encoded.append([bytestring[i]])

            # print(f'{i}:\t{bytestring[i]}')

        if not do_the_back_referenc:
            length = 1


        # if the history size is smaller that the inpu stream:
        # for j in range(length):
        #     if (i + j) < len(bytestring):
        #         history.append(bytestring[i + j])
        #     if len(history) == conf['history_size'] + 1:
        #         print("history cap reached")
        #         history.pop(0)

        # assuming history size is larger than the input byte stream:
        history = [x for x in bytestring[:i + length]]



        i = i + length

    # print(f'ratio before haffman: {len(lzss_bitstream)/(8 * len(bytestring))}')
    return [literals_and_length_symbols, distance_symbols, encoded, basic_encoded]
