import matplotlib.pyplot as plt
from g_toolkit import *
import ast
# rows = 112*80
# cols = 24
#
# file_name = f'../verilog/aeb/zeros_{rows}_{cols}.mem'
# with open(file_name, 'w') as foo:
#     for i in range(rows):
#         foo.write(('0'*cols) + '\n')
#
#
# exit()

fig = plt.figure()
fig.subplots_adjust(hspace=0.4, wspace=0.4)
fig.set_size_inches(40, 30, forward=True)

# with open('../verilog/aeb/output_file_hue_hist_blocks.txt', 'r') as file:
with open('../verilog/aeb/output_file_union_mags.txt', 'r') as file:

    data = file.read()

    # reading integers for BLOCKS HISTS
    # data = [int(x) for x in data.split('\n')[:-1]]


    # reading floats for UNION MAGS
    data = [ast.literal_eval(x) for x in data.split('\n')[:-1]]


block_counter = 0
ax_counter = 1
# assert sum(data) == 320*240
# assert len(data) == 256*8*8
sum = 0
for crop_idx_height in range(8):

    for crop_idx_width in range(8):


        ax = fig.add_subplot(8, 8, ax_counter)  ##########
        # ax.set_ylim([0, 0.01])

        slice = data[block_counter * 180: (block_counter + 1) * 180]

        print(f'block: {ax_counter - 1}, len:{len(slice)}, sum:{np.sum(slice)}')

        sum = sum + np.sum(slice)

        assert(len(slice) == 180)
        # assert(np.sum(slice) == (width * height) / 64)
        # print((sum(slice) == 1200)
        ax.plot(slice)
        block_counter += 1

        # ax.plot(hue_hist_full_frame_deducted_normalized, lw=0.5, c='blue', )
        # ax.plot(union_mags,lw=0.3, c='red', label = f'mag:{sum(union_mags)}, sd:{np.round(1 * sum(hue_desired_unions_sd[crop_idx_height][crop_idx_width]), 2)}')
        # #
        # plt.legend()
        ax_counter += 1

print(f'collected {sum} pixels. data contained {np.sum(data)} pixels. width * height={width * height}')
plt.show()

"""
        val width_cropped = vs.width / crop_count

        block_row :         Int = block_width_height_idx / crop_count
        block_col :         Int = block_width_height_idx % crop_count

        pixel_block_row:    Int = pixel_counter / width_cropped
        pixel_block_col:    Int = pixel_counter % width_cropped

        pixel_global_row :  Int = pixel_block_row +  block_row * height_cropped
        pixel_global_col :  Int = pixel_block_col + block_col * width_cropped

"""