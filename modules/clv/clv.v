
            

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




    reg                                             		huffman_codes_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				huffman_codes_mem_read_addr      ;
    wire                [huffman_codes_width - 1 	 : 0]    				huffman_codes_mem_read_data      ;
    reg                                             		huffman_codes_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				huffman_codes_mem_write_addr     ;
    reg                 [huffman_codes_width - 1 	 : 0]    				huffman_codes_mem_write_data     ;

    memory_list #(
        .mem_width(huffman_codes_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file("./input.txt")

    ) huffman_codes_mem(
        .clk(clk),
        .r_en(  huffman_codes_mem_read_enable),
        .r_addr(huffman_codes_mem_read_addr),
        .r_data(huffman_codes_mem_read_data),
        .w_en(  huffman_codes_mem_write_enable),
        .w_addr(huffman_codes_mem_write_addr),
        .w_data(huffman_codes_mem_write_data)
    );




                

    reg                                             		argsrot_idx_for_cl_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				argsrot_idx_for_cl_mem_read_addr      ;
    wire                [9 - 1 	 : 0]    				argsrot_idx_for_cl_mem_read_data      ;
    reg                                             		argsrot_idx_for_cl_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				argsrot_idx_for_cl_mem_write_addr     ;
    reg                 [9 - 1 	 : 0]    				argsrot_idx_for_cl_mem_write_data     ;

    memory_list #(
        .mem_width(9),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file(0)

    ) argsrot_idx_for_cl_mem(
        .clk(clk),
        .r_en(  argsrot_idx_for_cl_mem_read_enable),
        .r_addr(argsrot_idx_for_cl_mem_read_addr),
        .r_data(argsrot_idx_for_cl_mem_read_data),
        .w_en(  argsrot_idx_for_cl_mem_write_enable),
        .w_addr(argsrot_idx_for_cl_mem_write_addr),
        .w_data(argsrot_idx_for_cl_mem_write_data)
    );




                

    reg                                             		clrec_vs_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				clrec_vs_mem_read_addr      ;
    wire                [22 - 1 	 : 0]    				clrec_vs_mem_read_data      ;
    reg                                             		clrec_vs_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				clrec_vs_mem_write_addr     ;
    reg                 [22 - 1 	 : 0]    				clrec_vs_mem_write_data     ;

    memory_list #(
        .mem_width(22),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file(0)

    ) clrec_vs_mem(
        .clk(clk),
        .r_en(  clrec_vs_mem_read_enable),
        .r_addr(clrec_vs_mem_read_addr),
        .r_data(clrec_vs_mem_read_data),
        .w_en(  clrec_vs_mem_write_enable),
        .w_addr(clrec_vs_mem_write_addr),
        .w_data(clrec_vs_mem_write_data)
    );




                

    reg                                             		clrec_freq_list_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				clrec_freq_list_mem_read_addr      ;
    wire                [freq_list_width - 1 	 : 0]    				clrec_freq_list_mem_read_data      ;
    reg                                             		clrec_freq_list_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				clrec_freq_list_mem_write_addr     ;
    reg                 [freq_list_width - 1 	 : 0]    				clrec_freq_list_mem_write_data     ;

    memory_list #(
        .mem_width(freq_list_width),
        .address_len(address_len),
        .mem_depth(freq_list_depth),
        .initial_file(0)

    ) clrec_freq_list_mem(
        .clk(clk),
        .r_en(  clrec_freq_list_mem_read_enable),
        .r_addr(clrec_freq_list_mem_read_addr),
        .r_data(clrec_freq_list_mem_read_data),
        .w_en(  clrec_freq_list_mem_write_enable),
        .w_addr(clrec_freq_list_mem_write_addr),
        .w_data(clrec_freq_list_mem_write_data)
    );




                

            reg                                                     reset_rams_flag                     = 0;
    
            reg                 [q_full - 1 : 0]                    ram_reset_counter_cap;
    
            reg                 [q_full - 1 : 0]                    counter_ram_reset_A                 = 0;
            reg                 [q_full - 1 : 0]                    lagger_ram_reset_A                  = 0;
    
    
            always @(negedge clk) begin
                if (reset_rams_flag == 1) begin
                    lagger_ram_reset_A = lagger_ram_reset_A + 1;
    
                    if (lagger_ram_reset_A == 1) begin
    
    
                        
    
                        if (counter_ram_reset_A < max_length_symbol) begin
                            argsrot_idx_for_cl_mem_write_addr                  = counter_ram_reset_A;
                        end
    
                    
    
                        if (counter_ram_reset_A < max_length_symbol) begin
                            clrec_vs_mem_write_addr                  = counter_ram_reset_A;
                        end
    
                    
    
                        if (counter_ram_reset_A < freq_list_depth) begin
                            clrec_freq_list_mem_write_addr                  = counter_ram_reset_A;
                        end
    
                    
    
    
                    end else if (lagger_ram_reset_A == 2) begin
    
    
                        
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              argsrot_idx_for_cl_mem_write_data                  = counter_ram_reset_A;
                          end
    
                      
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              clrec_vs_mem_write_data                  = 0;
                          end
    
                      
    
                          if (counter_ram_reset_A < freq_list_depth) begin
                              clrec_freq_list_mem_write_data                  = 0;
                          end
    
                      
    
    
                    end else if (lagger_ram_reset_A == 3) begin
    
    
                        
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              argsrot_idx_for_cl_mem_write_enable                  = 1;
                          end
    
                      
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              clrec_vs_mem_write_enable                  = 1;
                          end
    
                      
    
                          if (counter_ram_reset_A < freq_list_depth) begin
                              clrec_freq_list_mem_write_enable                  = 1;
                          end
    
                      
    
    
                    end else if (lagger_ram_reset_A == 4) begin
    
    
                        
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              argsrot_idx_for_cl_mem_write_enable                  = 0;
                          end
    
                      
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              clrec_vs_mem_write_enable                  = 0;
                          end
    
                      
    
                          if (counter_ram_reset_A < freq_list_depth) begin
                              clrec_freq_list_mem_write_enable                  = 0;
                          end
    
                      
    
    
    
                    end else if (lagger_ram_reset_A == 5) begin
    
                        if (counter_ram_reset_A < ram_reset_counter_cap - 1) begin
                            counter_ram_reset_A = counter_ram_reset_A + 1;
    
                        end else begin
                            counter_ram_reset_A = 0;
                            reset_rams_flag = 0;
                            $display("A: finished reset_rams_flag");
    
    
                            // setting and launching the first flag
                            
                                  counter_F0 = 0;
                                  read_lagger_F0 = 0;
                                  write_lagger_F0 = 0;
                                  sorter_bump_flag_F0 = 0;
                                  sorter_stage_F0 = sorter_stage_looping_F0;
                                  F0_argsort_cl_table_flag = 1;
            
                        end
    
    
                        lagger_ram_reset_A = 0;
    
                    end 
                end
            end
    
            
