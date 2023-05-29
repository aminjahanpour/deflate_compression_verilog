import cv2
import hue_analysis
from g_toolkit import *
import jpeg_toolbox
import thesmuggler

import matplotlib.pyplot as plt


rt = thesmuggler.smuggle("../verilog/python/rom_toolkit.py")


def dump_frame():

    # file_name = './gol.bmp'
    file_name = 'shuttle'
    # file_name = 'truck'

    # mode = 'rgb'
    # mode = 'hsv'
    mode = 'ycbcr'

    hue_analysis.rgb_to_hsv(62, 106, 200)
    img_bgr_raw = cv2.imread(f'./{file_name}.png')


    img_bgr_raw = cv2.resize(img_bgr_raw, (width, height), interpolation=cv2.INTER_NEAREST)

    img_hsv_raw = cv2.cvtColor(img_bgr_raw, cv2.COLOR_BGR2HSV)
    img_rgb_raw = cv2.cvtColor(img_bgr_raw, cv2.COLOR_BGR2RGB)
    img_ycrbc_raw = cv2.cvtColor(img_bgr_raw, cv2.COLOR_BGR2YCrCb)

    # hue_hist_full_frame = cv2.calcHist([img_hsv_raw], [0], None, [180], [0, 180])
    # plt.plot(hue_hist_full_frame)
    # plt.show()
    counter = 0

    with open(f'../verilog/aeb/frame_{width}_{height}_{mode}_888_{file_name}.mem', 'w') as my_file:
        # rgb(62,  106, 200) -> hsv(0.6135, 0.69, 200)
        # hue_analysis.rgb_to_hsv(62, 106, 200) = (0.6135265700483092,  0.69,   200)
        # in 255 scale =                          (156,                 176,    200)

        for row in range(height):
            for col in range(width):



                """
                RGB
                """
                r =  bin(int(img_rgb_raw[row][col][0])).replace('0b', '')
                if (len(r) < 8):
                    r = '0' * (8 - len(r)) + r

                g = bin(img_rgb_raw[row][col][1]).replace('0b', '')
                if (len(g) < 8):
                    g = '0' * (8 - len(g)) + g

                b = bin(img_rgb_raw[row][col][2]).replace('0b', '')
                if (len(b) < 8):
                    b = '0' * (8 - len(b)) + b

                if (mode == 'rgb'):

                    print(f'red:{img_rgb_raw[row][col][0]}, g: {img_rgb_raw[row][col][1]}, b: {img_rgb_raw[row][col][2]}')

                    assert len(r+g+b) == 24
                    my_file.write(r+g+b+'\n')


                elif (mode == 'hsv'):
                    """
                    HSV
                    """
                    h =  bin(int(img_hsv_raw[row][col][0])).replace('0b', '')
                    if (len(h) < 8):
                        h = '0' * (8 - len(h)) + h

                    s = bin(img_hsv_raw[row][col][1]).replace('0b', '')
                    if (len(s) < 8):
                        s = '0' * (8 - len(s)) + s

                    v = bin(img_hsv_raw[row][col][2]).replace('0b', '')
                    if (len(v) < 8):
                        v = '0' * (8 - len(v)) + v

                    # if (counter == 8115):
                    #     print(f'r:{int(img_rgb_raw[row][col][0])}, g: {img_rgb_raw[row][col][1]}, b: {img_rgb_raw[row][col][2]}')

                    print(int(img_hsv_raw[row][col][0]),

                          hue_analysis.rgb_hsv_opencv(
                              img_rgb_raw[row][col][0]/255,
                              img_rgb_raw[row][col][1]/255,
                              img_rgb_raw[row][col][2]/255,
                          ),

                          int(179. * hue_analysis.rgb_to_hue(
                              img_rgb_raw[row][col][0] / 255,
                              img_rgb_raw[row][col][1] / 255,
                              img_rgb_raw[row][col][2] / 255,
                          ))

                          )
                        # print(r+g+b)

                    assert len(r+g+b) == 24, (img_hsv_raw[row][col], h,s,v)
                    my_file.write(h+s+v+'\n')




                elif (mode == 'ycbcr'):
                    """
                    YCBCR
                    """
                    y =  bin(int(img_ycrbc_raw[row][col][0])).replace('0b', '')
                    if (len(y) < 8):
                        y = '0' * (8 - len(y)) + y

                    cr = bin(img_ycrbc_raw[row][col][1]).replace('0b', '')
                    if (len(cr) < 8):
                        cr = '0' * (8 - len(cr)) + cr

                    cb = bin(img_ycrbc_raw[row][col][2]).replace('0b', '')
                    if (len(cb) < 8):
                        cb = '0' * (8 - len(cb)) + cb

                    assert len(y+cr+cb) == 24, (img_hsv_raw[row][col], y,cr,cb)
                    my_file.write(y+cb+cr+'\n')

                counter = counter + 1


def print_zig_zag_uv():
    for idx, el in enumerate(jpeg_toolbox.zig_zag_uvs):
        a = toBinaryStringofLenght(el[1][0],3) + toBinaryStringofLenght(el[1][1],3)
        print(f"zig_zag_uvs_N0[{idx}] = 6'b{a};")

def print_zig_zag_index():
    for idx, el in enumerate(jpeg_toolbox.zig_zag_uvs):
        a = toBinaryStringofLenght(el[1][0],3) + toBinaryStringofLenght(el[1][1],3)
        print(f"zig_zag_index_N1[{idx}] = {el[0]};")

def dump_quantization_tables():
    with open(f'../../verilog/aeb/jpeg_y_quantization_table.mem', 'w') as my_file:
        for x in range(8):
            for y in range(8):
                a = jpeg_toolbox.jpeg_y_quantization_table[x, y]
                a = 1 / a
                b = rt.float_bin(a, 24).replace('_', '')
                my_file.write(f'{b}\n')

    with open(f'../../verilog/aeb/jpeg_c_quantization_table.mem', 'w') as my_file:
        for x in range(8):
            for y in range(8):
                a = jpeg_toolbox.jpeg_c_quantization_table[x, y]
                a = 1 / a
                b = rt.float_bin(a, 24).replace('_', '')
                my_file.write(f'{b}\n')


def dump_dct_constants():
    with open(f'../../verilog/aeb/dct_constants.mem', 'w') as my_file:

        for u in range(8):
            for v in range(8):
                for x in range(8):
                    for y in range(8):
                        a = np.cos((2. * x + 1.) * u * np.pi / 16) * np.cos((2. * y + 1.) * v * np.pi / 16)
                        b = rt.float_bin(a, 24).replace('_', '')
                        my_file.write(f'{b}\n')


def main():
    # dump_frame()
    # print_zig_zag()
    # dump_dct_constants()
    # dump_quantization_tables()
    print_zig_zag_index()
if __name__ == '__main__':
    main()

