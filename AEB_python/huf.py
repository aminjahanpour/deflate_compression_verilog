import numpy as np
from collections import OrderedDict
import bitstring
import copy
import bitstring
import numpy as np


def get_code_lengths(codes, cap):
    """
    code_lengths is a vector of length of the huffman code assigned to each symbol
    here we also find the run of zero that possibly exist at the end of the code_length vector

    """

    code_lengths = OrderedDict()

    # freq_dict = get_symbols_frequency_dict(data)


    for i in range(cap):
        i_bitstring = bitstring.BitArray(f'uint9={i}').bin
        if (i_bitstring in codes.keys()):
            code_lengths[i_bitstring] = len(codes[i_bitstring])
        else:
            code_lengths[i_bitstring] = 0

    code_lengths = list(code_lengths.values())

    for i in reversed(range(cap)):
        if (code_lengths[i] != 0):
            tail_zero_len = cap - i - 1
            break

    # print(code_lengths)
    # print('zero_tail:', tail_zero_len)


    return code_lengths, tail_zero_len




def apply_encoding_order_to_code_length_table(cl_cl_table):



    ordered_code_lengths = []

    ordered_code_lengths.append(cl_cl_table[16]) # 0
    ordered_code_lengths.append(cl_cl_table[17]) # 1
    ordered_code_lengths.append(cl_cl_table[18]) # 2
    ordered_code_lengths.append(cl_cl_table[0])  # 3
    ordered_code_lengths.append(cl_cl_table[8])  # 4
    ordered_code_lengths.append(cl_cl_table[7])  # 5
    ordered_code_lengths.append(cl_cl_table[9])  # 6
    ordered_code_lengths.append(cl_cl_table[6])  # 7
    ordered_code_lengths.append(cl_cl_table[10]) # 8
    ordered_code_lengths.append(cl_cl_table[5])  # 9
    ordered_code_lengths.append(cl_cl_table[11]) # 10
    ordered_code_lengths.append(cl_cl_table[4])  # 11
    ordered_code_lengths.append(cl_cl_table[12]) # 12
    ordered_code_lengths.append(cl_cl_table[3])  # 13
    ordered_code_lengths.append(cl_cl_table[13]) # 14
    ordered_code_lengths.append(cl_cl_table[2])  # 15
    ordered_code_lengths.append(cl_cl_table[14]) # 16
    ordered_code_lengths.append(cl_cl_table[1])  # 17
    ordered_code_lengths.append(cl_cl_table[15]) # 18



    for i in reversed(range(19)):
        if (ordered_code_lengths[i] != 0):
            tail_zero_len = 19 - i - 1
            break

    return ordered_code_lengths[:len(ordered_code_lengths)-tail_zero_len], tail_zero_len

def codes_size_in_bytes(codes):
    a = len(codes.keys()) * 9 / 8
    b = max([len(x) for x in codes.values()]) * len(codes.values()) / 8

    return b


def get_symbols_frequency_dict(data):
    symbols_frequency_dict = OrderedDict()
    for element in data:
        if symbols_frequency_dict.get(element) == None:
            symbols_frequency_dict[element] = 1
        else:
            symbols_frequency_dict[element] += 1
    return symbols_frequency_dict



