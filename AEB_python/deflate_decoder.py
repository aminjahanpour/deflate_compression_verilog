import huf
import deflate_tables as dt
import deflate_interpert_header


def multi_block_decode(input_bitstream,
           block_lengths,
           ll_table_symbols_freq_dict,
           distance_table_symbols_freq_dict,
            verbose = False

           ):
    """
    rebuild the tree based on the provided frequency tables
    """

    last_byte_of_block_indexes = []
    for el in block_lengths:
        if len(last_byte_of_block_indexes) == 0:
            last_byte_of_block_indexes = [el]
        else:
            last_byte_of_block_indexes.append(last_byte_of_block_indexes[-1] + el)

    have_we_produced_huffman_tree_for_the_new_block = 0;

    block_counter = 0


    decoded_bytearray = bytearray()


    bytes_decoded_count = 0

    # obviously the first thing is always a literal

    next_one_is_an_ll = 1

    total_used_bits = 0

    while True:

        if not have_we_produced_huffman_tree_for_the_new_block:

            if block_counter == len(block_lengths):
                print(f"___________finished decoding:{bytes_decoded_count} bytes")

                return decoded_bytearray

            if(verbose): print(f"___________starting new block while bytes_decoded_count:{bytes_decoded_count}")

            ll_table_huffman_tree, _       , _ = huf.encode_based_on_provided_frequency_dict(ll_table_symbols_freq_dict        [block_counter])
            distance_table_huffman_tree, _ , _ = huf.encode_based_on_provided_frequency_dict(distance_table_symbols_freq_dict  [block_counter])

            have_we_produced_huffman_tree_for_the_new_block = 1
            block_counter = block_counter + 1








        if (next_one_is_an_ll and have_we_produced_huffman_tree_for_the_new_block):

            decoded_ll_symbol, used_bits_count_ll = huf.decode_first_element_only(
                                                                                        input_bitstream[total_used_bits:],
                                                                                        ll_table_huffman_tree)

            # print(f"decoded_output: {decoded_ll_symbol}, used_bits_count: {used_bits_count_ll}")
            total_used_bits = total_used_bits + used_bits_count_ll




            if decoded_ll_symbol <= 255:
                # print("this is a literal")
                decoded_bytearray.append(decoded_ll_symbol)

                if(verbose): print(f"bytes_decoded_count: {bytes_decoded_count}, literal: {decoded_ll_symbol}")
                bytes_decoded_count += 1


                if (bytes_decoded_count == last_byte_of_block_indexes[block_counter - 1]):
                    have_we_produced_huffman_tree_for_the_new_block=0


            elif decoded_ll_symbol >= 257:
                # print("this is a length")
                length_info = dt.get_length_and_offset_from_symbol(decoded_ll_symbol)
                length = length_info['base_length']
                if (length_info['offset_bits_count'] > 0):
                    length = length + int(input_bitstream[total_used_bits: total_used_bits + length_info['offset_bits_count']], 2)
                    total_used_bits = total_used_bits + length_info['offset_bits_count']


                next_one_is_an_ll = 0


            else:
                assert False, "cant be here!"



        # reading a distance
        elif (next_one_is_an_ll==0 and have_we_produced_huffman_tree_for_the_new_block):
            decoded_distance_symbol, used_bits_count_distance = huf.decode_first_element_only(input_bitstream[total_used_bits:], distance_table_huffman_tree)
            # print(f"decoded_output: {decoded_distance_symbol}, used_bits_count: {used_bits_count_distance}")
            total_used_bits = total_used_bits + used_bits_count_distance


            distance_info = dt.get_distance_and_offset_from_symbol(decoded_distance_symbol)
            distance = distance_info['base_distance']
            if (distance_info['offset_bits_count'] > 0):
                distance = distance + int(input_bitstream[total_used_bits: total_used_bits + distance_info['offset_bits_count']], 2)
                total_used_bits = total_used_bits + distance_info['offset_bits_count']

            next_one_is_an_ll = 1

            # now we have the length and the distance


            if (distance >= length): # this is a dog
                if(distance == 1):
                    decoded_bytearray.append(decoded_bytearray[-1])


                else:
                    temp_bytearray = bytearray()
                    for cc in range(-distance, -distance + length):
                        temp_bytearray.append(decoded_bytearray[cc])

                    decoded_bytearray = decoded_bytearray + temp_bytearray

                if(verbose): print(f"decoding a dog for block_counter: {block_counter}  distance:{distance} , length:{length}")




            else: #CAT
                if(verbose): print(f"decoding a cat for block_counter: {block_counter}  distance:{distance} , length:{length}")

                assert length % distance == 0, f"CAT decoder complains: length {length} % distance {distance} != 0"

                i = 0

                while i < length:

                    for cc in decoded_bytearray[-distance:]:
                        decoded_bytearray.append(cc)

                    i = i + distance



            if(verbose): print(f"bytes_decoded_count: {bytes_decoded_count}")
            bytes_decoded_count += length

            if (bytes_decoded_count == last_byte_of_block_indexes[block_counter - 1]):
                have_we_produced_huffman_tree_for_the_new_block = 0




