import numpy as np
import g_toolkit

def lzss_encode(bytestring, conf, working_with_bytearray, verbose=False):


    lzss_bitstream = ''

    encoded = []
    history = []


    i = 0


    while i < len(bytestring) :

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

        if(len(history) > 0):


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


                    deepest_index_in_the_history = max(0, i - conf['history_size'])

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
                            # print(f'i: {i}, search_len:{search_len}, history_start_search_idx_list:{history_start_search_idx_list}, search_term:{search_term}')

                            found_something = True
                            distance = i - history_start_search_idx
                            length = search_len



                            """
                            a CAT scanner can look through all the future (of course respecting the length limitaion)
                            to activate a CAT scanner the found match must have been immediately placed before the current time
                            in other words, we activate a CAT scanner only if we find a match right behind us
                            
                            we want to keep min_search_len relatively small because we do not want to miss the CATs
                            if we have found cats, we need to reset the length before counting the cats.
                            """
                            if (history_start_search_idx == i - search_len and search_len > 1):
                                # print(f"CAT possibility bytestring[i]:{bytestring[i]}   CAT posibility")

                                cat_counter = 0
                                cats_count = 0
                                while cat_counter * search_len <= conf['future_size']:
                                    # cat candidate is from the future
                                    cat_candidate = bytestring[i + cat_counter*search_len : i + (cat_counter+1)*search_len]



                                    if(cat_candidate == search_term):
                                        if verbose: print(f"CAT confirmed:      cat_counter:{cat_counter}    bytestring[i]: {bytestring[i]}        cat_candidate:{cat_candidate}")

                                        if ((cats_count + 1) * search_len) <= (2 ** conf['length_bits'] - 1):

                                            cats_count = cats_count + 1
                                            length = cats_count * search_len
                                        else:
                                            if verbose: print("can't add more cats because of length_bits")
                                            break

                                    else:
                                        if verbose: print("collected all the cats")

                                        break

                                    cat_counter = cat_counter + 1


                                # print(f" found {cats_count} CAT cases of {search_term}")

                                if (cats_count > 1):
                                    if verbose: print("CATs collected")
                                    cats_found = 1





                            break

                    if found_something:
                        break




        """
        we need to cancel the discovery if the length exceeds the limit
        """
        if (length > (2 ** conf['length_bits'] - 1)):
            if verbose: print("we need to cancel the discovery if the length exceeds the limit")
            length= 0
            found_something = 0
            cats_found = 0


        # building the lzss bitstream


        """
        if we did not find anything, lzss only writes the literal preceded by the zero bit flag
        if we found a dog then we need to check if it is worth back-referencing to it
        """

        do_the_back_referenc = (cats_found or ((length >= conf['mlwbr']) and found_something))

        if (do_the_back_referenc):
            if verbose:  print(f'{i}\t[{distance}:{length}]:\t bytestring[i]: {bytestring[i]}, \t\t{"".join(history)}')
            encoded.append([distance, length])

            lzss_bitstream = lzss_bitstream + '1'
            lzss_bitstream = lzss_bitstream + g_toolkit.toBinaryStringofLenght(distance, conf['distance_bits'])
            lzss_bitstream = lzss_bitstream + g_toolkit.toBinaryStringofLenght(length, conf['length_bits'])

        else:
            if verbose:  print(f'{i}:\t{bytestring[i]}, \t\t{"".join(history)}')
            # print(f'{i}:\t{bytestring[i]}\t\t{("".join(history))}')
            encoded.append([bytestring[i]])

            lzss_bitstream = lzss_bitstream + '0'

            if working_with_bytearray:
                lzss_bitstream = lzss_bitstream + g_toolkit.toBinaryStringofLenght(bytestring[i], conf['literal_length'])
            else:
                lzss_bitstream = lzss_bitstream + g_toolkit.toBinaryStringofLenght(ord(bytestring[i]), conf['literal_length'])


        if not do_the_back_referenc:
            length = 1


        for j in range(length):
            if (i+j) < len(bytestring):
                history.append(bytestring[i+j])
            if len(history) == conf['history_size'] + 1:
                history.pop(0)

        # if cats_found:
        #     length = length - 1

        i = i + length

    print(f'ratio: {len(lzss_bitstream)/(8 * len(bytestring))}')
    return encoded


