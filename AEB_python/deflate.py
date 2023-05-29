import json
import zlib

import g_toolkit
import deflate_optimizer as do
import deflate_encoder
import deflate_decoder
import requests
import numpy as np

import deflate_build_bitstream
import bitstring


def to_8bits_verilog_ram(raw):
    return [bitstring.BitArray(f"uint8={x}").bin for x in raw]

def compress_byte_array(raw):

    conf = {

        'min_search_len': 2,  # this needs to stay small because we want to find cats
        'history_size': 32_768,
        'future_size': 10,  # originally this was 258
        'mlwbr': 3
    }

    literals_and_length_symbols, distance_symbols, encoded, basic_encoded = deflate_encoder.lzss_encode(
        raw,
        conf=conf,
        verbose=False)

    if len(distance_symbols) > 1 :

        basic_decoded = deflate_decoder.lzss_direct_decode(basic_encoded, True)
        assert all([x == y for x, y in zip(raw, basic_decoded)]), "basic decoding does not match"

        encoded_bitstream, header_bitstream = deflate_build_bitstream.build_encoded_bitstream(
            literals_and_length_symbols, distance_symbols, encoded)

        compressed_package_total_size = (len(encoded_bitstream) + len(header_bitstream)) / 8
        # compressed_package_total_size = len(encoded_bitstream)/8
        print(
            f'SINGLE BLOCK encoded size: {compressed_package_total_size} bytes---------------->ratio: {compressed_package_total_size / (len(raw))}')

        file_name = './out/deflate_out.gzip'

        g_toolkit.dump_bitstring_to_file_as_bytes(encoded_bitstream, file_name)

        return encoded_bitstream, header_bitstream

    else:
        print('no ll-dist pair found')
        return None

def decompress_byte_array(encoded_bitstream, header_bitstream):

    # bit_stream_from_compressed_file = g_toolkit.load_bitstream_from_byte_files(file_name)
    decoded = deflate_decoder.single_block_decode(encoded_bitstream, header_bitstream)

    # print(decoded)

    # for i in range(raw_bytes_count):
    #     print(f'i:{i}: raw:{raw[i]}, decoded:{decoded[i]}, {raw[i]==decoded[i]}')

    sdf = [(x == y) for x, y in zip(raw, decoded)]
    # assert all([x==y for x,y in zip(raw, decoded)])
    #
    #
    if all([x == y for x, y in zip(raw, decoded)]):
        print("all good")
    else:
        print(sdf)



if __name__ == '__main__':

    # because block 1 ignores lengths smaller than 3

    starting_byte = 0
    raw_bytes_count = 400
    optimization = False

    raw = bytearray(open('./lz_raw_data.txt', 'rb').read())
    # raw = bytearray(open('./gol.bmp', 'rb').read())
    # raw = bytearray(open('./cat.bmp', 'rb').read())
    # raw = bytearray(open('./datasheet.ods', 'rb').read())
    # raw = bytearray(open('./out/my_jpg.txt', 'rb').read())

    raw = raw[starting_byte: starting_byte + raw_bytes_count]

    # raw = "A_LASS;_A_LAD;_A_SALAD;_ALASKA"
    #                  |
    # raw = "A_LASS;_A_LAD;_A_SALAD;_ALASKA_!@#$%^&*CATCATCATXAPLA"
    # raw = "A_LASS;_A_LAD;_A_SALAD;_ALASKA_!@#$%^&*CATCATCATXAPLAion"
    #

    # for i in range(len(raw)):
    #     print(i, raw[i])

    # raw_8bit_verilog_ram = to_8bits_verilog_ram(raw)

    zlib_compression_ratio = len(zlib.compress(raw)) / len(raw)

    print(f"org size:{len(raw)} bytes. zlib output is {len(zlib.compress(raw))} Bytes, zlib_compression_ratio: {zlib_compression_ratio}  ___________")

    encoded_bitstream, header_bitstream = compress_byte_array(raw)


    decompress_byte_array(encoded_bitstream, header_bitstream)