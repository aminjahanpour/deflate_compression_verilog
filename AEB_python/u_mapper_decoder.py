import numpy as np

import hue_analysis
# from t_mapper import toBinaryStringofLenght
import matplotlib.pyplot as plt

from g_toolkit import *







def decoder(encoded_buffer_comp, u_mapper_layout, vs):

    comp_len = vs['comp_len']
    sum_bpu = vs['sum_bpu']
    color_system = vs['color_system']
    bpu_r = vs['bpu_r']
    bpu_g = vs['bpu_g']
    bpu_b = vs['bpu_b']
    r_mask = vs['r_mask']
    g_mask = vs['g_mask']
    b_mask = vs['b_mask']

    encoded_byte_array_full = inflate(encoded_buffer_comp)


    full_rgb_frame = np.zeros(shape=(height, width, 3),dtype='uint8')


    height_cropped = int(height / u_mapper_layout['crop_count'])
    width_cropped = int(width / u_mapper_layout['crop_count'])




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



    block_counts = len(u_mapper_layout['most_significant_block_width_height_idxs'])

    block_bytes_count = int(width_cropped * height_cropped * sum_bpu / 8)
    block_bytepacks_size = int(define_bytes_pack_size(sum_bpu, block_bytes_count))
    block_bytepacks_to_unpack = int(block_bytes_count / block_bytepacks_size)


    assert block_bytepacks_to_unpack * block_bytepacks_size * block_counts== len(encoded_byte_array_full)


    for block_idx, block_width_height_idx in enumerate(u_mapper_layout['most_significant_block_width_height_idxs']):

        block_starting_byte_idx = block_idx * block_bytes_count
        block_ending_byte_idx = (block_idx+1) * block_bytes_count

        block_encoded_byte_array = encoded_byte_array_full[block_starting_byte_idx : block_ending_byte_idx]






        frame_buffer = []

        bytepack_bitstring = ""


        for bytepack_idx in range(block_bytepacks_to_unpack):

            for byte_idx in range(block_bytepacks_size):

                bytepack_bitstring = bytepack_bitstring + toBinaryStringofLenght(
                    block_encoded_byte_array[bytepack_idx * block_bytepacks_size + byte_idx],
                    8
                )


            assert(block_bytepacks_size * 8  == len(bytepack_bitstring))

            chunks = [bytepack_bitstring[i:i + sum_bpu] for i in range(0, len(bytepack_bitstring), sum_bpu)]

            for pixel_bitstring in chunks:
                pixel_aeb = int(pixel_bitstring, 2) & 0xff

                if color_system == 0:
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
                    y_rec = basepoints_y[pixel_aeb]

                    if vs['display_mode'] == 0:
                        # rgb_rec = hue_analysis.yiq_to_rgb(y_rec, y_rec, y_rec)

                        r_rec_tc = int(y_rec * 255)
                        g_rec_tc = int(y_rec * 255)
                        b_rec_tc = int(y_rec * 255)

                        frame_buffer.append([r_rec_tc, g_rec_tc, b_rec_tc])

                    else:

                        frame_buffer.append(y_rec)


                elif color_system == 4:
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
            min_v = u_mapper_layout['min_hue'] / 179
            max_v = u_mapper_layout['max_hue'] / 179

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


    plt.title(f'(U) color_system: {color_system}    sum_bpu: {sum_bpu}   comp_len: {comp_len}')
    plt.imshow(full_rgb_frame)
    plt.show()

    # else:







