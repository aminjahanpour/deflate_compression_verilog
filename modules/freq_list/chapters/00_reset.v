
            

module freq_list (
    input                                               clk,
    input                                               reset
);


// Output Files

integer                                                 C2_output_file_freq_mem;
integer                                                 C2_output_file_freq_list_mem;



// Reset
always @(posedge reset) begin

    reset_rams_flag                         = 1;


    ram_reset_counter_cap                   = 286;





    
    C2_output_file_freq_mem =                                $fopen("./dumps/C2_output_file_freq_mem.txt", "w");
C2_output_file_freq_list_mem =                                $fopen("./dumps/C2_output_file_freq_list_mem.txt", "w");


end


            