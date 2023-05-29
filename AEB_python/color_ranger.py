"""

in block_filtering you are asking each block, what is your contribution to all the peaks except the common one.
then we filter out a certain percentage of the most significant ones.
it gives you the blocks with useful information in them. The problem is we don't know which of the filtered
blocks are more useful for us. some blocks may be including items with hues apart from the common hue yet
of no interest for us. e.g. a river.
to get around this problem, as a next step, we ask every cropped image, what is your contribution to the
 peaks within a certain hue range (of course outside the common-hue-range)?

one cropped image might say: I contain 95% of the pixels whose hues have formed non-zero value in the
 distribution ( of course outside the common hues range).

so we pick a number of blocks from block_filtering, and next, we find the color range (outside the common) to which they contribute.


for every cropped image:
    for every color_range outside the common hue range:
        evaluate the union of the cropped image to the histogram of full frame for the color_range




BASED ON 360 degrees:

RED: 55
320 : 360 | 0 : 15

ORANGE: 25
15: 40

YELLOW: 30
40 : 70

GREEN: 90
70 : 160

BLUE: 105
160: 265

PURPLE: 55
265: 320



in a block:
how much variation of hue/sat/value exist?


"""

import cv2
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import detection
import copy
from matplotlib import colors
from matplotlib.patches import Rectangle

import mo_toolkit
from g_toolkit import *
from base_points import *
from statsmodels.stats.weightstats import DescrStatsW



hue_color_ranges = [
    [int(0 * 180 / 360), int(40 * 180 / 360)],  # ORANGE 28.33
    [int(40 * 180 / 360), int(70 * 180 / 360)],  # YELLOW
    [int(70 * 180 / 360), int(160 * 180 / 360)],  # GREEN
    [int(160 * 180 / 360), int(265 * 180 / 360)],  # BLUE
    [int(265 * 180 / 360), int(320 * 180 / 360)],  # PURPLE
    [int(320 * 180 / 360), int(360 * 180 / 360)]  # RED
]


def get_st_for_hue_mags(hue_mag_pairs_for_hue_range):
    hues = [x[0] for x in hue_mag_pairs_for_hue_range]
    weights_union_mag = [x[1] for x in hue_mag_pairs_for_hue_range]

    ret = 0.0
    if len(weights_union_mag) == 0:
        return ret

    if max(weights_union_mag) != 0:
        ret = DescrStatsW(hues, weights=weights_union_mag, ddof=0).var

    if not(ret >= 0 ):
        asd =3
    return ret

def get_most_significant_block_idxs(blocks_overall_contribution_mags, non_dominated_block_idxs, top_blocks_count):

    """
    sort blocks_overall_contribution_mags from highest to lowest

    ALG 1)

    start from top of the sorted blocks_overall_contribution_mags
    if is non dominated, pick it
    continue until you
        - either fill top_blocks_count
        - or you run out of non dominated blocks


    do you still need more?

        start from the top again
        pick first ones until you fill top_blocks_count




    """



    # ret = non_dominated_block_idxs
    #
    # if len(non_dominated_block_idxs) > top_blocks_count:
    #     # pick highest mags among the non_dominated ones
    #     ret_mags =  [blocks_overall_contribution_mags[x] for x in ret]
    #     ret_mags_argsort = np.argsort(ret_mags)
    #
    #     counter = 0
    #     while len(ret) > top_blocks_count:
    #         ret.pop(ret_mags_argsort[counter])
    #         counter += 1
    #
    #
    # elif len(non_dominated_block_idxs) < top_blocks_count:
    #     # add from blocks_overall_contribution_mags
    #     most_significant_block_idxs = np.argsort(-np.asarray(blocks_overall_contribution_mags))
    #
    #     counter = 0
    #     while len(non_dominated_block_idxs) < top_blocks_count:
    #         item = most_significant_block_idxs[counter]
    #         if item not in ret:
    #             ret.append(item)
    #         counter += 1
    #
    # else :
    #     ret = non_dominated_block_idxs


    """
    ALG 2)
    dominated_needed = max(0 , top_blocks_count - non_dominated_block_counts)
    total_needed = top_blocks_count
    
    for i:
        if (total_needed > 0):
            if (non dominated):
                pick i
                total_needed -= 1;
                
            else (dominated)
                if (dominated_needed > 0)
                    pick i
                    dominated_needed -= 1
                    
        if total_needed == 0:
            break
            

    """
    ret = []
    most_significant_block_idxs = np.argsort(-np.asarray(blocks_overall_contribution_mags))

    dominated_needed = max(0, top_blocks_count - len(non_dominated_block_idxs))
    total_needed = top_blocks_count

    for idx, block_idx in enumerate(most_significant_block_idxs):

        if (total_needed > 0):
            if (block_idx in non_dominated_block_idxs):
                ret.append(block_idx)
                total_needed -= 1
            else:
                if (dominated_needed > 0):
                    ret.append(block_idx)
                    dominated_needed -= 1
                    total_needed -= 1

        if total_needed == 0:
            break


    return ret


