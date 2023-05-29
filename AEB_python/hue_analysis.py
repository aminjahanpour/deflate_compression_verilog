from PIL import Image, ImageDraw
from math import acos, sqrt
import numpy as np

import matplotlib.pyplot as plt

ONE_THIRD = 1.0 / 3.0
ONE_SIXTH = 1.0 / 6.0
TWO_THIRD = 2.0 / 3.0





def rgb_to_ycbcr(rgb):
    """
    0 <= r, g, b <= 1.0

     0      <= y <= 1.0
    -0.5959 <= i <= 0.5959
    -0.5227 <= q <= 0.5227

    0 <= i + 0.5959 <= 1.1918
    0 <= q + 0.5227<= 1.0454

    0 <= (i + 0.5959)/1.1918 <= 1
    0 <= (q + 0.5227)/1.0454 <= 1
    """

    r, g,b = rgb

    y =  int(round(       0.299 *       r   +     0.587 * g     +       0.114 * b,0))
    cb = int(round(128. - 0.168736 *    r - 0.331264 *  g + 0.5 *       b,0))
    cr = int(round(128. + 0.5 *         r - 0.418688 *  g - 0.081312 *  b,0))


    return np.array([y, cb, cr], dtype='uint8')





def rgb_to_yiq(r, g, b):
    """
    0 <= r, g, b <= 1.0

     0      <= y <= 1.0
    -0.5959 <= i <= 0.5959
    -0.5227 <= q <= 0.5227

    0 <= i + 0.5959 <= 1.1918
    0 <= q + 0.5227<= 1.0454

    0 <= (i + 0.5959)/1.1918 <= 1
    0 <= (q + 0.5227)/1.0454 <= 1
    """

    y = 0.299 * r + 0.587 * g + 0.114 * b
    i = 0.5959 * r - 0.2746 * g - 0.3213 * b
    q = 0.2115 * r - 0.5227 * g + 0.3112 * b

    # mapping to range(0, 1)
    i = (i + 0.5959) / 1.1918
    q = (q + 0.5227) / 1.0454

    return (y, i, q)

def yiq_to_rgb(y, i, q):
    # recover i and q from range(0, 1) to their real range
    i = (i * 1.1918) - 0.5959
    q = (q * 1.0454) - 0.5227

    r = y + 0.956 * i + 0.619 * q
    g = y - 0.272 * i - 0.647 * q
    b = y - 1.106 * i + 1.703 * q

    if r < 0.0:
        r = 0.0
    if g < 0.0:
        g = 0.0
    if b < 0.0:
        b = 0.0
    if r > 1.0:
        r = 1.0
    if g > 1.0:
        g = 1.0
    if b > 1.0:
        b = 1.0
    return (r, g, b)

def rgb_hsv_opencv(r, g, b):
    v = max(r,g,b)

    if (v != 0):
        s = (v - min(r,g,b)) / v
    else:
        v = 0

    if (v == r):
        h = 60 * (g-b) / (v - min(r,g,b))
    elif (v==g):
        h = 120 + 60*(b-r) / (v - min(r,g,b))
    elif (v==b):
        h = 240 + 60 * (r-g) / (v-min(r,g,b))

    if ((r==b) and (g==b)):
        h = 0

    if (h < 0):
        h = h + 360.

    return h

def rgb_to_hsv(r, g, b):
    maxc = max(r, g, b)
    minc = min(r, g, b)
    v = maxc
    if minc == maxc:
        return 0.0, 0.0, v
    delta = maxc - minc
    s = delta / maxc
    rc = (maxc - r) / delta
    gc = (maxc - g) / delta
    bc = (maxc - b) / delta
    if r == maxc:
        h = bc - gc
    elif g == maxc:
        h = 2.0 + rc - bc
    else:
        h = 4.0 + gc - rc
    h = (h / 6.0) % 1.0 # the expression (% 1.0) extracts the floating part of the number
    return h, s, v

def hsv_to_rgb(h, s, v):
    if s == 0.0:
        return v, v, v
    i = int(h * 6.0)  # XXX assume int() truncates!
    f = (h * 6.0) - i
    p = v * (1.0 - s)
    q = v * (1.0 - s * f)
    t = v * (1.0 - s * (1.0 - f))
    i = i % 6
    if i == 0:
        return v, t, p
    if i == 1:
        return q, v, p
    if i == 2:
        return p, v, t
    if i == 3:
        return p, q, v
    if i == 4:
        return t, p, v
    if i == 5:
        return v, p, q
    # Cannot get here


def rgb_to_hue(r, g, b):
    maxc = max(r, g, b)
    minc = min(r, g, b)
    if minc == maxc:
        return 0.0
    delta = maxc - minc
    rc = (maxc - r) / delta
    gc = (maxc - g) / delta
    bc = (maxc - b) / delta
    if r == maxc:
        h = bc - gc
    elif g == maxc:
        h = 2.0 + rc - bc
    else:
        h = 4.0 + gc - rc
    h = (h / 6.0) % 1.0
    return h
