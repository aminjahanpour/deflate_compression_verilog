from PIL import Image
import colorsys


"""
this is encoder and decoder for one payload
one payload contains ppp pixels

the payload size for each sum_bpu is taken from the datasheet.ods table
payload should be the largest integer that is smaller than 33,
and results in ppp and ppb values that are integer.

sum_bpu of 1 and 2 are only used in the Y color system.
"""
color_system = 0
display_mode = 0
sum_bpu = 16
bpu_config = 3
gray_config = 5

if (sum_bpu == 1):
    payload_size = 20

elif (sum_bpu == 2):
    payload_size = 20

elif (sum_bpu == 3):
    payload_size = 30

elif (sum_bpu == 4):
    payload_size = 32

elif (sum_bpu == 5):
    payload_size = 20

elif (sum_bpu == 6):
    payload_size = 30

elif (sum_bpu == 7):
    payload_size = 28

elif (sum_bpu == 8):
    payload_size = 32

elif (sum_bpu == 9):
    payload_size = 18

elif (sum_bpu == 10):
    payload_size = 20

elif (sum_bpu == 11):
    payload_size = 22

elif (sum_bpu == 12):
    payload_size = 30

elif (sum_bpu == 13):
    payload_size = 26

elif (sum_bpu == 14):
    payload_size = 28

elif (sum_bpu == 15):
    payload_size = 30

elif (sum_bpu == 16):
    payload_size = 32

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
    (min_, mid_, max_),

]

gray_configs = [
    (0.3, 0.6, 0.1), # 000

    (0.35, 0.55, 0.1),  # +-0
    (0.3, 0.65, 0.05),  # 0+-
    (0.25, 0.6, 0.15),  # -0+

    (0.4, 0.5, 0.1), # +-0
    (0.3, 0.7, 0.0), # 0+-
    (0.2, 0.6, 0.2), # -0+
]

# for color systems:
bpu_r = bpu_configs[bpu_config][0]
bpu_g = bpu_configs[bpu_config][1]
bpu_b = bpu_configs[bpu_config][2]

# for y system:
gray_config = gray_configs[gray_config]

assert bpu_r + bpu_g + bpu_b == sum_bpu
assert payload_size * 8 > sum_bpu

ili_bpu_r = 5
ili_bpu_g = 6
ili_bpu_b = 5

ppp = payload_size * 8 / sum_bpu  # pixel per payload
ppb = 320 / ppp  # payload per burst
ppf = 240 * ppb  # payload per frame

assert ppp == int(ppp)
assert ppb == int(ppb)
assert ppf == int(ppf)

print(f'payload_size: {payload_size}')
print(f'ppp: {ppp}')
print(f'ppb: {ppb}')
print(f'ppf: {ppf}')
ppp = int(ppp)
ppb = int(ppb)
ppf = int(ppf)

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
ppp = len(px)
bpu_r = 8
bpu_g = 8
bpu_b = 8
sum_bpu = 24


# this is the mask to recover the values of the relevant color component via ANDING
r_mask = (2 ** bpu_r - 1) << (bpu_g + bpu_b)
g_mask = (2 ** bpu_g - 1) << bpu_b
b_mask = 2 ** bpu_b - 1

"""
ENCODER
"""

for idx, rgb in enumerate(px):

    r_org = rgb[0]
    g_org = rgb[1]
    b_org = rgb[2]


    # perform the conversion to the target color system
    if color_system == 0:
        # RGB. no conversion needed.
        pass
    elif color_system == 1:
        # YIQ
        pass
    elif color_system == 2:
        #HSV
        pass
    elif color_system == 3:
        # Y
        pass
    elif color_system == 4:
        # HUE
        pass


        # yp is build based on the original true color
        # yp is an 8-bit number in essence.
        yp_org = round(gray_config[0] * rgb[0] + gray_config[1] * rgb[1] + gray_config[2] * rgb[2], 0)

    if color_system in [0, 1, 2]:
        r = int(r_org * (2 ** bpu_r - 1) / (255))
        g = int(g_org * (2 ** bpu_g - 1) / (255))
        b = int(b_org * (2 ** bpu_b - 1) / (255))

        print(rgb)
    else:
        y = int(yp_org * (2 ** sum_bpu - 1) / (255))

        print(yp_org)

    if color_system in [0, 1, 2]:
        aeb = r << (bpu_g + bpu_b) | g << (bpu_b) | b
    else:
        aeb = y

    if idx == 0:
        aeb_buffer = aeb << ((ppp - 1) * sum_bpu)
    else:
        aeb_buffer = aeb_buffer | aeb << ((ppp - idx - 1) * sum_bpu)

    assert aeb < 2 ** sum_bpu

    if color_system in [0, 1, 2]:
        r_rec = (aeb & r_mask) >> (bpu_g + bpu_b)
        g_rec = (aeb & g_mask) >> (bpu_b)
        b_rec = (aeb & b_mask)


        assert r == r_rec and g == g_rec and b == b_rec

        r_rec_tc = r_rec * (2 ** (8 - bpu_r))
        g_rec_tc = g_rec * (2 ** (8 - bpu_g))
        b_rec_tc = b_rec * (2 ** (8 - bpu_b))

    else:
        y_rec_tc = aeb * (2 ** (8 - sum_bpu))

    # print(bin(aeb))

print(aeb_buffer)
print(bin(aeb_buffer))

"""
DECODER
"""

for i in range(ppp):
    pixel_aeb = (aeb_buffer & ((2 ** sum_bpu - 1) << ((ppp - (i + 1)) * sum_bpu))) >> ((ppp - (i + 1)) * sum_bpu)

    if color_system in [0, 1, 2]:
        r_rec = (pixel_aeb & r_mask) >> (bpu_g + bpu_b)
        g_rec = (pixel_aeb & g_mask) >> (bpu_b)
        b_rec = (pixel_aeb & b_mask)

        # recovered and decoded true color values
        r_rec_tc = r_rec * (2 ** (8 - bpu_r))
        g_rec_tc = g_rec * (2 ** (8 - bpu_g))
        b_rec_tc = b_rec * (2 ** (8 - bpu_b))

        print(r_rec_tc, g_rec_tc, b_rec_tc)

    else:
        y_rec = pixel_aeb
        y_rec_tc = y_rec * (2 ** (8 - sum_bpu))
        print(y_rec_tc)



    # now in order to display the pixel on ili,
    # we need to take the pixels into ili bpu

    if color_system in [0, 1, 2]:
        r = int(r_rec_tc * (2 ** ili_bpu_r - 1) / 255)
        g = int(g_rec_tc * (2 ** ili_bpu_g - 1) / 255)
        b = int(b_rec_tc * (2 ** ili_bpu_b - 1) / 255)

    else:
        r = int(y_rec_tc * (2 ** ili_bpu_r - 1) / 255)
        g = int(y_rec_tc * (2 ** ili_bpu_g - 1) / 255)
        b = int(y_rec_tc * (2 ** ili_bpu_b - 1) / 255)

    color_2bytes = r << 11 | g << 5 | b
    assert color_2bytes <= 2 ** 16
