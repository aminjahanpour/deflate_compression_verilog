
            

module clcoding (
    input                                               clk,
    input                                               reset
);


// Output Files

integer                                                 G4_output_file_pre_bitstream;
integer                                                 G5_output_file_symbols_mem;
integer                                                 G6_output_file_general;



// Reset
always @(posedge reset) begin

    reset_rams_flag                         = 1;


    ram_reset_counter_cap                   = 1;





    
    G4_output_file_pre_bitstream =                                $fopen("./dumps/G4_output_file_pre_bitstream.txt", "w");
G5_output_file_symbols_mem =                                $fopen("./dumps/G5_output_file_symbols_mem.txt", "w");
G6_output_file_general =                                $fopen("./dumps/G6_output_file_general.txt", "w");


end


            