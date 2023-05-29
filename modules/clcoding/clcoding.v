
            

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


            

localparam                                              address_len                      = 24;
localparam                                              laggers_len                      = 8;
localparam                                              q_full                      = 48;
localparam                                              q_half                      = 24;
localparam                                              input_bytes_count                      = 134;
localparam                                              lzss_future_size                      = 10;
localparam                                              lzss_min_search_len                      = 2;
localparam                                              lzss_history_size                      = 32768;
localparam                                              lzss_mlwbr                      = 3;
localparam                                              length_symbol_counts                      = 255;
localparam                                              distance_symbol_counts                      = 999;
localparam                                              max_length_symbol                      = 286;
localparam                                              max_distance_symbol                      = 30;
localparam                                              freq_list_width                      = 63;
localparam                                              vs_val_for_taken_by_symbol                      = 229;
localparam                                              encoded_mem_width                      = 8;
localparam                                              input_bits_to_writer_width                      = 16;
localparam                                              pre_bitstream_width                      = 21;
localparam                                              cl_cl_count                      = 19;
localparam                                              lzss_output_width                      = 40;
localparam                                              huffman_codes_width                      = 41;
localparam                                              ll_freq_list_depth                      = 573;
localparam                                              distance_freq_list_depth                      = 61;
localparam                                              freq_list_depth                      = 573;
localparam                                              huffman_nodes_count                      = 2860;
localparam                                              compiler_max_output_count                      = 2860;
localparam                                              total_header_bits_width                      = 24;
localparam                                              mem_bits_reader_bus_width                      = 24;




    reg                                             		input_huffman_codes_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				input_huffman_codes_mem_read_addr      ;
    wire                [huffman_codes_width - 1 	 : 0]    				input_huffman_codes_mem_read_data      ;
    reg                                             		input_huffman_codes_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				input_huffman_codes_mem_write_addr     ;
    reg                 [huffman_codes_width - 1 	 : 0]    				input_huffman_codes_mem_write_data     ;

    memory_list #(
        .mem_width(huffman_codes_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file("./input.txt")

    ) input_huffman_codes_mem(
        .clk(clk),
        .r_en(  input_huffman_codes_mem_read_enable),
        .r_addr(input_huffman_codes_mem_read_addr),
        .r_data(input_huffman_codes_mem_read_data),
        .w_en(  input_huffman_codes_mem_write_enable),
        .w_addr(input_huffman_codes_mem_write_addr),
        .w_data(input_huffman_codes_mem_write_data)
    );




                

    reg                                             		pre_bitstream_clcoding_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				pre_bitstream_clcoding_mem_read_addr      ;
    wire                [pre_bitstream_width - 1 	 : 0]    				pre_bitstream_clcoding_mem_read_data      ;
    reg                                             		pre_bitstream_clcoding_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				pre_bitstream_clcoding_mem_write_addr     ;
    reg                 [pre_bitstream_width - 1 	 : 0]    				pre_bitstream_clcoding_mem_write_data     ;

    memory_list #(
        .mem_width(pre_bitstream_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file(0)

    ) pre_bitstream_clcoding_mem(
        .clk(clk),
        .r_en(  pre_bitstream_clcoding_mem_read_enable),
        .r_addr(pre_bitstream_clcoding_mem_read_addr),
        .r_data(pre_bitstream_clcoding_mem_read_data),
        .w_en(  pre_bitstream_clcoding_mem_write_enable),
        .w_addr(pre_bitstream_clcoding_mem_write_addr),
        .w_data(pre_bitstream_clcoding_mem_write_data)
    );




                

    reg                                             		symbols_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				symbols_mem_read_addr      ;
    wire                [9 - 1 	 : 0]    				symbols_mem_read_data      ;
    reg                                             		symbols_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				symbols_mem_write_addr     ;
    reg                 [9 - 1 	 : 0]    				symbols_mem_write_data     ;

    memory_list #(
        .mem_width(9),
        .address_len(address_len),
        .mem_depth(input_bytes_count),
        .initial_file(0)

    ) symbols_mem(
        .clk(clk),
        .r_en(  symbols_mem_read_enable),
        .r_addr(symbols_mem_read_addr),
        .r_data(symbols_mem_read_data),
        .w_en(  symbols_mem_write_enable),
        .w_addr(symbols_mem_write_addr),
        .w_data(symbols_mem_write_data)
    );




                

            reg                                                     reset_rams_flag                     = 0;
    
            reg                 [q_full - 1 : 0]                    ram_reset_counter_cap;
    
            reg                 [q_full - 1 : 0]                    counter_ram_reset_A                 = 0;
            reg                 [q_full - 1 : 0]                    lagger_ram_reset_A                  = 0;
    
    
            always @(negedge clk) begin
                if (reset_rams_flag == 1) begin
                    lagger_ram_reset_A = lagger_ram_reset_A + 1;
    
                    if (lagger_ram_reset_A == 1) begin
    
    
                        
    
    
                    end else if (lagger_ram_reset_A == 2) begin
    
    
                        
    
    
                    end else if (lagger_ram_reset_A == 3) begin
    
    
                        
    
    
                    end else if (lagger_ram_reset_A == 4) begin
    
    
                        
    
    
    
                    end else if (lagger_ram_reset_A == 5) begin
    
                        if (counter_ram_reset_A < ram_reset_counter_cap - 1) begin
                            counter_ram_reset_A = counter_ram_reset_A + 1;
    
                        end else begin
                            counter_ram_reset_A = 0;
                            reset_rams_flag = 0;
                            $display("A: finished reset_rams_flag");
    
    
                            // setting and launching the first flag
                            
                                  counter_G6              = max_length_symbol - 1;
                                  lagger_G6               = 0;
                                  hlit_G                  = 0;
                                  G6_find_tail_zeros_flag = 1;
            
                        end
    
    
                        lagger_ram_reset_A = 0;
    
                    end 
                end
            end
    
            