def build_tree(freq_list):
    # [int(x[0],2) for x in freq_list]
    a= [[int(x[0], 2), x[1]] for x in freq_list]
    a.sort(key=lambda x: x[0])
    a.sort(key=lambda x: x[1])
    freq_list = [[bitstring.BitArray(f"uint9={x[0]}").bin, x[1], False] for x in a]

    nodes = []

    while len([x for x in freq_list if x[2] == False]) > 1:

        freq_list.sort(key=lambda x: x[1])

        freq_list = [x for x in freq_list if x[1] >= 1]




        # find a left (prefering a symbol to a node)
        found_a_left = False
        candidate_left = None
        wanted_freq_already_identified = False

        for el_idx, el in enumerate(freq_list):

            if el[2] == False:

                if not wanted_freq_already_identified:
                    candidate_left = el
                    wanted_freq = el[1]
                    wanted_freq_already_identified = True

                if (el[1] == wanted_freq) and (len(el[0])) == 9:
                    # this is not a node. go with it.
                    found_a_left = True
                    el[2] = True
                    left = el
                    break


        if not found_a_left:
            candidate_left[2] = True
            left = candidate_left








        # find a right (prefering a symbol to a node)
        found_a_right = False
        candidate_right = None
        wanted_freq_already_identified = False

        for el_idx, el in enumerate(freq_list):

            if el[2] == False:

                if not wanted_freq_already_identified:
                    candidate_right = el
                    wanted_freq = el[1]
                    wanted_freq_already_identified = True

                if (el[1] == wanted_freq) and (len(el[0])) == 9:
                    # this is not a node. go with it.
                    found_a_right = True
                    el[2] = True
                    right = el
                    break


        if not found_a_right:
            candidate_right[2] = True
            right = candidate_right






        # # find a left (regardless)
        # for el in freq_list:
        #     if el[2] == False:
        #         el[2] = True
        #         left = el
        #         break
        #
        # # find a right (regardless)
        # for el in freq_list:
        #     if el[2] == False:
        #         el[2] = True
        #         right = el
        #         break







        node_name = drop_256(left[0]) + '100000000' + drop_256(right[0])

        assert len(node_name) % 9 == 0

        freq_list.append([node_name, left[1] + right[1], False])

        nodes.append(node_name)

        # print(int(left[0], 2), int(right[0], 2))
    # int(left[0], 2), int(right[0], 2)
    # node lengths: [int(len(x)/9 -1) for x in nodes]

    return nodes



def drop_256(bitstring):

    left_name_chunks = [bitstring[i:i + 9] for i in range(0, len(bitstring), 9)]
    left_name_rebuilt = ''

    for left_name_chunk in left_name_chunks:
        if left_name_chunk != '100000000':
            left_name_rebuilt = left_name_rebuilt + left_name_chunk
        # else:
        #     print("dropped 256")


    return left_name_rebuilt


def assign_binaries(symbols, nodes):
    ret = {}
    for el in symbols:
        ret[el] = ''

    for node in nodes[::-1]:
        left, right = split_node(node)


        for el in [left[i:i + 9] for i in range(0, len(left), 9)]:
            ret[el] = ret[el] + '0'

        for el in [right[i:i + 9] for i in range(0, len(right), 9)]:
            ret[el] = ret[el] + '1'

    return ret


def split_node(node):

    node_chunks = [node[i:i + 9] for i in range(0, len(node), 9)]
    for idx, chunk in enumerate(node_chunks):
        if chunk == '100000000':
            node_left_side = node[: idx * 9]
            node_right_side = node[(idx+1) * 9:]

            assert len(node) == 9 + len(node_left_side) + len(node_right_side)

            return [node_left_side, node_right_side]

    assert False, "was not able to split the node"




def decode_next(encoded, codes):
    """
    this function gives you the next symbol and the number of bits used to decode it
    """

    min_code_len = min([len(x) for x in codes.values()])
    max_code_len = max([len(x) for x in codes.values()])

    for search_len in range(min_code_len, max_code_len + 1):
        for symbol, code in codes.items():

            if encoded[:search_len] == code:
                return symbol, len(code)

    assert False, 'can not find a match in the keys. was not able to decode'


def decode_to_bytestream(encoded, codes):
    ret = bytearray()
    while len(encoded) > 0:
        decoded_bitstream, used_bits = decode_next(encoded, codes)

        # assert decoded_bitstream[0] == '0'
        # decoded_bitstream   = decoded_bitstream[1:]
        # decoded_byte        = bitstring.BitArray(f'0b{decoded_bitstream}').int
        decoded_byte        = int(decoded_bitstream, 2)


        # print(f'decoding {decoded_bitstream}')
        # print(f'byte: {decoded_byte}')


        ret.append(decoded_byte)
        encoded = encoded[used_bits:]



    return ret



def decode_to_bitstream(encoded, codes):
    ret = ''
    while len(encoded) > 0:
        decoded_bitstream, used_bits = decode_next(encoded, codes)

        ret = ret + decoded_bitstream

        encoded = encoded[used_bits:]

    return ret



def get_basic_codes_for_given_data(data_9bits_set):

    if len(data_9bits_set) == 1:
        return {f'{data_9bits_set[0]}':'0'}


    freq_dict = get_symbols_frequency_dict(data_9bits_set)

    aa = [[bitstring.BitArray(f"0b{x[0]}").uint, x[1]] for x in freq_dict.items()]
    aa.sort(key=lambda x: x[0])
    # aa.sort(key=lambda x: x[1])
    # [print(x[0], x[1]) for x in aa]
    assert sum(list(freq_dict.values())) == len(data_9bits_set)

    dd = get_basic_codes_for_given_freq_dict(freq_dict)
    dd_val = sorted([[int(x[0],2),x[1]] for x in dd.items()], key=lambda x:x[0])
    return get_basic_codes_for_given_freq_dict(freq_dict)



