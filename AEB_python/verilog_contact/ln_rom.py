import numpy as np
import matplotlib.pyplot as plt
import rom_toolkit as rt
def main():
    n = 1.92909238

    sdf= rt.q_to_qhex('0000000000000000000000000000000000000000000000000000000000010010_0110101110110001101110111011010101010101000101100000000000000000')

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
            f.write(f'%s\n' %  rt.q_to_qhex(rt.float_bin(abs(np.log(v)), rt.Q))[2:])

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