reg                 [8 - 1 :     0]                     verbose = 3;

/*







pre bitstream format:

    bits:
    [20 : 16] bit counts
    [15 :  0] bits

    total width of the bus = 21 (pre_bitstream_width)

    20 16  15             0
    00000  0000000000000000
    
    
*/










// G6

// flag
reg                                                     G6_find_tail_zeros_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G6;
reg                 [q_full - 1 : 0]                    lagger_G6;

// G6 variables
reg                 [9 - 1      : 0]                    hlit_G;
reg                 [9 - 1      : 0]                    cl_counts_G;
    

//G6_find_tail_zeros_flag
always @(negedge clk) begin
if (G6_find_tail_zeros_flag == 1) begin
    lagger_G6 = lagger_G6 + 1;

    if (lagger_G6 == 1) begin

        input_huffman_codes_mem_read_addr = counter_G6;

    end else if (lagger_G6 == 2) begin


        if (input_huffman_codes_mem_read_data[31 : 20] == 0) begin
            hlit_G = hlit_G + 1;

        end else begin



            cl_counts_G                      = max_length_symbol - hlit_G;


            $fdisplayb(G6_output_file_general, hlit_G);


            if (verbose > 0) $display("G6: found hlit_G to be: %d, so cl_counts_G becomes: max_length_symbol(%d) - hlit_G(%d) = %d", hlit_G, max_length_symbol, hlit_G, cl_counts_G);


            G6_find_tail_zeros_flag         = 0;
            // setting and launching G0
            G0_clcoding_main_loop_flag      = 1;
            counter_G0                      = 0;
            lagger_G0                       = 0;
            symbols_count_G                 = 0;
            pre_bitstream_clcoding_mem_write_addr    = 0;
            symbols_mem_write_addr          = 0;

        end

    end else if (lagger_G6 == 3) begin
        counter_G6 = counter_G6 - 1;
        lagger_G6 = 0;
    
    end 
end
end





























// G0

// flag
reg                                                     G0_clcoding_main_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G0;
reg                 [q_full - 1 : 0]                    lagger_G0;

// G0 variables
reg                 [9 - 1      : 0]                    length_G0;
reg                                                     found_something_G0;
reg                 [9 - 1      : 0]                    use_case_G0;

reg                 [9 - 1      : 0]                    symbols_count_G;

// we stored our code lengths in 12 bits when storing the huffman codes.
reg                 [12 - 1      : 0]                   current_G0;
reg                 [12 - 1      : 0]                   next_G0;




