
            

module cl_decode (
    input                                               clk,
    input                                               reset
);


// Output Files

integer                                                 M_output_file_general;
integer                                                 M4_output_file_cl_decode_cl_ll_mem;
integer                                                 M5_output_file_cl_decode_cl_distance_mem;
integer                                                 M6_output_file_cl_decode_extracted_cl_symbols_mem;



// Reset
always @(posedge reset) begin

    reset_rams_flag                         = 1;


    ram_reset_counter_cap                   = 286;





    
    M_output_file_general =                                $fopen("./dumps/M_output_file_general.txt", "w");
M4_output_file_cl_decode_cl_ll_mem =                                $fopen("./dumps/M4_output_file_cl_decode_cl_ll_mem.txt", "w");
M5_output_file_cl_decode_cl_distance_mem =                                $fopen("./dumps/M5_output_file_cl_decode_cl_distance_mem.txt", "w");
M6_output_file_cl_decode_extracted_cl_symbols_mem =                                $fopen("./dumps/M6_output_file_cl_decode_extracted_cl_symbols_mem.txt", "w");


end


            