def range_colors(img_bgr,
                 hue_bins_to_remove_percentage,
                 # min_value,
                 blur_param,
                 crop_count,
                 top_blocks_count,
                 vs
                 ):
    sum_bpu = vs['sum_bpu']
    color_system = vs['color_system']
    bpu_r = vs['bpu_r']
    bpu_g = vs['bpu_g']
    bpu_b = vs['bpu_b']
    # gray_config = vs['gray_config']
    # hue_min = vs['hue_min']
    # hue_max = vs['hue_max']




    num_dec = 1
    num_objs = 2
    Archive = []





    sum_bpu_max = vs['sum_bpu']

    img_hsv = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2HSV)

    # hues = img_hsv[:, :, 0].flatten()
    # plt.hist(hues)
    # plt.show()

    """
    mask pixels with low Value
    """
    # vals = img_hsv[:, :, 2].flatten()
    # min_val_accepted = int(np.percentile(vals, min_value_percentage))
    # lb = np.array([0, 0, min_val_accepted])
    # ub = np.array([255, 255, 255])

    # lb = np.array([0, 0, min_value])
    # ub = np.array([255, 255, 255])
    # val_included_mask = cv2.inRange(img_hsv, lb, ub)
    #
    # img_hsv = cv2.bitwise_and(img_hsv, img_hsv, mask=val_included_mask)

    if color_system == 0:
        # img_bgr = cv2.bitwise_and(img_bgr, img_bgr, mask=val_included_mask)
        img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)

    elif color_system == 3:
        # img_bgr = cv2.bitwise_and(img_bgr, img_bgr, mask=val_included_mask)
        img_gray = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2GRAY)

    # hue_hist_full_frame_after_val_filter = cv2.calcHist([img_hsv], [0], None, [180], [0, 180])
    # plt.plot(hue_hist_full_frame_after_val_filter, label='after_val_filter')
    # plt.show()

    """
    build full frame hue histogram
    """
    hue_hist_full_frame = cv2.calcHist([img_hsv], [0], None, [180], [0, 180])

    # hue_hist_full_frame[0] = 0

    remaining_pixels_count_masked = sum([x[0] for x in hue_hist_full_frame])

    assert (remaining_pixels_count_masked <= width * height)

    hue_hist_full_frame_normalized = hue_hist_full_frame / remaining_pixels_count_masked

    assert np.round(sum([x[0] for x in hue_hist_full_frame_normalized]), 0) == 1

    plt.plot(hue_hist_full_frame)
    plt.show()
    #
    # plt.plot(hue_hist_full_frame_normalized)
    # plt.title('hue_hist_full_frame_normalized')
    # plt.show()

    """
    find the to-be-excluded hues
    """

    excluded_hues, hue_excluded_mask = detection.cum_mask_all_excluded_hues(img_hsv, hue_bins_to_remove_percentage)

    excluded_hues_string=''
    for i in range(180):
        excluded_hues_string = excluded_hues_string + ('1' if i in excluded_hues else '0')

    excluded_hues_string = excluded_hues_string[::-1]
    print(f'excluded hues: {excluded_hues_string}')

    hue_included_mask = cv2.bitwise_not(hue_excluded_mask)

    hue_np_mask = np.asarray([x not in excluded_hues for x in range(180)])


    """
    
    when we want to generate basepoints, why are we filtering out pixels with excluded hues?
    many pixels with excluded hues need to be encoded and transmitted after all
    I don't see the point
    
    excluded hues only use is to find the most significant blocks
    we only need to exclude the none significant blocks from the image
    in order to produce the basepoints.
    
    
    defend:
    I build my basepoints base on the red, green, and blue values of pixels whose hue is not excluded
    
    objection:
    I don't care if the hue in excluded or not
    we are encoding those pixels anyway if they are within the most significant blocks
    so to make efficient use of or bpus, we need to biuld our basepoints based on every pixel that is being encoded
    those are every pixels within the significant blocks. regardless of their hues
    by excluding hues we are left with very few pixels which can never provide the right base
    for generating an efficient base point. that is why we need to go through recursion to fill our base points.
    
    
    """

    if color_system == 0:
        img_rgb_masked = cv2.bitwise_and(img_rgb, img_rgb, mask=hue_included_mask)
        # plt.imshow(img_rgb)
        # plt.show()

        # red_hist_full_frame = cv2.calcHist([img_rgb], [0], None, [256], [0, 256])
        # green_hist_full_frame = cv2.calcHist([img_rgb], [1], None, [256], [0, 256])
        # blue_hist_full_frame = cv2.calcHist([img_rgb], [2], None, [256], [0, 256])
        #
        # red_hist_full_frame[0] = 0
        # green_hist_full_frame[0] = 0
        # blue_hist_full_frame[0] = 0
        #
        # plt.plot(red_hist_full_frame,label='red',color='red')
        # plt.plot(green_hist_full_frame,label='green',color='green')
        # plt.plot(blue_hist_full_frame,label='blue',color='blue')
        # plt.legend()
        # plt.show()
    elif color_system == 3:
        # grey_hist_full_frame = cv2.calcHist([img_gray], [0], None, [256], [0, 256])
        # grey_hist_full_frame[0] = 0
        # plt.plot(grey_hist_full_frame, label='before')

        img_gray_masked = cv2.bitwise_and(img_gray, img_gray, mask=hue_included_mask)

        # grey_hist_full_frame[0] = 0
        # plt.plot(grey_hist_full_frame, label='after')
        # plt.legend()
        # plt.show()

    """
    1) ------------------------------------------------------------------------- HUE COMPARISON
    deduct the undesired pixels from hue_hist_full_frame
    """

    hue_hist_full_frame_deducted = copy.deepcopy(hue_hist_full_frame)

    for excluded_hue in excluded_hues:
        hue_hist_full_frame_deducted[excluded_hue] = 0

    """
    and normalize the histogram to unity
    """

    remaining_pixels_count_desired = sum([x[0] for x in hue_hist_full_frame_deducted])
    hue_hist_full_frame_deducted_normalized = hue_hist_full_frame_deducted / remaining_pixels_count_desired
    assert np.round(sum([x[0] for x in hue_hist_full_frame_deducted_normalized]), 0) == 1


    print("sum of remaining pixels:", int(remaining_pixels_count_desired))
    print("number of hues excluded:", len(excluded_hues))

    # for el in hue_hist_full_frame_deducted_normalized:
    #     print(f'hist: {el[0]}')

    """
    identify base-points for u-mapper
    """
    umapper_basepoints_r = []
    umapper_basepoints_g = []
    umapper_basepoints_b = []
    umapper_basepoints_y = []
    umapper_basepoints_h = []

    if vs['color_system'] == 0:
        red_hist_full_frame_hue_deducted = cv2.calcHist([img_rgb_masked], [0], None, [256], [0, 256])
        green_hist_full_frame_hue_deducted = cv2.calcHist([img_rgb_masked], [1], None, [256], [0, 256])
        blue_hist_full_frame_hue_deducted = cv2.calcHist([img_rgb_masked], [2], None, [256], [0, 256])

        red_hist_full_frame_hue_deducted[0] = 0
        green_hist_full_frame_hue_deducted[0] = 0
        blue_hist_full_frame_hue_deducted[0] = 0

        # plt.plot(red_hist_full_frame_hue_deducted,label='red',color='red')
        # plt.plot(green_hist_full_frame_hue_deducted,label='green',color='green')
        # plt.plot(blue_hist_full_frame_hue_deducted,label='blue',color='blue')
        #
        #
        # plt.legend()
        # plt.show()



        umapper_basepoints_r = get_umapper_basepoints(red_hist_full_frame_hue_deducted, bpu_r, 256)
        umapper_basepoints_g = get_umapper_basepoints(green_hist_full_frame_hue_deducted, bpu_g, 256)
        umapper_basepoints_b = get_umapper_basepoints(blue_hist_full_frame_hue_deducted, bpu_b, 256)

    elif vs['color_system'] == 3:

        grey_hist_full_frame_hue_deducted = cv2.calcHist([img_gray_masked], [0], None, [256], [0, 256])
        grey_hist_full_frame_hue_deducted[0] = 0

        umapper_basepoints_y = get_umapper_basepoints(grey_hist_full_frame_hue_deducted, sum_bpu, 256)

        plt.plot(grey_hist_full_frame_hue_deducted, label='y')

        # for base_point in umapper_basepoints_y:
        #     plt.plot([base_point*256, base_point*256], [0, 30],c='black')


        # plt.legend()
        # plt.show()


    elif vs['color_system'] == 4:

        umapper_basepoints_h = get_umapper_basepoints(hue_hist_full_frame_deducted, sum_bpu, 180)

    # for base_point in umapper_basepoints:
    #     plt.plot([base_point*180, base_point*180], [0, 0.03],c='black')
    #
    # plt.plot(hue_hist_full_frame_deducted_normalized, lw=0.5)
    # plt.show()

    assert width % crop_count == height % crop_count == 0
    height_cropped = int(height / crop_count)
    width_cropped = int(width / crop_count)

    fig = plt.figure()
    fig.subplots_adjust(hspace=0.4, wspace=0.4)
    fig.set_size_inches(40, 30, forward=True)

    ax_counter = 1

    hue_desired_unions_mag = np.zeros(shape=[crop_count, crop_count, len(hue_color_ranges)])
    hue_desired_unions_sd = np.zeros(shape=[crop_count, crop_count, len(hue_color_ranges)])


    blocks_width_height_idxs = []
    blocks_overall_contribution_mags = []
    blocks_overall_contribution_sds = []
    blocks_gmapper_basepoints = []

    img_hsv_ranged = copy.deepcopy(img_hsv)

    """
    we use the block's full normalizes histogram to compare with the full frame deducted and normalized hostogram.
    but then we deduct the excluded hues from the blocks histogram in order to find the g-mapper base points based on
    the given sum_bpu.
    
    """
    block_counter = 0

    for crop_idx_height in range(crop_count):

        for crop_idx_width in range(crop_count):

            cropped_img = img_hsv[
                          crop_idx_height * height_cropped: (crop_idx_height + 1) * height_cropped,
                          crop_idx_width * width_cropped: (crop_idx_width + 1) * width_cropped
                          ]

            """
            use the normalized hue histogram of the block to compare with
                the normalized deducted hue histogram of the full frame 
            """
            hue_hist_cropped_img = cv2.calcHist([cropped_img], [0], None, [180], [0, 180])

            # hue_hist_cropped_img[0] = 0

            remaining_pixels_count = sum([int(x[0]) for x in hue_hist_cropped_img])

            assert remaining_pixels_count == width_cropped * height_cropped

            hue_hist_cropped_img_normalized = hue_hist_cropped_img / remaining_pixels_count

            union_mags = copy.deepcopy(hue_hist_cropped_img_normalized)
            for i in range(union_mags.shape[0]):
                union_mags[i][0] = 0.
            # assert np.round(sum([x[0] for x in hue_hist_cropped_img_normalized]), 0) == 1




            for hue_color_range_idx, hue_color_range in enumerate(hue_color_ranges):

                hue_mag_pairs_for_hue_range = []

                cropped_img_hue_desired_union_magnitude = 0

                for hue in range(hue_color_range[0], hue_color_range[1]):

                    if hue not in excluded_hues:

                        union_mag = min(hue_hist_cropped_img_normalized[hue][0], hue_hist_full_frame_deducted_normalized[hue][0])

                        union_mags[hue] = union_mag

                        hue_mag_pairs_for_hue_range.append([hue, union_mag])

                        cropped_img_hue_desired_union_magnitude += pow(union_mag, 2)

                # cropped_img_hue_desired_union_magnitude = np.sqrt(cropped_img_hue_desired_union_magnitude / 180)

                hue_desired_unions_mag[crop_idx_height][crop_idx_width][hue_color_range_idx
                ] = cropped_img_hue_desired_union_magnitude

                """
                calculate the sd for the union values within the hue range
                """

                range_st = get_st_for_hue_mags(hue_mag_pairs_for_hue_range)
                assert range_st >= 0
                hue_desired_unions_sd[crop_idx_height][crop_idx_width][hue_color_range_idx
                ] = range_st


            blocks_width_height_idxs.append((crop_idx_height, crop_idx_width))

            blocks_overall_contribution_mag = sum(hue_desired_unions_mag[crop_idx_height][crop_idx_width])
            blocks_overall_contribution_sd = sum(hue_desired_unions_sd[crop_idx_height][crop_idx_width])

            print(f'block_counter: {block_counter}\t\tss: {blocks_overall_contribution_mag}\t\tsd: {blocks_overall_contribution_sd}')


            blocks_overall_contribution_mags.append(blocks_overall_contribution_mag)
            blocks_overall_contribution_sds.append(blocks_overall_contribution_sd)

            snew = mo_toolkit.solution(num_dec, num_objs)
            snew.dv = [block_counter]
            snew.f = [-blocks_overall_contribution_mag, -blocks_overall_contribution_sd]
            if block_counter == 0:
                Archive.append(snew)
            else:
                Archive, _ = mo_toolkit.Update_Archive(Archive, snew)


            """
            ( not needed for u-mapper)
            calculate the normalized deducted hue histogram of the block
            in order to find the g_mapper basepoints
           
            """

            # plt.plot(hue_hist_cropped_img_normalized, label='block full normalized')
            if color_system == 0:
                cropped_img_rgb = img_rgb_masked[
                              crop_idx_height * height_cropped: (crop_idx_height + 1) * height_cropped,
                              crop_idx_width * width_cropped: (crop_idx_width + 1) * width_cropped
                              ]
                red_hist_cropped_img = cv2.calcHist([cropped_img_rgb], [0], None, [256], [0, 256])
                green_hist_cropped_img = cv2.calcHist([cropped_img_rgb], [1], None, [256], [0, 256])
                blue_hist_cropped_img = cv2.calcHist([cropped_img_rgb], [2], None, [256], [0, 256])

                red_hist_cropped_img[0] = 0
                green_hist_cropped_img[0] = 0
                blue_hist_cropped_img[0] = 0


                red_gbp_high, red_gbp_medium, red_gbp_low = get_gbp_set(red_hist_cropped_img, bpu_r, 256)
                green_gbp_high, green_gbp_medium, green_gbp_low = get_gbp_set(green_hist_cropped_img, bpu_g, 256)
                blue_gbp_high, blue_gbp_medium, blue_gbp_low = get_gbp_set(blue_hist_cropped_img, bpu_b, 256)

                gbp_high =   [red_gbp_high, green_gbp_high, blue_gbp_high]
                gbp_medium = [red_gbp_medium, green_gbp_medium, blue_gbp_medium]
                gbp_low =    [red_gbp_low, green_gbp_low, blue_gbp_low]


            elif color_system == 3:
                cropped_img_gray = img_gray_masked[
                              crop_idx_height * height_cropped: (crop_idx_height + 1) * height_cropped,
                              crop_idx_width * width_cropped: (crop_idx_width + 1) * width_cropped
                              ]

                gray_hist_cropped_img = cv2.calcHist([cropped_img_gray], [0], None, [256], [0, 256])


                gray_hist_cropped_img[0] = 0
                gbp_high, gbp_medium, gbp_low = get_gbp_set(gray_hist_cropped_img, sum_bpu_max, 256)


            elif color_system == 4:

                hue_hist_cropped_img[0] = 0

                for hue in excluded_hues:
                    hue_hist_cropped_img[hue] = 0

                gbp_high, gbp_medium, gbp_low = get_gbp_set(hue_hist_cropped_img, sum_bpu_max, 180)


            blocks_gmapper_basepoints.append(
                [
                    gbp_high,
                    gbp_medium,
                    gbp_low
                ]

            )

            block_counter += 1


            #___________________ plotting
            ax = fig.add_subplot(crop_count, crop_count, ax_counter)  ##########
            #

            # block hist
            ax.plot(hue_hist_cropped_img_normalized, lw=0.5, c='green', label=f'w:{crop_idx_width}, h:{crop_idx_height}\nunion:{np.round(cropped_img_hue_desired_union_magnitude, 2)}')

            # full frame hue hist masked
            # ax.plot(hue_hist_full_frame_deducted_normalized, lw=0.5, c='blue', label="hue_hist_full_frame_deducted_normalized")

            #union mags
            # ax.plot(union_mags,lw=0.3, c='red', label = f'mag:{sum(union_mags)}, sd:{np.round(1 * sum(hue_desired_unions_sd[crop_idx_height][crop_idx_width]), 2)}')

            #
            # plt.legend()
            ax_counter += 1

    plt.legend()
    plt.show()
    #
    # plt.imshow(cv2.cvtColor(img_hsv_ranged, cv2.COLOR_HSV2RGB))
    # plt.show()

    # sns.heatmap(hue_desired_unions[:,:,-1], cmap="Blues", cbar=False)
    # plt.title('hue desired')
    # plt.show()

    """
    now we pick the blocks with most significant contributions.
    among the chosen ones, the ones with highest rank, are codded with their high sum_bpu (gmapper_basepoints_high)
    the ones with lowest rank, are codded with low sum_bpu (gmapper_basepoints_low)
    
    """

    # plt.scatter(x=blocks_overall_contribution_sds, y = blocks_overall_contribution_mags)
    # plt.show()


    non_dominated_block_idxs=[x.dv[0] for x in Archive]

    most_significant_block_idxs = get_most_significant_block_idxs(blocks_overall_contribution_mags, non_dominated_block_idxs, top_blocks_count)

    # most_significant_block_idxs = np.argsort(-np.asarray(blocks_overall_contribution_mags))[
    #                               :top_blocks_count]


    most_significant_block_idxs_string=''
    for i in range(crop_count*crop_count):
        most_significant_block_idxs_string = most_significant_block_idxs_string + ('1' if i in most_significant_block_idxs else '0')

    most_significant_block_idxs_string = most_significant_block_idxs_string[::-1]
    print(f'most_significant_block_idxs_string: {most_significant_block_idxs_string}')


    #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
    # most_significant_block_idxs = [48]
    #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1

    most_significant_block_basepoints = []
    most_significant_block_width_height_idxs = []

    for idx, most_significant_block_idx in enumerate(most_significant_block_idxs):
        relative_rank_in_3 = int(idx * 3 / len(most_significant_block_idxs))

        most_significant_block_basepoints.append(
            blocks_gmapper_basepoints[most_significant_block_idx][relative_rank_in_3]
        )
        most_significant_block_width_height_idxs.append(blocks_width_height_idxs[most_significant_block_idx])

    #     print(most_significant_block_idx,
    #           blocks_width_height_idxs[most_significant_block_idx],
    #           blocks_overall_contribution_mags[most_significant_block_idx],
    #           blocks_gmapper_basepoints[most_significant_block_idx])
    # #
    # print(most_significant_block_basepoints)

    #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
    # most_significant_block_basepoints = [[0.,  0.73828125, 0.8046875, 0.828125]]
    #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1


    """
    building the final mask based on most_significant_blocks
    """
    final_mask = np.ones(img_hsv.shape[:2], dtype="uint8")

    block_counter = 0
    for crop_idx_height in range(crop_count):

        for crop_idx_width in range(crop_count):

            if block_counter not in most_significant_block_idxs:
                # cropped_img = img_hsv_ranged[
                #               crop_idx_height * height_cropped: (crop_idx_height + 1) * height_cropped,
                #               crop_idx_width * width_cropped: (crop_idx_width + 1) * width_cropped
                #               ] = [0, 0, 0]

                cv2.rectangle(
                    final_mask,
                    (crop_idx_width * width_cropped, crop_idx_height * height_cropped),
                    ((crop_idx_width + 1) * width_cropped, (crop_idx_height + 1) * height_cropped),
                    (0, 0, 0),
                    -1)

            block_counter += 1

    # plt.imshow(cv2.cvtColor(img_hsv_ranged, cv2.COLOR_HSV2RGB))
    # plt.show()

    img_hsv_final_masked = cv2.bitwise_and(img_hsv, img_hsv, mask=final_mask)
    # plt.imshow(cv2.cvtColor(img_hsv_final_masked, cv2.COLOR_HSV2RGB))
    # plt.show()

    img_rgb_final_masked = cv2.bitwise_and(img_rgb, img_rgb, mask=final_mask)
    cv2.imwrite("./ranger_output_masked.bmp", cv2.cvtColor(img_rgb_final_masked, cv2.COLOR_RGB2BGR))



    # hue_hist_full_frame_masked = cv2.calcHist([img_hsv_final_masked], [0], None, [180], [0, 180])
    # hue_hist_full_frame_masked[0] = 0
    # plt.plot(hue_hist_full_frame, label='full')
    # plt.plot(hue_hist_full_frame_masked, label='masked')
    # plt.legend()
    # plt.show()

    to_g_mapper = {
        'most_significant_block_width_height_idxs': most_significant_block_width_height_idxs,
        'most_significant_block_basepoints': most_significant_block_basepoints,
        'crop_count': crop_count,
        'min_hue': img_hsv_final_masked[:, :, [0]].min(),
        'max_hue': img_hsv_final_masked[:, :, [0]].max(),
    }

    u_mapper_layout = {
        'most_significant_block_width_height_idxs': most_significant_block_width_height_idxs,
        'basepoints_h': umapper_basepoints_h,
        'basepoints_r': umapper_basepoints_r,
        'basepoints_g': umapper_basepoints_g,
        'basepoints_b': umapper_basepoints_b,
        'basepoints_y': umapper_basepoints_y,
        'sum_bpu': sum_bpu_max,
        'crop_count': crop_count,
        'min_hue': img_hsv_final_masked[:, :, [0]].min(),
        'max_hue': img_hsv_final_masked[:, :, [0]].max(),
    }

    blured_masked_hsv = cv2.blur(img_hsv_final_masked, (blur_param, blur_param))

    gray_blured_masked_hsv = cv2.cvtColor(blured_masked_hsv, cv2.COLOR_BGR2GRAY)

    otsu_thresh_val, otsu = cv2.threshold(gray_blured_masked_hsv, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

    canny_lower = 125  # int(max(0, 10.95 * otsu_thresh_val))
    canny_upper = 255  # int(min(255, 22 * otsu_thresh_val))

    canny_gray_blured_masked_hsv = cv2.Canny(gray_blured_masked_hsv, canny_lower, canny_upper)

    # plt.imshow(cv2.cvtColor(canny_gray_blured_masked_hsv, cv2.COLOR_GRAY2RGB))
    # plt.show()

    return img_hsv_ranged, \
           img_hsv_final_masked, \
           blured_masked_hsv, \
           canny_gray_blured_masked_hsv, \
           gray_blured_masked_hsv, \
           to_g_mapper, \
           u_mapper_layout