//G0_clcoding_main_loop_flag
always @(negedge clk) begin
if (G0_clcoding_main_loop_flag == 1) begin
    lagger_G0 = lagger_G0 + 1;

    if (lagger_G0 == 1) begin

        if (counter_G0 < cl_counts_G) begin
            input_huffman_codes_mem_read_addr = counter_G0;

            length_G0           = 0;
            found_something_G0   = 0;
            use_case_G0         = 0;
         
        end else begin
            
            G0_clcoding_main_loop_flag = 0;
            // setting and launching G4
            counter_G4 = 0;
            lagger_G4 = 0;
            G4_dump_pre_bitstream_clcoding_flag = 1;

        end



    end else if (lagger_G0 == 2) begin
        current_G0 = input_huffman_codes_mem_read_data[31 : 20];


    end else if (lagger_G0 == 3) begin

        if (counter_G0 == cl_counts_G - 1) begin

            if (verbose > 0) $display("G0: STORING: %d as the last load.", current_G0);
            
                G0_clcoding_main_loop_flag = 0;
                // setting and launching G2
                input_bits_to_writer_G = current_G0;
                input_bits_to_writer_count_G = 5;
                lagger_G2 = 0;
                G2_write_to_pre_bitstream_clcoding_flag = 1;

                // counter_G2 = 0;
                // lagger_G2 = 0;
                // last_load_G = 1;
                // starting_index_G2 = 0;
                // allowed_to_write_G2 = 1;
        end
        

    end else if (lagger_G0 == 4) begin

        if (counter_G0 == cl_counts_G - 1) begin
            
                G0_clcoding_main_loop_flag = 0;
                // setting and launching G3
                symbols_mem_write_data = current_G0;
                lagger_G3 = 0;
                G3_append_symbol_to_mem_flag = 1;

        end
        

    end else if (lagger_G0 == 5) begin
        if (counter_G0 == cl_counts_G - 1) begin

            G0_clcoding_main_loop_flag = 0;
            // setting and launching G4
            counter_G4 = 0;
            lagger_G4 = 0;
            G4_dump_pre_bitstream_clcoding_flag = 1;


        end


    end else if (lagger_G0 == 6) begin
        current_G0 = input_huffman_codes_mem_read_data[31 : 20];
        if (verbose > 1) $display("\n\n\nG0: ___________________-counter_G0:%d, cl_counts_G - 1:%d, current_G0:%d", counter_G0,cl_counts_G - 1,  current_G0);


        G0_clcoding_main_loop_flag = 0;
        //setting and launching G1
        counter_G1 = 0;
        lagger_G1 = 0;
        G1_find_run_lengths_flag = 1;


    end else if (lagger_G0 == 7) begin
        if (found_something_G0) begin
            if (verbose > 1) $display("G0: found that %d repeats %d times.", current_G0, length_G0);


            if (current_G0 == 0) begin
                if ((3 <= length_G0 + 1) && (length_G0 + 1 <= 10)) begin
                    use_case_G0 = 17;

                end else if ((11 <= length_G0 + 1) && (length_G0 + 1 <= 138)) begin
                    use_case_G0 = 18;

                end

            end else begin

                if ((3 <= length_G0) && (length_G0 <= 6)) begin
                    use_case_G0 = 16;
                end
            end

        end

        if (verbose > 1) $display("G0: use case: %d", use_case_G0);


    end else if (lagger_G0 == 8) begin

        if ((found_something_G0) && (use_case_G0 != 0)) begin

            counter_G0 = counter_G0 + length_G0 + 1;

            if (current_G0 == 0) begin

                if (verbose > 0) $display("G0: STORING: repeat a zero length %d times, use_case: %d", length_G0 + 1, use_case_G0);

                // python: encoded = encoded + bitstring.BitArray(f"uint5={use_case}").bin

                G0_clcoding_main_loop_flag = 0;
                // setting and launching G2
                input_bits_to_writer_G = use_case_G0;
                input_bits_to_writer_count_G = 5;
                lagger_G2 = 0;
                G2_write_to_pre_bitstream_clcoding_flag = 1;

                if (verbose > 1) $display("G0: l4: found ZERO with usecase:%d, launching the writer.", use_case_G0);

            end

        end


    end else if (lagger_G0 == 9) begin


        if ((found_something_G0) && (use_case_G0 != 0)) begin

            if (current_G0 == 0) begin

                // python: symbols.append(use_case)

                G0_clcoding_main_loop_flag = 0;
                // setting and launching G3
                symbols_mem_write_data = use_case_G0;
                lagger_G3 = 0;
                G3_append_symbol_to_mem_flag = 1;

                if (verbose > 1) $display("G0: l5: and now storing symbol:%d", use_case_G0);

            end

        end


    end else if (lagger_G0 == 10) begin


        if ((found_something_G0) && (use_case_G0 != 0)) begin

            if (current_G0 == 0) begin

                if (use_case_G0 == 17) begin
                    G0_clcoding_main_loop_flag = 0;
                    // setting and launching G2
                    input_bits_to_writer_G = length_G0 + 1 - 3;
                    input_bits_to_writer_count_G = 3;
                    lagger_G2 = 0;
                    G2_write_to_pre_bitstream_clcoding_flag = 1;

                    if (verbose > 1) $display("G0: l6: use_case_G0 == 17, launching the writer to store %d", length_G0 + 1 - 3);


                end else if (use_case_G0 == 18) begin
                    G0_clcoding_main_loop_flag = 0;
                    // setting and launching G2
                    input_bits_to_writer_G = length_G0 + 1 - 11;
                    input_bits_to_writer_count_G = 7;
                    lagger_G2 = 0;
                    G2_write_to_pre_bitstream_clcoding_flag = 1;

                    if (verbose > 1) $display("G0: l6: use_case_G0 == 18, launching the writer  to store %d.", length_G0 + 1 - 11);


                end

            end

        end



    end else if (lagger_G0 == 11) begin


        if ((found_something_G0) && (use_case_G0 != 0)) begin

            if (current_G0 != 0) begin

                if (verbose > 0) $display("G0: STORING: %d", current_G0);
                if (verbose > 0) $display("G0: STORING: repeat the previous length  %d times, use_case: %d", length_G0, use_case_G0);

                // python: encoded = encoded + bitstring.BitArray(f"uint5={current}").bin

                G0_clcoding_main_loop_flag = 0;
                // setting and launching G2
                input_bits_to_writer_G = current_G0;
                input_bits_to_writer_count_G = 5;
                lagger_G2 = 0;
                G2_write_to_pre_bitstream_clcoding_flag = 1;

                if (verbose > 1) $display("G0: l4: found NONZERO with usecase:%d, launching the writer.", use_case_G0);

            end

        end



    end else if (lagger_G0 == 12) begin


        if ((found_something_G0) && (use_case_G0 != 0)) begin

            if (current_G0 != 0) begin
                // python: symbols.append(current)

                G0_clcoding_main_loop_flag = 0;
                // setting and launching G3
                symbols_mem_write_data = current_G0;
                lagger_G3 = 0;
                G3_append_symbol_to_mem_flag = 1;


            end


        end




    end else if (lagger_G0 == 13) begin


        if ((found_something_G0) && (use_case_G0 != 0)) begin

            if (current_G0 != 0) begin
                // python: encoded = encoded + bitstring.BitArray(f"uint5={use_case}").bin

                G0_clcoding_main_loop_flag = 0;
                // setting and launching G2
                input_bits_to_writer_G = use_case_G0;
                input_bits_to_writer_count_G = 5;
                lagger_G2 = 0;
                G2_write_to_pre_bitstream_clcoding_flag = 1;


            end

        end




    end else if (lagger_G0 == 14) begin

        if ((found_something_G0) && (use_case_G0 != 0)) begin

            if (current_G0 != 0) begin
                // python: symbols.append(use_case)

                G0_clcoding_main_loop_flag = 0;
                // setting and launching G3
                symbols_mem_write_data = use_case_G0;
                lagger_G3 = 0;
                G3_append_symbol_to_mem_flag = 1;


            end

        end



    end else if (lagger_G0 == 15) begin

        if ((found_something_G0) && (use_case_G0 != 0)) begin

            if (current_G0 != 0) begin
                // python: rep_offset = max(0, length - 3)

                G0_clcoding_main_loop_flag = 0;
                // setting and launching G2
                if (length_G0 <= 3) begin
                    input_bits_to_writer_G = 0;
                end else begin
                    input_bits_to_writer_G = length_G0 - 3;
                end
                input_bits_to_writer_count_G = 2;
                lagger_G2 = 0;
                G2_write_to_pre_bitstream_clcoding_flag = 1;


            end
        end



    end else if (lagger_G0 == 16) begin

        if (found_something_G0 * use_case_G0 == 0) begin

                if (verbose > 0) $display("G0: STORING: %d", current_G0);
            
                // encoded = encoded + bitstring.BitArray(f"uint5={current}").bin

                G0_clcoding_main_loop_flag = 0;
                // setting and launching G2
                input_bits_to_writer_G = current_G0;
                input_bits_to_writer_count_G = 5;
                lagger_G2 = 0;
                G2_write_to_pre_bitstream_clcoding_flag = 1;

                if (verbose > 1) $display("G0: l12: did not find anything. storing the symbol only. launching the writer.");

        end




    end else if (lagger_G0 == 17) begin

        if (found_something_G0 * use_case_G0 == 0) begin
                // python: symbols.append(current)

                G0_clcoding_main_loop_flag = 0;
                // setting and launching G3
                symbols_mem_write_data = current_G0;
                lagger_G3 = 0;
                G3_append_symbol_to_mem_flag = 1;
                if (verbose > 1) $display("G0: l13: also storing the symbol.");

        end




    end else if (lagger_G0 == 18) begin

        if (found_something_G0  * use_case_G0 == 0) begin
            counter_G0 = counter_G0 + 1;
        end




    end else if (lagger_G0 == 19) begin



        if (verbose > 1) $display("G0: l15, finished the work for this counter.");
        lagger_G0 = 0;
    
    end
