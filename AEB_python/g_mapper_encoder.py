import numpy as np
from math import log

import hue_analysis

from g_toolkit import *
from base_points import *



"""
every bit gives us 2 possibilities. n bits give us 2^n possibilities.
T-mapper gives all the possibilities equal space and so it consumes all the bits.
U-mapper gives the most dense parts of the histogram more resolution but still adds possibilities
to the g_basepoints until it consumes all the bits. but this added resolution makes the buffer 
less compressibile and does not always add useful info.
G-Mapper is the answer to this problem. It no longer works based on the possibilities that
bits provide. it goes the other way. it works based on the number of required possibilities and
builts and bits based on the that.



min { 2^n - p^K }

subject to:
p^K <= 2^n
n >= 1, n in integer
K >= 1, K is integer

decision variables: n and K 


n: number of bits
p: number of possibilities
K: number of pixels to be encoded together

for example, p = 3
for K = 5 we have p^K = 3^5 = 243, and
for n = 8 we have 2^n = 2^8 = 256

so we can encode, every 5 pixels in 8 bits, with a small waste of space. 

normally you'd need to use 2 bits to store at least 4 states. so for 5 pixels you'd need 10 bits.

G: comp_len: 659, comp_ratio: 0.48814814814814816
G: comp_len: 787, comp_ratio: 0.582962962962963
G: comp_len: 856, comp_ratio: 0.6340740740740741
G: comp_len: 575, comp_ratio: 0.42592592592592593
G: comp_len: 1077, comp_ratio: 0.7977777777777778
G: comp_len: 689, comp_ratio: 0.5103703703703704


"""
def encoder(full_rgb_frame, g_mapper_layout, vs):

    color_system = vs['color_system']
    # bpu_r = vs['bpu_r']
    # bpu_g = vs['bpu_g']
    # bpu_b = vs['bpu_b']
    gray_config = vs['gray_config']
    # hue_min = vs['hue_min']
    # hue_max = vs['hue_max']

    height_cropped = int(height / g_mapper_layout['crop_count'])
    width_cropped = int(width / g_mapper_layout['crop_count'])


    n_pixels = height_cropped * width_cropped


    full_encoded_buffer = bytearray()

    for block_idx, block_width_height_idx in enumerate(g_mapper_layout['most_significant_block_width_height_idxs']):

        block = full_rgb_frame[
                      block_width_height_idx[0] * height_cropped: (block_width_height_idx[0] + 1) * height_cropped,
                      block_width_height_idx[1] * width_cropped: (block_width_height_idx[1] + 1) * width_cropped
                      ]


        flatten_block = block.reshape((height_cropped * width_cropped, 3))

        if color_system == 0:

            basepoints_r = g_mapper_layout['most_significant_block_basepoints'][block_idx][0]
            basepoints_g = g_mapper_layout['most_significant_block_basepoints'][block_idx][1]
            basepoints_b = g_mapper_layout['most_significant_block_basepoints'][block_idx][2]

            range_counts_r = len(basepoints_r)
            range_counts_g = len(basepoints_g)
            range_counts_b = len(basepoints_b)

            bpu_r = infer_sum_bpu(len(basepoints_r))
            bpu_g = infer_sum_bpu(len(basepoints_g))
            bpu_b = infer_sum_bpu(len(basepoints_b))

            sum_bpu = bpu_r + bpu_g + bpu_b

            basepoints_r = basepoints_r + [1.]
            basepoints_g = basepoints_g + [1.]
            basepoints_b = basepoints_b + [1.]

            assert len(basepoints_r) - 1 == range_counts_r
            assert len(basepoints_g) - 1 == range_counts_g
            assert len(basepoints_b) - 1 == range_counts_b

        elif color_system == 3:
            basepoints_y = g_mapper_layout['most_significant_block_basepoints'][block_idx]
            range_counts_y = len(basepoints_y)

            sum_bpu = infer_sum_bpu(len(basepoints_y))

            basepoints_y = basepoints_y + [1.]

            assert len(basepoints_y) - 1 == range_counts_y

        elif color_system == 4:
            basepoints_h = g_mapper_layout['most_significant_block_basepoints'][block_idx]
            range_counts_h = len(basepoints_h)

            sum_bpu = infer_sum_bpu(len(basepoints_h))


            basepoints_h = basepoints_h + [1.]

            assert len(basepoints_h) - 1 == range_counts_h


        assert n_pixels * sum_bpu % 8 == 0
        output_size_in_bytes = int(n_pixels * sum_bpu / 8)
        encoded_buffer = bytearray(output_size_in_bytes)
        aeb_string_buffer = ''
        aeb_buffer_counter = 0


        for idx, rgb in enumerate(flatten_block):
            r_org = rgb[0]
            g_org = rgb[1]
            b_org = rgb[2]

            r_org_norm = r_org / 255
            g_org_norm = g_org / 255
            b_org_norm = b_org / 255


            if color_system == 0:
                r = get_aeb(basepoints_r, range_counts_r, r_org_norm)
                g = get_aeb(basepoints_g, range_counts_g, g_org_norm)
                b = get_aeb(basepoints_b, range_counts_b, b_org_norm)

                aeb = r << (bpu_g + bpu_b) | g << (bpu_b) | b


            elif color_system == 3:
                yp_org = round(gray_config[0] * r_org + gray_config[1] * g_org + gray_config[2] * b_org, 0) / 255.

                aeb = get_aeb(basepoints_y, range_counts_y, yp_org)


            elif color_system == 4:
                hue_org = hue_analysis.rgb_to_hue(r_org_norm, g_org_norm, b_org_norm)

                aeb = get_aeb(basepoints_h,range_counts_h,hue_org)


            dd = toBinaryStringofLenght(aeb, sum_bpu)
            aeb_string_buffer = aeb_string_buffer + dd

            if (len(aeb_string_buffer) % 8 == 0):
                chunks = [aeb_string_buffer[i:i + 8] for i in range(0, len(aeb_string_buffer), 8)]
                for b in chunks:
                    encoded_buffer[aeb_buffer_counter] = int(b, 2) & 0xff

                    aeb_buffer_counter += 1

                aeb_string_buffer = ''


        full_encoded_buffer = full_encoded_buffer + encoded_buffer

    return full_encoded_buffer

