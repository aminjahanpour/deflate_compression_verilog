import shutil
import os
import glob
from subprocess import Popen


from modules import modules
from os import listdir

import bitstring

import subprocess

from build_modules import build_modules
import json

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

def merge_chapters():

    for module in modules.keys():

        with open(f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module}\\{module}.v', "w") as g:

            for chapter in [f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module}\\chapters\\{x}' for x in listdir(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module}\\chapters\\")]:
                with open(chapter, "r") as f:
                    v1 = f.readlines()

                    for line in v1:
                        g.write(line)

                    g.write('\n')


def run_module(module):
    os.chdir(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module}\\")
    # os.system('apio sim')
    # subprocess.run('apio sim', capture_output=False)
    run_return= os.popen('apio sim').read()

    lines = run_return.split('\n')
    for line in lines:
        if 'ERROR' in line:
            if '[ ERROR ] Took' not in line:
                print(line)

        if 'error' in line:
            print(line)


        if '!!!' in line:
            print(line)

    time_spent = lines[-11].split(' ')[-1]

    try:


        if int(time_spent) <= int(modules[module]['duration']):
            time_spent = int(time_spent)
            allowed_time = int(modules[module]['duration'])

            used_percentage = int(round(100 * time_spent / allowed_time,0))

            if used_percentage == 0:
                print(f'{module}: used_percentage was Zero. error.')
                exit()
            print(f"{module} used {used_percentage}% of its allowed time.")
    except:
        print(f'{module}: time violation error.')
        exit()



