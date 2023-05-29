import numpy as np
import matplotlib.pyplot as plt
import rom_toolkit as rt
from math import sin, sqrt, log, pi

sigma = 1e-18
N = 100
fun='log'

def main():


    for i in range(1, 17):
        N = int(11.02612544 + i * 1.92909238) + 1

        print(f"            {i}   :   begin")

        v = 1.0 / N
        print(f"                      PopSizeI       = 'sb{rt.float_bin(v,64)};  //{v}")


        v = 1.0 / (N - 1)
        print(f"                      inv_N_1        = 'sb{rt.float_bin(v,64)};  //{v}")


        v = 1.0 * i / 1073741824
        print(f"                      ParamCountRnd  = 'sb{rt.float_bin(v,64)};  //{v}")

        v = 2.0 / i
        print(f"                      AllpProbDamp   = 'sb{rt.float_bin(v,64)};  //{v}")

        print(f"                      end")

    # IDEAL        print(rt.get_float_bin(255.,24))
    ideals = []
    X = []
    for idx, v in enumerate(np.arange(sigma, 100, 0.1)):

        if (fun == 'sqrt'):
            ideals.append(sqrt(v))

        elif (fun == 'log'):
            ideals.append(log(v))

        X.append(v)
    plt.scatter(x=X, y=ideals, label='ideal', marker="o")




    # ROM
    X_rom = []
    rom = []
    with open(f'{fun}_table_{N}x{2*rt.Q}.mem', "w") as f:

        for i in range(N):
            x = ((2 << i) - 1) * sigma
            X_rom.append(x)
            # print(f'i={i}, {rt.float_bin(x)}, {x}')
            print(f'i={i}, {rt.float_bin(x)}, {x}, {np.log(x)}, {np.sqrt(x)}')

            if (fun == 'sqrt'):
                rom.append(sqrt(x))
                f.write(f'%s\n' % rt.float_bin(sqrt(x), rt.Q).replace('_',''))


            elif (fun == 'log'):
                rom.append(log(x))
                f.write(f'%s\n' % rt.float_bin(log(x), rt.Q).replace('_',''))

    plt.scatter(x=X_rom, y=rom, label='ROM', marker="+")



    # TEST
    inters = []
    inter_x = []
    for idx, b in enumerate(np.arange(sigma, 60, 0.1)):

        two_to_idx = int(1. + (b / sigma))  # = 7 = 2^2 + remainder
        idx = two_to_idx.bit_length() - 2

        a = ((2 << idx) - 1) * sigma
        dist_mult = (1 / (2 << idx)) * (1./sigma)
        v = rom[idx] + ((b - a) * dist_mult) * (rom[idx + 1] - rom[idx])

        inters.append(v)
        inter_x.append(b)
        # print(b, idx, inter_sqrte)


    plt.scatter(x=inter_x,y=inters, label='INTER',s=1, c='yellow')




    b = 0.75


    two_to_idx = int(1.+(b/sigma)) # = 7 = 2^2 + remainder
    # print(two_to_idx)

    # print(rt.float_bin(two_to_idx))

    idx = two_to_idx.bit_length() - 2
    print(idx)
    """
    i=2,    0000000000000000000000000000000000000000000000000000000000000000_0000000000010011101010010010101000110000010101010011001001100010, 0.00030000000000000003
            0000000000000000000000000000000000000000000000000000000000000000_0000000000101011111010001011110000010110100111000010001110111000
    
            0000000000000000000000000000000000000000000000000000000000000111_1011001100110011001100110011001100110011001100110100000000000000
    """
    plt.legend()
    plt.show()
if __name__ == '__main__':

    main()
