from PIL import Image, ImageDraw
from math import acos, sqrt
import numpy as np

import matplotlib.pyplot as plt
import hue_analysis
from PIL import Image, ImageDraw

def main():
    file_name = 'shuttle_16.bmp'
    # file_name = 'tavos.jpg'
    # file_name = 'car.png'
    # file_name = 'tent.png'
    # file_name = 'easy.png'


    pass

    with Image.open(f'./{file_name}') as imm:
        px = imm.load()

    width = imm.size[0]
    height = imm.size[1]

    output_filename = f'{file_name.replace(".","_")}.rgb'

    img_rgb = Image.new('RGB', imm.size)


    with open(output_filename, 'w') as output_file:

        for mm in range(height):

            for nn in range(width):
                r_org = px[nn, mm][0]
                g_org = px[nn, mm][1]
                b_org = px[nn, mm][2]


                r_5 = r_org >> 3
                g_6 = g_org >> 2
                b_5 = b_org >> 3



                rgb = r_5<<11 | g_6<<5 | b_5

                assert rgb <= 2**16 - 1

                output_file.write(f'{rgb}\n')


                r_rec = (rgb >>11 & 31) << 3
                g_rec = (rgb >> 5 & 63) << 2
                b_rec = (rgb      & 31) << 3


                img_rgb.putpixel((nn, mm), (r_rec, g_rec, b_rec))

    img_rgb.save(f'./{output_filename}.bmp')


if __name__ == '__main__':
    main()


    """
    
    every 5.3 pixels are xored with encrypted value of the same counter
    
    assume counter increases by one per each block of 128 bits
    
    """