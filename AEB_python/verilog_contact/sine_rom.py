import numpy as np
import matplotlib.pyplot as plt
import rom_toolkit as rt
from math import sin

fun = 'sine'
def main():
    n = 1.92909238

    sdf= rt.q_to_qhex('0000000000000000000000000000000000000000000000000000000000010010_0110101110110001101110111011010101010101000101100000000000000000')

    a = 0.0
    c = 90.0
    N = 50
    step = (c-a)/N

    # IDEAL
    sines = []
    X = []
    for idx, v in enumerate(np.arange(a, c, 0.1)):
        sines.append(sin(v * np.pi / 180.0))
        X.append(v)
    plt.scatter(x=X, y=sines, label='ideal', marker="o")


    # ROM
    rom = []
    x = []
    with open(f'{fun}_table_{N+1}x{2*rt.Q}.mem', "w") as f:
        for idx, v in enumerate(np.arange(a, (c + step), step)):

            # print(rt.float_bin(sin(v * np.pi / 180.0), rt.Q), idx, v)

            # f.write(f'%s\n' % rt.q_to_qhex(rt.float_bin(sin(v * np.pi / 180.0), rt.Q))[2:])
            f.write(f'%s\n' % rt.float_bin(sin(v * np.pi / 180.0), rt.Q).replace('_', ''))

            rom.append(sin(v * np.pi / 180.0))
            x.append(v)

        plt.scatter(x=x, y=rom, label='ROM',marker="+")


    # TEST
    inters = []
    inter_x = []
    for b in np.arange(a, c,  0.01):
        #
        # b = 0.22345
        # print("log(b)", np.log(b))

        idx = int((b-a) * N / (c-a))

        x_idx_ = x[idx]
        x_idxp1_ = x[idx+1]

        x_idx = a + idx * step
        x_idxp1 = x_idx + step

        assert abs(x_idx_ - x_idx) < 0.00000000000000001


        inter_sine = rom[idx] + ((b - x_idx)/step) * (rom[idx + 1] - rom[idx])

        inters.append(inter_sine)
        inter_x.append(b)
        print(b, idx, inter_sine)


    plt.scatter(x=inter_x,y=inters, label='INTER',s=1, c='yellow')


    plt.legend()
    plt.show()
if __name__ == '__main__':
    main()
