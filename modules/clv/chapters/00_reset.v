
            

module clv (
    input                                               clk,
    input                                               reset
);


// Output Files

integer                                                 F1_output_file_huffman_codes_mem;
integer                                                 F2_output_file_argsrot_idx_for_cl_mem;
integer                                                 F4_output_file_clrec_freq_list_mem;
integer                                                 F8_output_file_clrec_vs_mem;



// Reset
always @(posedge reset) begin

    reset_rams_flag                         = 1;


    ram_reset_counter_cap                   = 573;





    
    F1_output_file_huffman_codes_mem =                                $fopen("./dumps/F1_output_file_huffman_codes_mem.txt", "w");
F2_output_file_argsrot_idx_for_cl_mem =                                $fopen("./dumps/F2_output_file_argsrot_idx_for_cl_mem.txt", "w");
F4_output_file_clrec_freq_list_mem =                                $fopen("./dumps/F4_output_file_clrec_freq_list_mem.txt", "w");
F8_output_file_clrec_vs_mem =                                $fopen("./dumps/F8_output_file_clrec_vs_mem.txt", "w");


end


            