def lzss_decode(encoded, working_with_bytearray):

    if working_with_bytearray:
        decoded_bytearray = bytearray()

    else:
        decoded_string = ''





    for el in encoded:

        this_is_a_literal = len(el) == 1

        if (this_is_a_literal):
            if working_with_bytearray:
                decoded_bytearray.append(el[0])
            else:
                decoded_string = decoded_string + el[0]

        else:
            distance, length = el

            if (distance >= length): # this is a dog
                if(distance == 1):
                    if working_with_bytearray:
                        decoded_bytearray.append(decoded_bytearray[-1])

                    else:
                        decoded_string = decoded_string +  decoded_string[-1]

                else:
                    if working_with_bytearray:
                        temp_bytearray = bytearray()
                        for cc in range(-distance, -distance + length):
                            temp_bytearray.append(decoded_bytearray[cc])

                        decoded_bytearray = decoded_bytearray + temp_bytearray


                    else:
                        temp_decoded_string = ''
                        for cc in range(-distance, -distance + length):
                            temp_decoded_string = temp_decoded_string + decoded_string[cc]
                        decoded_string = decoded_string +  temp_decoded_string




            else: #CAT

                assert length % distance == 0
                i = 0

                while i < length:

                    if working_with_bytearray:
                        for cc in decoded_bytearray[-distance:]:
                            decoded_bytearray.append(cc)

                    else:
                        decoded_string = decoded_string + decoded_string[-distance:]

                    i = i + distance









    if working_with_bytearray:
        return decoded_bytearray
    else:
        return decoded_string


def get_needed_bitcounts(max_value):
    a = np.log2(max_value)
    if a != int(a):
        a = int(a) + 1

    a = int(a)

    return a


def find_min_length_worth_of_back_referencing(conf):
    for l in range(100):
        if (
                (l * conf['literal_length']) / (1 + conf['distance_bits']+conf['length_bits'])
                >=
                (conf['literal_length'] / (conf['literal_length'] + 1))
        ):
            return l



if __name__ == '__main__':

    conf = {
        'distance_bits':    5,
        'length_bits':      3,
        'literal_length':   8,

        'min_search_len':   2, # this needs to stay small because we want to find cats
    }

    conf['history_size'] = 2 ** conf['distance_bits'] - 1
    conf['future_size'] = 1000

    conf['mlwbr'] = find_min_length_worth_of_back_referencing(conf)


    assert conf['history_size'] <= 2 ** conf['distance_bits']
    assert conf['length_bits'] > 0



    # raw = bytearray(open('./lz_raw_data.txt', 'rb').read())
    # raw = bytearray(open('./gol.bmp', 'rb').read())
    # raw = bytearray(open('./cat.bmp', 'rb').read())
    # raw = bytearray(open('./datasheet.ods', 'rb').read())

    raw = "A_LASS;_A_LAD;_A_SALAD;_ALASKA"
    #                  |
    # raw = "A_LASS;_A_LAD;_A_SALAD;_ALASKA_!@#$%^&*CATCATCATXAPLA"
    # raw = "90ABBBBBBBBBBbBBBCD"
    #
    working_with_bytearray = False
    # working_with_bytearray = True


    # for i in range(len(raw)):
    #     print(i, raw[i])

    print("___________")

    encoded = lzss_encode(raw, conf=conf, working_with_bytearray=working_with_bytearray, verbose=True)
    decoded = lzss_decode(encoded, working_with_bytearray=working_with_bytearray)

    # print(decoded)

    # for i in range(len(raw)):
    #     print(f'i:{i}: raw:{raw[i]}, decoded:{decoded[i]}, {raw[i]==decoded[i]}')

    #
    # sdf = sorted([(x,y) for x,y in zip(raw, decoded)])
    assert all([x==y for x,y in zip(raw, decoded)])


    if all([x==y for x,y in zip(raw, decoded)]):
        print("all good")


