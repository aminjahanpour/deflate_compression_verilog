import requests
from PIL import Image

import color_ranger
import hue_analysis
import compress_pickle
import codecs
import cv2
import matplotlib.pyplot as plt
import detection
import g_mapper_encoder
import g_mapper_decoder

import zlib
import u_mapper_decoder
import u_mapper_encoder

import t_mapper_encoder
import t_mapper_decoder

from g_toolkit import *

global width
global height




# no canny
# color_system, sum_bpu , display_mode=4 , 2 , 1

# with canny
color_system, sum_bpu , display_mode=0 ,24 , 0
# color_system, sum_bpu , display_mode=0 , 10 , 0
# color_system, sum_bpu , display_mode=3 , 3 , 0


# sum_bpu_hbsa = 2

bpu_config = 0
gray_config = 0

ip_method = 'b'
ip_param_1 = 2
ip_param_2 = 20
ip_param_3 = 150


# green
# hue_min = 75 / 360
# hue_max = 165 / 360

# blue
hue_min = 180 / 360
hue_max = 255 / 360


# cap = cv2.VideoCapture(0)
# assert cap.set(cv2.CAP_PROP_FRAME_WIDTH, width)
# assert cap.set(cv2.CAP_PROP_FRAME_HEIGHT, height)



mean_ = int(round(sum_bpu / 3, 0))
max_ = int(0.61 * sum_bpu)
mid_ = int(0.35 * sum_bpu)
min_ = sum_bpu - max_ - mid_

bpu_configs = [
    (mean_, mean_, sum_bpu - 2 * mean_),
    (max_, mid_, min_),
    (max_, min_, mid_),
    (mid_, min_, max_),
    (mid_, max_, min_),
    (min_, max_, mid_),
    (min_, mid_, max_)

]

# for color systems:
bpu_r = bpu_configs[bpu_config][0]
bpu_g = bpu_configs[bpu_config][1]
bpu_b = bpu_configs[bpu_config][2]

# debugging
# bpu_r = 6
# bpu_g = 2
# bpu_b = 1


# for y system:
gray_config = (0.299, 0.587, 0.114)

assert bpu_r + bpu_g + bpu_b == sum_bpu


px = [
    (210, 15, 220),
    (3, 143, 12),
    (88, 25, 1),
    (59, 82, 104),
    (32, 60, 12),
    (220, 130, 153),
    (254, 154, 15)
]
# in reality, we read ppp pixels from the camera. but here it is hard coded so we need the lone below.
# bpu_r = 3
# bpu_g = 3
# bpu_b = 1
# sum_bpu = 7


# this is the mask to recover the values of the relevant color component via ANDING
r_mask = (2 ** bpu_r - 1) << (bpu_g + bpu_b)
g_mask = (2 ** bpu_g - 1) << bpu_b
b_mask =  2 ** bpu_b - 1

vs={
'sum_bpu' : sum_bpu,
'color_system' : color_system,
'bpu_r' : bpu_r,
'bpu_g' : bpu_g,
'bpu_b' : bpu_b,
'gray_config' : gray_config,
'hue_min' : hue_min,
'hue_max' : hue_max,
'r_mask' : r_mask,
'g_mask' : g_mask,
'b_mask' : b_mask,
'display_mode': display_mode,
}
# int(r, 2) & 0xff
def compress_pickle_object(obj, algorithm='gzip'):
    return codecs.encode(compress_pickle.dumps(obj, algorithm), "base64").decode()


def decompress_pickle_object(obj, algorithm='gzip'):
    return compress_pickle.loads(codecs.decode(obj.get_encoded_for_given_codes(), "base64"), compression=algorithm)



def produce_hbsa_frame(payload_array):

    frame_buffer = []

    hues = []

    for idx, rgb in enumerate(payload_array):

        r_org = rgb[0]
        g_org = rgb[1]
        b_org = rgb[2]

        r_org_norm = r_org / 255
        g_org_norm = g_org / 255
        b_org_norm = b_org / 255

        hue_org = hue_analysis.rgb_to_hue(r_org_norm, g_org_norm, b_org_norm)
        hues.append(hue_org)

    low_hue = min(hues)
    high_hue = max(hues)

    plt.hist(hues)
    plt.show()

    for hue in hues:
        hue_norm = (hue - low_hue)/(high_hue - low_hue)
        hue = int(hue_norm * (2 ** sum_bpu_hbsa - 1))

        frame_buffer.append(hue)

    min_v = min(frame_buffer)
    max_v = max(frame_buffer)

    assert min_v < max_v

    sa_frame_buffer = [sa_colors.iloc[int(((x - min_v) / (max_v - min_v)) * 1023)].values[1:] for x in frame_buffer]
    buff = np.asarray(sa_frame_buffer, dtype="uint8").reshape(height, width, 3)

    return buff


