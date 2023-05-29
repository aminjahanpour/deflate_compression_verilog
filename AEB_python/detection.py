import cv2
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from g_toolkit import *

import copy



def cum_mask_all_excluded_hues(img_hsv, hue_bins_to_remove_percentage):

    hue_hist = cv2.calcHist([img_hsv], [0], None, [180], [0, 180])

    hue_bins_sorted = list(np.argsort([-int(x[0]) for x in hue_hist]))


    hue_thresh_idx = 0
    sum_pixels = 0
    while 1:
        sum_pixels += hue_hist[hue_bins_sorted[hue_thresh_idx]][0]
        if sum_pixels >= width * height * hue_bins_to_remove_percentage / 100:
            break
        hue_thresh_idx += 1

    excluded_hues = hue_bins_sorted[:(hue_thresh_idx + 1)]

    for idx, hue_not_accepted in enumerate(excluded_hues):

        lower_band_mask = np.array([hue_not_accepted, 0, 0])
        upper_band_mask = np.array([hue_not_accepted, 256, 256])

        if idx == 0:
            hue_excluded_mask = cv2.inRange(img_hsv, lower_band_mask, upper_band_mask)
        else:
            hue_excluded_mask = cv2.add(hue_excluded_mask, cv2.inRange(img_hsv, lower_band_mask, upper_band_mask))

    return excluded_hues, hue_excluded_mask


