from PIL import Image
import colorsys

bpu_r = 5
bpu_g = 6
bpu_b = 5

file_name = 'gol.bmp'
file_name = 'tavos.jpg'
file_name = 'space.jpg'

with Image.open(f'./{file_name}') as imm:
    px = imm.load()

img_rgb = Image.new('RGB', imm.size)

buff = []
counter = 0

with open(f'./{file_name}.dat', 'w') as ff:

    for mm in range(imm.size[1]):

        for nn in range(imm.size[0]):
            r_org = px[nn, mm][0]
            g_org = px[nn, mm][1]
            b_org = px[nn, mm][2]

            r = int(r_org * (2 ** bpu_r) / (2 ** 8))
            g = int(g_org * (2 ** bpu_g) / (2 ** 8))
            b = int(b_org * (2 ** bpu_b) / (2 ** 8))

            color_2bytes = r << 11 | g << 5 | b
            assert color_2bytes <= 2 ** 16

            b1_bin = color_2bytes >> 8
            b2_bin = color_2bytes & 0xFF

            # ff.write(f'{b1_bin}, {b2_bin},')
            ff.write(f'{color_2bytes},')
            counter += 1
            if counter ==10:
                ff.write('\n')
                counter = 0

            assert color_2bytes == b1_bin << 8 | b2_bin

            r_rec = (2 ** (8 - bpu_r)) * r
            g_rec = (2 ** (8 - bpu_g)) * g
            b_rec = (2 ** (8 - bpu_b)) * b

            img_rgb.putpixel((nn, mm), (r_rec, g_rec, b_rec))

img_rgb.save(f'./var_rgb_aeb_{file_name}')
