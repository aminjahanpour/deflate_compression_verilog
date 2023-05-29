
            

module compiler (
    input                                               clk,
    input                                               reset
);


// Output Files

integer                                                 K7_output_file_header_pre_bitstream_mem;
integer                                                 K_output_file_general;



// Reset
always @(posedge reset) begin

    reset_rams_flag                         = 1;


    ram_reset_counter_cap                   = 2860;





    
    K7_output_file_header_pre_bitstream_mem =                                $fopen("./dumps/K7_output_file_header_pre_bitstream_mem.txt", "w");
K_output_file_general =                                $fopen("./dumps/K_output_file_general.txt", "w");


end


            