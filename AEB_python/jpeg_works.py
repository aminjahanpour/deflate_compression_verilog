import copy
import bitstring

import numpy as np

import g_toolkit
from g_toolkit import *
import hue_analysis
import cv2
import matplotlib.pyplot as plt
from scipy.fftpack import dct, idct
import huf
import zlib

import jpeg_toolbox


fig = plt.figure()
fig.subplots_adjust(hspace=0.4, wspace=0.4)
fig.set_size_inches(40, 30, forward=True)


def dct2_sci(block):
    return dct(dct(block.T, norm='ortho').T, norm='ortho')


def idct2_sci(block):
    return idct(idct(block.T, norm='ortho').T, norm='ortho')


def build_dct(img_ycbcr,  qt_factor, this_is_y):
    frame_dtc = np.zeros(shape=(height, width))
    frame_dtc_quantized = np.zeros(shape=(height, width), dtype='int')

    block_counter = 0

    stacked_dct =       np.zeros(shape=(block_counts_in_height * block_count_in_weight, 8, 8))
    stacked_quantized = np.zeros(shape=(block_counts_in_height * block_count_in_weight, 8, 8), dtype='int')

    for crop_idx_height in range(block_counts_in_height):

        for crop_idx_width in range(block_count_in_weight):
            cropped_img = img_ycbcr[
                          crop_idx_height * 8: (crop_idx_height + 1) * 8,
                          crop_idx_width * 8: (crop_idx_width + 1) * 8
                          ]


            block_dct = my_dct_pre_calculated(cropped_img)
            # block_dct_ = dct2_sci(cropped_img)

            stacked_dct[block_counter] = block_dct

            if this_is_y:
                stacked_quantized[block_counter] = np.round(np.divide(block_dct, qt_factor * jpeg_toolbox.jpeg_y_quantization_table), 0).astype('int')


            else:
                stacked_quantized[block_counter] = np.round(np.divide(block_dct, qt_factor * jpeg_toolbox.jpeg_c_quantization_table), 0).astype('int')

            frame_dtc_quantized[
            crop_idx_height * 8: (crop_idx_height + 1) * 8,
            crop_idx_width * 8: (crop_idx_width + 1) * 8
            ] = stacked_quantized[block_counter]

            frame_dtc[
            crop_idx_height * 8: (crop_idx_height + 1) * 8,
            crop_idx_width * 8: (crop_idx_width + 1) * 8
            ] = block_dct


            block_counter = block_counter + 1


    return frame_dtc, stacked_dct, frame_dtc_quantized, stacked_quantized


def recover_dct(frame_dtc):
    frame_idtc = np.empty(shape=(height, width))

    for crop_idx_height in range(block_counts_in_height):

        for crop_idx_width in range(block_count_in_weight):
            cropped_frame_dtc = frame_dtc[
                                crop_idx_height * 8: (crop_idx_height + 1) * 8,
                                crop_idx_width * 8: (crop_idx_width + 1) * 8
                                ]

            # block_idct_scipy = idct2_sci(cropped_frame_dtc)
            # block_idct_opencv = cv2.idct(cropped_frame_dtc)

            frame_idtc[
            crop_idx_height * 8: (crop_idx_height + 1) * 8,
            crop_idx_width * 8: (crop_idx_width + 1) * 8
            ] = cv2.idct(cropped_frame_dtc)

    return frame_idtc





def deserialize_quantized_values(bitstreams, dtc_depth, dc_bits, ac_bits, qt_factor , this_is_y):

    frame_dtc = np.zeros(shape=(height, width))

    depth_cut_size= int(len(bitstreams)/ dtc_depth)

    bitstreams = [bitstreams[i:i + depth_cut_size] for i in range(0, len(bitstreams), depth_cut_size)]

    for depth in range(dtc_depth):

        bits_to_read = dc_bits if depth == 0 else ac_bits

        assert len(bitstreams[depth]) % bits_to_read == 0

        chunks = [bitstreams[depth][i:i + bits_to_read] for i in range(0, len(bitstreams[depth]), bits_to_read)]

        for idx, chunk in enumerate(chunks):

            u, v = jpeg_toolbox.zig_zag_uvs[depth][1]


            value = bitstring.BitArray(f'0b{chunk}').int


            if this_is_y:
                value = value * qt_factor * jpeg_toolbox.jpeg_y_quantization_table[u, v]
            else:
                value = value * qt_factor * jpeg_toolbox.jpeg_c_quantization_table[u, v]


            """
            you need to figure out the position of the top left pixel in the frame 
            """
            r = int(idx / int(width/8))
            c = idx - r * int(width/8)


            frame_dtc[r*8 + u, c * 8 + v] = value



    return frame_dtc






