import numpy as np

import hue_analysis
# from t_mapper import toBinaryStringofLenght
import matplotlib.pyplot as plt

from g_toolkit import *








def decoder(encoded_buffer_comp, g_mapper_layout, vs):

    # comp_len = vs['comp_len']
    color_system = vs['color_system']


    # encoded_byte_array_full = inflate(encoded_buffer_comp)
    encoded_byte_array_full = encoded_buffer_comp


    full_rgb_frame = np.zeros(shape=(height, width, 3),dtype='uint8')


    height_cropped = int(height / g_mapper_layout['crop_count'])
    width_cropped = int(width / g_mapper_layout['crop_count'])


    """
    pre-processing the layout
    generate sum_bpu and byte_array_lengths for each block
    """
    blocks_bytepacks_size= []
    blocks_bytes_count = []
    blocks_bytepacks_to_unpack = []

    # range_counts_r_s = []
    # range_counts_g_s = []
    # range_counts_b_s = []
    # range_counts_h_s = []
    # range_counts_y_s = []

    basepoints_r_s = []
    basepoints_g_s = []
    basepoints_b_s = []
    basepoints_h_s = []
    basepoints_y_s = []

    # bpu_r_s = []
    bpu_g_s = []
    bpu_b_s = []

    sum_bpu_s = []

    r_mask_s = []
    g_mask_s = []
    b_mask_s = []


    for block_idx, block_width_height_idx in enumerate(g_mapper_layout['most_significant_block_width_height_idxs']):


        if color_system == 0:

            basepoints_r = g_mapper_layout['most_significant_block_basepoints'][block_idx][0]
            basepoints_g = g_mapper_layout['most_significant_block_basepoints'][block_idx][1]
            basepoints_b = g_mapper_layout['most_significant_block_basepoints'][block_idx][2]

            # range_counts_r = len(basepoints_r)
            # range_counts_g = len(basepoints_g)
            # range_counts_b = len(basepoints_b)

            bpu_r = infer_sum_bpu(len(basepoints_r))
            bpu_g = infer_sum_bpu(len(basepoints_g))
            bpu_b = infer_sum_bpu(len(basepoints_b))

            sum_bpu = bpu_r + bpu_g + bpu_b

            basepoints_r = basepoints_r + [1.]
            basepoints_g = basepoints_g + [1.]
            basepoints_b = basepoints_b + [1.]

            r_mask = (2 ** bpu_r - 1) << (bpu_g + bpu_b)
            g_mask = (2 ** bpu_g - 1) << bpu_b
            b_mask = 2 ** bpu_b - 1


            #---------------------------------------------- storeing
            basepoints_r_s.append(basepoints_r)
            basepoints_g_s.append(basepoints_g)
            basepoints_b_s.append(basepoints_b)

            # range_counts_r_s.append(range_counts_r)
            # range_counts_g_s.append(range_counts_g)
            # range_counts_b_s.append(range_counts_b)

            # bpu_r_s.append(bpu_r)
            bpu_g_s.append(bpu_g)
            bpu_b_s.append(bpu_b)

            sum_bpu_s.append(sum_bpu)

            r_mask_s.append(r_mask)
            g_mask_s.append(g_mask)
            b_mask_s.append(b_mask)



        elif color_system == 3:
            basepoints_y = g_mapper_layout['most_significant_block_basepoints'][block_idx]
            range_counts_y = len(basepoints_y)

            sum_bpu = infer_sum_bpu(len(basepoints_y))

            basepoints_y = basepoints_y + [1.]

            #---------------------------------------------- storeing
            basepoints_y_s.append(basepoints_y)
            # range_counts_y_s.append(range_counts_y)
            sum_bpu_s.append(sum_bpu)
            # basepoints_y_s.append(basepoints_y)

            assert len(basepoints_y) - 1 == range_counts_y

        elif color_system == 4:
            basepoints_h = g_mapper_layout['most_significant_block_basepoints'][block_idx]

            range_counts_h = len(basepoints_h)

            sum_bpu = infer_sum_bpu(len(basepoints_h))

            basepoints_h = basepoints_h + [1.]

            assert len(basepoints_h) - 1 == range_counts_h

            # ---------------------------------------------- storeing
            basepoints_h_s.append(basepoints_h)
            # range_counts_h_s.append(range_counts_h)
            sum_bpu_s.append(sum_bpu)
            # basepoints_h_s.append(basepoints_h)


        block_bytes_count = int(width_cropped * height_cropped * sum_bpu / 8)
        blocks_bytes_count.append(block_bytes_count)

        block_bytepacks_size = int(define_bytes_pack_size(sum_bpu, block_bytes_count))
        blocks_bytepacks_size.append(block_bytepacks_size)


        block_bytepacks_to_unpack= int(block_bytes_count / block_bytepacks_size)
        blocks_bytepacks_to_unpack.append(block_bytepacks_to_unpack)

    assert sum(blocks_bytes_count) == len(encoded_byte_array_full)


    for block_idx, block_width_height_idx in enumerate(g_mapper_layout['most_significant_block_width_height_idxs']):

        sum_bpu = sum_bpu_s[block_idx]




        block_starting_byte_idx = sum(blocks_bytes_count[:block_idx])
        block_ending_byte_idx = block_starting_byte_idx + blocks_bytes_count[block_idx]

        block_encoded_byte_array = encoded_byte_array_full[block_starting_byte_idx : block_ending_byte_idx]



        bytepacks_size = blocks_bytepacks_size[block_idx]

        bytepacks_to_unpack = blocks_bytepacks_to_unpack[block_idx]


        frame_buffer = []

        bytepack_bitstring = ""


        for bytepack_idx in range(bytepacks_to_unpack):

            for byte_idx in range(bytepacks_size):

                bytepack_bitstring = bytepack_bitstring + toBinaryStringofLenght(
                    block_encoded_byte_array[bytepack_idx * bytepacks_size + byte_idx],
                    8
                )


            assert(bytepacks_size * 8  == len(bytepack_bitstring))

            chunks = [bytepack_bitstring[i:i + sum_bpu] for i in range(0, len(bytepack_bitstring), sum_bpu)]

            for pixel_bitstring in chunks:
                pixel_aeb = int(pixel_bitstring, 2) & 0xff

                if color_system == 0:

                    # loading
                    basepoints_r = basepoints_r_s[block_idx]
                    basepoints_g = basepoints_g_s[block_idx]
                    basepoints_b = basepoints_b_s[block_idx]

                    bpu_g=bpu_g_s[block_idx]
                    bpu_b=bpu_b_s[block_idx]

                    r_mask = r_mask_s[block_idx]
                    g_mask = g_mask_s[block_idx]
                    b_mask = b_mask_s[block_idx]



                    r_rec = (pixel_aeb & r_mask) >> (bpu_g + bpu_b)
                    g_rec = (pixel_aeb & g_mask) >> (bpu_b)
                    b_rec = (pixel_aeb & b_mask)

                    r_rec_tc = int(basepoints_r[r_rec] * 255)
                    g_rec_tc = int(basepoints_g[g_rec] * 255)
                    b_rec_tc = int(basepoints_b[b_rec] * 255)

                    if vs['display_mode'] == 0:
                        frame_buffer.append([r_rec_tc, g_rec_tc, b_rec_tc])

                    else:
                        frame_buffer.append(r_rec_tc << 16 | g_rec_tc << 8 | b_rec_tc)


                elif color_system == 3:

                    basepoints_y = basepoints_y_s[block_idx]

                    y_rec = basepoints_y[pixel_aeb]

                    if vs['display_mode'] == 0:

                        r_rec_tc = int(y_rec * 255)
                        g_rec_tc = int(y_rec * 255)
                        b_rec_tc = int(y_rec * 255)

                        frame_buffer.append([r_rec_tc, g_rec_tc, b_rec_tc])

                    else:

                        frame_buffer.append(y_rec)


                elif color_system ==4:

                    basepoints_h = basepoints_h_s[block_idx]

                    hue_rec = basepoints_h[pixel_aeb]

                    if vs['display_mode'] == 0:
                        rgb_rec = hue_analysis.hsv_to_rgb(hue_rec, 128. / 255., 128. / 255.)

                        r_rec_tc = int(rgb_rec[0] * 255)
                        g_rec_tc = int(rgb_rec[1] * 255)
                        b_rec_tc = int(rgb_rec[2] * 255)

                        frame_buffer.append([r_rec_tc, g_rec_tc, b_rec_tc])

                    else:

                        frame_buffer.append(hue_rec)


            bytepack_bitstring = ''




        if vs['display_mode'] == 0:

            assert len(frame_buffer) == width_cropped * height_cropped
            buff = np.asarray(frame_buffer, dtype="uint8").reshape(height_cropped, width_cropped, 3)


        else:
            'spectrum analysis'

            # convert frame_buffer to rgb using sa_colors
            min_v = g_mapper_layout['min_hue'] / 179
            max_v = g_mapper_layout['max_hue'] / 179

            assert min_v < max_v

            sa_block_buffer = [sa_colors.iloc[int(((x - min_v) / (max_v - min_v)) * 1023)].values[1:] for x in
                               frame_buffer]

            buff = np.asarray(sa_block_buffer, dtype="uint8").reshape(height_cropped, width_cropped, 3)
            print('unique values:', list(set(frame_buffer)))


        full_rgb_frame[
                block_width_height_idx[0] * height_cropped: (block_width_height_idx[0] + 1) * height_cropped,
                block_width_height_idx[1] * width_cropped: (block_width_height_idx[1] + 1) * width_cropped
                ] = buff

        frame_buffer = []


    return full_rgb_frame


    # else:







