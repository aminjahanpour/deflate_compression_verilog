import huf
import bitstring
import deflate_cl_encoding



def decode_encoded_cl(ll_cl_fully_encoded, ll_cl_codes):

    decoded = ''

    while len(ll_cl_fully_encoded) > 0:

        decoded_bitstream, used_bits = huf.decode_next(ll_cl_fully_encoded, ll_cl_codes)

        ll_cl_fully_encoded = ll_cl_fully_encoded[used_bits:]

        decoded += decoded_bitstream[-5:]


        symbol = int(decoded_bitstream, 2)


        if symbol == 16:

            reps = ll_cl_fully_encoded[:2]

            ll_cl_fully_encoded = ll_cl_fully_encoded[2:]

            decoded = decoded + reps



        elif symbol == 17:

            reps = ll_cl_fully_encoded[:3]

            ll_cl_fully_encoded = ll_cl_fully_encoded[3:]

            decoded = decoded + reps


        elif symbol == 18:

            reps = ll_cl_fully_encoded[:7]

            ll_cl_fully_encoded = ll_cl_fully_encoded[7:]

            decoded = decoded + reps




    return decoded


def interpert(bitstream):

    total_used_bits = 0

    chunk = bitstream[total_used_bits:total_used_bits+8]
    total_used_bits += 8

    hlit_cl = int(chunk, 2)


    remaining_ll_cl_cl = 19 - hlit_cl

    ll_cl_cl_table_unordered = []

    for i in range(remaining_ll_cl_cl):
        chunk = bitstream[total_used_bits:total_used_bits + 3]
        total_used_bits += 3

        ll_cl_cl_table_unordered.append(int(chunk, 2))

    for i in range(hlit_cl):
        ll_cl_cl_table_unordered.append(0)

    ll_cl_cl_table = []
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[3]) #0
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[17]) #1
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[15]) #2
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[13]) #3
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[11]) #4
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[9]) #5
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[7]) #6
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[5]) #7
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[4]) #8
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[6]) #9
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[8]) #10
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[10]) #11
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[12]) #12
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[14]) #13
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[16]) #14
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[18]) #15
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[0]) #16
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[1]) #17
    ll_cl_cl_table.append(ll_cl_cl_table_unordered[2]) #18



    chunk = bitstream[total_used_bits:total_used_bits+8]
    total_used_bits += 8

    hdist_cl = int(chunk, 2)

    remaining_dd_cl_cl = 19 - hdist_cl

    dd_cl_cl_table_unordered = []

    for i in range(remaining_dd_cl_cl):
        chunk = bitstream[total_used_bits:total_used_bits + 3]
        total_used_bits += 3

        dd_cl_cl_table_unordered.append(int(chunk, 2))


    for i in range(hdist_cl):
        dd_cl_cl_table_unordered.append(0)




    dd_cl_cl_table = []
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[3]) #0
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[17]) #1
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[15]) #2
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[13]) #3
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[11]) #4
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[9]) #5
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[7]) #6
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[5]) #7
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[4]) #8
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[6]) #9
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[8]) #10
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[10]) #11
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[12]) #12
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[14]) #13
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[16]) #14
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[18]) #15
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[0]) #16
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[1]) #17
    dd_cl_cl_table.append(dd_cl_cl_table_unordered[2]) #18



    chunk = bitstream[total_used_bits:total_used_bits + 8]
    total_used_bits += 8
    hlit = int(chunk, 2)

    chunk = bitstream[total_used_bits:total_used_bits + 8]
    total_used_bits += 8
    hdist = int(chunk, 2)




    chunk = bitstream[total_used_bits:total_used_bits+10]
    total_used_bits += 10

    ll_cl_fully_encoded_bitlength = int(chunk, 2)


    ll_cl_fully_encoded = bitstream[total_used_bits:total_used_bits+ll_cl_fully_encoded_bitlength]
    total_used_bits += ll_cl_fully_encoded_bitlength





    chunk = bitstream[total_used_bits:total_used_bits + 10]
    total_used_bits += 10

    dd_cl_fully_encoded_bitlength = int(chunk, 2)

    dd_cl_fully_encoded = bitstream[total_used_bits:total_used_bits + dd_cl_fully_encoded_bitlength]
    total_used_bits += dd_cl_fully_encoded_bitlength





    ll_cl_codes = huf.get_codes_from_cl_table(ll_cl_cl_table)
    dd_cl_codes = huf.get_codes_from_cl_table(dd_cl_cl_table)




    """
    now I can use the ll_cl_codes to decode ll_cl_fully_encoded
    """
    # readable_ll_cl_codes={}
    # for el in ll_cl_codes.keys():
    #     readable_ll_cl_codes[int(el, 2)] = ll_cl_codes[el]

    ll_cl_decoded_bitstream = decode_encoded_cl(ll_cl_fully_encoded, ll_cl_codes)
    ll_cl_decoded = deflate_cl_encoding.cl_decoding(ll_cl_decoded_bitstream) + hlit * [0]

    dd_cl_decoded_bitstream = decode_encoded_cl(dd_cl_fully_encoded, dd_cl_codes)
    dd_cl_decoded = deflate_cl_encoding.cl_decoding(dd_cl_decoded_bitstream) + hdist * [0]



    ll_codes = huf.get_codes_from_cl_table(ll_cl_decoded)
    dd_codes = huf.get_codes_from_cl_table(dd_cl_decoded)




    return [ll_cl_cl_table,
            dd_cl_cl_table,
            ll_cl_fully_encoded,
            dd_cl_fully_encoded,
            ll_cl_codes,
            dd_cl_codes,
            ll_cl_decoded,
            dd_cl_decoded,
            ll_codes,
            dd_codes
            ]