"""
this function takes a frame and transmits it in ppf (payload per frame) payloads
"""



"""
talks to the camera
grabs a frame
reshape it into a list
"""
def gray_to_3channels(dst):
    a = np.zeros(shape=(height, width, 3), dtype='uint8')
    for i in range(dst.shape[0]):  # 240
        for j in range(dst.shape[1]):  # 320
            a[i][j] = [dst[i][j], dst[i][j], dst[i][j]]

    return a


def send_frame(frame):
    payload = {'payload': frame,
           'width': width,
           'height': height,
           'hue_min': hue_min,
           'hue_max': hue_max,
           'color_system': color_system,
           'display_mode': display_mode,
           'sum_bpu': sum_bpu,
           'bpu_r': bpu_r,
           'bpu_g': bpu_g,
           'bpu_b': bpu_b,
           'ppp': 0,
           'ppf': 0
           }

    resp = requests.post(url="http://127.0.0.1:5000/", json=payload)


def frame_by_frame():
    # payload_tx(px)

    global width
    global height

    counter = 0

    while 1:
        # print(counter)
        # random pixels ----------------------------
        rnd_frame = np.zeros(shape=(height, width), dtype="uint8")
        rnd_frame = (np.random.rand(height, width, 3) * 255).astype(np.uint8)
        frame = rnd_frame.reshape((height * width, 3))
        send_frame(frame)

        # camera ------------------------------------
        # ret, frame = cap.read()
        # assert ret
        # frame = frame.reshape((height * width, 3))
        # send_frame(frame)

        # read from file -------------------------



        file_names = ['car.png', 'tent.png', 'easy.png']
        for file_name in file_names:


            with Image.open(f'./{file_name}') as imm:
                imm = imm.resize((320, 240), Image.NEAREST)
                px = np.array(imm)
                width, height = imm.size
                px_ = np.zeros(shape=(height, width, 3), dtype="uint8")
                for i in range(width):
                    for j in range(height):
                        px_[j, i] = px[j, i][:3]


                # flipping rgb to bgr to build opencv
                opencv_img = np.flip(px_, 2)


                if (ip_method == 'b'):
                    dst = cv2.blur(opencv_img, (ip_param_1, ip_param_1))

                elif (ip_method == 'gb'):
                    dst = cv2.GaussianBlur(opencv_img, (ip_param_1, ip_param_1), 1)

                elif (ip_method == 'mb'):
                    dst = cv2.medianBlur(opencv_img, ip_param_1)

                elif (ip_method == 'box_filter'):
                    dst = cv2.boxFilter(opencv_img,-1,( ip_param_1, ip_param_1))

                elif (ip_method == 'buildPyramid'):
                    dst = cv2.buildPyramid(opencv_img, 11)


                elif (ip_method == 'bf'):
                    dst = cv2.bilateralFilter(opencv_img,ip_param_2,ip_param_3,ip_param_3)

                elif (ip_method == 'bfb'):
                    dst = cv2.bilateralFilter(opencv_img,ip_param_2,ip_param_3,ip_param_3)
                    dst = cv2.blur(dst, (ip_param_1, ip_param_1))

                elif (ip_method == 'den'):
                    dst = cv2.fastNlMeansDenoisingColored(opencv_img,None,10,10,7,21)

                elif (ip_method == 'canny'):
                    # v1 = np.median(opencv_img)
                    #
                    # gray = cv2.cvtColor(opencv_img, cv2.COLOR_BGR2GRAY)
                    # v2 = np.median(gray)
                    # np.max(gray)
                    #
                    #
                    # sigma = 0.3333
                    # lower = int(max(0, (1.0 - sigma) * v1))
                    # upper = int(min(255, (1.0 + sigma) * v1))
                    # dst = cv2.Canny(gray, lower, upper)


                    dst = cv2.Canny(opencv_img, 700, 255)

                    dst = gray_to_3channels(dst)


                elif (ip_method == 'otsu'):
                    # blur = cv2.blur(opencv_img, (ip_param_1, ip_param_1))
                    gray = cv2.cvtColor(opencv_img, cv2.COLOR_BGR2GRAY)

                    otsu_thresh_val, otsu = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

                    dst = gray_to_3channels(otsu)

                elif (ip_method == 'tc'):
                    blur = cv2.blur(opencv_img, (ip_param_1, ip_param_1))
                    gray = cv2.cvtColor(blur, cv2.COLOR_BGR2GRAY)

                    otsu_thresh_val, otsu = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

                    dst = gray_to_3channels(otsu)

                    sigma = 0.0333
                    lower = int(max(0,  0.5*otsu_thresh_val))
                    upper = int(min(255,   otsu_thresh_val))

                    # lower, upper = 700, 255

                    dst = cv2.Canny(dst, lower, upper)

                    dst = gray_to_3channels(dst)




                if (ip_method != ''):
                    px_ = np.flip(dst, 2)



                frame = px_.reshape((height * width, 3))

                send_frame(frame, [ip_method, ip_param_1])
        break



        counter += 1



