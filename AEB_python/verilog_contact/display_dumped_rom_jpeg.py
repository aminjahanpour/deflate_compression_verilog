import numpy as np
from PIL import Image
import t_mapper_decoder
import copy
import cv2
import matplotlib.pyplot as plt


dim = 8

file_name = "../../verilog/aeb/jpeg_dumps/output_file_eight_by_eight_grouped.txt"
# file_name = "../verilog/aeb/jpeg_dumps/output_file_two_by_two_grouped.txt"

from g_toolkit import *


sum_bpu =24


r_mask = (2 ** 8 - 1) << (8 + 8)
g_mask = (2 ** 8 - 1) << 8
b_mask = 2 ** 8 - 1


data_file = open(file_name, 'r').read()

data = [[(int(x, 2) & r_mask) >> 16,(int(x, 2) & g_mask) >> 8, (int(x, 2) & b_mask)  ] for x in data_file.split('\n')[:-1]]

chunks = [data[i:i + (dim*dim)] for i in range(0, len(data), (dim*dim))]


full_ycbyr_frame = np.zeros(shape=(height, width, 3), dtype='uint8')

stacked = []

for idx, chunk in enumerate(chunks):
    # if dim == 8:
    a = np.asarray(chunk, dtype='uint8').reshape((dim, dim, 3))

    # elif dim == 2:
    #     a = np.asarray(chunk, dtype='uint8').reshape((8, 8, 3))

    stacked.append(a)



block_counter = 0
for crop_idx_height in range(int(height / dim)):

    for crop_idx_width in range(int(width / dim)):
        full_ycbyr_frame[
                      crop_idx_height * dim: (crop_idx_height + 1) * dim,
                      crop_idx_width * dim: (crop_idx_width + 1) * dim
                      ] = stacked[block_counter]

        block_counter+=1




# img_bgr_raw = cv2.imread('shuttle.png')
# img_bgr_raw = cv2.resize(img_bgr_raw, (width, height), interpolation=cv2.INTER_NEAREST)
#
# img_ycrcb = cv2.cvtColor(img_bgr_raw, cv2.COLOR_BGR2YCrCb)

# plt.plot((img_ycrcb[:,:,0]).flatten(), lw= 0.5)
# plt.plot((full_ycbyr_frame[:, :, 0]).flatten())
# plt.scatter(x=img_ycrcb[:,:,1], y = full_ycbyr_frame[:,:,2])
#
# # plt.hist(img_ycbcr[:, :, 0].flatten())
#
# plt.show()

# to save ycbcr you need to switch cr with cb
a = copy.deepcopy(full_ycbyr_frame[:, :, 1])
full_ycbyr_frame[:, :, 1] = full_ycbyr_frame[:, :, 2]
full_ycbyr_frame[:, :, 2] = a
# cv2.imwrite("./y_cb_cr_fromverilog.bmp", cv2.cvtColor(full_ycbyr_frame, cv2.COLOR_YCrCb2BGR))

plt.imshow(cv2.cvtColor(cv2.cvtColor(full_ycbyr_frame, cv2.COLOR_YCrCb2BGR), cv2.COLOR_BGR2RGB)   )
plt.show()