
            

module huffman (
    input                                               clk,
    input                                               reset
);


// Output Files

integer                                                 E2_output_file_huff_freq_mem;
integer                                                 E4_output_file_freq_list_mem;
integer                                                 E10_output_file_huffman_nodes_mem;
integer                                                 E14_output_file_huffman_codes_mem;



// Reset
always @(posedge reset) begin

    reset_rams_flag                         = 1;


    ram_reset_counter_cap                   = 2860;





    
    E2_output_file_huff_freq_mem =                                $fopen("./dumps/E2_output_file_huff_freq_mem.txt", "w");
E4_output_file_freq_list_mem =                                $fopen("./dumps/E4_output_file_freq_list_mem.txt", "w");
E10_output_file_huffman_nodes_mem =                                $fopen("./dumps/E10_output_file_huffman_nodes_mem.txt", "w");
E14_output_file_huffman_codes_mem =                                $fopen("./dumps/E14_output_file_huffman_codes_mem.txt", "w");


end


            