import rom_toolkit as rt

file_name = f'../aeb/enum_64_48.mem'
with open(file_name, 'w') as foo:
    for i in range(64):
        foo.write(rt.zero_comp(bin(i).lstrip("0b"), 48) + '\n')
