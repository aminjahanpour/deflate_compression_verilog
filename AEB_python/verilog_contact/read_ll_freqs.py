import bitstring

with open("../../verilog/deflate/dumps/E2_output_file_ll_freq_mem.txt", "r") as  my_file:
        data = my_file.read().split('\n')

for idx, el in enumerate(data):
    if (len(el) > 0):
        f = int(el)
        if f>0:
            print(idx, f)