/*
clrec_vs mem:
    bits:
    [21: 13], 9 bits, index of child v on the left side (0 if side is free)
    [12: 4] , 9 bits, index of child v on the right side  (0 if side is free)
    [3 : 0] , 4 bits, node depth

    21     13  12      4  3  0
    000000000  000000000  0000
    


last_v_with_an_available_side:
    [13 : 5], 9 bits, root_v_idx_F
    [4]     , 1 bit , root_free_side_F
    [3 : 0] , 4 bits, root_v_depth_F

    13      5 4 3  0        
    000000000 0 0000
*/



reg                 [5 - 1 :      0]                    verbose = 3;
reg                                                     display_reg;


// F0

// flag
reg                                                     F0_argsort_cl_table_flag   = 0;


//loop reset to zero
reg                 [q_full - 1 : 0]                    counter_F0;
reg                 [q_full - 1 : 0]                    read_lagger_F0;
reg                 [q_full - 1 : 0]                    write_lagger_F0;
reg                                                     sorter_bump_flag_F0;
reg                                                     sorter_stage_F0; // reset to sorter_stage_looping_F0


// no reset needed
reg                 [41 - 1 : 0]            sorter_v1_F0;
reg                 [41 - 1 : 0]            sorter_v2_F0;
reg                 [9 - 1 : 0]            sorter_v1_arg_F0;
reg                 [9 - 1 : 0]            sorter_v2_arg_F0;

// Stages
localparam          sorter_stage_looping_F0         = 0;
localparam          sorter_stage_swapping_F0        = 1;



