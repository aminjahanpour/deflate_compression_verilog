
            

module lzss (
    input                                               clk,
    input                                               reset
);


// Output Files

integer                                                 D6_output_file_ll_symbols_mem;
integer                                                 D6_output_file_distance_symbols_mem;
integer                                                 D6_output_file_lzss_output_mem;
integer                                                 D_output_file_general;



// Reset
always @(posedge reset) begin

    reset_rams_flag                         = 1;


    ram_reset_counter_cap                   = 1;





    
    D6_output_file_ll_symbols_mem =                                $fopen("./dumps/D6_output_file_ll_symbols_mem.txt", "w");
D6_output_file_distance_symbols_mem =                                $fopen("./dumps/D6_output_file_distance_symbols_mem.txt", "w");
D6_output_file_lzss_output_mem =                                $fopen("./dumps/D6_output_file_lzss_output_mem.txt", "w");
D_output_file_general =                                $fopen("./dumps/D_output_file_general.txt", "w");


end


            