def get_basic_codes_for_given_freq_dict(freq_dict):

    freq_list = [[x, y, False] for x, y in zip(freq_dict.keys(), freq_dict.values()) if y > 0]


    #the nodes's nodes are 9 bits long because they need to store the spacer byte which is coded as 256
    nodes = build_tree(freq_list)

    for el in nodes:
        assert len(el) - 9 == len(drop_256(el))


    # print(f'nodes: {nodes}')


    # after producing the codes, we no longer need to
    codes = assign_binaries([x[0] for x in freq_list], nodes)

    readable_codes=[[int(x, 2), len(y),y] for x, y in codes.items()]
    assert sum([1/pow(2,x[1]) for x in readable_codes]) == 1.0
    # print(f'codes: {codes}')

    # for data in data_9bits_set:
    #     assert data in list(codes.keys())


    return codes



def get_codes_from_cl_table(cl_table):

    cl_table_arg_sort = np.argsort(cl_table)


    nodes_freq = get_freqs_for_code_lengths(copy.deepcopy(cl_table))

    rec_freq_dict = OrderedDict()

    gg = len(cl_table_arg_sort) * [0]

    for idx, node_freq in enumerate(nodes_freq):
        rec_freq_dict[bitstring.BitArray(f"uint9={cl_table_arg_sort[idx]}").bin] = node_freq

        gg[cl_table_arg_sort[idx]] = node_freq


    # [print(x) for x in gg if x > 0]

    rec_codes = get_basic_codes_for_given_freq_dict(rec_freq_dict)

    return rec_codes


def get_canonical_codes_for_given_data(data, convert_to_9bits, cl_table_cap):
    """
    get basic frequency table
    get basic codes for the basic frequency table

    generate code lengths table for the codes
    sort the code lengths table
    get the cl_vs and cl_nodes for the sorted code lengths
    get the binary codes for cl_vs and cl_nodes




    """


    if (convert_to_9bits):
        data_9bits_set = to_9bit_set(data)

        if len(data_9bits_set) == 1:
            return {f'{data_9bits_set[0]}': '0'}

    else:
        data_9bits_set = data



    basic_codes = get_basic_codes_for_given_data(data_9bits_set)

    cl_table, tail_zeros = get_code_lengths(basic_codes, cap=cl_table_cap)


    rec_codes = get_codes_from_cl_table(cl_table)

    assert sorted([len(x) for x in list(rec_codes.values())]) == sorted([len(x) for x in list(basic_codes.values())])


    return [rec_codes, cl_table, tail_zeros]





def get_encoded_for_given_codes(data, codes):
    ret = ''
    for el in data:
        ret = ret + codes['0'+bitstring.BitArray(f'uint8={el}').bin]

    return ret



def pick_the_last_v_with_an_available_side(vs):

    for idx, el in enumerate(reversed(vs)):
        if el[0] == 0:
            # print(f"F5: found the last_v_with_an_available_side at {idx} with free left, vs_count_F3 - counter_F5 - 1: {len(vs) - idx - 1}");
            return len(vs) - idx - 1, 0, el[2]
        if el[1] == 0:
            return len(vs) - idx - 1, 1, el[2]

    assert False, 'no v found'