def discovery():

    global width
    global height


    while 1:
        # print(counter)
        # random pixels ----------------------------
        # rnd_frame = np.zeros(shape=frame.shape, dtype="uint8")
        # rnd_frame = (np.random.rand(height, width, 3) * 255).astype(np.uint8)
        # frame = rnd_frame.reshape((height * width, 3))
        # send_frame(frame)

        # camera ------------------------------------
        # ret, frame = cap.read()
        # assert ret
        # frame = frame.reshape((height * width, 3))
        # send_frame(frame)

        # read from file -------------------------



        file_names = ['car.png', 'tent.png', 'easy.png']
        for file_name in file_names:


            with Image.open(f'./{file_name}') as imm:
                imm = imm.resize((320, 240), Image.NEAREST)
                px = np.array(imm)
                width, height = imm.size
                px_ = np.zeros(shape=(height, width, 3), dtype="uint8")
                for i in range(width):
                    for j in range(height):
                        px_[j, i] = px[j, i][:3]


                # flipping rgb to bgr to build opencv
                opencv_img = np.flip(px_, 2)

                dst = cv2.blur(opencv_img, (2, 2))

                px_ = np.flip(dst, 2)

                frame = px_.reshape((height * width, 3))

                """
                 produce a hue-based frame with SA colors
                 based on the provided sum_bpu
                """
                hbsa_frame = produce_hbsa_frame(frame)

                hbsa_frame_flipped = np.flip(hbsa_frame, 2)


                hbsa_frame_flipped = cv2.blur(hbsa_frame_flipped, (5, 5))


                gray = cv2.cvtColor(hbsa_frame_flipped, cv2.COLOR_BGR2GRAY)

                otsu_thresh_val, otsu = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

                dst = gray_to_3channels(otsu)

                lower = int(max(0, 0.5 * otsu_thresh_val))
                upper = int(min(255, otsu_thresh_val))

                # lower, upper = 700, 255

                dst = cv2.Canny(dst, lower, upper)

                dst = gray_to_3channels(dst)


                px_ = np.flip(dst, 2)

                frame = px_.reshape((height * width, 3))

                send_frame(frame, [ip_method, ip_param_1])
        break



        counter += 1



def masking():


    file_names = ['car.png', 'tent.png', 'easy.png']
    for file_name in file_names:

        img = cv2.imread(file_name)

        # masked_hsv, canny_gray_masked_hsv, final_included_mask = detection.mask_and_canny(
        #     img,
        #     min_value_percentage=30,
        #     hue_bins_to_remove_percentage = 90,
        # blur_param=5)

        plt.imshow(cv2.cvtColor(masked_hsv, cv2.COLOR_HSV2RGB))
        plt.show()

        # plt.imshow(cv2.cvtColor(final_included_mask, cv2.COLOR_GRAY2RGB))
        # plt.show()


        plt.imshow(cv2.cvtColor(canny_gray_masked_hsv, cv2.COLOR_GRAY2RGB))
        plt.show()