end

end






























// G1

// flag
reg                                                     G1_find_run_lengths_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G1;
reg                 [q_full - 1 : 0]                    lagger_G1;

// G1 variables

    

//G1_find_run_lengths_flag
always @(negedge clk) begin
if (G1_find_run_lengths_flag == 1) begin
    lagger_G1 = lagger_G1 + 1;

    if (lagger_G1 == 1) begin
        input_huffman_codes_mem_read_addr = counter_G0 + 1 + length_G0;
        
    end else if (lagger_G1 == 2) begin
        next_G0 = input_huffman_codes_mem_read_data[31 : 20];

    end else if (lagger_G1 == 3) begin
        if (current_G0 == next_G0) begin
            length_G0 = length_G0 + 1;

            found_something_G0 = 1;

            if (counter_G0 + length_G0 == cl_counts_G - 1) begin
                // break
                G1_find_run_lengths_flag    = 0;
                G0_clcoding_main_loop_flag  = 1;
            end

        end



    end else if (lagger_G1 == 4) begin
        if (current_G0 == next_G0) begin

            if (current_G0 == 0) begin
                if (length_G0 + 1 == 138) begin
                    // break
                    G1_find_run_lengths_flag    = 0;
                    G0_clcoding_main_loop_flag  = 1;

                end 
            end


        end




    end else if (lagger_G1 == 5) begin
        if (current_G0 == next_G0) begin

            if (current_G0 != 0) begin
                if (length_G0 == 6) begin
                    // break
                    G1_find_run_lengths_flag    = 0;
                    G0_clcoding_main_loop_flag  = 1;

                end 
            end


        end


    end else if (lagger_G1 == 6) begin
        if (current_G0 != next_G0) begin

            // break
            G1_find_run_lengths_flag    = 0;
            G0_clcoding_main_loop_flag  = 1;

        end




    end else if (lagger_G1 == 7) begin

        counter_G1 = counter_G1 + 1;


        //setting and launching G2
        //counter_G2 = 0;
        //lagger_G2 = 0;
        //next_flag_G2 = 1;



        lagger_G1 = 0;
    
    end 
