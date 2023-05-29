import bitstring

my_file = open('C:\\Users\\jahan\\Desktop\\verilog\\deflate\\AEB_python\\lz_raw_data.txt', 'r')
data = my_file.read()

input_data = []
for data_idx, el in enumerate(data):
    input_data.append(ord(el))
    # ff.write(bitstring.BitArray(f"uint8={ord(el)}").bin)
    # ff.write('\n')
v=3


my_file = open('C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\decoder\\dumps\\O10_output_file_decoded_bits_mem.txt', 'r')
decoded_data = [int(x,2) for x in my_file.read().split('\n')[:-1] if x != 8*'x']

for i in range(len(decoded_data)):
    print(f'{i}: org: {input_data[i]}, decoded: {decoded_data[i]}            match:{input_data[i]==decoded_data[i]}')

assert input_data == decoded_data
print("all good")