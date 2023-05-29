import pandas as pd
import zlib
import numpy as np
import bitstring


width, height = 320, 240
# width, height = 112, 80
block_counts_in_height = int(height / 8)
block_count_in_weight = int(width / 8)



# sa_colors = pd.read_csv('../aeb_receiver/bent-cool-warm-table-byte-1024.csv')

def inflate(data):
    decompress = zlib.decompressobj(
            -zlib.MAX_WBITS  # see above
    )
    inflated = decompress.decompress(data)
    inflated += decompress.flush()
    return inflated

    # return zlib.decompress(data)


def deflate(data, compresslevel=9):
    compress = zlib.compressobj(
            compresslevel,        # level: 0-9
            zlib.DEFLATED,        # method: must be DEFLATED
            -zlib.MAX_WBITS,      # window size in bits:
                                  #   -15..-8: negate, suppress header
                                  #   8..15: normal
                                  #   16..30: subtract 16, gzip header
            zlib.DEF_MEM_LEVEL,   # mem level: 1..8/9
            0                     # strategy:
                                  #   0 = Z_DEFAULT_STRATEGY
                                  #   1 = Z_FILTERED
                                  #   2 = Z_HUFFMAN_ONLY
                                  #   3 = Z_RLE
                                  #   4 = Z_FIXED
    )
    deflated = compress.compress(data)
    deflated += compress.flush()
    return deflated

    # return zlib.compress(data)



def twos_comp(val, bits):
    """compute the 2's complement of int value val"""
    if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
        val = val - (1 << bits)        # compute negative value
    return val                         # return positive value as is


def toBinaryStringofLenght(v, sum_bpu):
    initial_result = "{0:b}".format(v)
    if (len(initial_result) < sum_bpu):
        initial_result = '0' * (sum_bpu - len(initial_result)) + initial_result

    assert( len(initial_result) == sum_bpu), f'v:{v}, sum_bpu: {sum_bpu}'
    # print(initial_result)
    return initial_result

def infer_sum_bpu(base_points_count):

    i = 1
    while 1:
        if base_points_count <= 2 ** i:
            break
        i+=1

    return i


def define_bytes_pack_size(sum_bpu, bytes_count):
    """
    we need an integer that
        - is a multiple of sum_bpu
        - is a factor of bytes_count
    """
    i = sum_bpu * 8
    while 1:

        a = ((i*8) % sum_bpu == 0)

        b = (bytes_count % i == 0)

        if a and b:
            break
        i+=1

        if (i * sum_bpu == bytes_count):
            raise

    return i

def get_aeb(basepoints, range_counts, v_normal):
    for i in range(range_counts):
        if (basepoints[i] <= v_normal) and (v_normal < basepoints[i + 1]):
            break

    return i





def bitstring_to_bytes(s):
    b = bytearray()

    chunks = [s[i:i + 8] for i in range(0, len(s), 8)]
    for chunk in chunks:
        b.append(int(chunk, 2) & 0xff)

    return b


def dump_bitstring_to_file_as_bytes(full_raw_aeb, file_name):

    byte_stream = bitstring_to_bytes(full_raw_aeb)

    with open(f'./{file_name}', 'wb') as my_file:

        my_file.write(byte_stream)
    return byte_stream


def dump_bytestream_to_file(bytestream, file_name):

    with open(f'./{file_name}', 'wb') as my_file:

        my_file.write(bytestream)



def load_bitstream_from_byte_files(file_name):
    with open(f'./{file_name}', 'rb') as my_file:
        read_from_file= my_file.read()

    bit_stream_from_compressed_file = ''
    for b in read_from_file:
        bit_stream_from_compressed_file = bit_stream_from_compressed_file + toBinaryStringofLenght(b, 8)


    return bit_stream_from_compressed_file




def get_needed_bitcounts(max_value):
    a = np.log2(max_value)
    if a != int(a):
        a = int(a) + 1

    a = int(a)

    return a
