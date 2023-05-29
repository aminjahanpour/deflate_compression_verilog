import numpy as np
from g_toolkit import *
from matplotlib import pyplot as plt

dim = 2
data = list(range(width * height))
chunks = [data[i:i + (dim*dim)] for i in range(0, len(data), (dim*dim))]



full_ycbyr_frame = np.zeros(shape=(int(height / dim) , int(width / dim), dim, dim), dtype='uint8')

stacked = []

for idx, chunk in enumerate(chunks):
    # if dim == 8:
    a = np.asarray(chunk, dtype='uint8').reshape((dim, dim))

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




df=5