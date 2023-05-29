import rom_toolkit as rt
import numpy as np

with open('random.mem', "w") as f:
    for i in range(41):
        f.write(f'{rt.float_bin(100 * np.random.normal(), 64).replace("_", "")}\n')

