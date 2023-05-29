import cv2
import numpy as np
import matplotlib.pyplot as plt
cap = cv2.VideoCapture(0)

import detection
import color_ranger

import g_mapper_encoder
import g_mapper_decoder

from main import vs

while (1):
    _, frame = cap.read()

    # _, blured_masked_hsv  ,canny_gray_masked_hsv, final_included_mask = detection.mask_and_canny(frame,
    #                                                                       min_value_percentage=20,
    #                                                                       hue_bins_to_remove_percentage=80,
    #                                                                          blur_param=3)

    # img_hsv_ranged, img_hsv_final_masked, blured_masked_hsv, canny_gray_blured_masked_hsv, gray_blured_masked_hsv = color_ranger.range_colors(frame,
    #                                                                        hue_bins_to_remove_percentage=90,
    #                                                                        min_value=int(
    #                                                                            2 * 255 / 365),
    #                                                                        blur_param=2,
    #                                                                        crop_count=8)
    #
    # cv2.imshow('frame', frame)
    # cv2.imshow('ranged', cv2.cvtColor(img_hsv_ranged, cv2.COLOR_HSV2BGR))
    # cv2.imshow('final_masked', cv2.cvtColor(img_hsv_final_masked, cv2.COLOR_HSV2BGR))
    # cv2.imshow('canny', cv2.cvtColor(canny_gray_blured_masked_hsv, cv2.COLOR_GRAY2RGB))
    # cv2.imshow('gray_blured_masked_hsv', cv2.cvtColor(gray_blured_masked_hsv, cv2.COLOR_GRAY2RGB))

    img_bgr_raw = cv2.resize(frame, (320, 240), interpolation=cv2.INTER_NEAREST)

    img_hsv_ranged, img_hsv_final_masked, blured_masked_hsv, canny_gray_blured_masked_hsv, gray_blured_masked_hsv, g_mapper_layout, u_mapper_layout = color_ranger.range_colors(
        img_bgr_raw,
        hue_bins_to_remove_percentage=95,
        min_value=int(2 * 255 / 365),
        blur_param=2,
        crop_count=8,
        top_blocks_percentage=0.15,
        vs=vs
    )


    g_full_encoded_buffer = g_mapper_encoder.encoder(cv2.cvtColor(img_bgr_raw, cv2.COLOR_BGR2RGB), g_mapper_layout, vs)

    full_rgb_frame = g_mapper_decoder.decoder(
        g_full_encoded_buffer,
        g_mapper_layout,
        vs)

    cv2.imshow('frame', frame)
    cv2.imshow('ranged', cv2.cvtColor(full_rgb_frame, cv2.COLOR_RGB2BGR))

    k = cv2.waitKey(5) & 0xFF
    if k == 27:
        break

cv2.destroyAllWindows()
cap.release()
