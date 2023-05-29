import bitstring



def verify_verilog_huffman_codes(file_name, verbose):
    with open(f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\clv\\input.txt', "r") as  my_file:
    # with open(f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\encoder_workstation\\canonical_codes_{file_name}.txt', "r") as  my_file:
    # with open(f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\decoder_workstation\\canonical_codes_{file_name}.txt', "r") as  my_file:
            data = my_file.read().split('\n')


    idx = 0
    sum = 0
    cls = []
    codes = {}
    if verbose:
        print('codes = {')
    for el in data:
        if(len(el) > 2):
            symbol = int(el[:9], 2)
            cl = int(el[9 : 21], 2)
            code = el[-cl:]

            if cl> 0 :
                cls.append(cl)


            if cl > 0:
                sum += 1/pow(2, cl)
                # print(f'idx:{idx}, symbol:{symbol}, cl:{cl}, code:{code}')

                d9_bit_symb = bitstring.BitArray(f"uint9={symbol}").bin
                if verbose:
                    print(f"'{d9_bit_symb}' : '{code}',")


                codes[d9_bit_symb] = code

                idx += 1
    if verbose:
        print('}')


        if 'cl' in file_name:
            print(cls[:19])
        else:
            print(sorted(cls))


    assert sum == 1
    if verbose:
        print(sum)
    print("all good")
    return codes

def main():
    verify_verilog_huffman_codes('ll',1)
    # verify_verilog_huffman_codes('distance',1)
    # verify_verilog_huffman_codes('cl_ll',1)
    # verify_verilog_huffman_codes('cl_distance',1)


if __name__ == '__main__':
    main()