def get_freqs_for_code_lengths(code_lengths):

    code_lengths.sort()

    max_depth = max(code_lengths)



    """
    a v is formatted per below:
    [
    index of child v on the left side (0 if side is free),      9 bits
    index of child v on the right side  (0 if side is free),    9 bits
    node depth,                                                 4 bits
    ]
    
    

    """


    vs = [[0, 0, 1]]

    nodes_freqs = []


    vs_val_for_taken_by_symbol = 299

    for counter_F3, cl in enumerate(code_lengths):

        # print(f"\nF3: counter_F3:            {counter_F3}, cl_F: {cl}")
        if cl == 0:
            nodes_freqs.append(0)
            continue

        # pick the last v with an available side
        root_v_idx, root_free_side, root_v_depth = pick_the_last_v_with_an_available_side(vs)

        assert root_v_depth <= max_depth
        """
        do I need a new v?

        only if assigning the node to the root v not
        provide enough depth
        """

        if cl == root_v_depth:
            vs[root_v_idx][root_free_side] = vs_val_for_taken_by_symbol

            node_freq = 2 ** (max_depth - root_v_depth)
            nodes_freqs.append(node_freq)


        else:
            node_was_placed = False

            # establish a series of roots until you get deep enough to place `cl`
            for counter_F6, i in enumerate(range(cl - root_v_depth)):

                """
                create a new v
                assign it to the empty side of the root v
                make the new v root
                we agree to place the node on the left side of the new v
                """
                new_v_idx = len(vs)
                vs[root_v_idx][root_free_side] = new_v_idx

                # print(f"F6: counter_F6:{counter_F6}    cl_F:{cl},          root_v_depth_F:{root_v_depth},  (cl_F - root_v_depth_F - 1): {cl - root_v_depth - 1}")
                #
                # if (counter_F6 == cl - root_v_depth - 1):
                #     print("-----------------------------------------------------------------------counter_F6 == cl_F - root_v_idx_F - 1")



                if i == cl - root_v_depth - 1:
                    new_v = [vs_val_for_taken_by_symbol, 0, root_v_depth + 1]
                    node_was_placed = True

                else:
                    new_v = [0, 0, root_v_depth + 1]

                vs.append(new_v)



                root_v_idx = new_v_idx
                root_v_depth = root_v_depth + 1
                root_free_side = 0

                assert root_v_depth <= max_depth

            if not node_was_placed:
                vs[-1][0] = vs_val_for_taken_by_symbol


            node_freq = 2 ** (max_depth - root_v_depth)
            nodes_freqs.append(node_freq)





        # print(f"cl={cl}")
        # for idx,v in enumerate(vs):
        #     print(f"{idx}, ({v[0]}, {v[1]}),       depth:  {v[2]}")




    return nodes_freqs


def to_9bit_set(literals):
    ret = []
    for l in literals:
        ret.append(bitstring.BitArray(f'uint9={l}').bin)

    return ret


def req_freq_to_basic_codes(rec_frecs):
    ll_9bit_set = to_9bit_set(list(range(len(rec_frecs))))
    freq_dict = get_symbols_frequency_dict(ll_9bit_set)
    dd = get_basic_codes_for_given_freq_dict(freq_dict)



if __name__ == '__main__':
    # data = "AABCBAD"
    # data = "    channel_bitstreams_per_channel_y = serialize_quantized_values_per_channel(stacked_quantized_y, dtc_depth_y, dc_bits, ac_bits)"


    cl= [3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6]


    rec_frecs = get_freqs_for_code_lengths(sorted(cl))


    req_freq_to_basic_codes(rec_frecs)

    # cl_vs, cl_nodes = get_codes_for_code_lengths([1,2,3,3])
    # cl_vs, cl_nodes = get_codes_for_code_lengths([4,4,3,2,2,2])
    # cl_vs, cl_nodes = get_codes_for_code_lengths([2,2,2,3,4,4])



    # raw_bytes_count = 2000
    # data = bytearray(open('./car.bmp', 'rb').read())[:raw_bytes_count]
    data = bytearray(open('./lz_raw_data.txt', 'rb').read())

    codes = {
        '000100000': '0000',
        '000100001': '11110',
        '000100010': '0001',
        '000100011': '0110',
        '000100100': '11111',
        '000100101': '110010',
        '000100110': '110011',
        '000101010': '110000',
        '000111011': '110001',
        '000111101': '110110',
        '001000000': '110111',
        '001000001': '101',
        '001000011': '110100',
        '001000100': '110101',
        '001001011': '001010',
        '001001100': '0111',
        '001010000': '001011',
        '001010011': '0100',
        '001010100': '001000',
        '001011000': '001001',
        '001011110': '001110',
        '001011111': '0101',
        '001100001': '001111',
        '001101001': '001100',
        '001101110': '001101',
        '001101111': '11100',
        '001110010': '11101',
        '001110111': '10010',
        '100000001': '10011',
        '100000010': '10000',
        '100000100': '10001',
    }

    # codes, cl_table, tail_zeros = get_canonical_codes_for_given_data(data, convert_to_9bits=True, cl_table_cap= 256)


    encoded = get_encoded_for_given_codes(data, codes)




    # print(f'encoded: {encoded}')
    print(f'comp ratio: {len(encoded)/(len(data)*8)}')

    decoded = decode_to_bytestream(encoded, codes)

    assert data == decoded

    print("ALL GOOD")
