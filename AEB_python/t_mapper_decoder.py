import numpy as np

import hue_analysis
# from t_mapper import toBinaryStringofLenght
import matplotlib.pyplot as plt

from g_toolkit import *









def decoder(encoded_buffer_comp, vs):

    sum_bpu = vs['sum_bpu']
    color_system = vs['color_system']
    bpu_r = vs['bpu_r']
    bpu_g = vs['bpu_g']
    bpu_b = vs['bpu_b']
    gray_config = vs['gray_config']
    hue_min = vs['hue_min']
    hue_max = vs['hue_max']
    r_mask = vs['r_mask']
    g_mask = vs['g_mask']
    b_mask = vs['b_mask']
    display_mode = vs['display_mode']

    encoded_byte_array_full = encoded_buffer_comp


    full_rgb_frame = np.zeros(shape=(height, width, 3),dtype='uint8')


    block_bytes_count = int(width * height * sum_bpu / 8)

    block_bytepacks_size = int(define_bytes_pack_size(sum_bpu, block_bytes_count))

    block_bytepacks_to_unpack = int(block_bytes_count / block_bytepacks_size)

    assert block_bytepacks_to_unpack * block_bytepacks_size == len(encoded_byte_array_full)



    frame_buffer = []

    bytepack_bitstring = ""

    bytepacks_to_unpack = block_bytepacks_to_unpack
    bytepacks_size = block_bytepacks_size
    block_encoded_byte_array = encoded_byte_array_full

    for bytepack_idx in range(bytepacks_to_unpack):

        for byte_idx in range(bytepacks_size):
            bytepack_bitstring = bytepack_bitstring + toBinaryStringofLenght(
                block_encoded_byte_array[bytepack_idx * bytepacks_size + byte_idx],
                8
            )

        assert (bytepacks_size * 8 == len(bytepack_bitstring))

        chunks = [bytepack_bitstring[i:i + sum_bpu] for i in range(0, len(bytepack_bitstring), sum_bpu)]

        for pixel_bitstring in chunks:
            pixel_aeb = int(pixel_bitstring, 2)

            # if vs['display_mode'] == 0:
            #     rgb_rec = hue_analysis.hsv_to_rgb(hue_rec, 128. / 255., 128. / 255.)
            #
            #     r_rec_tc = int(rgb_rec[0] * 255)
            #     g_rec_tc = int(rgb_rec[1] * 255)
            #     b_rec_tc = int(rgb_rec[2] * 255)
            #
            #     frame_buffer.append([r_rec_tc, g_rec_tc, b_rec_tc])
            #
            # else:
            #
            #     frame_buffer.append(hue_rec)

            if color_system == 0:  # RGB
                r_rec = (pixel_aeb & r_mask) >> (bpu_g + bpu_b)
                g_rec = (pixel_aeb & g_mask) >> (bpu_b)
                b_rec = (pixel_aeb & b_mask)

                r_rec_tc = r_rec * (2 ** (8 - bpu_r))
                g_rec_tc = g_rec * (2 ** (8 - bpu_g))
                b_rec_tc = b_rec * (2 ** (8 - bpu_b))

                if display_mode == 0:
                    frame_buffer.append([r_rec_tc, g_rec_tc, b_rec_tc])

                else:
                    frame_buffer.append(r_rec_tc << 16 | g_rec_tc << 8 | b_rec_tc)


            elif color_system == 1:  # YIQ
                y_rec = (pixel_aeb & r_mask) >> (bpu_g + bpu_b)
                i_rec = (pixel_aeb & g_mask) >> (bpu_b)
                q_rec = (pixel_aeb & b_mask)

                y_rec_tc = y_rec * (2 ** (8 - bpu_r))
                i_rec_tc = i_rec * (2 ** (8 - bpu_g))
                q_rec_tc = q_rec * (2 ** (8 - bpu_b))

                if display_mode == 0:

                    rgb_rec =  hue_analysis.yiq_to_rgb(y_rec_tc / 255., i_rec_tc / 255., q_rec_tc / 255.)

                    r_rec_tc = int(rgb_rec[0] * 255)
                    g_rec_tc = int(rgb_rec[1] * 255)
                    b_rec_tc = int(rgb_rec[2] * 255)

                    frame_buffer.append([r_rec_tc, g_rec_tc, b_rec_tc])

                else:
                    frame_buffer.append(y_rec << 16 | i_rec << 8 | q_rec)



            elif color_system == 2:  # HSV
                h_rec = (pixel_aeb & r_mask) >> (bpu_g + bpu_b)
                s_rec = (pixel_aeb & g_mask) >> (bpu_b)
                v_rec = (pixel_aeb & b_mask)

                h_rec_tc = h_rec * (2 ** (8 - bpu_r))
                s_rec_tc = s_rec * (2 ** (8 - bpu_g))
                v_rec_tc = v_rec * (2 ** (8 - bpu_b))

                if display_mode == 0:

                    rgb_rec = hue_analysis.hsv_to_rgb(h_rec_tc / 255., s_rec_tc / 255., v_rec_tc / 255.)

                    r_rec_tc = int(rgb_rec[0] * 255)
                    g_rec_tc = int(rgb_rec[1] * 255)
                    b_rec_tc = int(rgb_rec[2] * 255)

                    frame_buffer.append([r_rec_tc, g_rec_tc, b_rec_tc])

                else:
                    frame_buffer.append(h_rec_tc << 16 | s_rec_tc << 8 | v_rec_tc)


            elif color_system == 3:  # Y
                y_rec = pixel_aeb
                y_rec_tc = y_rec * (2 ** (8 - sum_bpu))


                if display_mode == 0:

                    r_rec_tc = int(y_rec_tc)
                    g_rec_tc = int(y_rec_tc)
                    b_rec_tc = int(y_rec_tc)

                    frame_buffer.append([r_rec_tc, g_rec_tc, b_rec_tc])

                else:
                    frame_buffer.append(y_rec)


            elif color_system == 4:  # HUE
                hue_rec = pixel_aeb
                hue_rec_tc = hue_rec * (2 ** (8 - sum_bpu))

                if display_mode == 0:

                    hsv_rec = hue_analysis.hsv_to_rgb(hue_rec_tc / 255., 128. / 255., 128. / 255.)

                    r_rec_tc = int(hsv_rec[0] * 255)
                    g_rec_tc = int(hsv_rec[1] * 255)
                    b_rec_tc = int(hsv_rec[2] * 255)

                    frame_buffer.append([r_rec_tc, g_rec_tc, b_rec_tc])


                else:
                    frame_buffer.append(hue_rec)


            elif color_system == 5:  # HUE FOCUS
                hue_rec = pixel_aeb

                if hue_rec != 0:

                    hue_focus = hue_rec * (2 ** (8 - sum_bpu))

                    # hue_rec = int(255 * (hue_min + (hue_focus/255.) * (hue_max-hue_min)))

                    hue_rec = hue_min + (hue_focus / 255.) * (hue_max-hue_min)
                    hue_tc = int(hue_rec * 255)

                else:
                    hue_tc = 0

                if display_mode == 0:

                    hsv_rec = hue_analysis.hsv_to_rgb(hue_tc / 255., 128. / 255., 128. / 255.)

                    r_rec_tc = int(hsv_rec[0] * 255)
                    g_rec_tc = int(hsv_rec[1] * 255)
                    b_rec_tc = int(hsv_rec[2] * 255)

                    frame_buffer.append([r_rec_tc, g_rec_tc, b_rec_tc])


                else:
                    frame_buffer.append(hue_tc)






        bytepack_bitstring = ''



    if display_mode == 0:

        assert len(frame_buffer) == width * height
        buff = np.asarray(frame_buffer, dtype="uint8").reshape(height, width, 3)


    else:
        'spectrum analysis'

        # convert frame_buffer to rgb using sa_colors
        min_v = min(frame_buffer)
        max_v = max(frame_buffer)

        assert min_v < max_v

        sa_frame_buffer = [sa_colors.iloc[int(((x-min_v)/(max_v-min_v))*1023)].values[1:] for x in frame_buffer]
        buff = np.asarray(sa_frame_buffer, dtype="uint8").reshape(height, width, 3)
        print('unique values:', list(set(frame_buffer)))

    plt.title(f'(T) color_system: {color_system}    sum_bpu: {sum_bpu}   ')
    plt.imshow(buff)
    plt.show()








