
            

module writer (
    input                                               clk,
    input                                               reset
);


// Output Files

integer                                                 H_output_file_general;
integer                                                 H4_output_file_bit_stream_mem;



// Reset
always @(posedge reset) begin

    reset_rams_flag                         = 1;


    ram_reset_counter_cap                   = 286;





    
    H_output_file_general =                                $fopen("./dumps/H_output_file_general.txt", "w");
H4_output_file_bit_stream_mem =                                $fopen("./dumps/H4_output_file_bit_stream_mem.txt", "w");


end


            