end
end


























// G2

// flag
reg                                                     G2_write_to_pre_bitstream_clcoding_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    lagger_G2;

// G2 variables
reg                 [input_bits_to_writer_width - 1: 0] input_bits_to_writer_G;
reg                 [6 - 1      : 0]                    input_bits_to_writer_count_G;

    

//G2_write_to_pre_bitstream_clcoding_flag
always @(negedge clk) begin
if (G2_write_to_pre_bitstream_clcoding_flag == 1) begin
    lagger_G2 = lagger_G2 + 1;

    if (lagger_G2 == 1) begin
        pre_bitstream_clcoding_mem_write_data = input_bits_to_writer_count_G << 16;
        pre_bitstream_clcoding_mem_write_data = pre_bitstream_clcoding_mem_write_data | input_bits_to_writer_G;


        if (input_bits_to_writer_G > (2 << (input_bits_to_writer_count_G - 1))) begin
            
            $display("\n\n\n\n !!!!!!  writing a value larger than its bus width! \n\n\n\n");

        end

    end else if (lagger_G2 == 2) begin
        pre_bitstream_clcoding_mem_write_enable = 1;

    end else if (lagger_G2 == 3) begin
        pre_bitstream_clcoding_mem_write_enable = 0;

    end else if (lagger_G2 == 4) begin
        pre_bitstream_clcoding_mem_write_addr = pre_bitstream_clcoding_mem_write_addr + 1;

    end else if (lagger_G2 == 5) begin
        G2_write_to_pre_bitstream_clcoding_flag = 0;
        G0_clcoding_main_loop_flag = 1;
    
    end 