def run_encoder():

    os.system('cls')

    merge_chapters()



    """
    LZSS
    
    input:
        - input bytes
        
    output:
        - ll symbols
        - distance symbols
        - lzss output (not used)
        
    general output file lines:
        - ll symbols count
        - distance symbols count
        - lzss_outputs_count_D
    """
    # run lzss
    run_module('lzss')

    # extract the general outputs
    with open("C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\lzss\\dumps\\D_output_file_general.txt", 'r') as f:
        lines = f.read().split('\n')[:-1]
        ll_symbols_count = lines[0]
        distance_symbols_count = lines[1]
        lzss_outputs_count = lines[2]



    # save to encoder_workstation
    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\lzss\\dumps\\D6_output_file_ll_symbols_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\symbols_ll.txt')

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\lzss\\dumps\\D6_output_file_distance_symbols_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\symbols_distance.txt')

    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\lzss\\dumps\\D6_output_file_lzss_output_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\lzss_output.txt')



    generate_freq_list('ll', ll_symbols_count)
    generate_freq_list('distance', distance_symbols_count)



    registers = {'lzss_outputs_count': lzss_outputs_count}



    run_encoder_tasks_on_input_symbols('ll', registers)
    run_encoder_tasks_on_input_symbols('distance', registers)


    print(registers)




    """
    COMPILER
        * generates the full header bitstream

    config:
        - hlit_cl
        - hdist_cl
        - count_of_pre_bitstream_for_reordered_cl_cl_values_ll
        - count_of_pre_bitstream_for_reordered_cl_cl_values_distance
        - hlit
        - hdist
        - cl_codings_pre_bitstream_words_count_ll
        - cl_codings_pre_bitstream_words_count_distance
        - recode_cl_total_bits_to_write_ll
        - recode_cl_total_bits_to_write_distance


    input:

    output:

    general:
        - header_total_pre_bitstream_words_count
        - total_header_bits
    """


    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\fully_coded_cl_pre_bitstream_ll.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\input_cl_ll_pre_bitstream.txt')

    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\fully_coded_cl_pre_bitstream_distance.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\input_cl_distance_pre_bitstream.txt')

    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\cl_cl_bitstream_ll.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\input_cl_cl_ll_pre_bitstream.txt')

    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\cl_cl_bitstream_distance.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\input_cl_cl_distance_pre_bitstream.txt')




    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\canonical_codes_ll.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\input_ll_codes.txt')

    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\canonical_codes_distance.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\input_distance_codes.txt')

    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\lzss_output.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\input_lzss_output.txt')





    with open("C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\config.txt", 'w') as write_config_file:
        write_config_file.write(bitstring.BitArray(f"uint48={registers['hlit_cl']}").bin)
        write_config_file.write("\n")
        write_config_file.write(bitstring.BitArray(f"uint48={registers['hdist_cl']}").bin)
        write_config_file.write("\n")
        write_config_file.write(bitstring.BitArray(f"uint48={registers['count_of_pre_bitstream_for_reordered_cl_cl_values_ll']}").bin)
        write_config_file.write("\n")
        write_config_file.write(bitstring.BitArray(f"uint48={registers['count_of_pre_bitstream_for_reordered_cl_cl_values_distance']}").bin)
        write_config_file.write("\n")
        write_config_file.write(bitstring.BitArray(f"uint48={registers['hlit']}").bin)
        write_config_file.write("\n")
        write_config_file.write(bitstring.BitArray(f"uint48={registers['hdist']}").bin)
        write_config_file.write("\n")
        write_config_file.write(bitstring.BitArray(f"uint48={registers['cl_codings_pre_bitstream_words_count_ll']}").bin)
        write_config_file.write("\n")
        write_config_file.write(bitstring.BitArray(f"uint48={registers['cl_codings_pre_bitstream_words_count_distance']}").bin)

        write_config_file.write("\n")
        write_config_file.write(bitstring.BitArray(f"uint48={registers['recode_cl_total_bits_to_write_ll']}").bin)
        write_config_file.write("\n")
        write_config_file.write(bitstring.BitArray(f"uint48={registers['recode_cl_total_bits_to_write_distance']}").bin)
        write_config_file.write("\n")
        write_config_file.write(registers['lzss_outputs_count'])


    run_module('compiler')


    # extract the compiled pre-bitstream words count
    with open("C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\dumps\\K_output_file_general.txt", 'r') as f:
        lines = f.read().split('\n')[:-1]
        compiled_pre_bitstream_words_count = lines[0]
        total_header_bits = lines[1]



    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\dumps\\K7_output_file_header_pre_bitstream_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\compiled.txt')







    """
    WRITER 

    config:
        - count of pre bitstream of cl codings


    inputs:
        - pre bitstream of cl codings

    output:
        - pre bitstream (with huffman codes applied)


    general output file lines:
        - last_entry_bits_count
        - total_bits_written
    """


    # # feed `writer` with pre-bitstream values from `compiler`
    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\compiled.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\writer\\input.txt')

    with open("C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\writer\\config.txt", 'w') as write_config_file:
        write_config_file.write(compiled_pre_bitstream_words_count)
        write_config_file.write('\n')
        write_config_file.write(total_header_bits)

    # run writer
    run_module('writer')

    # get a copy of the bitstream
    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\writer\\dumps\\H4_output_file_bit_stream_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\header_bitstream.txt')

    with open("C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\writer\\dumps\\H_output_file_general.txt", 'r') as f:
        lines = f.read().split('\n')[:-1]
        last_entry_bits_count = int(lines[0], 2)
        total_bits_written = int(lines[1], 2)
        total_words_written = int(lines[2], 2)


    print(f"last_entry_bits_count: {last_entry_bits_count}, total_bits_written: {total_bits_written}")



    # with open("C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\decode\\config.txt", 'r') as f:
    #     f.write(total_words_written)
    registers['lzss_outputs_count'] = int(registers['lzss_outputs_count'], 2)
    with open("C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\registers.json", "w") as outfile:
        json.dump(registers, outfile)


