import numpy as np
import matplotlib.pyplot as plt

Q = 64

# '0000000000000000000000000000000000000000000000000000000000010010_0110101110110001101110111011010101010101000101100000000000000000')


def q_to_qhex(q_value):
    # whole, dec = q_value.split("_")
    #
    # whole = '0b' + whole + int(Q/2) * '0'
    #
    # ret = whole + dec
    # ret = int(whole, 2)



    # ret = int(whole, 2) << int(Q/2)
    # ret += int(dec, 2)

    # ret = int(whole, 2)
    #
    # for i in range(Q):
    #     ret += int(dec[i]) * 1. / (2 ** (i+1))
    if (q_value[0] == '0'):
        ret = '0b' + q_value.replace('_', '')
    else:
        ret = '-0b' + q_value.replace('_', '')


    ret = int(ret, 2)

    return hex(ret)
def zero_comp(a, n, left=True):
    ret = a
    if len(ret) < n:
        while len(ret) < n:
            if left:
                ret = "0" + ret
            else:
                ret = ret + "0"
    return ret


def flip_bits(bits):
    ret = ''
    for i in range(len(bits)):
        if bits[i] == '0':
            ret = ret + '1'
        else:
            ret = ret + '0'
    return ret


def get_float_bin(number, places=Q):
    ret = float_bin(number, places)
    ret =f'    localparam                 [q_full - 1 : 0]                    two_fifty_five                      = \'b{ret};   //  {number}'

    return ret
def float_bin(number, places=Q):
    """
    this function is used to feed the rom reader in verilog
    in verilog, the sign bit is included

    :param number:
    :param places:
    :return:
    """

    if (number >= 0.0):
        whole = int(number)
        dec = number - whole


        res = zero_comp(bin(whole).lstrip("0b"), places) + "_"

        res = res + dec_to_bin(dec, places)

    else:
        whole = int(number)
        dec =  whole - number

        whole_str = zero_comp(bin(-whole).lstrip("0b"), places)
        whole_str = flip_bits(whole_str)



        # whole_str = '1' + whole_str

        dec_str = dec_to_bin(dec, places)
        dec_str = flip_bits(dec_str)


        # assert len(whole_str) -1 == len(dec_str) == Q

        res = whole_str + '_' + dec_str

    return res




def dec_to_bin(n, places):
    b = n
    l = []

    m = 0

    while m < places:

        b = b * 2

        if b == 1.0:
            l.append('1')
            break

        else:
            if b > 1:
                l.append('1')
                b = b - 1

            else:
                l.append('0')

        m += 1


    return zero_comp(''.join(l), places, False)

def main():
    n = 1.92909238

    sdf=q_to_qhex('0000000000000000000000000000000000000000000000000000000000010010_0110101110110001101110111011010101010101000101100000000000000000')

    a = 0.00000001
    c = 1.0
    N = 200
    step = 1/N

    # IDEAL
    lns = []
    X = []
    for idx, v in enumerate(np.arange(a, c, 0.00001)):
        lns.append(np.log(v))
        X.append(v)
    plt.scatter(x=X, y=lns, label='ideal', s=1)


    # ROM
    rom = []
    x = []
    with open("log_rom.mem", "w") as f:
        for idx, v in enumerate(np.arange(a, c, step)):
            # print(float_bin(abs(np.log(v)), Q), idx, v)
            f.write(f'%s\n' %  q_to_qhex(float_bin(abs(np.log(v)), Q))[2:])

            rom.append(np.log(v))
            x.append(v)
        plt.scatter(x=x,y=rom, label='ROM',s=20)


    # TEST
    inters = []
    inter_x = []
    for b in np.arange(a, c - 0.1,  0.0001):
        #
        # b = 0.22345
        # print("log(b)", np.log(b))

        idx = int((b-a) * N / (c-a))

        x_idx_ = x[idx]
        x_idxp1_ = x[idx+1]

        x_idx = a + idx * step
        x_idxp1 = x_idx + step

        assert abs(x_idx_ - x_idx) < 0.00000000000000001



        # inter_log = rom[idx] + ((b - x_idx)/step) * (rom[idx + 1] - rom[idx])
        inter_log = rom[idx] + ((b - x_idx)*N) * (rom[idx + 1] - rom[idx])

        inters.append(inter_log)
        inter_x.append(b)
        # print(idx, inter_log)
    plt.scatter(x=inter_x,y=inters, label='INTER',s=2)

    # plt.plot(inters)

    plt.legend()
    plt.show()
if __name__ == '__main__':
    main()