// F0_argsort_cl_table_flag
always @(negedge clk) begin

    if (F0_argsort_cl_table_flag == 1) begin



        if (sorter_stage_F0 == sorter_stage_looping_F0) begin
            read_lagger_F0 = read_lagger_F0 + 1;

            if (read_lagger_F0 == 1) begin
                huffman_codes_mem_read_addr =counter_F0;    
                argsrot_idx_for_cl_mem_read_addr =counter_F0;
                
            end else if (read_lagger_F0 == 2) begin
                sorter_v1_F0 = huffman_codes_mem_read_data;
                sorter_v1_arg_F0 = argsrot_idx_for_cl_mem_read_data;

            end else if (read_lagger_F0 == 3) begin
                huffman_codes_mem_read_addr =counter_F0 + 1;    
                argsrot_idx_for_cl_mem_read_addr =counter_F0 + 1;

            end else if (read_lagger_F0 == 4) begin
                sorter_v2_F0 = huffman_codes_mem_read_data;
                sorter_v2_arg_F0 = argsrot_idx_for_cl_mem_read_data;

            end else if (read_lagger_F0 == 5) begin
                if (sorter_v1_F0[31 : 20] > sorter_v2_F0[31 : 20]) begin
                    // $display("bump");
                    sorter_bump_flag_F0 = 1;
                    sorter_stage_F0= sorter_stage_swapping_F0;
                end 
                
                read_lagger_F0 = 0;

                if (counter_F0 < max_length_symbol - 2) begin
                    counter_F0 = counter_F0 + 1;

                end else begin

                    counter_F0 = 0;

                    if (sorter_bump_flag_F0 == 0) begin
                        F0_argsort_cl_table_flag = 0;
                        $display("F0: SORTING FINISHED, time:%d", $time);



                        //setting and launching F1
                        counter_F1 = 0;
                        lagger_F1 = 0;
                        max_cl_F1 = 0;
                        F1_dump_huffman_codes_flag = 1;
            


                    end
                    sorter_bump_flag_F0 = 0;

                end

            end

        end else if (sorter_stage_F0 == sorter_stage_swapping_F0) begin

            write_lagger_F0 = write_lagger_F0 + 1;

            if (write_lagger_F0 == 1) begin
                if (counter_F0 == 0) begin
                    huffman_codes_mem_write_addr = (max_length_symbol - 2);
                    argsrot_idx_for_cl_mem_write_addr = (max_length_symbol - 2);
                end else begin
                    huffman_codes_mem_write_addr =counter_F0 - 1;
                    argsrot_idx_for_cl_mem_write_addr =counter_F0 - 1;
                end


            end else if (write_lagger_F0 == 2) begin
                huffman_codes_mem_write_data = sorter_v2_F0;  
                argsrot_idx_for_cl_mem_write_data = sorter_v2_arg_F0;

            end else if (write_lagger_F0 == 3) begin
                huffman_codes_mem_write_enable = 1;
                argsrot_idx_for_cl_mem_write_enable = 1;
                

            end else if (write_lagger_F0 == 4) begin
                huffman_codes_mem_write_enable = 0;
                argsrot_idx_for_cl_mem_write_enable = 0;
                

            end else if (write_lagger_F0 == 5) begin
                if (counter_F0 == 0) begin
                    huffman_codes_mem_write_addr = max_length_symbol - 1;
                    argsrot_idx_for_cl_mem_write_addr = max_length_symbol - 1;
                end else begin
                    huffman_codes_mem_write_addr =counter_F0;
                    argsrot_idx_for_cl_mem_write_addr =counter_F0;
                end


            end else if (write_lagger_F0 == 6) begin
                huffman_codes_mem_write_data = sorter_v1_F0;
                argsrot_idx_for_cl_mem_write_data = sorter_v1_arg_F0;

            end else if (write_lagger_F0 == 7) begin
                huffman_codes_mem_write_enable = 1;
                argsrot_idx_for_cl_mem_write_enable = 1;

            end else if (write_lagger_F0 == 8) begin
                huffman_codes_mem_write_enable = 0;
                argsrot_idx_for_cl_mem_write_enable = 0;

            end else if (write_lagger_F0 == 9) begin
                write_lagger_F0 = 0;
                sorter_stage_F0= sorter_stage_looping_F0;
            end

        end
    end

end












// F1

// flag
reg                                                     F1_dump_huffman_codes_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F1;
reg                 [q_full - 1 : 0]                    lagger_F1;

// F1 variables
reg                 [9 - 1 :      0]                    max_cl_F1;
//F1_dump_huffman_codes_flag
always @(negedge clk) begin
if (F1_dump_huffman_codes_flag == 1) begin
    lagger_F1 = lagger_F1 + 1;

    if (lagger_F1 == 1) begin
        huffman_codes_mem_read_addr = counter_F1;

    end else if (lagger_F1 == 2) begin
        $fdisplayb(F1_output_file_huffman_codes_mem, huffman_codes_mem_read_data);

        if (huffman_codes_mem_read_data[31 : 20] > max_cl_F1) begin
            max_cl_F1 = huffman_codes_mem_read_data[31 : 20];
        end

        if (huffman_codes_mem_read_data[31 : 20] > 0) begin
            $display("F1: cl = %d", huffman_codes_mem_read_data[31 : 20]);
        end

    end else if (lagger_F1 == 3) begin

        if (counter_F1 < max_length_symbol - 1) begin
            counter_F1 = counter_F1 + 1;

        end else begin
            $fclose(F1_output_file_huffman_codes_mem);
            F1_dump_huffman_codes_flag = 0;
            
            $display("F1: max_cl_F1: %d", max_cl_F1);
            $display("F1: finished dumping huffman_codes");


            //setting and launching F2
            counter_F2 = 0;
            lagger_F2 = 0;
            F2_dump_argsrot_idx_for_cl_flag = 1;


        end

        lagger_F1 = 0;
    
    end 
