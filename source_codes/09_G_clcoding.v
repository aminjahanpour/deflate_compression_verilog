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

