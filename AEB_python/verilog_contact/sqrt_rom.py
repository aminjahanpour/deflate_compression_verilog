import numpy as np
import matplotlib.pyplot as plt
import rom_toolkit as rt
from math import sin, sqrt
def main():

    a = 0.0
    c = 50.0
    N = 200
    step = (c-a)/N

    # IDEAL
    sqrtes = []
    X = []
    for idx, v in enumerate(np.arange(a, c, 0.1)):
        sqrtes.append(sqrt(v))
        X.append(v)
    plt.scatter(x=X, y=sqrtes, label='ideal', marker="o")


    # ROM
    rom = []
    x = []
    with open(f'sqrt_table_{N+1}x{2*rt.Q}.mem', "w") as f:
        for idx, v in enumerate(np.arange(a, (c + step), step)):

            # print(rt.float_bin(sqrt(v ), rt.Q), idx, v)

            f.write(f'%s\n' %  rt.q_to_qhex(rt.float_bin(sqrt(v), rt.Q))[2:])

            rom.append(sqrt(v))
            x.append(v)

        plt.scatter(x=x, y=rom, label='ROM',marker="+")


    # TEST
    inters = []
    inter_x = []
    for b in np.arange(a, c,  0.001):
        #
        # b = 0.22345
        # print("log(b)", np.log(b))

        idx = int((b-a) * N / (c-a))

        x_idx_ = x[idx]
        x_idxp1_ = x[idx+1]

        x_idx = a + idx * step
        x_idxp1 = x_idx + step

        assert abs(x_idx_ - x_idx) < 0.00000000000000001


        inter_sqrte = rom[idx] + ((b - x_idx)/step) * (rom[idx + 1] - rom[idx])

        inters.append(inter_sqrte)
        inter_x.append(b)
        print(b, idx, inter_sqrte)


    plt.scatter(x=inter_x,y=inters, label='INTER',s=1, c='yellow')


    plt.legend()
    plt.show()
if __name__ == '__main__':
    main()
