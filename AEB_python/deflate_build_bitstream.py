import huf
import bitstring
import deflate_encoder
import deflate_cl_encoding
import deflate_interpert_header

import numpy as np



def build_encoded_bitstream(literals_and_length_symbols, distance_symbols, encoded):

    """
    we need to merge 8-bit literals and 9-bit length symbols and get one tree for both of them
    in this case, the huffman encoder does not need to increase the data to 9-bits.
    bacause the data are already in 9 bits.
    also the data would not contain 256 which is used by huffman.
    """

    # get ll and dd codes
    ll_9bit_set = huf.to_9bit_set(literals_and_length_symbols)
    dd_9bit_set = huf.to_9bit_set(distance_symbols)

    ll_codes, ll_cl_table_full, hlit = huf.get_canonical_codes_for_given_data(ll_9bit_set, convert_to_9bits=False, cl_table_cap=286)
    dd_codes, dd_cl_table_full, hdist = huf.get_canonical_codes_for_given_data(dd_9bit_set, convert_to_9bits=False, cl_table_cap=30)


    # trimming the tail zeros before encoding
    ll_cl_table = ll_cl_table_full[:len(ll_cl_table_full)-hlit]
    dd_cl_table = dd_cl_table_full[:len(dd_cl_table_full)-hdist]


    # encode code length of ll and dd
    ll_cl_initialy_encoded, ll_cl_symbols = deflate_cl_encoding.cl_encoding(ll_cl_table)
    dd_cl_initialy_encoded, dd_cl_symbols = deflate_cl_encoding.cl_encoding(dd_cl_table)


    ll_cl_codes, ll_cl_cl_table_org, _ = huf.get_canonical_codes_for_given_data(ll_cl_symbols, convert_to_9bits=True, cl_table_cap=19)
    dd_cl_codes, dd_cl_cl_table_org, _ = huf.get_canonical_codes_for_given_data(dd_cl_symbols, convert_to_9bits=True, cl_table_cap=19)


    ll_cl_fully_encoded = deflate_cl_encoding.apply_huffman_codes_to_encoded_cl_bitstream(ll_cl_initialy_encoded, ll_cl_codes)
    dd_cl_fully_encoded = deflate_cl_encoding.apply_huffman_codes_to_encoded_cl_bitstream(dd_cl_initialy_encoded, dd_cl_codes)


    ll_cl_cl_table, hlit_cl = huf.apply_encoding_order_to_code_length_table(ll_cl_cl_table_org)
    dd_cl_cl_table, hdist_cl = huf.apply_encoding_order_to_code_length_table(dd_cl_cl_table_org)

    assert len(ll_cl_cl_table) + hlit_cl == len(dd_cl_cl_table) + hdist_cl == 19

    assert ll_cl_table == deflate_cl_encoding.cl_decoding(ll_cl_initialy_encoded)
    assert dd_cl_table == deflate_cl_encoding.cl_decoding(dd_cl_initialy_encoded)

    """
    8 bits for: hlit_cl
    3 bits per el for el in ll_cl_cl_table
    8 bits for: hdist_cl
    3 bits per el for el in dd_cl_cl_table

    8 bits for: hlit
    8 bits for: hdist

    10 bits for: bit length of ll_cl_fully_encoded
    var bits for: ll_cl_fully_encoded

    10 bits for:  bit length of dd_cl_fully_encoded
    var bits for: dd_cl_fully_encoded
    
    """

    header_bitstream = bitstring.BitArray(f"uint8={hlit_cl}").bin
    for el in ll_cl_cl_table:
        assert el <= 7, el
        header_bitstream = header_bitstream + bitstring.BitArray(f"uint3={el}").bin

    header_bitstream += bitstring.BitArray(f"uint8={hdist_cl}").bin
    for el in dd_cl_cl_table:
        assert el <= 7
        header_bitstream = header_bitstream + bitstring.BitArray(f"uint3={el}").bin

    assert len(header_bitstream) == 2*8 + 3 * (len(ll_cl_cl_table) + len(dd_cl_cl_table))


    header_bitstream = header_bitstream + bitstring.BitArray(f"uint8={hlit}").bin
    header_bitstream = header_bitstream + bitstring.BitArray(f"uint8={hdist}").bin


    header_bitstream += bitstring.BitArray(f"uint10={len(ll_cl_fully_encoded)}").bin
    header_bitstream += ll_cl_fully_encoded


    header_bitstream += bitstring.BitArray(f"uint10={len(dd_cl_fully_encoded)}").bin
    header_bitstream += dd_cl_fully_encoded






    ll_cl_cl_table_rec, dd_cl_cl_table_rec, ll_cl_fully_encoded_rec, dd_cl_fully_encoded_rec, ll_cl_codes_rec, dd_cl_codes_rec, ll_cl_decoded_rec, dd_cl_decoded_rec, ll_codes_rec, dd_codes_rec = deflate_interpert_header.interpert(header_bitstream)

    assert ll_cl_cl_table_rec == ll_cl_cl_table_org
    assert dd_cl_cl_table_rec == dd_cl_cl_table_org
    assert ll_cl_fully_encoded_rec == ll_cl_fully_encoded
    assert dd_cl_fully_encoded_rec == dd_cl_fully_encoded

    assert list(ll_cl_codes_rec.keys())== list(ll_cl_codes.keys())
    assert list(ll_cl_codes_rec.values())== list(ll_cl_codes.values())

    assert list(dd_cl_codes_rec.keys())== list(dd_cl_codes.keys())
    assert list(dd_cl_codes_rec.values())== list(dd_cl_codes.values())

    assert ll_cl_table_full == ll_cl_decoded_rec
    assert dd_cl_table_full == dd_cl_decoded_rec

    assert list(ll_codes_rec.keys())== list(ll_codes.keys())
    assert list(ll_codes_rec.values())== list(ll_codes.values())

    assert list(dd_codes_rec.keys())== list(dd_codes.keys())
    assert list(dd_codes_rec.values())== list(dd_codes.values())



    bitstream = ''

    for el in encoded:
        if len(el) == 1: # this is a literal
            bitstream = bitstream + ll_codes['0' + bitstring.BitArray(f'uint8={el[0]}').bin]
        else:
            length_symbol, length_offset_bits, distance_symbol, distance_offset_bits =   el
            bitstream = bitstream + ll_codes[bitstring.BitArray(f'uint9={length_symbol}').bin]
            bitstream = bitstream + length_offset_bits
            bitstream = bitstream + dd_codes[bitstring.BitArray(f'uint9={distance_symbol}').bin]
            bitstream = bitstream + distance_offset_bits

    return bitstream, header_bitstream








if __name__ == '__main__':
    with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\writer\\dumps\\H4_output_file_bit_stream_mem.txt", "r") as my_file:
        data = my_file.read().split('\n')[:-1]

    with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\writer\\dumps\\H_output_file_general.txt", "r") as my_file:
        las_word_bits_count = int(my_file.read().split('\n')[:-1][0], 2)

    header_bitstream = ''.join(data[:-1])

    assert len(header_bitstream) % 8 == 0

    header_bitstream += data[-1][:las_word_bits_count]





    ll_cl_cl_table_rec, dd_cl_cl_table_rec, ll_cl_fully_encoded_rec, dd_cl_fully_encoded_rec, ll_cl_codes_rec, dd_cl_codes_rec, ll_cl_decoded_rec, dd_cl_decoded_rec, ll_codes_rec, dd_codes_rec = deflate_interpert_header.interpert(
        header_bitstream)

    sdf = 4

