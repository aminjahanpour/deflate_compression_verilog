import numpy as np
import g_toolkit

def lz77_encode(bytestring, conf, working_with_bytearray):


    lzss_bitstream = ''

    encoded = []
    history = []


    i = 0


    while i < len(bytestring) :

        distance = 0
        length = 0



        """
        anything in 
        bytestring[i: i + future_size]
        
        is found in 
        bytestring[i - history_size: i]
        
        ?
        """

        found_something = False
        cat_counter = 0

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
                    history_start_search_idx_list = list(range(i - search_len, max(0, i - conf['history_size']) - 1, -1))


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
                            a CAT scanner can look through all the future
                            to activate a CAT scanner the found match must have been immmidiatly place before the current time
                            in other words, we activate a CAT scanner only if we find a match right behind us
                            """
                            if (history_start_search_idx == i - search_len and search_len > 1):
                                # print(f"CAT possibility bytestring[i]:{bytestring[i]}   CAT posibility")

                                cat_counter = 0
                                cat_count = 0
                                while cat_counter * search_len <= conf['future_size']:
                                    # cat candidate is from the future
                                    cat_candidate = bytestring[i + cat_counter*search_len : i + (cat_counter+1)*search_len]



                                    if(cat_candidate == search_term):
                                        # print(f"CAT confirmed:      cat_counter:{cat_counter}    bytestring[i]: {bytestring[i]}        cat_candidate:{cat_candidate}")
                                        cat_count = cat_count + 1
                                    else:
                                        break

                                    cat_counter = cat_counter + 1


                                # print(f" found {cat_count} CAT cases of {search_term}")

                                if (cat_count > 1):
                                    print("CATTING")
                                    length = cat_count * search_len
                                    



                            break

                    if found_something:
                        break






        if found_something:
            current = bytestring[i: i + length+1]
        else:
            current = [bytestring[i]]


        # print(f'{i}:\t[{distance}:{length}, {current[-1]}]\t\thistory:  {"".join(history)} \t\t\t\tcurrent:  {"".join(current)}')
        print(f'{i}:\t[{distance}:{length}, {current[-1]}]')

        encoded.append([distance, length, current[-1]])

        # building the lzss bitstream


        """
        if we did not find anything, lzss only writes the literal preceded by the zero bit flag
        """

        if (length > 1):
            lzss_bitstream = lzss_bitstream + '1' + g_toolkit.toBinaryStringofLenght(distance, 2 ** conf['distance_bits']) + g_toolkit.toBinaryStringofLenght(length,2**conf['length_bits'])

        lzss_bitstream = lzss_bitstream + '0'
        if working_with_bytearray:
            lzss_bitstream = lzss_bitstream + g_toolkit.toBinaryStringofLenght(current[-1], 8)
        else:
            lzss_bitstream = lzss_bitstream + g_toolkit.toBinaryStringofLenght(ord(current[-1]), 8)


        # lzss_bitstream = lzss_bitstream + g_toolkit.toBinaryStringofLenght()


        for j in range(length+1):
            if (i+j) < len(bytestring):
                history.append(bytestring[i+j])
            if len(history) == conf['history_size'] + 1:
                history.pop(0)

        i = i + 1 + length



    return encoded


def lz77_decode(encoded, working_with_bytearray):

    if working_with_bytearray:
        decoded_bytearray = bytearray()

    else:
        decoded_string = ''




    for el in encoded:
        distance, length, literal = el

        if distance == 0:
            if working_with_bytearray:
                decoded_bytearray.append(literal)
            else:
                decoded_string = decoded_string + literal



        elif (distance >= length): # this is not a CAT
            if(distance == 1):
                if working_with_bytearray:
                    decoded_bytearray.append(decoded_bytearray[-1])
                    decoded_bytearray.append(literal)
                else:
                    decoded_string = decoded_string +  decoded_string[-1] + literal

            else:
                if working_with_bytearray:
                    temp_bytearray = bytearray()
                    for cc in range(-distance, -distance + length):
                        temp_bytearray.append(decoded_bytearray[cc])

                    decoded_bytearray = decoded_bytearray + temp_bytearray
                    decoded_bytearray.append(literal)

                else:
                    temp_decoded_string = ''
                    for cc in range(-distance, -distance + length):
                        temp_decoded_string = temp_decoded_string + decoded_string[cc]
                    decoded_string = decoded_string +  temp_decoded_string + literal




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
                decoded_bytearray.append(literal)
            else:
                decoded_string = decoded_string + literal


        # if decode_to_bytearray:
        #     print(el, raw_bytearray)
        # else:
        #     print(el, decoded)







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






if __name__ == '__main__':

    conf = {
        'future_size': 9,
        'history_size': 9,
        'min_search_len': 1,


    }

    conf['distance_bits'] = get_needed_bitcounts(conf['history_size'])

    conf['length_bits'] = 5


    assert conf['history_size'] <= 2 ** conf['distance_bits']
    assert conf['length_bits'] > 0



    # raw = bytearray(open('./lz_raw_data.txt', 'rb').read())
    # raw = bytearray(open('./gol.bmp', 'rb').read())
    # raw = bytearray(open('./cat.bmp', 'rb').read())
    # raw = bytearray(open('./datasheet.ods', 'rb').read())

    raw = "A_LASS;_A_LAD;_A_SALAD;_ALASKA"
    # raw = "A_LASS;_A_LAD;_A_SALAD;_ALASKA_!@#$%^&*CATCATCATXAPLA"
    # raw = "1234567890ABBBBBBBBBBBBbBBBCD"

    working_with_bytearray = False
    # working_with_bytearray = True


    # for i in range(len(raw)):
    #     print(i, raw[i])
    #
    # print("___________")

    encoded = lz77_encode(raw, conf=conf, working_with_bytearray=working_with_bytearray)
    decoded = lz77_decode(encoded, working_with_bytearray=working_with_bytearray)

    print(decoded)

    for i in range(len(raw)-1):
        print(f'i:{i}: raw:{raw[i]}, decoded:{decoded[i]}, {raw[i]==decoded[i]}')
        # print(f'i:{i}: raw:{raw[i]}')
    #
    sdf = sorted([(x,y) for x,y in zip(raw, decoded)])
    assert all([x==y for x,y in zip(raw, decoded)])


    if all([x==y for x,y in zip(raw, decoded)]):
        print("all good")