def serialize_quantized_values_per_channel(stacked_quantized, dtc_depth, dc_bits, ac_bits):
    """
    scheme 2:
    go zig_zag on all blocks simultaniously
    """

    ret = ''

    for i in range(dtc_depth):
        u, v = jpeg_toolbox.zig_zag_uvs[i][1]

        values = stacked_quantized[:, u, v]


        for value in values:

            v = bitstring.BitArray(f'int8={value}').bin

            ret = ret + v

    print(f"{len(ret) / 8000} K bytes")

    return ret

def find_needed_bit_lengths(stacked_quantized, dtc_depth, percentile, verbose=False):


    channel_bits_needed = []

    for i in range(dtc_depth):
        u, v = jpeg_toolbox.zig_zag_uvs[i][1]

        values = stacked_quantized[:, u, v]

        if verbose:
            ax = fig.add_subplot(8, 8, jpeg_toolbox.zig_zag_uvs[i][0] + 1)

            ax.hist(stacked_quantized[:, u, v], bins=50)

        if i == 0:
            dc_low = min(values)
            dc_tr_low = int(np.percentile(abs(values), 1, axis=0))
            dc_tr_high = int(np.percentile(abs(values), 99, axis=0))

            if verbose:
                ax.plot([dc_tr_low, dc_tr_low], [0, 200])
                ax.plot([dc_tr_high, dc_tr_high], [0, 200])

            bits_needed = jpeg_toolbox.get_bits_needed(dc_tr_high - dc_tr_low)
            bits_needed = 16

            channel_bits_needed.append(bits_needed)

            if verbose:
                print(f"{i}: bits needed no trimming: {jpeg_toolbox.get_bits_needed(max(values))}, bits needed after trimming {bits_needed}")

        else:

            tr = int(np.percentile(abs(values), percentile, axis=0))

            if verbose:
                ax.plot([tr, tr], [0, 200])


            bits_needed = jpeg_toolbox.get_bits_needed(tr)

            bits_needed = bits_needed + 1

            bits_needed = 8


            channel_bits_needed.append(bits_needed)

            if verbose:
                print(f"{i}: bits needed no trimming: {1+jpeg_toolbox.get_bits_needed(max(abs(values)))}, bits needed after trimming {bits_needed}")



        if verbose:
            ax.set_xlim([min(values), max(values)])

    if verbose:
        plt.show()


    return [channel_bits_needed, dc_low]



def my_dct(in_arr, depth):
    dct = np.zeros(shape=(8, 8))

    for i in range(depth):

        u, v = jpeg_toolbox.zig_zag_uvs[i][1]

        sum = 0

        for x in range(8):
            for y in range(8):
                sum = sum + in_arr[x][y] * np.cos((2. * x + 1.) * u * np.pi / 16) * np.cos(
                    (2. * y + 1.) * v * np.pi / 16)

        cu = (1. / np.sqrt(2)) if (u == 0) else 1
        cv = (1. / np.sqrt(2)) if (v == 0) else 1

        dct[u, v] = 0.25 * cu * cv * sum

    return dct

def populate_dct_constants():
    ret = np.zeros(shape=(8,8,8,8,1))

    for u in range(8):
        for v in range(8):
            for x in range(8):
                for y in range(8):
                    ret[u,v,x,y] = np.cos((2. * x + 1.) * u * np.pi / 16) * np.cos((2. * y + 1.) * v * np.pi / 16)

    return ret

def my_dct_pre_calculated(in_arr):
    dct = np.zeros(shape=(8, 8))

    dct_constants = populate_dct_constants()

    for i in range(64):

        u, v = jpeg_toolbox.zig_zag_uvs[i][1]

        sum = 0

        for x in range(8):
            for y in range(8):
                sum = sum + in_arr[x][y] * dct_constants[u,v,x,y]

        cu = (1. / np.sqrt(2)) if (u == 0) else 1
        cv = (1. / np.sqrt(2)) if (v == 0) else 1

        dct[u, v] = 0.25 * cu * cv * sum

    return dct




