import shutil
import build_modules

build_modules.build_modules()


# for decoder
# shutil.copyfile(
#     f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\header_bitstream.txt',
#     f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\decoder\\input.txt')



# for cl decode
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



#for compiler

#
# shutil.copyfile(
#     'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\fully_coded_cl_pre_bitstream_ll.txt',
#     f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\input_cl_ll_pre_bitstream.txt')
#
# shutil.copyfile(
#     'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\fully_coded_cl_pre_bitstream_distance.txt',
#     f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\input_cl_distance_pre_bitstream.txt')
#
# shutil.copyfile(
#     'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\cl_cl_bitstream_ll.txt',
#     f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\input_cl_cl_ll_pre_bitstream.txt')
#
# shutil.copyfile(
#     'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\cl_cl_bitstream_distance.txt',
#     f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\input_cl_cl_distance_pre_bitstream.txt')
#
# shutil.copyfile(
#     'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\lzss_output.txt',
#     f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\input_lzss_output.txt')
#
# shutil.copyfile(
#     'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\canonical_codes_ll.txt',
#     f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\input_ll_codes.txt')
#
# shutil.copyfile(
#     'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\canonical_codes_distance.txt',
#     f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\input_distance_codes.txt')
#
# shutil.copyfile(
#     'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\compiler_config.txt',
#     f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\compiler\\config.txt')
#




# for decoder


# shutil.copyfile(
#     f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\header_bitstream.txt',
#     f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\decoder\\input.txt')
#
# shutil.copyfile(
#     f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\cl_decode_last_read_state.txt",
#     f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\decoder\\config.txt', )
#
# shutil.copyfile(
#     f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\canonical_codes_ll.txt",
#     f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\decoder\\input_ll_codes.txt', )
#
# shutil.copyfile(
#     f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\canonical_codes_distance.txt",
#     f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\decoder\\input_distance_codes.txt', )

