import hue_analysis

import numpy as np
import cv2 as cv
cap = cv.VideoCapture(0)
assert cap.set(cv.CAP_PROP_FRAME_WIDTH, 320)
assert cap.set(cv.CAP_PROP_FRAME_HEIGHT,240)


bpu = [2, 2, 2]

width = 320
height = 240

if not cap.isOpened():
    print("Cannot open camera")
    exit()

ret, px = cap.read()
assert ret

buff = np.empty(shape=px.shape,dtype="uint8")


def encode_decode(rgb):

    r_org_norm = rgb[0] / 255
    g_org_norm = rgb[1] / 255
    b_org_norm = rgb[2] / 255

    # yp_org = 0.1 * r_org + 0.3 * g_org + 0.6 * b_org
    hue_org = hue_analysis.rgb_to_hue(r_org_norm, g_org_norm, b_org_norm)
    #
    #
    # yiq_org = hue_analysis.rgb_to_yiq(r_org_norm, g_org_norm, b_org_norm)
    # hsv_org = hue_analysis.rgb_to_hsv(r_org_norm, g_org_norm, b_org_norm)


    # assert 0 <= yiq_org[0] <= 1 and 0 <= yiq_org[1] <= 1 and 0 <= yiq_org[2] <= 1
    # assert 0 <= hsv_org[0] <= 1 and 0 <= hsv_org[1] <= 1 and 0 <= hsv_org[2] <= 1

    ###########################
    ## ENCOING

    # r = int(r_org_norm * (2 ** bpu[0] - 1))
    # g = int(g_org_norm * (2 ** bpu[1] - 1))
    # b = int(b_org_norm * (2 ** bpu[2] - 1))


    # only Y
    # yp = int(yp_org * (2 ** bpu[0] - 1) / 255)

    # YIQ
    # y = int(yiq_org[0] * (2 ** bpu[0] - 1) )
    # ii = int(yiq_org[1] * (2 ** bpu[1] - 1))
    # q = int(yiq_org[2] * (2 ** bpu[2] - 1))
    # assert y >= 0 and ii >= 0 and q >= 0

    # HUE only
    hue = int(hue_org * (2 ** bpu[0] - 1))

    # HSV
    # hh = int(hsv_org[0] * (2 ** bpu[0] - 1))
    # ss = int(hsv_org[1] * (2 ** bpu[1] - 1))
    # vv = int(hsv_org[2] * (2 ** bpu[2] - 1))

    ###########################
    ## DECOING

    # RGB
    # r_rec = (2 ** (8 - bpu[0])) * r
    # g_rec = (2 ** (8 - bpu[1])) * g
    # b_rec = (2 ** (8 - bpu[2])) * b

    # zz_rgb[mm][nn] = r_rec << 16 | g_rec << 8 | b_rec


    # only Y
    # yp_rec = (2 ** (8 - bpu[0])) * yp

    # zz_y[mm][nn] = yp_rec


    # YIQ
    # y_rec = (2 ** (8 - bpu[0])) * y
    # ii_rec = (2 ** (8 - bpu[1])) * ii
    # q_rec = (2 ** (8 - bpu[2])) * q

    # zz_yiq[mm][nn] = y_rec << 16 | ii_rec << 8 | q_rec


    # HUE only
    hue_rec = (2 ** (8 - bpu[0])) * hue

    # zz_hue[mm][nn] = hue_rec


    # HSV
    # hh_rec = (2 ** (8 - bpu[0])) * hh
    # ss_rec = (2 ** (8 - bpu[1])) * ss
    # vv_rec = (2 ** (8 - bpu[2])) * vv

    # zz_hsv[mm][nn] = hh_rec << 16 | ss_rec << 8 | vv_rec


    # verifying the t-mapper
    # if bpu[0] == 8:
    #     assert r_rec == r_org
    #     assert yp_rec == int(yp_org)
    #     assert hue_rec == int(hue)
    #     assert hh_rec == int(hsv_org[0] * 255)
    #     assert y_rec == int(yiq_org[0] * 255)
    #
    # if bpu[1] == 8:
    #     assert g_rec == g_org
    # if bpu[2] == 8:
    #     assert b_rec == b_org





    # RGB

    # if bpu[0] == 8 and bpu[1] == 8 and bpu[2] == 8:
    #     assert all([x==y for x,y in zip (px[mm, nn] , buff[mm, nn])]  )

    # # YIQ, Y ONLY: 1 BIT for bpu=1
    # r_rec = yp_rec
    # g_rec = yp_rec
    # b_rec = yp_rec

    # img_y.putpixel((nn, mm), (r_rec, g_rec, b_rec))


    # # YIQ FULL
    # yiq_rec = hue_analysis.yiq_to_rgb(y_rec / 255., ii_rec / 255., q_rec / 255.)
    # r_rec = int(yiq_rec[0] * 255)
    # g_rec = int(yiq_rec[1] * 255)
    # b_rec = int(yiq_rec[2] * 255)
    # img_yiq.putpixel((nn, mm), (r_rec, g_rec, b_rec))

    # HUE ONLY
    hsv_rec = hue_analysis.hsv_to_rgb(hue_rec / 255., 128. / 255., 128. / 255.)
    r_rec = int(hsv_rec[0] * 255)
    g_rec = int(hsv_rec[1] * 255)
    b_rec = int(hsv_rec[2] * 255)

    # img_hue.putpixel((nn, mm), (r_rec, g_rec, b_rec))

    # HSV
    # hsv_rec = hue_analysis.hsv_to_rgb(hh_rec / 255., ss_rec / 255., vv_rec / 255.)
    # r_rec = int(hsv_rec[0] * 255)
    # g_rec = int(hsv_rec[1] * 255)
    # b_rec = int(hsv_rec[2] * 255)



    # img_hsv.putpixel((nn, mm), (r_rec, g_rec,b_rec))

    return [r_rec, g_rec, b_rec]


while True:


    ret, px = cap.read()
    assert ret

    for mm in range(height):
        buff[mm]=[encode_decode(rgb) for rgb in px[mm]]






    cv.imshow('frame', buff)
    if cv.waitKey(1) == ord('q'):
        break
    print('dd')






cap.release()
cv.destroyAllWindows()