if __name__ == '__main__':

    df=5

    file_name = 'shuttle.png'


    # file_name = 'gol.bmp'
    # file_name = 'truck.png'
    # file_name = 'farm.jpg'
    # file_name = 'cat.bmp'

    img_bgr_raw = cv2.imread(file_name)

    # testing the downsampling
    # dd= jpeg_toolbox.sub_sample_plane(img_bgr_raw[:, :, 0],0.1,0.12)
    # img_bgr_raw[:, :, 0] = jpeg_toolbox.sub_sample_plane(img_bgr_raw[:, :, 0],0.5,0.5)
    # img_bgr_raw[:, :, 1] = jpeg_toolbox.sub_sample_plane(img_bgr_raw[:, :, 1],0.5,0.5)
    # img_bgr_raw[:, :, 2] = jpeg_toolbox.sub_sample_plane(img_bgr_raw[:, :, 2],0.5,0.5)
    # cv2.imwrite("./downsampled.bmp", img_bgr_raw)

    # assert all([x == y for x, y in zip(dd.flatten(), img_bgr_raw[:, :, 0].flatten())])

    img_bgr_raw = cv2.resize(img_bgr_raw, (width, height), interpolation=cv2.INTER_NEAREST)

    # img_ycrcb = cv2.cvtColor(img_bgr_raw, cv2.COLOR_BGR2YCrCb)

    img_rgb = cv2.cvtColor(img_bgr_raw, cv2.COLOR_BGR2RGB)

    img_ycbcr = np.apply_along_axis(hue_analysis.rgb_to_ycbcr, 2, img_rgb)

    # verifigcation plots
    # plt.plot((img_ycrcb[:,:,0]).flatten(), lw= 0.5)
    # plt.plot((img_ycbcr[:, :, 0]).flatten())
    # plt.scatter(x=img_ycrcb[:,:,2], y = img_ycbcr[:,:,1])

    # plt.hist(img_ycbcr[:, :, 0].flatten())

    # plt.show()

    # applying downsampling on Cb and Cr
    downsample_pixel_count= 2

    img_ycbcr[:, :, 1] = jpeg_toolbox.sub_sample_plane(img_ycbcr[:, :, 1], downsample_pixel_count)
    img_ycbcr[:, :, 2] = jpeg_toolbox.sub_sample_plane(img_ycbcr[:, :, 2], downsample_pixel_count)

    img_y  = img_ycbcr[:, :, 0]
    img_cb = img_ycbcr[:, :, 1]
    img_cr = img_ycbcr[:, :, 2]




    # a = copy.deepcopy(img_ycbcr[:, :, 1])
    # img_ycbcr[:, :, 1] = img_ycbcr[:, :, 2]
    # img_ycbcr[:, :, 2] = a
    # cv2.imwrite("./downsampled_cb_cr.bmp", cv2.cvtColor(img_ycbcr, cv2.COLOR_YCrCb2BGR))
    # plt.imshow(cv2.cvtColor(cv2.cvtColor(img_ycbcr, cv2.COLOR_YCrCb2BGR), cv2.COLOR_BGR2RGB))
    # plt.show()
    # exit()
    dc_bits = 8
    ac_bits = 8

    dtc_depth_y = 64
    dtc_depth_cb = 1
    dtc_depth_cr = 1

    percentile = 0 # no longer in effect
    qt_factor = 1

    sig_groups_count = int(width * height / 64)

    frame_dtc_y, stacked_dct_y, frame_dtc_quantized_y, stacked_quantized_y = build_dct(img_y, qt_factor, this_is_y=True)
    channel_bitstreams_per_channel_y = serialize_quantized_values_per_channel(stacked_quantized_y, dtc_depth_y, dc_bits, ac_bits)

    frame_dtc_cb, stacked_dct_cb, frame_dtc_quantized_cb, stacked_quantized_cb = build_dct(img_cb, qt_factor, this_is_y=False)
    channel_bitstreams_per_channel_cb = serialize_quantized_values_per_channel(stacked_quantized_cb, dtc_depth_cb, dc_bits, ac_bits)

    frame_dtc_cr, stacked_dct_cr, frame_dtc_quantized_cr, stacked_quantized_cr = build_dct(img_cr, qt_factor, this_is_y=False)
    channel_bitstreams_per_channel_cr = serialize_quantized_values_per_channel(stacked_quantized_cr, dtc_depth_cr, dc_bits, ac_bits)

    full_raw_bitstring = channel_bitstreams_per_channel_y + channel_bitstreams_per_channel_cb + channel_bitstreams_per_channel_cr



    with open(f'../verilog/aeb/jpeg_dumps/output_file_jpeg_serialized.txt', 'r') as my_file:
        verilog_bitstream = my_file.read().replace('\n', '')
    #
    # full_raw_bitstring = verilog_bitstream


    print("uncompressed bitstream:",len(full_raw_bitstring)/8000, 'Kb')

    aeb_byte_stream = dump_bitstring_to_file_as_bytes(full_raw_bitstring, "./out/my_jpg.txt")


    assert len(full_raw_bitstring) == int(sig_groups_count * (dtc_depth_y + dtc_depth_cb+ dtc_depth_cr) * 8)

    vb = [verilog_bitstream [i:i + 8] for i in range(0, len(verilog_bitstream ), 8)]
    pb = [full_raw_bitstring[i:i + 8] for i in range(0, len(full_raw_bitstring), 8)]

    sdf=all([x==y for x,y in zip (vb, pb)])

    dequantized_dct_frame_y  = deserialize_quantized_values(full_raw_bitstring[:int(sig_groups_count * dtc_depth_y * 8)], dtc_depth_y, dc_bits, ac_bits, qt_factor, this_is_y=True)
    dequantized_dct_frame_cb = deserialize_quantized_values(full_raw_bitstring[int(sig_groups_count * dtc_depth_y * 8):int(sig_groups_count * (dtc_depth_y + dtc_depth_cb)) * 8], dtc_depth_cb, dc_bits, ac_bits, qt_factor, this_is_y=False)
    dequantized_dct_frame_cr = deserialize_quantized_values(full_raw_bitstring[int(sig_groups_count * (dtc_depth_y + dtc_depth_cb)) * 8:], dtc_depth_cr, dc_bits, ac_bits, qt_factor, this_is_y=False)




    # assert len(full_raw_bitstring) / 8 == len(aeb_byte_stream)


    zlib_encoded = zlib.compress(aeb_byte_stream)
    zlib_decoded = zlib.decompress(zlib_encoded)


    dump_bytestream_to_file(zlib_encoded, "./out/py_zlib_bytes.gzip")


    assert all([x == y for x,y in zip (aeb_byte_stream, zlib_decoded)])

    # half_compression_ratio = len(halfman_encoded) / len(full_raw_aeb)
    zlib_compression_ratio = 8*len(zlib_encoded) / len(full_raw_bitstring)

    # print(f'compression_ratio: {half_compression_ratio}, output size: {len(halfman_encoded) / 8000} Kb')
    print(f'compression_ratio: {zlib_compression_ratio}, output size: {len(zlib_encoded)/1000} Kb')






    idtc_y_arr = recover_dct(dequantized_dct_frame_y)
    idtc_cb_arr = recover_dct(dequantized_dct_frame_cb)
    idtc_cr_arr = recover_dct(dequantized_dct_frame_cr)

    # replace original y with decoded ones and save the image for comparision
    img_ycrcb_opencv = cv2.cvtColor(img_bgr_raw, cv2.COLOR_BGR2YCrCb)

    img_ycrcb_opencv[:, :, 0] = idtc_y_arr
    img_ycrcb_opencv[:, :, 1] = idtc_cr_arr  # np.zeros(shape=(height, width))
    img_ycrcb_opencv[:, :, 2] = idtc_cb_arr  # np.zeros(shape=(height, width))

    img_bgr = cv2.cvtColor(img_ycrcb_opencv, cv2.COLOR_YCrCb2BGR)
    # cv2.imwrite(f"./dci_output_{len(zlib_encoded)/1000}_Kb.bmp", img_bgr)


    ax = fig.add_subplot(2, 1, 1)
    ax.imshow(img_rgb)
    plt.title(f'original')

    ax = fig.add_subplot(2, 1, 2)
    ax.imshow(cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB))
    plt.title(f'{len(zlib_encoded)/1000}_Kb')


    plt.show()

