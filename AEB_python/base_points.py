import copy



def get_gbp_set(hist, max_bpu, hist_ub):
    max_range_counts = 2 ** max_bpu
    ret_high, _ = identify_gmapper_basepoints(hist, max(2, max_range_counts), hist_ub)
    ret_medium, _ = identify_gmapper_basepoints(hist, max(2, max_range_counts-2), hist_ub)
    ret_low, _ = identify_gmapper_basepoints(hist, max(2, max_range_counts-4), hist_ub)

    return ret_high, ret_medium, ret_low


def identify_gmapper_basepoints(hist, max_range_counts, hist_ub):
    """
    this function takes a histogram and a max range_counts and returns
    a set of g_mapper base points.

    it will return max_range_counts-1 integers at max. (the output is actually float numbers relative to hist_ub)

    the output values are the hue values on which the g_mapper will collapse on.

    for example, if the output of this function is: [92, 132]
    it translate into below collapsing layout:

    0.000 <- [0   .. 91 ] - inclusive
    0.333 <- [92  .. 131] - inclusive
    0.666 <- [132 .. 179] - inclusive

    it also implies that the final chosen range_counts is 3
    """
    remaining_pixels_count = sum([int(x[0]) for x in hist])

    if remaining_pixels_count != 0:
        normalized_hist = hist / remaining_pixels_count

        ret = [0.]

        ret = ret + get_basepoints_in_range(hist, remaining_pixels_count, max_range_counts, 0, hist_ub, hist_ub)

    else:
        normalized_hist = None
        ret = [x / max_range_counts for x in range(max_range_counts)]

    return ret, normalized_hist




def get_basepoints_in_range(hist, remaining_pixels_count, max_range_counts, hue_range_start, hue_range_end, hist_ub):
    """
    this function returns as many basepoint as it can find using the provided cap
    """

    ret = []

    sum_ = 0

    cap = remaining_pixels_count / max_range_counts


    for hue in range(hue_range_start, hue_range_end):

        sum_ += hist[hue][0]

        if sum_ >= cap:

            ret.append(1.*hue/hist_ub)

            sum_ = 0

        if len(ret) == max_range_counts-1:
            break

    return ret                                      # [x*256 for x in ret]



def get_umapper_basepoints(hist, sum_bpu, hist_ub):
    """
    this function takes a histogram and sum_bpu and returns
    2**sum_bpu number of u_mapper base-points.

    it will return normalized float values.

    the output values are the hue values on which the u_mapper will collapse on.


    Strategy 1)
    first we try the strategy of g_mapper: we get a number of basepoints. it is
    quite liekly that we still need more basepoints.

    Strategy 2)
    next: we repeat the strategy of the gm_mapper for every range in between
    the existing basepoints. starting from the shortest range.

    Strategy 3)
    finally: if we still need more basepoints, we produce them by simply halving
    the ranges. we keep halving until we reach 2**sum_bpu base points.
    """

    remaining_pixels_count = sum([int(x[0]) for x in hist])

    range_counts = 2 ** sum_bpu

    if remaining_pixels_count != 0:


        # Strategy 1) get the g_mapper base point for the whole range:
        ret, _ = identify_gmapper_basepoints(hist, range_counts, hist_ub)


        # Strategy 2) get g-base-points between existing base-points.
        # if len(ret) < range_counts:
        #
        #     basepoints_distances = [ret[t + 1] - ret[t] for t in range(len(ret) - 1)]
        #     sorted_basepoints_distances = sorted(basepoints_distances, reverse=True)
        #     for i in range(len(ret)-1):
        #         bp_idx = basepoints_distances.index(sorted_basepoints_distances[i])
        #
        #         hue_range_start = int(ret[bp_idx] * hist_ub)
        #         hue_range_end = int(ret[bp_idx+1] * hist_ub)
        #
        #         # get a new normalized histogram for this range
        #         sub_hist = copy.deepcopy(hist)
        #         sub_hist_total_pixels_in_range = sum([int(x[0]) for x in sub_hist[hue_range_start: hue_range_end]])
        #         if sub_hist_total_pixels_in_range == 0:
        #             continue
        #
        #         sum_hist_norm = sub_hist / sub_hist_total_pixels_in_range
        #         ret = ret + get_basepoints_in_range(sum_hist_norm, 0.5, 2, hue_range_start, hue_range_end, hist_ub)
        #         ret.sort()
        #
        #         if len(ret) == range_counts:
        #             return ret


        # Strategy 3) start halving until you get enough base-points
        if len(ret) < range_counts:
            basepoints_distances = [ret[t + 1] - ret[t] for t in range(len(ret) - 1)]
            sorted_basepoints_distances = sorted(basepoints_distances, reverse=True)

            for i in range(len(ret) - 1):
                bp_idx = basepoints_distances.index(sorted_basepoints_distances[i])
                hue_range_start = ret[bp_idx]
                hue_range_end = ret[bp_idx+1]

                ret = ret + [0.5 * (hue_range_start + hue_range_end)]
                ret.sort()

                if len(ret) == range_counts:
                    return ret

    else:
        # below is equivalent to T-mapper
        ret = [x  /range_counts for x in range(range_counts)]


    assert len(ret) == range_counts


    return ret