end
end







// F2

// flag
reg                                                     F2_dump_argsrot_idx_for_cl_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F2;
reg                 [q_full - 1 : 0]                    lagger_F2;

// F2 variables

//F2_dump_argsrot_idx_for_cl_flag
always @(negedge clk) begin
if (F2_dump_argsrot_idx_for_cl_flag == 1) begin
    lagger_F2 = lagger_F2 + 1;

    if (lagger_F2 == 1) begin
        argsrot_idx_for_cl_mem_read_addr = counter_F2;

    end else if (lagger_F2 == 2) begin
        $fdisplay(F2_output_file_argsrot_idx_for_cl_mem, argsrot_idx_for_cl_mem_read_data);

    end else if (lagger_F2 == 3) begin

        if (counter_F2 < max_length_symbol - 1) begin
            counter_F2 = counter_F2 + 1;

        end else begin
            $fclose(F2_output_file_argsrot_idx_for_cl_mem);
            F2_dump_argsrot_idx_for_cl_flag = 0;
            
            $display("F2: finished dumping argsrot_idx_for_cl at %d", $time);


            // setting and launching F3
            counter_F3 = 0;
            lagger_F3 = 0;
            done_with_this_symbol_F3 = 0;
            F3_recover_freq_list_from_cl_flag = 1;


        end

        lagger_F2 = 0;
    
    end 
end
end




















// F3

// flag
reg                                                     F3_recover_freq_list_from_cl_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F3;
reg                 [q_full - 1 : 0]                    lagger_F3;

// F3 variables
reg                                                     done_with_this_symbol_F3;
reg                 [9 - 1 : 0]                         vs_count_F3;
reg                 [9 - 1 : 0]                         cl_F;

