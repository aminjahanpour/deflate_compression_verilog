import numpy as np
from PIL import Image
import t_mapper_decoder

# file_name = "../verilog/aeb/output_file_aeb_frame.txt"
# file_name = "../verilog/aeb/output_file_source_rgb_frame.txt"
# file_name = "../verilog/aeb/output_file_source_gray_frame.txt"

file_name = "../../verilog/aeb/um_dumps/output_file_decoded_rgb.txt"
# file_name = "../verilog/aeb/aeb_not_encoded_24.mem"
# file_name = "../verilog/aeb/frame_320_240_rgb_888.mem" # this is what python itself wrote!

# file_name ='C:\\Users\\jahan\\Downloads\\verilog-main\\aeb\\output_file_decoded_rgb.txt'
# file_name = "../verilog/aeb/output_file_decoded_rgb.txt"
#
# width = 320
# height = 240


from g_toolkit import *


color_system =0
display_mode=0

sum_bpu =24


gray_config = 0

hue_min = 180 / 360
hue_max = 255 / 360


mean_ = int(round(sum_bpu / 3, 0))
max_ = int(0.61 * sum_bpu)
mid_ = int(0.35 * sum_bpu)
min_ = sum_bpu - max_ - mid_

if (sum_bpu == 3):
    bpu_h = 1
    bpu_s = 1
    bpu_v = 1
elif (sum_bpu == 4):
    bpu_h = 2
    bpu_s = 1
    bpu_v = 1
elif (sum_bpu == 5):
    bpu_h = 3 
    bpu_s = 1   
    bpu_v = 1
elif (sum_bpu == 6):
    bpu_h = 4
    bpu_s = 1
    bpu_v = 1
elif (sum_bpu == 7):
    bpu_h = 4
    bpu_s = 2
    bpu_v = 1
elif (sum_bpu == 8):
    bpu_h = 5
    bpu_s = 2 
    bpu_v = 1
elif (sum_bpu == 9):
    bpu_h = 6
    bpu_s = 2
    bpu_v = 1
elif (sum_bpu == 10):
    bpu_h = 7
    bpu_s = 2
    bpu_v = 1
elif (sum_bpu == 11):
    bpu_h = 8
    bpu_s = 2
    bpu_v = 1
elif (sum_bpu == 12):
    bpu_h = 8
    bpu_s = 3
    bpu_v = 1
elif (sum_bpu == 13):
    bpu_h = 8
    bpu_s = 4
    bpu_v = 1
elif (sum_bpu == 14):
    bpu_h = 8
    bpu_s = 4
    bpu_v = 2
elif (sum_bpu == 15):
    bpu_h = 8
    bpu_s = 5
    bpu_v = 2
elif (sum_bpu == 16):
    bpu_h = 8
    bpu_s = 6
    bpu_v = 2
elif (sum_bpu == 17):
    bpu_h = 8
    bpu_s = 6
    bpu_v = 3
elif (sum_bpu == 18):
    bpu_h = 8
    bpu_s = 7
    bpu_v = 3
elif (sum_bpu == 19):
    bpu_h = 8
    bpu_s = 8
    bpu_v = 3
elif (sum_bpu == 20):
    bpu_h = 8
    bpu_s = 8
    bpu_v = 4
elif (sum_bpu == 21):
    bpu_h = 8
    bpu_s = 8
    bpu_v = 5
elif (sum_bpu == 22):
    bpu_h = 8
    bpu_s = 8
    bpu_v = 6
elif (sum_bpu == 23):
    bpu_h = 8
    bpu_s = 8
    bpu_v = 7
elif (sum_bpu == 24):
    bpu_h = 8
    bpu_s = 8
    bpu_v = 8


r_mask = (2 ** bpu_h - 1) << (bpu_s + bpu_v)
g_mask = (2 ** bpu_s - 1) << bpu_v
b_mask = 2 ** bpu_v - 1


vs={
'sum_bpu' : sum_bpu,
'color_system' : color_system,
'bpu_r' : bpu_h,
'bpu_g' : bpu_s,
'bpu_b' : bpu_v,
'gray_config' : gray_config,
'hue_min' : hue_min,
'hue_max' : hue_max,
'r_mask' : r_mask,
'g_mask' : g_mask,
'b_mask' : b_mask,
'display_mode': display_mode,
}

data_file = open(file_name, 'r')

arr = np.empty(shape=(240, 310))

n_pixels = width*height

output_size_in_bytes = int(n_pixels * sum_bpu / 8)

encoded_buffer = bytearray(output_size_in_bytes)

aeb_buffer_counter = 0

aeb_string_buffer = ''
for idx, pixel in enumerate(data_file.readlines()):
    # aeb = int(pixel[:-1], 2) & 0xff
    dd = pixel[:-1]
    aeb = int(dd, 2)
    aeb_string_buffer = aeb_string_buffer + dd

    if (len(aeb_string_buffer) % 8 == 0):
        chunks = [aeb_string_buffer[i:i + 8] for i in range(0, len(aeb_string_buffer), 8)]
        for b in chunks:
            encoded_buffer[aeb_buffer_counter] = int(b, 2) & 0xff

            aeb_buffer_counter += 1

        aeb_string_buffer = ''


    if idx == 0:
        aeb_payload_buffer = aeb << ((n_pixels - 1) * sum_bpu)
    else:
        aeb_payload_buffer = aeb_payload_buffer | aeb << ((n_pixels - idx - 1) * sum_bpu)



t_mapper_decoder.decoder(
    encoded_buffer,
            vs)



sdf=4
# with Image.open(file_name) as imm:
#     imm = imm.resize((320, 240), Image.NEAREST)
#     px = np.array(imm)
#     width, height = imm.size
#     px_ = np.zeros(shape=(height, width, 3), dtype="uint8")
#     for i in range(width):
#         for j in range(height):
#             px_[j, i] = px[j, i][:3]

