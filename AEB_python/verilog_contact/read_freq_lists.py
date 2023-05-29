import bitstring

def intepert(bits):
    df=4
    return {
        'symbol' : int(bits[0:9],2) ,
        'freq' : int(bits[9:21],2),
        'used' : bits[21],
        'node' : bits[40]
        }



first_freq_list_file = open("../../verilog/deflate/dumps/E4_output_file_freq_list_ll_mem.txt", "r")
second_freq_list_file = open("../../verilog/deflate/dumps/F4_output_file_clrec_freq_list_ll_mem.txt", "r")

first_data = first_freq_list_file.read().split('\n')
second_data = second_freq_list_file.read().split('\n')

assert len(first_data) == len(second_data)


for i in range(len(first_data)-1):
    a= intepert(first_data[i])
    b= intepert(second_data[i])
    assert a['symbol'] == b['symbol']
    if not (a['freq'] | b['freq'] == 0):
        print(f"{a['symbol']}, a_freq: {a['freq']}, b_freq: {b['freq']}")






sdf=4

"""
the second freqs do not respect the first freqs
does python have this issue as well?


is there an issue in reusing the huffman code in verilog?
"""