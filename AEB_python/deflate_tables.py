# import g_toolkit
import bitstring

max_lenght = 257

block_one_ll_table = [
    #base length, symbol, offset bits
    [3, 257, 0],
    [4, 258, 0],
    [5, 259, 0],
    [6, 260, 0],
    [7, 261, 0],
    [8, 262, 0],
    [9, 263, 0],
    [10, 264, 0],
    [11, 265, 1],
    [13, 266, 1],
    [15, 267, 1],
    [17, 268, 1],
    [19, 269, 2],
    [23, 270, 2],
    [27, 271, 2],
    [31, 272, 2],
    [35, 273, 3],
    [43, 274, 3],
    [51, 275, 3],
    [59, 276, 3],
    [67, 277, 4],
    [83, 278, 4],
    [99, 279, 4],
    [115, 280, 4],
    [131, 281, 5],
    [163, 282, 5],
    [195, 283, 5],
    [227, 284, 5],
    [258, 285, 5]

]

block_one_distance_table = [

    # base dis     symbol   offset_bits
    [1			,    0	,	 0],
    [2			,    1	,	 0],
    [3			,    2	,	 0],
    [4			,    3	,	 0],
    [5			,    4	,	 1],
    [7			,    5	,	 1],
    [9			,    6	,	 2],
    [13			,    7	,	 2],
    [17			,    8	,	 3],
    [25			,    9	,	 3],
    [33			,    10	,	 4],
    [49			,    11	,	 4],
    [65			,    12	,	 5],
    [97			,    13	,	 5],
    [129		,    14	,	 6],
    [193		,    15	,	 6],
    [257		,    16	,	 7],
    [385		,    17	,	 7],
    [513		,    18	,	 8],
    [769		,    19	,	 8],
    [1025		,	20	,	 9],
    [1537		,	21	,	 9],
    [2049		,	22	,	10],
    [3073		,	23	,	10],
    [4097		,	24	,	11],
    [6145		,	25	,	11],
    [8193		,	26	,	12],
    [12289		,	27	,	12],
    [16385		,	28	,	13],
    [24577		,	29	,	13]
]


def get_length_and_offset_from_symbol(symbol):

    assert 257 <= symbol <= 285, "wrong range for symbol"
    for el in block_one_ll_table:
        if symbol == el[1]:
            verilog_string = bitstring.BitArray(f"uint9={el[0]}").bin
            verilog_string += bitstring.BitArray(f"uint3={el[2]}").bin

            return {
                'offset_bits_count': el[2],
                'base_length': el[0],
                'verilog_string': verilog_string
            }


def get_distance_and_offset_from_symbol(symbol):

    assert 0 <= symbol <= 29, "wrong range for symbol"
    for el in block_one_distance_table:
        if symbol == el[1]:
            verilog_string = bitstring.BitArray(f"uint15={el[0]}").bin
            verilog_string += bitstring.BitArray(f"uint4={el[2]}").bin

            return {
                'offset_bits_count': el[2],
                'base_distance': el[0],
                'verilog_string': verilog_string

            }


def get_symbol_and_offset_bits_from_LL_table(length):
    assert length>= 3, "length has be greater than 3"
    assert length<= max_lenght, "length has be smaller than 257"

    for idx in range(1, len(block_one_ll_table)):
        if (length < block_one_ll_table[idx][0]):
            base_length = block_one_ll_table[idx - 1][0]
            symbol      = block_one_ll_table[idx - 1][1]
            offset_bits_count = block_one_ll_table[idx - 1][2]

            symbol_bits = bitstring.BitArray(f"uint9={symbol}").bin


            offset_value    = length - base_length
            if (offset_bits_count) > 0:
                # offset_bits     = g_toolkit.toBinaryStringofLenght(offset_value, offset_bits_count)
                offset_bits     = bitstring.BitArray(f"uint{offset_bits_count}={offset_value}").bin
            else:
                offset_bits = ''

            break


    full_bitstream_for_verilog = symbol_bits + bitstring.BitArray(f"uint3={offset_bits_count}").bin
    if offset_bits == '':
        full_bitstream_for_verilog += '00000'
    else:
        full_bitstream_for_verilog += bitstring.BitArray(f"uint5={offset_value}").bin




    return {
        'symbol_bits'       :symbol_bits,
        'full_bitstream_for_verilog'       :full_bitstream_for_verilog,
        'offset_bits'       :offset_bits,
        'symbol'            :symbol,
        'base_length'       :base_length,
        'offset_bits_count' :offset_bits_count
    }


def get_symbol_and_offset_bits_from_distance_table(distance):
    for idx in range(1, len(block_one_distance_table)):
        if (distance < block_one_distance_table[idx][0]):
            base_distance       = block_one_distance_table[idx - 1][0]
            symbol              = block_one_distance_table[idx - 1][1]
            offset_bits_count   = block_one_distance_table[idx - 1][2]

            # symbol_bits     = g_toolkit.toBinaryStringofLenght(symbol, 5)
            symbol_bits = bitstring.BitArray(f"uint5={symbol}").bin

            offset_value    = distance - base_distance
            if (offset_bits_count) > 0:
                # offset_bits     = g_toolkit.toBinaryStringofLenght(offset_value, offset_bits_count)
                offset_bits     = bitstring.BitArray(f"uint{offset_bits_count}={offset_value}").bin

            else:
                offset_bits = ''
            break


    full_bitstream_for_verilog = symbol_bits + bitstring.BitArray(f"uint4={offset_bits_count}").bin
    if offset_bits == '':
        full_bitstream_for_verilog += '0000000000000'
    else:
        full_bitstream_for_verilog += bitstring.BitArray(f"uint13={offset_value}").bin



    return {
        'symbol_bits'       :symbol_bits,
        'full_bitstream_for_verilog': full_bitstream_for_verilog,
        'offset_bits'       :offset_bits,
        'symbol'            :symbol,
        'base_distance'     :base_distance,
        'offset_bits_count' :offset_bits_count
    }