end
end


















// G3

// flag
reg                                                     G3_append_symbol_to_mem_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G3;
reg                 [q_full - 1 : 0]                    lagger_G3;

// G3 variables

    

//G3_append_symbol_to_mem_flag
always @(negedge clk) begin
if (G3_append_symbol_to_mem_flag == 1) begin
    lagger_G3 = lagger_G3 + 1;

    if (lagger_G3 == 1) begin
        symbols_mem_write_enable = 1;
        
    end else if (lagger_G3 == 2) begin
        symbols_mem_write_enable = 0;

    end else if (lagger_G3 == 3) begin
        symbols_mem_write_addr = symbols_mem_write_addr + 1;

    end else if (lagger_G3 == 4) begin
        symbols_count_G = symbols_count_G + 1;

        G3_append_symbol_to_mem_flag = 0;
        G0_clcoding_main_loop_flag = 1;

        if (verbose > 2) $display("-\t\t\tG3: l4: stored %d th symbol. going back to caller.", symbols_count_G) ;


    end 
end
end














// G4

// flag
reg                                                     G4_dump_pre_bitstream_clcoding_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G4;
reg                 [q_full - 1 : 0]                    lagger_G4;

// G4 variables

//G4_dump_pre_bitstream_clcoding_flag
always @(negedge clk) begin
if (G4_dump_pre_bitstream_clcoding_flag == 1) begin
    lagger_G4 = lagger_G4 + 1;

    if (lagger_G4 == 1) begin
        pre_bitstream_clcoding_mem_read_addr = counter_G4;

    end else if (lagger_G4 == 2) begin
        $fdisplayb(G4_output_file_pre_bitstream, pre_bitstream_clcoding_mem_read_data);

    end else if (lagger_G4 == 3) begin

        if (counter_G4 < pre_bitstream_clcoding_mem_write_addr - 1) begin
            counter_G4 = counter_G4 + 1;

        end else begin
            $fclose(G4_output_file_pre_bitstream);

            $fdisplayb(G6_output_file_general, pre_bitstream_clcoding_mem_write_addr);


            G4_dump_pre_bitstream_clcoding_flag = 0;
            
            $display("G4: finished dumping encoded at %d", $time);


            //setting and launching G5
            counter_G5 = 0;
            lagger_G5 = 0;
            G5_dump_symbols_mem_flag = 1;



        end

        lagger_G4 = 0;
    
    end 
end
end














// G5

// flag
reg                                                     G5_dump_symbols_mem_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_G5;
reg                 [q_full - 1 : 0]                    lagger_G5;

// G5 variables

//G5_dump_symbols_mem_flag
always @(negedge clk) begin
if (G5_dump_symbols_mem_flag == 1) begin
    lagger_G5 = lagger_G5 + 1;

    if (lagger_G5 == 1) begin
        symbols_mem_read_addr = counter_G5;

    end else if (lagger_G5 == 2) begin
        $fdisplayb(G5_output_file_symbols_mem, symbols_mem_read_data);
        $display("G5: counter_G5: %d, symbol:%d", counter_G5, symbols_mem_read_data);

    end else if (lagger_G5 == 3) begin

        if (counter_G5 < symbols_count_G - 1) begin
            counter_G5 = counter_G5 + 1;

        end else begin
            $fclose(G5_output_file_symbols_mem);



            $fdisplayb(G6_output_file_general, symbols_count_G);


            $fclose(G6_output_file_general);
            

            G5_dump_symbols_mem_flag = 0;
            
            $display("G5: finished dumping symbols at %d", $time);


            //setting and launching G6
            //counter_G6 = 0;
            //lagger_G6 = 0;
            //next_flag_G6 = 1;


            $display("FINISHED_______________________________________%d", $time);

        end

        lagger_G5 = 0;
    
    end 
end
end



            

endmodule


            
