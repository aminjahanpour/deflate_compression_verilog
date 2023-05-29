import bitstring



def verify_pre_bitstream(file_name):
    with open(f"../../verilog/deflate/{file_name}", "r") as my_file:
        data = my_file.read().split('\n')[:-1]

    counts_org =[bitstring.BitArray(f"bin={x[:5]}").uint for x in  data]
    values_org = [int(x[-int(x[:5], 2):], 2) for x in  data]


    return [counts_org, values_org]


def verify_writer():


    with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\writer\\dumps\\H4_output_file_bit_stream_mem.txt", "r") as my_file:
        data = my_file.read().split('\n')[:-1]

    with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\writer\\dumps\\H_output_file_general.txt", "r") as my_file:
        las_word_bits_count = int(my_file.read().split('\n')[:-1][0], 2)

    verilog_bitstream = ''.join(data[:-1])

    assert len(verilog_bitstream) % 8 == 0

    verilog_bitstream += data[-1][:las_word_bits_count]

    verilog_chunks = [verilog_bitstream[i:i + 8] for i in range(0, len(verilog_bitstream), 8)]



    with open("C:\\Users\\jahan\\Desktop\\verilog\\deflate\\writer\\input.txt") as input_file:
        pre_bitstream = input_file.read().split('\n')[:-1]


    full_bitstream = ''

    for el in pre_bitstream:
        length = el[:5]
        full_bitstream += el[-int(length, 2):]


    # if len(full_bitstream) % 8 != 0:
    #     while len(full_bitstream) % 8 != 0:
    #         full_bitstream += '0'

    input_chunks  =  [full_bitstream[i:i + 8] for i in range(0, len(full_bitstream), 8)]

    test = [x==y for x,y in zip(verilog_chunks,input_chunks)]

    assert all(test)
    cv=4

def main():
    verify_writer()

    counts_org, values_org = verify_pre_bitstream('recode/input.txt')
    counts_recode, values_recode = verify_pre_bitstream('recode/dumps/I3_output_file_recode_pre_bitstream_mem.txt')

    assert sum(counts_recode) < sum(counts_org)
    df=4

if __name__ == '__main__':
    main()