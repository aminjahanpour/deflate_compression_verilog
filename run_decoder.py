import shutil
import os
import glob

from modules import modules
from os import listdir

from run_encoder import run_module
# import subprocess

from build_modules import build_modules

build_modules()


spliter = 4 * "\n"


"""
{
'hlit_cl': 5,
'hdist_cl': 3,

'hlit': 25,
'hdist': 21,


'recode_cl_total_bits_to_write_ll': 179,
'recode_cl_total_bits_to_write_distance': 9


'cl_codings_pre_bitstream_words_count_ll': 63,
'count_of_pre_bitstream_for_reordered_cl_cl_values_ll': 14,
'cl_codings_pre_bitstream_words_count_distance': 9,
'count_of_pre_bitstream_for_reordered_cl_cl_values_distance': 16,
         }
         
         


"""

def run_decoder():

    os.system('cls')

    merge_chapters()


    """
    Interperter

    input:
        - encoded data

    output:
        - cl_cl_ll to feed to clv
        - cl_cl_distance to feed to clv

    general output file lines:
        - total_header_bits_L
        - last_entry_bits_count_L
        - hlit_cl
        - hdist_cl
        - hlit
        - hdist
        - recode_cl_total_bits_to_write_ll
        - recode_cl_total_bits_to_write_distance
    """

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\header_bitstream.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\interperter\\input.txt')


    run_module('interperter')

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\interperter\\dumps\\L15_output_file_interperter_cl_cl_ll_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\cl_cl_ll.txt')


    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\interperter\\dumps\\L16_output_file_interperter_cl_cl_distance_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\cl_cl_distance.txt')



    shutil.copyfile(
        f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\interperter\\dumps\\L_output_file_general.txt",
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\interperter_config.txt')


    # with open("C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\interperter\\dumps\\L_output_file_general.txt") as decoder_config_file:
    #     lines = decoder_config_file.read().split('\n')[:-1]

    # total_header_bits_L = lines[0]
    # last_entry_bits_count_L = lines[1]
    # hlit_cl = lines[2]
    # hdist_cl = lines[3]
    # hlit = lines[4]
    # hdist = lines[5]
    # recode_cl_total_bits_to_write_ll = lines[6]
    # recode_cl_total_bits_to_write_distance = lines[7]


    get_codes_for_decoded_cl_cl_table('ll')
    get_codes_for_decoded_cl_cl_table('distance')


    assert_good_recovery_of_cl_codes('ll')
    assert_good_recovery_of_cl_codes('distance')





    """
    CL_DECODE
    """

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\header_bitstream.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\cl_decode\\input.txt')

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\canonical_codes_cl_ll.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\cl_decode\\codes_cl_ll.txt')

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\canonical_codes_cl_distance.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\cl_decode\\codes_cl_distance.txt')

    shutil.copyfile(
        f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\interperter_config.txt",
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\cl_decode\\config.txt')

    run_module('cl_decode')

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\cl_decode\\dumps\\M4_output_file_cl_decode_cl_ll_mem.txt',
        f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\cl_ll.txt")

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\cl_decode\\dumps\\M5_output_file_cl_decode_cl_distance_mem.txt',
        f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\cl_distance.txt")

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\cl_decode\\dumps\\M_output_file_general.txt',
        f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\cl_decode_last_read_state.txt")

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\cl_decode\\dumps\\M6_output_file_cl_decode_extracted_cl_symbols_mem.txt',
        f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\symbols_cl.txt")





    print('assert_good_recovery_of_symbols')
    assert_good_recovery_of_symbols()




    print('assert_good_recovery_of_cl_values ll')
    assert_good_recovery_of_cl_values('ll')



    print('assert_good_recovery_of_cl_values distance')
    assert_good_recovery_of_cl_values('distance')



    get_codes_for_decoded_cl_table('ll')
    get_codes_for_decoded_cl_table('distance')




    assert_good_recovery_of_codes('ll')
    assert_good_recovery_of_codes('distance')




    print('\n---------------------\ncodes are all good\n------------------\n')




    """
    DECODER
    
    """

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\header_bitstream.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\decoder\\input.txt')

    shutil.copyfile(
        f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\cl_decode_last_read_state.txt",
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\decoder\\config.txt',)


    shutil.copyfile(
        f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\canonical_codes_ll.txt",
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\decoder\\input_ll_codes.txt',)


    shutil.copyfile(
        f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\canonical_codes_distance.txt",
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\decoder\\input_distance_codes.txt',)


    run_module('decoder')

    shutil.copyfile(
        f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\decoder\\dumps\\O10_output_file_decoded_bits_mem.txt",
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\decoded.txt',)

    assert_good_decoding()





def assert_good_recovery_of_cl_values(subject):
    with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\canonical_codes_ll.txt") as encoder_codes:
        encoder_lines = encoder_codes.read().split('\n')[:-1]

    with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\cl_ll.txt") as encoder_codes:
        decoder_lines = encoder_codes.read().split('\n')[:-1]

    for i in range(len(encoder_lines)):
        if encoder_lines[i][9 : 21]!=decoder_lines[i][9 : 21]:
            print(f'i={i}, cl from encoder={encoder_lines[i][9 : 21]}  but  cl from decoder={decoder_lines[i][9 : 21]}')

    assert all([x[9 : 21]==y[9 : 21] for x, y in zip(encoder_lines, decoder_lines)])





def assert_good_recovery_of_symbols():
    with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\symbols_cl_ll.txt") as encoder_codes:
        symbols_ll_lines = encoder_codes.read().split('\n')[:-1]

    with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\symbols_cl_distance.txt") as encoder_codes:
        symbols_distance_lines = encoder_codes.read().split('\n')[:-1]

    with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\symbols_cl.txt") as encoder_codes:
        decoder_lines = encoder_codes.read().split('\n')[:-1]



    assert len(symbols_ll_lines) + len(symbols_distance_lines) == len(decoder_lines)

    for x in symbols_distance_lines:
        symbols_ll_lines.append(x)

    assert  symbols_ll_lines == decoder_lines
    sdf=3
    # for i in range(len(encoder_lines)):
    #     if encoder_lines[i][9: 21] != decoder_lines[i][9: 21]:
    #         print(f'i={i}, cl from encoder={encoder_lines[i][9: 21]}  but  cl from decoder={decoder_lines[i][9: 21]}')
    #
    # assert all([x[9: 21] == y[9: 21] for x, y in zip(encoder_lines, decoder_lines)])


def get_codes_for_decoded_cl_cl_table(subject):
    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\cl_cl_{subject}.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\clv\\input.txt')


    run_module('clv')


    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\clv\\dumps\\F4_output_file_clrec_freq_list_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\clv_generated_req_list_{subject}.txt')

    # canonical huffman

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\clv_generated_req_list_{subject}.txt',
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\huffman\\input.txt')

    # run huffman
    run_module('huffman')

    # store a copy in the decoder_workstation
    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\huffman\\dumps\\E14_output_file_huffman_codes_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\canonical_codes_cl_{subject}.txt')

    dfg=5

def get_codes_for_decoded_cl_table(subject):
    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\cl_{subject}.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\clv\\input.txt')

    run_module('clv')


    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\clv\\dumps\\F4_output_file_clrec_freq_list_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\clv_generated_req_list_{subject}.txt')

    # canonical huffman

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\clv_generated_req_list_{subject}.txt',
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\huffman\\input.txt')

    # run huffman
    run_module('huffman')

    # store a copy in the decoder_workstation
    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\huffman\\dumps\\E14_output_file_huffman_codes_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\canonical_codes_{subject}.txt')




def assert_good_recovery_of_codes(subject):
    with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\canonical_codes_{subject}.txt") as encoder_codes:
        encoder_lines = encoder_codes.read().split('\n')[:-1]

    with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\canonical_codes_{subject}.txt") as encoder_codes:
        decoder_lines = encoder_codes.read().split('\n')[:-1]

    assert encoder_lines == decoder_lines



def assert_good_recovery_of_cl_codes(subject):
    with open(
            f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\canonical_codes_cl_{subject}.txt") as encoder_codes:
        encoder_lines = encoder_codes.read().split('\n')[:-1]

    with open(
            f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\canonical_codes_cl_{subject}.txt") as encoder_codes:
        decoder_lines = encoder_codes.read().split('\n')[:-1]

    assert encoder_lines == decoder_lines



def assert_good_decoding():
    my_file = open('C:\\Users\\jahan\\Desktop\\verilog\\deflate\\AEB_python\\lz_raw_data.txt', 'r')
    data = my_file.read()

    input_data = []
    for data_idx, el in enumerate(data):
        input_data.append(ord(el))

    my_file = open('C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\decoded.txt','r')
    decoded_data = [int(x, 2) for x in my_file.read().split('\n')[:-1]]

    assert input_data == decoded_data
    print("\n\nALL GOOD\n\n")

def merge_chapters():

    for module in modules.keys():

        with open(f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module}\\{module}.v', "w") as g:

            for chapter in [f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module}\\chapters\\{x}' for x in listdir(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module}\\chapters\\")]:
                with open(chapter, "r") as f:
                    v1 = f.readlines()

                    for line in v1:
                        g.write(line)

                    g.write('\n')




def generate_canonical_huffman_code(subject):
    pass

    """
    HUFFMAN ON SYMBOLS


    inputs:
        - freq_list file

    output:
        - huffman codes

    """

    # initial huffman

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\freq_list_{subject}.txt',
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\huffman\\input.txt')

    # run huffman
    run_module('huffman')

    # store a copy in the encoder_workstation
    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\huffman\\dumps\\E14_output_file_huffman_codes_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\initial_codes_{subject}.txt')

    print(spliter)

    """
    CLV

    input:
        - huffman codes

    output:
        - freq_list file

    """

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\initial_codes_{subject}.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\clv\\input.txt')

    # run clv
    run_module('clv')

    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\clv\\dumps\\F4_output_file_clrec_freq_list_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\clv_generated_req_list_{subject}.txt')

    # canonical huffman

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\clv_generated_req_list_{subject}.txt',
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\huffman\\input.txt')

    # run huffman
    run_module('huffman')

    # store a copy in the encoder_workstation
    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\huffman\\dumps\\E14_output_file_huffman_codes_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\canonical_codes_{subject}.txt')

    print(spliter)


def generate_freq_list(subject, symbol_counts):
    """
    input:
    symbol_{subject}

    output:
    freq_list_{subject}

    """

    """
    FREQ_LIST

    config:
        - symbols count

    input:
        - symbols

    output:
        - freq_list file

    no general

    """

    # feed `freq_list` with subject symbols from `lzss`
    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\symbols_{subject}.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\freq_list\\input.txt')

    # feed `freq_list` config with subject symbols count
    with open("C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\freq_list\\config.txt", 'w') as f:
        f.write(symbol_counts)

    # run freq_list
    run_module('freq_list')

    # copy freq_list for subject into the encoder_workstation
    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\freq_list\\dumps\\C2_output_file_freq_list_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\freq_list_{subject}.txt')


if __name__ == '__main__':
    run_decoder()
