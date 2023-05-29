import numpy as np

zig_zag_uvs = [
    (0, [0, 0]),
    (1, [0, 1]),
    (8, [1, 0]),
    (16, [2, 0]),
    (9, [1, 1]),
    (2, [0, 2]),
    (3, [0, 3]),
    (10, [1, 2]),
    (17, [2, 1]),
    (24, [3, 0]),
    (32, [4, 0]),
    (25, [3, 1]),
    (18, [2, 2]),
    (11, [1, 3]),
    (4, [0, 4]),
    (5, [0, 5]),
    (12, [1, 4]),
    (19, [2, 3]),
    (26, [3, 2]),
    (33, [4, 1]),
    (40, [5, 0]),
    (48, [6, 0]),
    (41, [5, 1]),
    (34, [4, 2]),
    (27, [3, 3]),
    (20, [2, 4]),
    (13, [1, 5]),
    (6, [0, 6]),
    (7, [0, 7]),
    (14, [1, 6]),
    (21, [2, 5]),
    (28, [3, 4]),
    (35, [4, 3]),
    (42, [5, 2]),
    (49, [6, 1]),
    (56, [7, 0]),
    (57, [7, 1]),
    (50, [6, 2]),
    (43, [5, 3]),
    (36, [4, 4]),
    (29, [3, 5]),
    (22, [2, 6]),
    (15, [1, 7]),
    (23, [2, 7]),
    (30, [3, 6]),
    (37, [4, 5]),
    (44, [5, 4]),
    (51, [6, 3]),
    (58, [7, 2]),
    (59, [7, 3]),
    (52, [6, 4]),
    (45, [5, 5]),
    (38, [4, 6]),
    (31, [3, 7]),
    (39, [4, 7]),
    (46, [5, 6]),
    (53, [6, 5]),
    (60, [7, 4]),
    (61, [7, 5]),
    (54, [6, 6]),
    (47, [5, 7]),
    (55, [6, 7]),
    (62, [7, 6]),
    (63, [7, 7])
]

jpeg_y_quantization_table = np.array(

    [
        [16, 11, 10, 16, 24, 40, 51, 61],
        [12, 12, 14, 19, 26, 58, 60, 55],
        [14, 13, 16, 24, 40, 57, 69, 56],
        [14, 17, 22, 29, 51, 87, 80, 62],
        [18, 22, 37, 56, 68, 109, 103, 77],
        [24, 35, 55, 64, 81, 104, 113, 92],
        [49, 64, 78, 87, 103, 121, 120, 101],
        [72, 92, 95, 98, 112, 100, 103, 99]
    ]

)

jpeg_c_quantization_table = np.array(
    [
        [17,	18,	24,	47,	99,	99,	99,	99],
        [18,	21,	26,	66,	99,	99,	99,	99],
        [24,	26,	56,	99,	99,	99,	99,	99],
        [47,	66,	99,	99,	99,	99,	99,	99],
        [99,	99,	99,	99,	99,	99,	99,	99],
        [99,	99,	99,	99,	99,	99,	99,	99],
        [99,	99,	99,	99,	99,	99,	99,	99],
        [99,	99,	99,	99,	99,	99,	99,	99]
    ]
)


def sub_sample_plane(arr, pixel_counts):
    x_count = int(pixel_counts)
    y_count = int(pixel_counts)

    sumsampled_array = np.empty(shape=arr.shape, dtype='uint8')

    block_counter = 0

    block_counts_in_height = int(arr.shape[0] / y_count)
    block_counts_in_width = int(arr.shape[1] / x_count)

    for crop_idx_height in range(block_counts_in_height):

        for crop_idx_width in range(block_counts_in_width):
            cropped_img = arr[
                          crop_idx_height * y_count: (crop_idx_height + 1) * y_count,
                          crop_idx_width * x_count: (crop_idx_width + 1) * x_count
                          ]

            # sub_samppled_crop = cropped_img

            sumsampled_array[
            crop_idx_height * y_count: (crop_idx_height + 1) * y_count,
            crop_idx_width * x_count: (crop_idx_width + 1) * x_count
            ] = int(round(np.mean(cropped_img), 0))

            block_counter = block_counter + 1

    return sumsampled_array


def get_bits_needed(max_positive_value):
    if max_positive_value < 1:
        bits_needed = 1
    else:
        bits_needed = np.log2(max_positive_value)

    if bits_needed < 1:
        bits_needed = 1

    if bits_needed == int(bits_needed):
        bits_needed = int(bits_needed)
    else:
        bits_needed = int(int(bits_needed) + 1)

    # if bits_needed == 0:
    #     sdfdf=4
    return int(bits_needed)