def mask_and_canny(img, min_value_percentage, hue_bins_to_remove_percentage, blur_param):
    img = cv2.resize(img, (width, height), interpolation=cv2.INTER_NEAREST)

    img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    hues = img_hsv[:, :, 0].flatten()
    # # sats = img_hsv[:,:,1].flatten()
    vals = img_hsv[:, :, 2].flatten()
    #
    # plt.hist(hues)
    # plt.show()
    # # plt.hist(sats)
    # # plt.show()
    # plt.hist(vals)
    # plt.show()

    hue_hist = cv2.calcHist([img_hsv], [0], None, [180], [0, 180])

    hue_bins_sorted = list(np.argsort([-int(x[0]) for x in hue_hist]))

    min_val_accepted = int(np.percentile(vals, min_value_percentage))

    hue_thresh_idx = 0
    sum_pixels = 0
    while 1:
        sum_pixels += hue_hist[hue_bins_sorted[hue_thresh_idx]][0]
        if sum_pixels >= width * height * hue_bins_to_remove_percentage / 100:
            break
        hue_thresh_idx += 1

    for idx, hue_not_accepted in enumerate(hue_bins_sorted[:(hue_thresh_idx+1)]):

        lower_band_mask = np.array([hue_not_accepted, 0, 0])
        upper_band_mask = np.array([hue_not_accepted, 255, 255])

        if idx == 0:
            hue_excluded_mask = cv2.inRange(img_hsv, lower_band_mask, upper_band_mask)
        else:
            hue_excluded_mask = cv2.add(hue_excluded_mask, cv2.inRange(img_hsv, lower_band_mask, upper_band_mask))

    lower_band_mask = np.array([0, 0, min_val_accepted])
    upper_band_mask = np.array([255, 255, 255])
    val_included_mask = cv2.inRange(img_hsv, lower_band_mask, upper_band_mask)

    val_excluded_mask = cv2.bitwise_not(val_included_mask)

    final_excluded_mask = cv2.bitwise_or(val_excluded_mask, hue_excluded_mask)

    final_included_mask = cv2.bitwise_not(final_excluded_mask)

    masked_hsv = cv2.bitwise_and(img_hsv, img_hsv, mask=final_included_mask)
    # masked_hsv = img_hsv


    blured_masked_hsv = cv2.blur(masked_hsv, (blur_param, blur_param))

    gray_blured_masked_hsv = cv2.cvtColor(blured_masked_hsv, cv2.COLOR_BGR2GRAY)

    otsu_thresh_val, otsu = cv2.threshold(gray_blured_masked_hsv, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

    canny_lower = 150 # int(max(0, 10.95 * otsu_thresh_val))
    canny_upper = 255 #int(min(255, 22 * otsu_thresh_val))

    canny_gray_blured_masked_hsv = cv2.Canny(gray_blured_masked_hsv, canny_lower, canny_upper)

    return masked_hsv, blured_masked_hsv, canny_gray_blured_masked_hsv, final_included_mask




def blocks_filter(img,
                  hue_bins_to_remove_percentage,
                  min_value,
                  blur_param,
                  crop_count):

    img = cv2.resize(img, (width, height), interpolation=cv2.INTER_NEAREST)

    img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # hues = img_hsv[:, :, 0].flatten()
    # plt.hist(hues)
    # plt.show()


    """
    mask pixels with low Value
    """
    vals = img_hsv[:, :, 2].flatten()
    # min_val_accepted = int(np.percentile(vals, min_value_percentage))
    # lb = np.array([0, 0, min_val_accepted])
    # ub = np.array([255, 255, 255])

    lb = np.array([0, 0, min_value])
    ub = np.array([255, 255, 255])
    val_included_mask = cv2.inRange(img_hsv, lb, ub)


    # sats = img_hsv[:,:,1].flatten()
    # min_sat_accepted = int(np.percentile(sats, min_sat_percentage))
    # lb = np.array([0, min_sat_accepted, 0])
    # ub = np.array([255, 255, 255])

    # lb = np.array([0, 0, min_sat_percentage])
    # ub = np.array([255, 255, 255])
    # sat_included_mask = cv2.inRange(img_hsv, lb, ub)

    # plt.hist(sats, label='sats', bins=20)
    # plt.hist(vals, label='vals', bins=20)
    # plt.legend()
    # plt.show()


    # plt.imshow(cv2.cvtColor(img_hsv, cv2.COLOR_HSV2RGB))
    # plt.show()


    # hue_hist_full_frame_before_val_filter = cv2.calcHist([img_hsv], [0], None, [180], [0, 180])
    # plt.plot(hue_hist_full_frame_before_val_filter, label='before_val_filter')
    # plt.show()

    img_hsv = cv2.bitwise_and(img_hsv, img_hsv, mask=val_included_mask)

    # hue_hist_full_frame_after_val_filter = cv2.calcHist([img_hsv], [0], None, [180], [0, 180])
    # plt.plot(hue_hist_full_frame_after_val_filter, label='after_val_filter')
    # plt.show()


    # plt.imshow(cv2.cvtColor(img_hsv, cv2.COLOR_HSV2RGB))
    # plt.show()

    """
    build full frame hue histogram
    """
    hue_hist_full_frame = cv2.calcHist([img_hsv], [0], None, [180], [0, 180])

    hue_hist_full_frame[0] = 0

    remaining_pixels_count_masked = sum([x[0] for x in hue_hist_full_frame])

    assert (remaining_pixels_count_masked <= width * height)

    hue_hist_full_frame_normalized = hue_hist_full_frame / remaining_pixels_count_masked

    assert np.round(sum([x[0] for x in hue_hist_full_frame_normalized]), 0 ) == 1

    # plt.plot(hue_hist_full_frame)
    # plt.show()

    # plt.plot(hue_hist_full_frame_normalized)
    # plt.title('hue_hist_full_frame_normalized')
    # plt.show()


    """
    find the to-be-excluded hues
    """

    excluded_hues, hue_excluded_mask = cum_mask_all_excluded_hues(img_hsv, hue_bins_to_remove_percentage)

    hue_included_mask = cv2.bitwise_not(hue_excluded_mask)

    rev_hue_masked_hsv = cv2.bitwise_and(img_hsv, img_hsv, mask=hue_excluded_mask)


    """
    1) ------------------------------------------------------------------------- HUE COMPARISON
    deduct the undesired pixels from hue_hist_full_frame
    """

    hue_hist_full_frame_deducted = copy.deepcopy(hue_hist_full_frame)
    hue_hist_full_frame_rev_deducted = copy.deepcopy(hue_hist_full_frame)

    # for excluded_hue in excluded_hues:
    #     hue_hist_full_frame_deducted[excluded_hue] = 0

    for i in range(180):
        if i in excluded_hues:
            hue_hist_full_frame_deducted[i] = 0
        else:
            hue_hist_full_frame_rev_deducted[i] = 0

    """
    and normalize the histogram to unity
    """

    remaining_pixels_count_desired = sum([x[0] for x in hue_hist_full_frame_deducted])
    hue_hist_full_frame_deducted_normalized = hue_hist_full_frame_deducted / remaining_pixels_count_desired
    assert np.round(sum([x[0] for x in hue_hist_full_frame_deducted_normalized]), 0 ) == 1

    remaining_pixels_count_undesired = sum([x[0] for x in hue_hist_full_frame_rev_deducted])
    hue_hist_full_frame_rev_deducted_normalized = hue_hist_full_frame_rev_deducted / remaining_pixels_count_undesired
    assert np.round(sum([x[0] for x in hue_hist_full_frame_rev_deducted_normalized]), 0 ) == 1

    assert remaining_pixels_count_desired + remaining_pixels_count_undesired == remaining_pixels_count_masked

    """
    hue_hist_full_frame_deducted_normalized is the normalized histogram to which we will compare 
    the hue histogram of cropped images.
    """

    """
    2) ------------------------------------------------------------------------- SATURATION COMPARISON
    same process as above but here we work with saturation.
    generate full frame histogram of hue-masked image
    this will be our reference for comparison
    
    I need the Saturation histogram of the pixels with excluded Hue
    this reveals the distribution of Saturation among the common-hue pixels
    it tells us what Saturation distribution is expected from common-hue pixels
    
    then we can compare the saturation distribution of cropped images with this distribution.
    if the distributions are similar, it means that the cropped image has similar saturation distribution 
    to the common-hue pixels. this is another clue for us to decide if this cropped image contains an anomaly.
     
    """


    saturation_hist_rev_hue_masked_full_frame = cv2.calcHist([rev_hue_masked_hsv], [1], None, [256], [0, 256])

    # need to discard the 0s resulted from masking
    saturation_hist_rev_hue_masked_full_frame[0] = 0

    remaining_pixels_count = int(sum([x[0] for x in saturation_hist_rev_hue_masked_full_frame]))
    assert (remaining_pixels_count <= width * height)

    saturation_hist_rev_hue_masked_full_frame_normalized = saturation_hist_rev_hue_masked_full_frame / remaining_pixels_count


    # plt.plot(saturation_hist_rev_hue_masked_full_frame_normalized, label='saturation_hist_rev_hue_masked_full_frame_normalized')
    # plt.plot(cv2.calcHist([img_hsv], [1], None, [256], [0, 256]), label='original image')
    # plt.legend()
    # plt.show()

    """
    3) ------------------------------------------------------------------------- VALUE COMPARISON
    same logic used for sat
    
    """
    value_hist_rev_hue_masked_full_frame = cv2.calcHist([rev_hue_masked_hsv], [2], None, [256], [0, 256])
    value_hist_rev_hue_masked_full_frame[0] = 0
    # plt.plot(value_hist_rev_hue_masked_full_frame)
    # plt.show()

    remaining_pixels_count = int(sum([x[0] for x in value_hist_rev_hue_masked_full_frame]))
    assert (remaining_pixels_count <= width * height)

    value_hist_rev_hue_masked_full_frame_normalized = value_hist_rev_hue_masked_full_frame / remaining_pixels_count



    assert width % crop_count == height % crop_count == 0
    height_cropped = int(height / crop_count)
    width_cropped = int(width / crop_count)

    fig = plt.figure()
    fig.subplots_adjust(hspace=0.4, wspace=0.4)
    fig.set_size_inches(40, 30, forward=True)

    ax_counter = 1

    hue_desired_unions = np.zeros(shape=[crop_count, crop_count])
    hue_undesired_unions = np.zeros(shape=[crop_count, crop_count])

    crop_image_rank = np.zeros(shape=[crop_count, crop_count])

    # sat_unions = np.zeros(shape=[crop_count, crop_count])
    # val_unions = np.zeros(shape=[crop_count, crop_count])

    for crop_idx_height in range(crop_count):

        for crop_idx_width in range(crop_count):

            cropped_img = img_hsv[
                          crop_idx_height * height_cropped : (crop_idx_height + 1) * height_cropped,
                          crop_idx_width * width_cropped: (crop_idx_width + 1) * width_cropped
            ]

            # cropped_img = cv2.blur(cropped_img, (blur_param, blur_param))


            hue_hist_cropped_img = cv2.calcHist([cropped_img], [0], None, [180], [0, 180])

            hue_hist_cropped_img[0] = 0

            remaining_pixels_count = sum([int(x[0]) for x in hue_hist_cropped_img])


            # plt.plot(hue_hist_cropped_img)
            # plt.show()

            # sat_hist_cropped_img = cv2.calcHist([cropped_img], [1], None, [256], [0, 256])
            # val_hist_cropped_img = cv2.calcHist([cropped_img], [2], None, [256], [0, 256])

            assert remaining_pixels_count <= width_cropped * height_cropped


            hue_hist_cropped_img_normalized = hue_hist_cropped_img / remaining_pixels_count
            assert np.round(sum([x[0] for x in hue_hist_cropped_img_normalized]), 0) == 1

            # sat_hist_cropped_img_normalized = sat_hist_cropped_img / (width_cropped * height_cropped)
            # assert np.round(sum([x[0] for x in sat_hist_cropped_img_normalized]), 0) == 1
            #
            # val_hist_cropped_img_normalized = val_hist_cropped_img / (width_cropped * height_cropped)
            # assert np.round(sum([x[0] for x in val_hist_cropped_img_normalized]), 0) == 1



            cropped_img_hue_desired_union_magnitude = 0
            cropped_img_hue_undesired_union_magnitude = 0

            for i in range(180):


                if i in excluded_hues:
                    cropped_img_hue_undesired_union_magnitude += pow(
                        min(hue_hist_cropped_img_normalized[i][0], hue_hist_full_frame_rev_deducted_normalized[i][0]), 2)

                else:
                    cropped_img_hue_desired_union_magnitude +=  pow(
                        min(hue_hist_cropped_img_normalized[i][0], hue_hist_full_frame_deducted_normalized[i][0]), 2)



            cropped_img_hue_desired_union_magnitude = np.sqrt(cropped_img_hue_desired_union_magnitude / 180)
            cropped_img_hue_undesired_union_magnitude = np.sqrt(cropped_img_hue_undesired_union_magnitude / 180)

            hue_desired_unions[crop_idx_height][crop_idx_width] = cropped_img_hue_desired_union_magnitude #- cropped_img_hue_undesired_union_magnitude
            hue_undesired_unions[crop_idx_height][crop_idx_width] = cropped_img_hue_undesired_union_magnitude

            # cropped_img_sat_union_magnitude = 0
            # for i in range(len(saturation_hist_rev_hue_masked_full_frame_normalized)):
            #     cropped_img_sat_union_magnitude += pow(min(sat_hist_cropped_img_normalized[i][0], saturation_hist_rev_hue_masked_full_frame_normalized[i][0]), 2)
            #
            # cropped_img_sat_union_magnitude = np.sqrt(cropped_img_sat_union_magnitude / 256)
            #
            # sat_unions[crop_idx_height][crop_idx_width] = cropped_img_sat_union_magnitude
            #
            #
            # cropped_img_val_union_magnitude = 0
            # for i in range(len(value_hist_rev_hue_masked_full_frame_normalized)):
            #     cropped_img_val_union_magnitude += pow(min(val_hist_cropped_img_normalized[i][0], value_hist_rev_hue_masked_full_frame_normalized[i][0]), 2)
            #
            # cropped_img_val_union_magnitude = np.sqrt(cropped_img_val_union_magnitude / 256)
            #
            # val_unions[crop_idx_height][crop_idx_width] = cropped_img_val_union_magnitude




            ax = fig.add_subplot(crop_count, crop_count, ax_counter)  ##########

            ax.plot(hue_hist_cropped_img_normalized,lw=0.5, c='green', label=f'w:{crop_idx_width}, h:{crop_idx_height}\nunion:{np.round(cropped_img_hue_desired_union_magnitude, 2)}')
            ax.plot(hue_hist_full_frame_deducted_normalized,lw=0.5, c='blue', )
            # ax.plot(hue_hist_full_frame_rev_deducted_normalized,lw=0.5, c='red', )
            # ax.plot(hue_hist_full_frame_normalized,lw=0.3, c='cyan', )
            #
            # plt.legend()
            ax_counter += 1

    fig.tight_layout()

    plt.legend()
    plt.show()

    crop_image_rank = hue_desired_unions - 2 * hue_undesired_unions

    sns.heatmap(hue_desired_unions, cmap="Blues", cbar=False)
    plt.title('hue desired')
    plt.show()
    #
    # sns.heatmap(hue_undesired_unions, cmap="Blues", cbar=False)
    # plt.title('hue undesired')
    # plt.show()
    #
    # sns.heatmap(crop_image_rank, cmap="Blues", cbar=False)
    # plt.title('crop_image_rank')
    # plt.show()

    # sns.heatmap(-val_unions, cmap="Blues")
    # plt.title('-val')
    # plt.show()
    #
    # sns.heatmap(hue_unions-sat_unions-val_unions, cmap="Blues")
    # plt.title('all')
    # plt.show()
    sdf=4


