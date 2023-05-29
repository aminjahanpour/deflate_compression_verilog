import shutil
import thesmuggler
import glob
import os

from shared_local_params import shared_local_params
from modules import  modules


import bitstring
deflate_tables = thesmuggler.smuggle("C:\\Users\\jahan\\Desktop\\verilog\\deflate\\AEB_python\\deflate_tables.py")


def get_mem_by_name(name, module):
    for mem_key in list(modules[module]['rams'].keys()):
        if mem_key == name:
            return modules[module]['rams'][mem_key]


def build_modules():

    for module in modules.keys():
        for source_file in modules[module]['source_files']:
            try:
                shutil.copyfile(
                    f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module}\\chapters\\{source_file}',
                    f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\source_codes\\{source_file}')
            except:
                pass

    folder = f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules'
    for filename in os.listdir(folder):
        file_path = os.path.join(folder, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except:
            pass

    for module in modules.keys():
        os.mkdir(os.path.join("C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules", f"{module}"))
        os.mkdir(os.path.join(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module}", "chapters"))
        os.mkdir(os.path.join(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module}", "dumps"))

        for source_file in modules[module]['source_files']:
            shutil.copyfile(
                f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\source_codes\\{source_file}',
                f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module}\\chapters\\{source_file}')

    # os.mkdir(os.path.join("C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules", "workstation"))

    my_file = open('C:\\Users\\jahan\\Desktop\\verilog\\deflate\\AEB_python\\lz_raw_data.txt', 'r')
    data = my_file.read()

    with open('C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\lzss\\input_bitstring.mem', 'w') as ff:
        for data_idx, el in enumerate(data):
            ff.write(bitstring.BitArray(f"uint8={ord(el)}").bin)
            ff.write('\n')

    shared_local_params['input_bytes_count'] = data_idx + 1

    with open('C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\lzss\\ll_table.mem', 'w') as ff:
        for i in range(3, 258):
            info = deflate_tables.get_symbol_and_offset_bits_from_LL_table(i)
            ff.write(info['full_bitstream_for_verilog'])
            ff.write('\n')

    with open('C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\lzss\\distance_table.mem', 'w') as ff:
        for i in range(1, 1000):
            info = deflate_tables.get_symbol_and_offset_bits_from_distance_table(i)
            ff.write(info['full_bitstream_for_verilog'])
            ff.write('\n')


    with open('C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\decoder\\ll_symbols_table.mem', 'w') as ff:
        for i in range(257, 286):
            info = deflate_tables.get_length_and_offset_from_symbol(i)
            ff.write(info['verilog_string'])
            ff.write('\n')

    with open('C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\decoder\\distance_symbols_table.mem', 'w') as ff:
        for i in range(0, 30):
            info = deflate_tables.get_distance_and_offset_from_symbol(i)
            ff.write(info['verilog_string'])
            ff.write('\n')











    for module_key in modules.keys():
        module = modules[module_key]

        with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module_key}\\chapters\\00_reset.v", "w") as reset_file:

            integer_output_files = ''
            output_files_paths = ''

            for file in module['output_files']:
                integer_output_files += f"integer                                                 {file};\n"
                output_files_paths += f'{file} =                                $fopen("./dumps/{file}.txt", "w");\n'

            ram_reset_counter_cap = 1;
            for mem in module['rams'].keys():
                ram = module['rams'][mem]
                if ram['resetable'] > 0:
                    mem_depth = shared_local_params[ram['depth']]
                    if mem_depth in shared_local_params.keys():
                        mem_depth = shared_local_params[shared_local_params]
                    ram_reset_counter_cap = max(ram_reset_counter_cap, mem_depth)


            a = f"""
            

module {module_key} (
    input                                               clk,
    input                                               reset
);


// Output Files

{integer_output_files}


// Reset
always @(posedge reset) begin

    reset_rams_flag                         = 1;


    ram_reset_counter_cap                   = {ram_reset_counter_cap};





    
    {output_files_paths}

end


            """

            reset_file.write(a)

        with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module_key}\\chapters\\01_declarations.v", "w") as declarations_file:

            declarations_file.write(f"\n")

            for local_param in shared_local_params.keys():
                declarations_file.write(f"localparam                                              {local_param}                      = {shared_local_params[local_param]};\n")

            declarations_file.write(f"\n")

        with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module_key}\\chapters\\02_rams.v", "w") as myfile:

            for mem_name in module['rams'].keys():

                el = module['rams'][mem_name]


                initial_file_str = 0 if el['source_file'] == 0 else el['source_file']


                if el['source_file'] != 0:
                    assert el['resetable'] == 0


                a = f"""

    reg                                             \t\t{mem_name}_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]\t\t\t\t{mem_name}_mem_read_addr      ;
    wire                [{el['width']} - 1 	 : 0]    \t\t\t\t{mem_name}_mem_read_data      ;
    reg                                             \t\t{mem_name}_mem_write_enable   ;
    reg                 [address_len - 1 : 0]\t\t\t\t{mem_name}_mem_write_addr     ;
    reg                 [{el['width']} - 1 	 : 0]    \t\t\t\t{mem_name}_mem_write_data     ;

    memory_list #(
        .mem_width({el['width']}),
        .address_len(address_len),
        .mem_depth({el['depth']}),
        .initial_file({initial_file_str})

    ) {mem_name}_mem(
        .clk(clk),
        .r_en(  {mem_name}_mem_read_enable),
        .r_addr({mem_name}_mem_read_addr),
        .r_data({mem_name}_mem_read_data),
        .w_en(  {mem_name}_mem_write_enable),
        .w_addr({mem_name}_mem_write_addr),
        .w_data({mem_name}_mem_write_data)
    );




                """
                myfile.write(a)

        with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module_key}\\chapters\\03_A_reset_rams.v","w") as myfile:

            write_address_loops = ""
            write_data_loops = ""
            write_enable_loops = ""
            write_disable_loops = ""

            for mem_name in module['rams'].keys():
                el = module['rams'][mem_name]


                if el['resetable'] > 0:

                    write_address_loops += f"""
    
                        if (counter_ram_reset_A < {el['depth']}) begin
                            {mem_name}_mem_write_addr                  = counter_ram_reset_A;
                        end
    
                    """

                    write_data_loops += f"""
    
                          if (counter_ram_reset_A < {el['depth']}) begin
                              {mem_name}_mem_write_data                  = {0 if el['resetable'] == 1 else 'counter_ram_reset_A'};
                          end
    
                      """

                    write_enable_loops +=  f"""
    
                          if (counter_ram_reset_A < {el['depth']}) begin
                              {mem_name}_mem_write_enable                  = 1;
                          end
    
                      """

                    write_disable_loops +=  f"""
    
                          if (counter_ram_reset_A < {el['depth']}) begin
                              {mem_name}_mem_write_enable                  = 0;
                          end
    
                      """



            ram_reset_layout = f"""
            reg                                                     reset_rams_flag                     = 0;
    
            reg                 [q_full - 1 : 0]                    ram_reset_counter_cap;
    
            reg                 [q_full - 1 : 0]                    counter_ram_reset_A                 = 0;
            reg                 [q_full - 1 : 0]                    lagger_ram_reset_A                  = 0;
    
    
            always @(negedge clk) begin
                if (reset_rams_flag == 1) begin
                    lagger_ram_reset_A = lagger_ram_reset_A + 1;
    
                    if (lagger_ram_reset_A == 1) begin
    
    
                        {write_address_loops}
    
    
                    end else if (lagger_ram_reset_A == 2) begin
    
    
                        {write_data_loops}
    
    
                    end else if (lagger_ram_reset_A == 3) begin
    
    
                        {write_enable_loops}
    
    
                    end else if (lagger_ram_reset_A == 4) begin
    
    
                        {write_disable_loops}
    
    
    
                    end else if (lagger_ram_reset_A == 5) begin
    
                        if (counter_ram_reset_A < ram_reset_counter_cap - 1) begin
                            counter_ram_reset_A = counter_ram_reset_A + 1;
    
                        end else begin
                            counter_ram_reset_A = 0;
                            reset_rams_flag = 0;
                            $display("A: finished reset_rams_flag");
    
    
                            // setting and launching the first flag
                            {module['starter']}
                        end
    
    
                        lagger_ram_reset_A = 0;
    
                    end 
                end
            end
    
            """



            myfile.write(ram_reset_layout)

        with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module_key}\\chapters\\99_end_of_module.v","w") as myfile:
            myfile.write("""
            

endmodule


            """)

        with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module_key}\\{module_key}_tb.v","w") as tb_file:
            a = f"""
`timescale 1ps/1ps
`default_nettype none
`define DUMPSTR(x) `"x.vcd`"


module {module_key}_tb ();



    reg                                                     clk;
    reg                                                     reset;



    {module_key} {module_key}_inst (
        .clk(clk),
        .reset(reset)
    );


    always #1 clk = ~clk;


    parameter DURATION = {module['duration']};

    initial begin
        clk = 0;

        #1;
        $display("\\n running...");

        reset = 0;
        #1;
        reset = 1;
        
    end


    initial begin

        #(DURATION);
        $display("End of simulation at:%d", $time);
        $finish;

    end


endmodule



"""
            tb_file.write(a)

        with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module_key}\\run_{module_key}.py", "w") as py_file:

            x_term = '{x}'
            a = f"""
import shutil
import os

from os import listdir
from os.path import isfile, join

try:
    os.remove("./.sconsign.dblite")
    os.remove("./{module_key}_tb.out")
    os.remove("./hardware.out")
except:
    pass

with open('./{module_key}.v', "w") as g:

    for chapter in [f'./chapters/{x_term}' for x in listdir("./chapters/")]:
        with open(chapter, "r") as f:
            v1 = f.readlines()

            for line in v1:
                g.write(line)


os.system('cls')
os.system('apio sim')

            """
            py_file.write(a)

        with open(f"C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module_key}\\apio.ini", "w") as ini_file:
            a = """[env]
board = icestick


            """
            ini_file.write(a)


        for utility in module['utilities']:
            shutil.copyfile(
                f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\utilities\\{utility}.v',
                f'C:\\Users\\jahan\\Desktop\\verilog\\deflate\\modules\\{module_key}\\{utility}.v')



    print('\nmodules build successfully')

if __name__ == '__main__':
    build_modules()