def run_encoder_tasks_on_input_symbols(subject, registers):


    generate_canonical_huffman_code(subject)



    """
    CL CODING
    
    
    inputs:
        - input_huffman_codes_mem

    output file:
        pre_bitstream_mem
        symbols_mem

    general output file lines:
        - hlit
        - cl_codings_pre_bitstream_words_count
        - symbol counts

    
    """

    # feed cl coding with huffman codes
    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\canonical_codes_{subject}.txt',
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\clcoding\\input.txt')


    # run cl coding
    run_module('clcoding')


    # extract symbols count from lzss general output file and write it to huffman config file
    with open("C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\clcoding\\dumps\\G6_output_file_general.txt", 'r') as f:
        lines = f.read().split('\n')[:-1]
        hlit = lines[0]
        cl_codings_pre_bitstream_words_count = lines[1]
        symbols_count = lines[2]


    if subject == "ll":
        registers['hlit'] = int(hlit, 2)

    elif subject == 'distance':
        registers['hdist'] = int(hlit, 2) - 256


    registers[f'cl_codings_pre_bitstream_words_count_{subject}'] = int(cl_codings_pre_bitstream_words_count, 2)



    # get a copy of the symbols
    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\clcoding\\dumps\\G5_output_file_symbols_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\symbols_cl_{subject}.txt')

    # get a copy of the initially coded cl
    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\clcoding\\dumps\\G4_output_file_pre_bitstream.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\initially_coded_cl_{subject}.txt')


    generate_freq_list(f'cl_{subject}',symbols_count)


    print(spliter)







    """
    HUFFMAN ON CL SYMBOLS
    """

    generate_canonical_huffman_code(f'cl_{subject}')



    print(spliter)












    """
    RECODE CL CODES
        * generates two pre-bitstreams and a two-line general file
    
    
    inputs:
        - huffman codes for cl symbols
        - pre bitstream of cl codings
        - count of the above
        
    output:
        - pre bitstream (with huffman codes applied)    (Task 1)
        - count of the above                            (Task 1)
        
        - pre-bitstream for the reordered cl values     (Task 2)
        - hlit_cl                                       (Task 2)

        
    general output file lines (I_output_file_general):
        - hlit_cl
        - count of pre-bitstream for the reordered cl values
        - recode_total_bits_to_write
    """

    # feed `recode` with pre bitstream words from `cl coding`
    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\initially_coded_cl_{subject}.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\recode\\input.txt')


    # feed `recode` with huffman codes from `huffman`
    shutil.copyfile(
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\canonical_codes_cl_{subject}.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\recode\\codes.txt')


    # prodive `recode` with the count of input cl codings
    with open("C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\recode\\config.txt", 'w') as write_config_file:
        write_config_file.write(cl_codings_pre_bitstream_words_count)


    # run recode
    run_module('recode')


    with open("C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\recode\\dumps\\I_output_file_general.txt", 'r') as f:
        lines = f.read().split('\n')[:-1]
        hlit_cl = int(lines[0], 2)
        count_of_pre_bitstream_for_reordered_cl_cl_values = int(lines[1], 2)
        recode_cl_total_bits_to_write = int(lines[2], 2)

    assert hlit_cl + count_of_pre_bitstream_for_reordered_cl_cl_values == 19

    registers[f'{"hlit_cl" if subject == "ll" else "hdist_cl"}'] = hlit_cl

    registers[f'count_of_pre_bitstream_for_reordered_cl_cl_values_{subject}'] = count_of_pre_bitstream_for_reordered_cl_cl_values
    registers[f'recode_cl_total_bits_to_write_{subject}'] = recode_cl_total_bits_to_write


    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\recode\\dumps\\J1_output_file_recode_cl_cl_reordered_pre_bitstream_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\cl_cl_bitstream_{subject}.txt')


    shutil.copyfile(
        'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\recode\\dumps\\I4_output_file_recoded_cl_encoding_pre_bitstream_mem.txt',
        f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\fully_coded_cl_pre_bitstream_{subject}.txt')





    #         f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\input_cl_cl_{subject}_pre_bitstream.txt')




    print(f"did all for {subject}")





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
    run_encoder()