###################################################################################3

def main():
    # bpu = [2, 2,1]
    bpu = [8, 8, 8]
    #
    file_name = 'gol.bmp'
    # file_name = 'tavos.jpg'
    # file_name = 'car.png'
    file_name = 'tent.png'
    # file_name = 'easy.png'
    file_names = ['car.bmp', 'gol.bmp']

    fig, axes = plt.subplots(5, len(file_names))
    fig.set_size_inches(10 * len(file_names), 26)


    for idx, file_name in enumerate(file_names):
        pass

        with Image.open(f'./{file_name}') as imm:
            px = imm.load()

        img_rgb = Image.new('RGB', imm.size)
        img_y = Image.new('RGB', imm.size)
        img_yiq = Image.new('RGB', imm.size)
        img_hsv = Image.new('RGB', imm.size)
        img_hue = Image.new('RGB', imm.size)



        width = imm.size[0]
        height = imm.size[1]

        xx, yy = np.meshgrid(np.linspace(0, width - 1, width), np.linspace(0, height - 1, height))
        zz_hsv = np.zeros(shape=[height, width])
        zz_rgb = np.zeros(shape=[height, width])
        zz_yiq = np.zeros(shape=[height, width])
        zz_y = np.zeros(shape=[height, width])

        zz_hue = np.zeros(shape=[height, width])


        for mm in range(height):

            for nn in range(width):
                r_org = px[nn, mm][0]
                g_org = px[nn, mm][1]
                b_org = px[nn, mm][2]

                r_org_norm = r_org / 255
                g_org_norm = g_org / 255
                b_org_norm = b_org / 255

                yp_org = 0.1 * r_org + 0.3 * g_org + 0.6 * b_org
                hue_org = rgb_to_hue(r_org_norm, g_org_norm, b_org_norm)


                yiq_org = rgb_to_yiq(r_org_norm, g_org_norm, b_org_norm)
                hsv_org = rgb_to_hsv(r_org_norm, g_org_norm, b_org_norm)
                # hue_set.append(hsv_org[0])

                assert 0 <= yiq_org[0] <= 1 and 0 <= yiq_org[1] <= 1 and 0 <= yiq_org[2] <= 1
                assert 0 <= hsv_org[0] <= 1 and 0 <= hsv_org[1] <= 1 and 0 <= hsv_org[2] <= 1

                ###########################
                ## ENCOING

                r = int(r_org_norm * (2 ** bpu[0] - 1))
                g = int(g_org_norm * (2 ** bpu[1] - 1))
                b = int(b_org_norm * (2 ** bpu[2] - 1))


                # only Y
                yp = int(yp_org * (2 ** bpu[0] - 1) / 255)

                # YIQ
                y = int(yiq_org[0] * (2 ** bpu[0] - 1) )
                ii = int(yiq_org[1] * (2 ** bpu[1] - 1))
                q = int(yiq_org[2] * (2 ** bpu[2] - 1))
                assert y >= 0 and ii >= 0 and q >= 0

                # HUE only
                hue = int(hue_org * (2 ** bpu[0] - 1))

                # HSV
                hh = int(hsv_org[0] * (2 ** bpu[0] - 1))
                ss = int(hsv_org[1] * (2 ** bpu[1] - 1))
                vv = int(hsv_org[2] * (2 ** bpu[2] - 1))
                assert hh >= 0 and ss >= 0 and vv >= 0

                ###########################
                ## DECOING

                # RGB
                r_rec = (2 ** (8 - bpu[0])) * r
                g_rec = (2 ** (8 - bpu[1])) * g
                b_rec = (2 ** (8 - bpu[2])) * b

                zz_rgb[mm][nn] = r_rec << 16 | g_rec << 8 | b_rec


                # only Y
                yp_rec = (2 ** (8 - bpu[0])) * yp

                zz_y[mm][nn] = yp_rec


                # YIQ
                y_rec = (2 ** (8 - bpu[0])) * y
                ii_rec = (2 ** (8 - bpu[1])) * ii
                q_rec = (2 ** (8 - bpu[2])) * q

                zz_yiq[mm][nn] = y_rec << 16 | ii_rec << 8 | q_rec


                # HUE only
                hue_rec = (2 ** (8 - bpu[0])) * hue

                zz_hue[mm][nn] = hue_rec


                # HSV
                hh_rec = (2 ** (8 - bpu[0])) * hh
                ss_rec = (2 ** (8 - bpu[1])) * ss
                vv_rec = (2 ** (8 - bpu[2])) * vv

                zz_hsv[mm][nn] = hh_rec << 16 | ss_rec << 8 | vv_rec


                # verifying the t-mapper
                if bpu[0] == 8:
                    assert r_rec == r_org
                    assert yp_rec == int(yp_org)
                    assert hue_rec == int(hue)
                    assert hh_rec == int(hsv_org[0] * 255)
                    assert y_rec == int(yiq_org[0] * 255)

                if bpu[1] == 8:
                    assert g_rec == g_org
                if bpu[2] == 8:
                    assert b_rec == b_org






                # RGB
                img_rgb.putpixel((nn, mm), (r_rec, g_rec, b_rec))



                # # YIQ, Y ONLY: 1 BIT for bpu=1
                r_rec = yp_rec
                g_rec = yp_rec
                b_rec = yp_rec



                img_y.putpixel((nn, mm), (r_rec, g_rec, b_rec))


                # # YIQ FULL
                yiq_rec = yiq_to_rgb(y_rec / 255., ii_rec / 255., q_rec / 255.)
                r_rec = int(yiq_rec[0] * 255)
                g_rec = int(yiq_rec[1] * 255)
                b_rec = int(yiq_rec[2] * 255)



                img_yiq.putpixel((nn, mm), (r_rec, g_rec, b_rec))

                # HUE ONLY
                hsv_rec = hsv_to_rgb(hue_rec / 255., 128., 128.)
                r_rec = int(hsv_rec[0] * 255)
                g_rec = int(hsv_rec[1] * 255)
                b_rec = int(hsv_rec[2] * 255)

                img_hue.putpixel((nn, mm), (r_rec, g_rec, b_rec))

                # HSV
                hsv_rec = hsv_to_rgb(hh_rec / 255., ss_rec / 255., vv_rec / 255.)
                r_rec = int(hsv_rec[0] * 255)
                g_rec = int(hsv_rec[1] * 255)
                b_rec = int(hsv_rec[2] * 255)



                img_hsv.putpixel((nn, mm), (r_rec, g_rec,b_rec))


        img_rgb.save(f'./rgb_aeb_{file_name}')
        img_y.save(f'./y_aeb_{file_name}')
        img_yiq.save(f'./yiq_aeb_{file_name}')
        img_hsv.save(f'./hsv_aeb_{file_name}')
        img_hue.save(f'./hue_aeb_{file_name}')



        ###################------------------- RECOVERED RGB SPECTRUM

        zz_rgb = zz_rgb[:-1, :-1]
        zz_hsv = zz_hsv[:-1, :-1]
        zz_yiq = zz_yiq[:-1, :-1]
        zz_y = zz_y[:-1, :-1]
        zz_hue = zz_hue[:-1, :-1]

        z_min_rgb, z_max_rgb = zz_rgb.min(), zz_rgb.max()
        z_min_hsv, z_max_hsv = zz_hsv.min(), zz_hsv.max()
        z_min_yiq, z_max_yiq = zz_yiq.min(), zz_yiq.max()
        z_min_y, z_max_y = zz_y.min(), zz_y.max()
        z_min_hue, z_max_hue = zz_hue.min(), zz_hue.max()



        ax = axes[0, idx]
        c = ax.pcolormesh(xx, yy, zz_rgb, cmap='RdBu', vmin=z_min_rgb, vmax=z_max_rgb)
        ax.set_title('rgb spectrum')
        ax.axis([xx.min(), xx.max(), yy.max(), yy.min()])
        fig.colorbar(c, ax=ax)


        ax = axes[1, idx]
        c = ax.pcolormesh(xx, yy, zz_hsv, cmap='RdBu', vmin=z_min_hsv, vmax=z_max_hsv)
        ax.set_title('hsv spectrum')
        ax.axis([xx.min(), xx.max(), yy.max(), yy.min()])
        fig.colorbar(c, ax=ax)

        ax = axes[2, idx]
        c = ax.pcolormesh(xx, yy, zz_yiq, cmap='RdBu', vmin=z_min_yiq, vmax=z_max_yiq)
        ax.set_title('yiq spectrum')
        ax.axis([xx.min(), xx.max(), yy.max(), yy.min()])
        fig.colorbar(c, ax=ax)

        ax = axes[3, idx]
        c = ax.pcolormesh(xx, yy, zz_y, cmap='RdBu', vmin=z_min_y, vmax=z_max_y)
        ax.set_title('y spectrum')
        ax.axis([xx.min(), xx.max(), yy.max(), yy.min()])
        fig.colorbar(c, ax=ax)



        ax = axes[4, idx]
        c = ax.pcolormesh(xx, yy, zz_hue, cmap='RdBu', vmin=z_min_hue, vmax=z_max_hue)
        ax.set_title('hue spectrum')
        ax.axis([xx.min(), xx.max(), yy.max(), yy.min()])
        fig.colorbar(c, ax=ax)


        fig.suptitle(bpu, fontsize=20)
    plt.show()

if __name__ == '__main__':
    main()
