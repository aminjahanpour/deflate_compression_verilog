import numpy as np
from math import log

import hue_analysis

from g_toolkit import *
from base_points import *



def encoder(full_rgb_frame, u_mapper_layout, vs):

    sum_bpu = vs['sum_bpu']
    color_system = vs['color_system']
    bpu_r = vs['bpu_r']
    bpu_g = vs['bpu_g']
    bpu_b = vs['bpu_b']
    gray_config = vs['gray_config']
    hue_min = vs['hue_min']
    hue_max = vs['hue_max']

    height_cropped = int(height / u_mapper_layout['crop_count'])
    width_cropped = int(width / u_mapper_layout['crop_count'])


    n_pixels = height_cropped * width_cropped


    full_encoded_buffer = bytearray()








    if color_system == 0:
        range_counts_r = 2 ** bpu_r
        range_counts_g = 2 ** bpu_g
        range_counts_b = 2 ** bpu_b

        basepoints_r = u_mapper_layout['basepoints_r'] + [1.]
        basepoints_g = u_mapper_layout['basepoints_g'] + [1.]
        basepoints_b = u_mapper_layout['basepoints_b'] + [1.]

        assert len(basepoints_r) - 1 == range_counts_r
        assert len(basepoints_g) - 1 == range_counts_g
        assert len(basepoints_b) - 1 == range_counts_b

    elif color_system == 3:
        basepoints_y = u_mapper_layout['basepoints_y'] + [1.]
        range_counts_y = 2 ** sum_bpu

        assert  len(basepoints_y) - 1 == range_counts_y

    elif color_system == 4:
        basepoints_h = u_mapper_layout['basepoints_h'] + [1.]
        range_counts_h = 2 ** sum_bpu

        assert len(basepoints_h) - 1 == range_counts_h

    for block_idx, block_width_height_idx in enumerate(u_mapper_layout['most_significant_block_width_height_idxs']):

        block = full_rgb_frame[
                      block_width_height_idx[0] * height_cropped: (block_width_height_idx[0] + 1) * height_cropped,
                      block_width_height_idx[1] * width_cropped: (block_width_height_idx[1] + 1) * width_cropped
                      ]


        flatten_block = block.reshape((height_cropped * width_cropped, 3))


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
                aeb = get_aeb(basepoints_y,range_counts_y,yp_org)

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


            if idx == 0:
                aeb_payload_buffer = aeb << ((n_pixels - 1) * sum_bpu)
            else:
                aeb_payload_buffer = aeb_payload_buffer | aeb << ((n_pixels - idx - 1) * sum_bpu)



        full_encoded_buffer = full_encoded_buffer + encoded_buffer
        # print('block')

    return full_encoded_buffer