def blocks_filter():
    file_names = ['car.png', 'tent.png', 'easy.png']
    file_names = [ 'tent.png']
    for file_name in file_names:
        img = cv2.imread(file_name)

        detection.blocks_filter(
            img,
            hue_bins_to_remove_percentage=90,
            min_value=int(20*255/365),
            blur_param=2,
            crop_count=4)

    we=4
        # plt.imshow(cv2.cvtColor(masked_hsv, cv2.COLOR_HSV2RGB))
        # plt.show()
        #
        # plt.imshow(cv2.cvtColor(canny_gray_masked_hsv, cv2.COLOR_GRAY2RGB))
        # plt.show()


def range_colors():
    # file_names = ['btr.png', 'tank_1.png', 'hole_tank.png', 'truck.png', 'tank_2.png', 'hide_tank.png']
    file_names = [ 'shuttle.png']
    # file_names = [ 'truck.jpg']
    for file_name in file_names:
        img_bgr_raw = cv2.imread(file_name)

        img_bgr_raw = cv2.resize(img_bgr_raw, (width, height), interpolation=cv2.INTER_NEAREST)


        img_hsv_ranged, img_hsv_final_masked, blured_masked_hsv, canny_gray_blured_masked_hsv, gray_blured_masked_hsv, g_mapper_layout, u_mapper_layout = color_ranger.range_colors(
            img_bgr_raw,
            hue_bins_to_remove_percentage=95,
            blur_param=2,
            crop_count=8,

            top_blocks_count=12,

            vs=vs
        )

        # img_bgr_raw = cv2.blur(img_bgr_raw, (2, 2))

        """
        U MAPPER
        """

        u_full_encoded_buffer = u_mapper_encoder.encoder(cv2.cvtColor(img_bgr_raw, cv2.COLOR_BGR2RGB), u_mapper_layout, vs)
        u_full_encoded_buffer_comp =  deflate(u_full_encoded_buffer)
        u_comp_len = len(u_full_encoded_buffer_comp)
        u_comp_ratio = u_comp_len / len(u_full_encoded_buffer)
        print(f'\nU: comp_len: {u_comp_len}, comp_ratio: {u_comp_ratio}')
        vs['comp_len'] = u_comp_len

        u_mapper_decoder.decoder(
            u_full_encoded_buffer_comp,
            u_mapper_layout,
            vs)



        """
        G MAPPER
        """

        # g_full_encoded_buffer = g_mapper_encoder.encoder(cv2.cvtColor(img_bgr_raw, cv2.COLOR_BGR2RGB), g_mapper_layout, vs)
        # g_full_encoded_buffer_comp =  deflate(g_full_encoded_buffer)
        # g_comp_len = len(g_full_encoded_buffer_comp)
        # g_comp_ratio = g_comp_len / len(g_full_encoded_buffer)
        # print(f'\nG: comp_len: {g_comp_len}, comp_ratio: {g_comp_ratio}')
        # vs['comp_len'] = g_comp_len
        #
        # full_rgb_frame = g_mapper_decoder.decoder(
        #     g_full_encoded_buffer,
        #     g_mapper_layout,
        #     vs)
        #
        # plt.title(f'(G) color_system: {color_system}    sum_bpu: {sum_bpu}   comp_len: {g_comp_len}')
        # plt.imshow(full_rgb_frame)
        # plt.show()

        """
        T MAPPER
        """


        # output_rgb = cv2.cvtColor(img_bgr_raw, cv2.COLOR_BGR2RGB)
        # output_rgb = img_hsv_final_masked
        # output_rgb = img_bgr_raw
        # img_hsv_final_masked
        #
        # t_full_encoded_buffer = t_mapper_encoder.encoder(output_rgb, vs)
        # t_full_encoded_buffer_comp =  deflate(t_full_encoded_buffer)
        # t_comp_len = len(t_full_encoded_buffer_comp)
        # t_comp_ratio = t_comp_len / len(t_full_encoded_buffer)
        #
        # print(f'\nT: comp_len: {t_comp_len}, comp_ratio: {t_comp_ratio}')
        #
        # t_mapper_decoder.decoder(
        #     t_full_encoded_buffer,
        #     vs)



if __name__ == '__main__':
    # masking()
    # discovery()
    # frame_by_frame()
    # blocks_filter()
    range_colors()


