
            

module recode (
    input                                               clk,
    input                                               reset
);


// Output Files

integer                                                 I4_output_file_recoded_cl_encoding_pre_bitstream_mem;
integer                                                 J1_output_file_recode_cl_cl_reordered_pre_bitstream_mem;
integer                                                 I_output_file_general;



// Reset
always @(posedge reset) begin

    reset_rams_flag                         = 1;


    ram_reset_counter_cap                   = 286;





    
    I4_output_file_recoded_cl_encoding_pre_bitstream_mem =                                $fopen("./dumps/I4_output_file_recoded_cl_encoding_pre_bitstream_mem.txt", "w");
J1_output_file_recode_cl_cl_reordered_pre_bitstream_mem =                                $fopen("./dumps/J1_output_file_recode_cl_cl_reordered_pre_bitstream_mem.txt", "w");
I_output_file_general =                                $fopen("./dumps/I_output_file_general.txt", "w");


end


            