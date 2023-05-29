
            

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




    reg                                             		fl_input_symbols_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				fl_input_symbols_mem_read_addr      ;
    wire                [9 - 1 	 : 0]    				fl_input_symbols_mem_read_data      ;
    reg                                             		fl_input_symbols_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				fl_input_symbols_mem_write_addr     ;
    reg                 [9 - 1 	 : 0]    				fl_input_symbols_mem_write_data     ;

    memory_list #(
        .mem_width(9),
        .address_len(address_len),
        .mem_depth(input_bytes_count),
        .initial_file("./input.txt")

    ) fl_input_symbols_mem(
        .clk(clk),
        .r_en(  fl_input_symbols_mem_read_enable),
        .r_addr(fl_input_symbols_mem_read_addr),
        .r_data(fl_input_symbols_mem_read_data),
        .w_en(  fl_input_symbols_mem_write_enable),
        .w_addr(fl_input_symbols_mem_write_addr),
        .w_data(fl_input_symbols_mem_write_data)
    );




                

    reg                                             		fl_config_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				fl_config_mem_read_addr      ;
    wire                [q_full - 1 	 : 0]    				fl_config_mem_read_data      ;
    reg                                             		fl_config_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				fl_config_mem_write_addr     ;
    reg                 [q_full - 1 	 : 0]    				fl_config_mem_write_data     ;

    memory_list #(
        .mem_width(q_full),
        .address_len(address_len),
        .mem_depth(20),
        .initial_file("./config.txt")

    ) fl_config_mem(
        .clk(clk),
        .r_en(  fl_config_mem_read_enable),
        .r_addr(fl_config_mem_read_addr),
        .r_data(fl_config_mem_read_data),
        .w_en(  fl_config_mem_write_enable),
        .w_addr(fl_config_mem_write_addr),
        .w_data(fl_config_mem_write_data)
    );




                

    reg                                             		fl_freq_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				fl_freq_mem_read_addr      ;
    wire                [q_full - 1 	 : 0]    				fl_freq_mem_read_data      ;
    reg                                             		fl_freq_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				fl_freq_mem_write_addr     ;
    reg                 [q_full - 1 	 : 0]    				fl_freq_mem_write_data     ;

    memory_list #(
        .mem_width(q_full),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file(0)

    ) fl_freq_mem(
        .clk(clk),
        .r_en(  fl_freq_mem_read_enable),
        .r_addr(fl_freq_mem_read_addr),
        .r_data(fl_freq_mem_read_data),
        .w_en(  fl_freq_mem_write_enable),
        .w_addr(fl_freq_mem_write_addr),
        .w_data(fl_freq_mem_write_data)
    );




                

    reg                                             		fl_freq_list_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				fl_freq_list_mem_read_addr      ;
    wire                [freq_list_width - 1 	 : 0]    				fl_freq_list_mem_read_data      ;
    reg                                             		fl_freq_list_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				fl_freq_list_mem_write_addr     ;
    reg                 [freq_list_width - 1 	 : 0]    				fl_freq_list_mem_write_data     ;

    memory_list #(
        .mem_width(freq_list_width),
        .address_len(address_len),
        .mem_depth(freq_list_depth),
        .initial_file(0)

    ) fl_freq_list_mem(
        .clk(clk),
        .r_en(  fl_freq_list_mem_read_enable),
        .r_addr(fl_freq_list_mem_read_addr),
        .r_data(fl_freq_list_mem_read_data),
        .w_en(  fl_freq_list_mem_write_enable),
        .w_addr(fl_freq_list_mem_write_addr),
        .w_data(fl_freq_list_mem_write_data)
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
                            fl_freq_mem_write_addr                  = counter_ram_reset_A;
                        end
    
                    
    
    
                    end else if (lagger_ram_reset_A == 2) begin
    
    
                        
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              fl_freq_mem_write_data                  = 0;
                          end
    
                      
    
    
                    end else if (lagger_ram_reset_A == 3) begin
    
    
                        
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              fl_freq_mem_write_enable                  = 1;
                          end
    
                      
    
    
                    end else if (lagger_ram_reset_A == 4) begin
    
    
                        
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              fl_freq_mem_write_enable                  = 0;
                          end
    
                      
    
    
    
                    end else if (lagger_ram_reset_A == 5) begin
    
                        if (counter_ram_reset_A < ram_reset_counter_cap - 1) begin
                            counter_ram_reset_A = counter_ram_reset_A + 1;
    
                        end else begin
                            counter_ram_reset_A = 0;
                            reset_rams_flag = 0;
                            $display("A: finished reset_rams_flag");
    
    
                            // setting and launching the first flag
                            
                                  lagger_CC                   = 0;
                                  CC_read_config_file_flag    = 1;
            
                        end
    
    
                        lagger_ram_reset_A = 0;
    
                    end 
                end
            end
    
            
/*

E2:
here we populate freq_list mem.
this is equvalent to python's freq_list
this memory is what we use to produce huffman nodes.

    bits:
    starting at  0, len of 9 : symbol value in 9 bits
    starting at  9, len of 12: frequency
    starting at 21, len of 1 : bit 41: is this entry used to build a node already?
    starting at 22, len of 1 : bit 40: is this entry a pointer to a node?
    starting at 23, len of 8 : the node's left side 9-bit terms count
    starting at 31, len of 12: starting index of the left  side of the node, if this is a pointer to a node
    starting at 43, len of 8 : the node's right side 9-bit terms count
    starting at 51, len of 12: starting index of the right side of the node, if this is a pointer to a node

    total width of the bus = 63 (freq_list_width)

62     54 53        42  41  40  39    32 31        20 19    12 11         0
000000000 000000000010  0   1   00000001 000000000000 00000001 000000000001




0   ..  8 9   ..    20  21  22  23 .. 30 31        42 43    50 51        62 

*/




// CC

// flag
reg                                                     CC_read_config_file_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    lagger_CC;

reg                 [q_full - 1 : 0]                    config_symbol_counts_C;

//CC_read_config_file_flag
always @(negedge clk) begin
if (CC_read_config_file_flag == 1) begin
    lagger_CC = lagger_CC + 1;

    if (lagger_CC == 1) begin
        fl_config_mem_read_addr = 0;
        
    end else if (lagger_CC == 2) begin
        config_symbol_counts_C = fl_config_mem_read_data;
        
    end else if (lagger_CC == 3) begin
    
        CC_read_config_file_flag = 0;
        
        $display("CC: config file read.");
        $display("CC: config_symbol_counts_C: %d", config_symbol_counts_C);


        // setting and launching C1
        counter_C1          = 0;
        lagger_C1           = 0;
        C1_get_freq_flag    = 1;
    
    end 
end
end













// C1

// flag
reg                                                     C1_get_freq_flag   = 0;


// system reset
reg                 [q_full - 1 : 0]                    counter_C1;
reg                 [q_full - 1 : 0]                    lagger_C1;


// C1_get_freq_flag
always @(negedge clk) begin
    if (C1_get_freq_flag == 1) begin
        lagger_C1 = lagger_C1 + 1;

        if (lagger_C1 == 1) begin
            fl_input_symbols_mem_read_addr = counter_C1;
        
        end else if (lagger_C1 == 2) begin
            fl_freq_mem_read_addr = fl_input_symbols_mem_read_data;
            fl_freq_mem_write_addr = fl_input_symbols_mem_read_data;

        end else if (lagger_C1 == 3) begin
            fl_freq_mem_write_data = fl_freq_mem_read_data + 1;

        end else if (lagger_C1 == 4) begin
            fl_freq_mem_write_enable = 1;
            
        end else if (lagger_C1 == 5) begin
            fl_freq_mem_write_enable = 0;

        end else if (lagger_C1 == 6) begin

            if (counter_C1 < config_symbol_counts_C - 1) begin
                counter_C1 = counter_C1 + 1;

            end else begin
                C1_get_freq_flag = 0;

                // setting and launching C2
                counter_C2 = 0;
                lagger_C2= 0;
                C2_freq_dumper_flag = 1;

            end

            lagger_C1 = 0;
            

        end 
    end
end
























// C2

// flag
reg                                                     C2_freq_dumper_flag   = 0;


//loop reset
reg                 [q_full - 1 : 0]                    counter_C2;
reg                 [q_full - 1 : 0]                    lagger_C2;




//C2_freq_dumper_flag
always @(negedge clk) begin
 if (C2_freq_dumper_flag == 1) begin
     lagger_C2 = lagger_C2 + 1;

     if (lagger_C2 == 1) begin
        fl_freq_mem_read_addr = counter_C2;
        fl_freq_list_mem_write_addr = counter_C2;

     end else if (lagger_C2 == 2) begin
        if (counter_C2 >= max_length_symbol) begin
            fl_freq_list_mem_write_data = counter_C2 << (freq_list_width - 9);

        end else begin
            fl_freq_list_mem_write_data = counter_C2 << (freq_list_width - 9);
            fl_freq_list_mem_write_data[freq_list_width - 9 - 1 -: 12] =  fl_freq_mem_read_data;

        end

     end else if (lagger_C2 == 3) begin
        $fdisplayb(C2_output_file_freq_list_mem, fl_freq_list_mem_write_data);

        if (counter_C2 < max_length_symbol) begin
            $fdisplay(C2_output_file_freq_mem, fl_freq_mem_read_data);

        end

     end else if (lagger_C2 == 4) begin
        fl_freq_list_mem_write_enable = 1;





     end else if (lagger_C2 == 5) begin
        fl_freq_list_mem_write_enable = 0;



     end else if (lagger_C2 == 6) begin

         if (counter_C2 < freq_list_depth - 1) begin
             counter_C2 = counter_C2 + 1;

         end else begin

            $fclose(C2_output_file_freq_mem);

            $fclose(C2_output_file_freq_list_mem);


            C2_freq_dumper_flag = 0;



            $display("FINISHED_______________________________________%d", $time);




         end

         lagger_C2 = 0;
        
     end 
 end
end









            

endmodule


            
