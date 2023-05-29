
            

module decoder (
    input                                               clk,
    input                                               reset
);


// Output Files

integer                                                 O10_output_file_decoded_bits_mem;



// Reset
always @(posedge reset) begin

    reset_rams_flag                         = 1;


    ram_reset_counter_cap                   = 1;





    
    O10_output_file_decoded_bits_mem =                                $fopen("./dumps/O10_output_file_decoded_bits_mem.txt", "w");


end


            