//F3_recover_freq_list_from_cl_flag
always @(negedge clk) begin
if (F3_recover_freq_list_from_cl_flag == 1) begin
    lagger_F3 = lagger_F3 + 1;


    /*
        vs = [[0, 0, 1]]
    */
    if (lagger_F3 == 1) begin
        $display("F3: starting to write 1 to clrec_vs_mem");

        clrec_vs_mem_write_addr = 0;

    end else if (lagger_F3 == 2) begin
        clrec_vs_mem_write_data = 22'b000000000_000000000_0001;
        
    end else if (lagger_F3 == 3) begin
        clrec_vs_mem_write_enable = 1;
        
    end else if (lagger_F3 == 4) begin
        clrec_vs_mem_write_enable = 0;
        $display("F3: wrote 1 to clrec_vs_mem, counter_F3:%d", counter_F3);

    end else if (lagger_F3 == 5) begin
        vs_count_F3 = 1;










    /*
    for cl in code_lengths:

        if cl == 0:
            nodes_freqs.append(0)
            continue
    */
    end else if (lagger_F3 == 6) begin
        huffman_codes_mem_read_addr = counter_F3;
        

                
        // if (counter_F3 == 0) begin
        // end
            

    end else if (lagger_F3 == 7) begin
        cl_F = huffman_codes_mem_read_data[31 : 20];
        if (cl_F > 0) begin
            $display("\n\nF3: cl_F:%d", cl_F);
        end

        if (cl_F == 0) begin
            done_with_this_symbol_F3 = 1;
            argsrot_idx_for_cl_mem_read_addr = counter_F3;
        end else begin
            done_with_this_symbol_F3 = 0;
        end

    end else if (lagger_F3 == 8) begin
        // $display("F3: counter_F3:%d, done_with_this_symbol_F3:%d", counter_F3, done_with_this_symbol_F3);

        if (cl_F == 0) begin
            clrec_freq_list_mem_write_addr = argsrot_idx_for_cl_mem_read_data;
            clrec_freq_list_mem_write_data = argsrot_idx_for_cl_mem_read_data << (freq_list_width - 9);
        
        end

    end else if (lagger_F3 == 9) begin
        if (cl_F == 0) begin
            clrec_freq_list_mem_write_enable = 1;
        end

    end else if (lagger_F3 == 10) begin
        if (cl_F == 0) begin
            clrec_freq_list_mem_write_enable = 0;
        end












    /*
        root_v_idx, root_free_side, root_v_depth = pick_the_last_v_with_an_available_side(vs)
    */
    end else if (lagger_F3 == 11) begin

        if (done_with_this_symbol_F3 == 0) begin

            $display("F3: need to find the last v with a free side.");

            F3_recover_freq_list_from_cl_flag = 0;

            // setting and launching F5
            // counter_F5 is a backward counter
            counter_F5 = vs_count_F3 - 1;
            lagger_F5 = 0;

            F5_pick_the_last_v_with_an_available_side_flag = 1;

        end






    /*
        if cl == root_v_depth:
            vs[root_v_idx][root_free_side] = vs_val_for_taken_by_symbol
    */

    end else if (lagger_F3 == 12) begin
        if (done_with_this_symbol_F3 == 0) begin
            // $display("F3: last_v_with_an_available_side:%b, root_v_idx_F:%d,root_free_side_F:%d,root_v_depth_F:%d",
            //  last_v_with_an_available_side, root_v_idx_F, root_free_side_F, root_v_depth_F);

            if (cl_F == root_v_depth_F) begin

                $display("F3:  ---->  cl_F(%d) = root_v_depth(%d)", cl_F, root_v_depth_F);
                $display("F3: updating vs[root_v_idx(%d)][root_free_side(%d)] = 299", root_v_idx_F,  root_free_side_F);
                clrec_vs_mem_read_addr  = root_v_idx_F;
                clrec_vs_mem_write_addr = root_v_idx_F;
            end

        end


    end else if (lagger_F3 == 13) begin
        if (done_with_this_symbol_F3 == 0) begin

            if (cl_F == root_v_depth_F) begin

                clrec_vs_mem_write_data = clrec_vs_mem_read_data ;

                if (root_free_side_F == 1'b0) begin
                    clrec_vs_mem_write_data[21 : 13] = vs_val_for_taken_by_symbol;        
                end else begin
                    clrec_vs_mem_write_data[12 : 4] = vs_val_for_taken_by_symbol;        
                end

            end

        end



    end else if (lagger_F3 == 14) begin
        if (done_with_this_symbol_F3 == 0) begin

            if (cl_F == root_v_depth_F) begin
                clrec_vs_mem_write_enable = 1 ;
            end

        end



    end else if (lagger_F3 == 15) begin
        if (done_with_this_symbol_F3 == 0) begin

            if (cl_F == root_v_depth_F) begin
                clrec_vs_mem_write_enable = 0 ;

                // starting to append the freq
                argsrot_idx_for_cl_mem_read_addr = counter_F3;
            end

        end



    /*
        if cl == root_v_depth:
            nodes_freqs.append(2 ** (max_depth - root_v_depth))
    */


    end else if (lagger_F3 == 16) begin
        if (done_with_this_symbol_F3 == 0) begin

            if (cl_F == root_v_depth_F) begin
                clrec_freq_list_mem_write_addr = argsrot_idx_for_cl_mem_read_data;
                clrec_freq_list_mem_write_data = argsrot_idx_for_cl_mem_read_data << (freq_list_width - 9);

                clrec_freq_list_mem_write_data[53 : 42] = nt_deflate.two_to_power(max_cl_F1 - root_v_depth_F);

                $display("F3: node_freq = 2 ** (max_depth (%d) - root_v_depth(%d)) = ", max_cl_F1, root_v_depth_F, clrec_freq_list_mem_write_data[53 : 42]);

            end

        end




    end else if (lagger_F3 == 17) begin
        if (done_with_this_symbol_F3 == 0) begin

            if (cl_F == root_v_depth_F) begin
                clrec_freq_list_mem_write_enable = 1;
            end

        end



    end else if (lagger_F3 == 18) begin
        if (done_with_this_symbol_F3 == 0) begin

            if (cl_F == root_v_depth_F) begin
                clrec_freq_list_mem_write_enable = 0;

                done_with_this_symbol_F3 = 1;
            end

        end



    end else if (lagger_F3 == 19) begin
        if (done_with_this_symbol_F3 == 0) begin



            $display("E3: ----> need to establish a series of roots until you get deep enough to place `cl`");
            
            /*
            create a new v
            assign it to the empty side of the root v
            make the new v root
            we agree to place the node on the left side of the new v
            */

            F3_recover_freq_list_from_cl_flag = 0;
            // setting and launching F6
            counter_F6 = 0;
            lagger_F6 = 0;
            node_was_placed_F6 = 0;
            F6_establish_a_series_of_vs_roots_flag = 1;

           

        end


    /*
        if not node_was_placed:
            vs[-1][0] = vs_val_for_taken_by_symbol
    */

    end else if (lagger_F3 == 20) begin
        if (done_with_this_symbol_F3 == 0) begin
            if (node_was_placed_F6 == 0) begin
                clrec_vs_mem_read_addr = vs_count_F3 - 1;
                clrec_vs_mem_write_addr = vs_count_F3 - 1;
            end
        end


    end else if (lagger_F3 == 21) begin
        if (done_with_this_symbol_F3 == 0) begin
            if (node_was_placed_F6 == 0) begin
                clrec_vs_mem_write_data = clrec_vs_mem_read_data;
                clrec_vs_mem_write_data = (vs_val_for_taken_by_symbol << 13);
                clrec_vs_mem_write_data[12 : 0] = clrec_vs_mem_read_data[12 : 0];
            end
        end

    end else if (lagger_F3 == 22) begin
        if (done_with_this_symbol_F3 == 0) begin
            if (node_was_placed_F6 == 0) begin
                clrec_vs_mem_write_enable = 1;
            end
        end


    end else if (lagger_F3 == 23) begin
        if (done_with_this_symbol_F3 == 0) begin
            if (node_was_placed_F6 == 0) begin
                clrec_vs_mem_write_enable = 0;
            end
        end






    /*
        node_freq = 2 ** (max_depth - root_v_depth)
        nodes_freqs.append(node_freq)

    */

    end else if (lagger_F3 == 24) begin
        if (done_with_this_symbol_F3 == 0) begin
            argsrot_idx_for_cl_mem_read_addr = counter_F3;

        end


    end else if (lagger_F3 == 25) begin
        if (done_with_this_symbol_F3 == 0) begin
            clrec_freq_list_mem_write_addr = argsrot_idx_for_cl_mem_read_data;
            clrec_freq_list_mem_write_data = argsrot_idx_for_cl_mem_read_data << (freq_list_width - 9);


            clrec_freq_list_mem_write_data[53 : 42] = nt_deflate.two_to_power(max_cl_F1 - root_v_depth_F);

            $display("f3: node_freq = 2 ** (max_depth (%d) - root_v_depth(%d)) = ", max_cl_F1, root_v_depth_F, clrec_freq_list_mem_write_data[53 : 42]);



        end


    end else if (lagger_F3 == 26) begin
        if (done_with_this_symbol_F3 == 0) begin
            clrec_freq_list_mem_write_enable = 1;
        end

    end else if (lagger_F3 == 27) begin
        if (done_with_this_symbol_F3 == 0) begin
            clrec_freq_list_mem_write_enable = 0;
            done_with_this_symbol_F3 = 1;
        end



    end else if (lagger_F3 == 28) begin
        
        if (verbose > 0 ) $display("F3: _________________________________________starting to list clrec_vs:");
        F3_recover_freq_list_from_cl_flag = 0;

        F8_dump_clrec_vs_mem_flag = 1;
        counter_F8 = 0;
        lagger_F8 = 0;



    end else if (lagger_F3 == 29) begin

        if (done_with_this_symbol_F3 == 0) begin
            $display("F3: counter_F3:%d !!!!!!!!!!!!!!!!!!!!!!!!! done_with_this_symbol_F3 is zero !!!!!!!!!!!!", counter_F3);
        end

        if (counter_F3 < max_length_symbol - 1) begin
            counter_F3 = counter_F3 + 1;

        end else begin
            
            F3_recover_freq_list_from_cl_flag = 0;
            
            


            //setting and launching F4
            counter_F4 = 0;
            lagger_F4 = 0;
            F4_dump_clrec_freq_list_flag = 1;




        end

        lagger_F3 = 5;
    
    end 
end
end




















// F4

// flag
reg                                                     F4_dump_clrec_freq_list_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F4;
reg                 [q_full - 1 : 0]                    lagger_F4;

// F4 variables

//F4_dump_clrec_freq_list_flag
always @(negedge clk) begin
if (F4_dump_clrec_freq_list_flag == 1) begin
    lagger_F4 = lagger_F4 + 1;

    if (lagger_F4 == 1) begin
        clrec_freq_list_mem_read_addr = counter_F4;

    end else if (lagger_F4 == 2) begin
        $fdisplayb(F4_output_file_clrec_freq_list_mem, clrec_freq_list_mem_read_data);

        // display_reg = nt_deflate.display_freq_list_entry(clrec_freq_list_mem_read_data, counter_F4);

    end else if (lagger_F4 == 3) begin

        if (counter_F4 < freq_list_depth - 1) begin
            counter_F4 = counter_F4 + 1;

        end else begin
            $fclose(F4_output_file_clrec_freq_list_mem);
            F4_dump_clrec_freq_list_flag = 0;
            
            $display("F4: finished dumping clrec_freq_list at %d", $time);

            $display("FINISHED_______________________________________%d", $time);





        end

        lagger_F4 = 0;
    
    end 
end
end


















// F5

// flag
reg                                                     F5_pick_the_last_v_with_an_available_side_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F5;
reg                 [q_full - 1 : 0]                    lagger_F5;

// F5 variables
reg                 [9 - 1 : 0]                         root_v_idx_F;
reg                                                     root_free_side_F;
reg                 [4 - 1 : 0]                         root_v_depth_F;
reg                 [4 - 1 : 0]                         root_v_depth_clone_F;


//F5_pick_the_last_v_with_an_available_side_flag
always @(negedge clk) begin
if (F5_pick_the_last_v_with_an_available_side_flag == 1) begin
    lagger_F5 = lagger_F5 + 1;

    if (lagger_F5 == 1) begin
        clrec_vs_mem_read_addr = counter_F5;
        // $display("F5: checking out clrec_vs_mem at: %d", clrec_vs_mem_read_addr);


    end else if (lagger_F5 == 2) begin

        // display_reg = nt_deflate.display_vs(clrec_vs_mem_read_data, counter_F5);

        if  ((clrec_vs_mem_read_data[3 : 0] > 0) && (clrec_vs_mem_read_data[21 : 13] == 0)) begin
            
            root_v_idx_F        = counter_F5;
            root_free_side_F    = 1'b0;
            root_v_depth_F      = clrec_vs_mem_read_data[3 : 0];
            root_v_depth_clone_F = root_v_depth_F;

            F5_pick_the_last_v_with_an_available_side_flag = 0;
            F3_recover_freq_list_from_cl_flag = 1;

            $display("F5: found the last_v_with (left). root_v_idx_F:%d   root_free_side_F:%d,   root_v_depth_F:%d",
             root_v_idx_F, root_free_side_F, root_v_depth_F);

        end
        

    end else if (lagger_F5 == 3) begin

        if ((clrec_vs_mem_read_data[3 : 0] > 0) &&(clrec_vs_mem_read_data[12 : 4] == 0)) begin

            root_v_idx_F        = counter_F5;
            root_free_side_F    = 1'b1;
            root_v_depth_F      = clrec_vs_mem_read_data[3 : 0];
            root_v_depth_clone_F = root_v_depth_F;

            F5_pick_the_last_v_with_an_available_side_flag = 0;
            F3_recover_freq_list_from_cl_flag = 1;

            $display("F5: found the last_v_with (right). root_v_idx_F:%d   root_free_side_F:%d,   root_v_depth_F:%d",
             root_v_idx_F, root_free_side_F, root_v_depth_F);

        end
        


    end else if (lagger_F5 == 4) begin

        if (counter_F5 > 0) begin
            counter_F5 = counter_F5 - 1;

        end else begin
            


            $display("E5 assertion error. no vs found !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11");
            F5_pick_the_last_v_with_an_available_side_flag = 0;
            
            




        end

        lagger_F5 = 0;
    
    end 
end
end
















// F6

// flag
reg                                                     F6_establish_a_series_of_vs_roots_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F6;
reg                 [q_full - 1 : 0]                    lagger_F6;

// F6 variables
reg                 [9 - 1 : 0]                         new_v_idx_F6;
reg                                                     node_was_placed_F6;


//F6_establish_a_series_of_vs_roots_flag
always @(negedge clk) begin
if (F6_establish_a_series_of_vs_roots_flag == 1) begin
    lagger_F6 = lagger_F6 + 1;


    /*
        new_v_idx = len(vs)
        vs[root_v_idx][root_free_side] = new_v_idx
    */
    if (lagger_F6 == 1) begin
        new_v_idx_F6 = vs_count_F3;

        clrec_vs_mem_read_addr = root_v_idx_F;
        clrec_vs_mem_write_addr = root_v_idx_F;

        $display("F6:       planting new_v_idx_F6: %d on root_v_idx_F:%d", new_v_idx_F6, root_v_idx_F);

    end else if (lagger_F6 == 2) begin
        clrec_vs_mem_write_data = clrec_vs_mem_read_data ;

        if (root_free_side_F == 1'b0) begin
            clrec_vs_mem_write_data[21 : 13] = new_v_idx_F6; 
            $display("F6:       overwriting left");

        end else begin
            clrec_vs_mem_write_data[12 : 4] = new_v_idx_F6;  
            $display("F6:       overwriting right");
                 
        end

    end else if (lagger_F6 == 3) begin
        clrec_vs_mem_write_enable = 1 ;

    end else if (lagger_F6 == 4) begin
        clrec_vs_mem_write_enable = 0 ;




    /*
        vs.append([
            vs_val_for_taken_by_symbol if i == cl - root_v_depth - 1 else 0,
             0,
              root_v_depth + 1])
    */
    end else if (lagger_F6 == 5) begin
        clrec_vs_mem_write_addr = vs_count_F3 ;


    end else if (lagger_F6 == 6) begin
        // $display("F6: counter_F6:%d    cl_F:%d,          root_v_depth_F:%d,  (cl_F - root_v_depth_F - 1): %d",
        // counter_F6, cl_F, root_v_depth_F, cl_F - root_v_depth_F - 1);

        if (counter_F6 == cl_F - root_v_depth_F - 1) begin
            clrec_vs_mem_write_data = vs_val_for_taken_by_symbol << 13;

            node_was_placed_F6 = 1;

            // $display("-----------------------------------------------------------------------counter_F6 == cl_F - root_v_idx_F - 1");
            // $display("\t\t F6: vs append cond 0");
            
        end else begin
            clrec_vs_mem_write_data = 0;
            // $display("\t\tF6: vs append cond 1");

        end

        clrec_vs_mem_write_data[3 : 0] = root_v_depth_F + 1;
        $display("F6:       ~~~~~~~~  appending vs with depth: %d\n", clrec_vs_mem_write_data[3 : 0]);



    end else if (lagger_F6 == 7) begin
        clrec_vs_mem_write_enable = 1 ;

    end else if (lagger_F6 == 8) begin
        clrec_vs_mem_write_enable = 0 ;

    end else if (lagger_F6 == 9) begin
        vs_count_F3 = vs_count_F3 + 1 ;



    /*
        root_v_idx = new_v_idx
        root_v_depth = root_v_depth + 1
        root_free_side = 0
    */
    end else if (lagger_F6 == 10) begin
        root_v_idx_F = new_v_idx_F6;
        root_v_depth_F = root_v_depth_F + 1;
        root_free_side_F = 0;

        $display("F6:       root_v_idx_F: %d, root_v_depth_F: %d, root_free_side_F:%d",root_v_idx_F, root_v_depth_F, root_free_side_F);

    end else if (lagger_F6 == 11) begin

        if (counter_F6 < cl_F - root_v_depth_clone_F - 1) begin
            counter_F6 = counter_F6 + 1;

        end else begin
            
            F6_establish_a_series_of_vs_roots_flag = 0;
            
            
            F3_recover_freq_list_from_cl_flag = 1;


            //setting and launching F7
            //counter_F7 = 0;
            //lagger_F7 = 0;
            //next_flag_F7 = 1;




        end

        lagger_F6 = 0;
    
    end 
end
end





















    
    








// F8

// flag
reg                                                     F8_dump_clrec_vs_mem_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_F8;
reg                 [q_full - 1 : 0]                    lagger_F8;

// F8 variables

//F8_dump_clrec_vs_mem_flag
always @(negedge clk) begin
if (F8_dump_clrec_vs_mem_flag == 1) begin
    lagger_F8 = lagger_F8 + 1;

    if (lagger_F8 == 1) begin
        clrec_vs_mem_read_addr = counter_F8;

    end else if (lagger_F8 == 2) begin
        // $fdisplayb(F8_output_file_clrec_vs_mem, clrec_vs_mem_read_data);
        if (verbose > 0) begin
            display_reg = nt_deflate.display_vs(clrec_vs_mem_read_data, counter_F8);
        end
    end else if (lagger_F8 == 3) begin

        if (counter_F8 < vs_count_F3 - 1) begin
            counter_F8 = counter_F8 + 1;

        end else begin
            // $fclose(F8_output_file_clrec_vs_mem);
            F8_dump_clrec_vs_mem_flag = 0;
            F3_recover_freq_list_from_cl_flag = 1;
            // $display("F8: finished dumping clrec_vs at %d", $time);


            //setting and launching F9
            // counter_F9 = 0;
            // lagger_F9 = 0;
            // next_flag_F9 = 1;



        end

        lagger_F8 = 0;
    
    end 
end
end





    





            

endmodule


            