import  huf

def lzss_direct_decode(encoded, working_with_bytearray):

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



def single_block_decode(input_bitstream, header_bitstream):
    """
    rebuild the tree based on the provided frequency tables
    """

    ll_cl_cl_table_rec, dd_cl_cl_table_rec, ll_cl_fully_encoded_rec, dd_cl_fully_encoded_rec, ll_cl_codes_rec, dd_cl_codes_rec, ll_cl_decoded_rec, dd_cl_decoded_rec, ll_codes, dd_codes = deflate_interpert_header.interpert(header_bitstream)

    decoded_bytearray = bytearray()


    # obviously the first thing is always a literal

    next_one_is_an_ll = 1

    total_used_bits = 0

    while (total_used_bits) < len(input_bitstream):

        if next_one_is_an_ll:

            # decoded_ll_symbol, used_bits_count_ll = huffman.decode_first_element_only(input_bitstream[total_used_bits:], ll_table_huffman_tree)
            # total_used_bits = total_used_bits + used_bits_count_ll


            decoded_bitstream, used_bits = huf.decode_next(input_bitstream[total_used_bits:], ll_codes)
            total_used_bits = total_used_bits + used_bits
            decoded_ll_symbol = int(decoded_bitstream, 2)


            if decoded_ll_symbol <= 255:
                # this is a literal
                decoded_bytearray.append(decoded_ll_symbol)



            else:
                # this is a length
                length_info = dt.get_length_and_offset_from_symbol(decoded_ll_symbol)
                length = length_info['base_length']
                if (length_info['offset_bits_count'] > 0):
                    length = length + int(input_bitstream[total_used_bits: total_used_bits + length_info['offset_bits_count']], 2)
                    total_used_bits = total_used_bits + length_info['offset_bits_count']

                next_one_is_an_ll = 0

        else:
            # decoded_distance_symbol, used_bits_count_distance = huffman.decode_first_element_only(input_bitstream[total_used_bits:], distance_table_huffman_tree)
            # print(f"decoded_output: {decoded_distance_symbol}, used_bits_count: {used_bits_count_distance}")
            # total_used_bits = total_used_bits + used_bits_count_distance

            decoded_bitstream, used_bits = huf.decode_next(input_bitstream[total_used_bits:], dd_codes)
            total_used_bits = total_used_bits + used_bits
            decoded_distance_symbol = int(decoded_bitstream, 2)




            distance_info = dt.get_distance_and_offset_from_symbol(decoded_distance_symbol)
            distance = distance_info['base_distance']
            if (distance_info['offset_bits_count'] > 0):
                distance = distance + int(input_bitstream[total_used_bits: total_used_bits + distance_info['offset_bits_count']], 2)
                total_used_bits = total_used_bits + distance_info['offset_bits_count']

            next_one_is_an_ll = 1










            # now we have the length and the distance


            if (distance >= length): # this is a dog
                if(distance == 1):
                    decoded_bytearray.append(decoded_bytearray[-1])


                else:
                    temp_bytearray = bytearray()
                    for cc in range(-distance, -distance + length):
                        temp_bytearray.append(decoded_bytearray[cc])

                    decoded_bytearray = decoded_bytearray + temp_bytearray





            else: #CAT

                assert length % distance == 0
                i = 0

                while i < length:

                    for cc in decoded_bytearray[-distance:]:
                        decoded_bytearray.append(cc)

                    i = i + distance





    return decoded_bytearray