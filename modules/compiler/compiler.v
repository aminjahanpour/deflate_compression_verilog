
            

module compiler (
    input                                               clk,
    input                                               reset
);


// Output Files

integer                                                 K7_output_file_header_pre_bitstream_mem;
integer                                                 K_output_file_general;



// Reset
always @(posedge reset) begin

    reset_rams_flag                         = 1;


    ram_reset_counter_cap                   = 2860;





    
    K7_output_file_header_pre_bitstream_mem =                                $fopen("./dumps/K7_output_file_header_pre_bitstream_mem.txt", "w");
K_output_file_general =                                $fopen("./dumps/K_output_file_general.txt", "w");


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




    reg                                             		compiler_input_cl_ll_pre_bitstream_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				compiler_input_cl_ll_pre_bitstream_mem_read_addr      ;
    wire                [pre_bitstream_width - 1 	 : 0]    				compiler_input_cl_ll_pre_bitstream_mem_read_data      ;
    reg                                             		compiler_input_cl_ll_pre_bitstream_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				compiler_input_cl_ll_pre_bitstream_mem_write_addr     ;
    reg                 [pre_bitstream_width - 1 	 : 0]    				compiler_input_cl_ll_pre_bitstream_mem_write_data     ;

    memory_list #(
        .mem_width(pre_bitstream_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file("./input_cl_ll_pre_bitstream.txt")

    ) compiler_input_cl_ll_pre_bitstream_mem(
        .clk(clk),
        .r_en(  compiler_input_cl_ll_pre_bitstream_mem_read_enable),
        .r_addr(compiler_input_cl_ll_pre_bitstream_mem_read_addr),
        .r_data(compiler_input_cl_ll_pre_bitstream_mem_read_data),
        .w_en(  compiler_input_cl_ll_pre_bitstream_mem_write_enable),
        .w_addr(compiler_input_cl_ll_pre_bitstream_mem_write_addr),
        .w_data(compiler_input_cl_ll_pre_bitstream_mem_write_data)
    );




                

    reg                                             		compiler_input_cl_distance_pre_bitstream_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				compiler_input_cl_distance_pre_bitstream_mem_read_addr      ;
    wire                [pre_bitstream_width - 1 	 : 0]    				compiler_input_cl_distance_pre_bitstream_mem_read_data      ;
    reg                                             		compiler_input_cl_distance_pre_bitstream_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				compiler_input_cl_distance_pre_bitstream_mem_write_addr     ;
    reg                 [pre_bitstream_width - 1 	 : 0]    				compiler_input_cl_distance_pre_bitstream_mem_write_data     ;

    memory_list #(
        .mem_width(pre_bitstream_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file("./input_cl_distance_pre_bitstream.txt")

    ) compiler_input_cl_distance_pre_bitstream_mem(
        .clk(clk),
        .r_en(  compiler_input_cl_distance_pre_bitstream_mem_read_enable),
        .r_addr(compiler_input_cl_distance_pre_bitstream_mem_read_addr),
        .r_data(compiler_input_cl_distance_pre_bitstream_mem_read_data),
        .w_en(  compiler_input_cl_distance_pre_bitstream_mem_write_enable),
        .w_addr(compiler_input_cl_distance_pre_bitstream_mem_write_addr),
        .w_data(compiler_input_cl_distance_pre_bitstream_mem_write_data)
    );




                

    reg                                             		compiler_input_cl_cl_ll_pre_bitstream_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				compiler_input_cl_cl_ll_pre_bitstream_mem_read_addr      ;
    wire                [pre_bitstream_width - 1 	 : 0]    				compiler_input_cl_cl_ll_pre_bitstream_mem_read_data      ;
    reg                                             		compiler_input_cl_cl_ll_pre_bitstream_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				compiler_input_cl_cl_ll_pre_bitstream_mem_write_addr     ;
    reg                 [pre_bitstream_width - 1 	 : 0]    				compiler_input_cl_cl_ll_pre_bitstream_mem_write_data     ;

    memory_list #(
        .mem_width(pre_bitstream_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file("./input_cl_cl_ll_pre_bitstream.txt")

    ) compiler_input_cl_cl_ll_pre_bitstream_mem(
        .clk(clk),
        .r_en(  compiler_input_cl_cl_ll_pre_bitstream_mem_read_enable),
        .r_addr(compiler_input_cl_cl_ll_pre_bitstream_mem_read_addr),
        .r_data(compiler_input_cl_cl_ll_pre_bitstream_mem_read_data),
        .w_en(  compiler_input_cl_cl_ll_pre_bitstream_mem_write_enable),
        .w_addr(compiler_input_cl_cl_ll_pre_bitstream_mem_write_addr),
        .w_data(compiler_input_cl_cl_ll_pre_bitstream_mem_write_data)
    );




                

    reg                                             		compiler_input_cl_cl_distance_pre_bitstream_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				compiler_input_cl_cl_distance_pre_bitstream_mem_read_addr      ;
    wire                [pre_bitstream_width - 1 	 : 0]    				compiler_input_cl_cl_distance_pre_bitstream_mem_read_data      ;
    reg                                             		compiler_input_cl_cl_distance_pre_bitstream_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				compiler_input_cl_cl_distance_pre_bitstream_mem_write_addr     ;
    reg                 [pre_bitstream_width - 1 	 : 0]    				compiler_input_cl_cl_distance_pre_bitstream_mem_write_data     ;

    memory_list #(
        .mem_width(pre_bitstream_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file("./input_cl_cl_distance_pre_bitstream.txt")

    ) compiler_input_cl_cl_distance_pre_bitstream_mem(
        .clk(clk),
        .r_en(  compiler_input_cl_cl_distance_pre_bitstream_mem_read_enable),
        .r_addr(compiler_input_cl_cl_distance_pre_bitstream_mem_read_addr),
        .r_data(compiler_input_cl_cl_distance_pre_bitstream_mem_read_data),
        .w_en(  compiler_input_cl_cl_distance_pre_bitstream_mem_write_enable),
        .w_addr(compiler_input_cl_cl_distance_pre_bitstream_mem_write_addr),
        .w_data(compiler_input_cl_cl_distance_pre_bitstream_mem_write_data)
    );




                

    reg                                             		compiler_input_ll_codes_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				compiler_input_ll_codes_mem_read_addr      ;
    wire                [huffman_codes_width - 1 	 : 0]    				compiler_input_ll_codes_mem_read_data      ;
    reg                                             		compiler_input_ll_codes_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				compiler_input_ll_codes_mem_write_addr     ;
    reg                 [huffman_codes_width - 1 	 : 0]    				compiler_input_ll_codes_mem_write_data     ;

    memory_list #(
        .mem_width(huffman_codes_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file("./input_ll_codes.txt")

    ) compiler_input_ll_codes_mem(
        .clk(clk),
        .r_en(  compiler_input_ll_codes_mem_read_enable),
        .r_addr(compiler_input_ll_codes_mem_read_addr),
        .r_data(compiler_input_ll_codes_mem_read_data),
        .w_en(  compiler_input_ll_codes_mem_write_enable),
        .w_addr(compiler_input_ll_codes_mem_write_addr),
        .w_data(compiler_input_ll_codes_mem_write_data)
    );




                

    reg                                             		compiler_input_distance_codes_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				compiler_input_distance_codes_mem_read_addr      ;
    wire                [huffman_codes_width - 1 	 : 0]    				compiler_input_distance_codes_mem_read_data      ;
    reg                                             		compiler_input_distance_codes_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				compiler_input_distance_codes_mem_write_addr     ;
    reg                 [huffman_codes_width - 1 	 : 0]    				compiler_input_distance_codes_mem_write_data     ;

    memory_list #(
        .mem_width(huffman_codes_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file("./input_distance_codes.txt")

    ) compiler_input_distance_codes_mem(
        .clk(clk),
        .r_en(  compiler_input_distance_codes_mem_read_enable),
        .r_addr(compiler_input_distance_codes_mem_read_addr),
        .r_data(compiler_input_distance_codes_mem_read_data),
        .w_en(  compiler_input_distance_codes_mem_write_enable),
        .w_addr(compiler_input_distance_codes_mem_write_addr),
        .w_data(compiler_input_distance_codes_mem_write_data)
    );




                

    reg                                             		compiler_input_lzss_output_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				compiler_input_lzss_output_mem_read_addr      ;
    wire                [lzss_output_width - 1 	 : 0]    				compiler_input_lzss_output_mem_read_data      ;
    reg                                             		compiler_input_lzss_output_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				compiler_input_lzss_output_mem_write_addr     ;
    reg                 [lzss_output_width - 1 	 : 0]    				compiler_input_lzss_output_mem_write_data     ;

    memory_list #(
        .mem_width(lzss_output_width),
        .address_len(address_len),
        .mem_depth(input_bytes_count),
        .initial_file("./input_lzss_output.txt")

    ) compiler_input_lzss_output_mem(
        .clk(clk),
        .r_en(  compiler_input_lzss_output_mem_read_enable),
        .r_addr(compiler_input_lzss_output_mem_read_addr),
        .r_data(compiler_input_lzss_output_mem_read_data),
        .w_en(  compiler_input_lzss_output_mem_write_enable),
        .w_addr(compiler_input_lzss_output_mem_write_addr),
        .w_data(compiler_input_lzss_output_mem_write_data)
    );




                

    reg                                             		compiler_config_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				compiler_config_mem_read_addr      ;
    wire                [q_full - 1 	 : 0]    				compiler_config_mem_read_data      ;
    reg                                             		compiler_config_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				compiler_config_mem_write_addr     ;
    reg                 [q_full - 1 	 : 0]    				compiler_config_mem_write_data     ;

    memory_list #(
        .mem_width(q_full),
        .address_len(address_len),
        .mem_depth(20),
        .initial_file("./config.txt")

    ) compiler_config_mem(
        .clk(clk),
        .r_en(  compiler_config_mem_read_enable),
        .r_addr(compiler_config_mem_read_addr),
        .r_data(compiler_config_mem_read_data),
        .w_en(  compiler_config_mem_write_enable),
        .w_addr(compiler_config_mem_write_addr),
        .w_data(compiler_config_mem_write_data)
    );




                

    reg                                             		header_pre_bitstream_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				header_pre_bitstream_mem_read_addr      ;
    wire                [pre_bitstream_width - 1 	 : 0]    				header_pre_bitstream_mem_read_data      ;
    reg                                             		header_pre_bitstream_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				header_pre_bitstream_mem_write_addr     ;
    reg                 [pre_bitstream_width - 1 	 : 0]    				header_pre_bitstream_mem_write_data     ;

    memory_list #(
        .mem_width(pre_bitstream_width),
        .address_len(address_len),
        .mem_depth(compiler_max_output_count),
        .initial_file(0)

    ) header_pre_bitstream_mem(
        .clk(clk),
        .r_en(  header_pre_bitstream_mem_read_enable),
        .r_addr(header_pre_bitstream_mem_read_addr),
        .r_data(header_pre_bitstream_mem_read_data),
        .w_en(  header_pre_bitstream_mem_write_enable),
        .w_addr(header_pre_bitstream_mem_write_addr),
        .w_data(header_pre_bitstream_mem_write_data)
    );




                

            reg                                                     reset_rams_flag                     = 0;
    
            reg                 [q_full - 1 : 0]                    ram_reset_counter_cap;
    
            reg                 [q_full - 1 : 0]                    counter_ram_reset_A                 = 0;
            reg                 [q_full - 1 : 0]                    lagger_ram_reset_A                  = 0;
    
    
            always @(negedge clk) begin
                if (reset_rams_flag == 1) begin
                    lagger_ram_reset_A = lagger_ram_reset_A + 1;
    
                    if (lagger_ram_reset_A == 1) begin
    
    
                        
    
                        if (counter_ram_reset_A < compiler_max_output_count) begin
                            header_pre_bitstream_mem_write_addr                  = counter_ram_reset_A;
                        end
    
                    
    
    
                    end else if (lagger_ram_reset_A == 2) begin
    
    
                        
    
                          if (counter_ram_reset_A < compiler_max_output_count) begin
                              header_pre_bitstream_mem_write_data                  = 0;
                          end
    
                      
    
    
                    end else if (lagger_ram_reset_A == 3) begin
    
    
                        
    
                          if (counter_ram_reset_A < compiler_max_output_count) begin
                              header_pre_bitstream_mem_write_enable                  = 1;
                          end
    
                      
    
    
                    end else if (lagger_ram_reset_A == 4) begin
    
    
                        
    
                          if (counter_ram_reset_A < compiler_max_output_count) begin
                              header_pre_bitstream_mem_write_enable                  = 0;
                          end
    
                      
    
    
    
                    end else if (lagger_ram_reset_A == 5) begin
    
                        if (counter_ram_reset_A < ram_reset_counter_cap - 1) begin
                            counter_ram_reset_A = counter_ram_reset_A + 1;
    
                        end else begin
                            counter_ram_reset_A = 0;
                            reset_rams_flag = 0;
                            $display("A: finished reset_rams_flag");
    
    
                            // setting and launching the first flag
                            
                                       counter_KC              = 0;
                                       lagger_KC               = 0;
                                       KC_read_config_file_flag   = 1;
                
                        end
    
    
                        lagger_ram_reset_A = 0;
    
                    end 
                end
            end
    
            
// KC

// flag
reg                                                     KC_read_config_file_flag   = 0;


// configs
reg                 [q_full - 1 : 0]                    hlit_cl;
reg                 [q_full - 1 : 0]                    hdist_cl;
reg                 [q_full - 1 : 0]                    count_of_pre_bitstream_for_reordered_cl_cl_values_ll;
reg                 [q_full - 1 : 0]                    count_of_pre_bitstream_for_reordered_cl_cl_values_distance;
reg                 [q_full - 1 : 0]                    hlit;
reg                 [q_full - 1 : 0]                    hdist;
reg                 [q_full - 1 : 0]                    cl_codings_pre_bitstream_words_count_ll;
reg                 [q_full - 1 : 0]                    cl_codings_pre_bitstream_words_count_distance;
reg                 [q_full - 1 : 0]                    recode_cl_total_bits_to_write_ll;
reg                 [q_full - 1 : 0]                    recode_cl_total_bits_to_write_distance;
reg                 [q_full - 1 : 0]                    lzss_outputs_count;


// loop reset
reg                 [q_full - 1 : 0]                    counter_KC;
reg                 [q_full - 1 : 0]                    lagger_KC;


reg                 [total_header_bits_width - 1  : 0]  total_header_bits;

// KC variables

//KC_read_config_file_flag
always @(negedge clk) begin
if (KC_read_config_file_flag == 1) begin
    lagger_KC = lagger_KC + 1;

    if (lagger_KC == 1) begin
        compiler_config_mem_read_addr = counter_KC;

    end else if (lagger_KC == 2) begin
        case (counter_KC)
            0   :    hlit_cl = compiler_config_mem_read_data;
            1   :    hdist_cl = compiler_config_mem_read_data;
            2   :    count_of_pre_bitstream_for_reordered_cl_cl_values_ll = compiler_config_mem_read_data;
            3   :    count_of_pre_bitstream_for_reordered_cl_cl_values_distance = compiler_config_mem_read_data;
            4   :    hlit = compiler_config_mem_read_data;
            5   :    hdist = compiler_config_mem_read_data;
            6   :    cl_codings_pre_bitstream_words_count_ll = compiler_config_mem_read_data;
            7   :    cl_codings_pre_bitstream_words_count_distance = compiler_config_mem_read_data;
            8   :    recode_cl_total_bits_to_write_ll = compiler_config_mem_read_data;
            9   :    recode_cl_total_bits_to_write_distance = compiler_config_mem_read_data;
           10   :    lzss_outputs_count = compiler_config_mem_read_data;
        endcase

    end else if (lagger_KC == 3) begin

        if (counter_KC < 20 - 1) begin
            counter_KC = counter_KC + 1;

        end else begin
            KC_read_config_file_flag = 0;
            
            $display("KC: hlit_cl: %d", hlit_cl);
            $display("KC: hdist_cl: %d", hdist_cl);
            $display("KC: count_of_pre_bitstream_for_reordered_cl_cl_values_ll: %d", count_of_pre_bitstream_for_reordered_cl_cl_values_ll);
            $display("KC: count_of_pre_bitstream_for_reordered_cl_cl_values_distance: %d", count_of_pre_bitstream_for_reordered_cl_cl_values_distance);
            $display("KC: hlit: %d", hlit);
            $display("KC: hdist: %d", hdist);
            $display("KC: cl_codings_pre_bitstream_words_count_ll: %d", cl_codings_pre_bitstream_words_count_ll);
            $display("KC: cl_codings_pre_bitstream_words_count_distance: %d", cl_codings_pre_bitstream_words_count_distance);
            $display("KC: recode_cl_total_bits_to_write_ll: %d", recode_cl_total_bits_to_write_ll);
            $display("KC: recode_cl_total_bits_to_write_distance: %d", recode_cl_total_bits_to_write_distance);
            $display("KC: lzss_outputs_count: %d", lzss_outputs_count);


            //setting and launching K1
            lagger_K1 = 0;
            header_pre_bitstream_mem_write_addr = 0;
            total_header_bits = 0;
            K1_compiler_main_loop_flag = 1;

        end

        lagger_KC = 0;
    
    end 
end
end












    
// K1

// flag
reg                                                     K1_compiler_main_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    lagger_K1;

// K1 variables
reg                 [5 - 1      : 0]                    compiler_writer_stage;
localparam          [5 - 1      : 0]                    compiler_writer_stage_single_value      = 0;
localparam          [5 - 1      : 0]                    compiler_writer_stage_cl_cl_ll          = 1;
localparam          [5 - 1      : 0]                    compiler_writer_stage_cl_cl_distance    = 2;
localparam          [5 - 1      : 0]                    compiler_writer_stage_cl_ll             = 3;
localparam          [5 - 1      : 0]                    compiler_writer_stage_cl_distance       = 4;
localparam          [5 - 1      : 0]                    compiler_writer_stage_encoder           = 5;
    

//K1_compiler_main_loop_flag
always @(negedge clk) begin
if (K1_compiler_main_loop_flag == 1) begin
    lagger_K1 = lagger_K1 + 1;

    if (lagger_K1 == 1) begin

        //     8 bits for: hlit_cl
        compiler_writer_stage = compiler_writer_stage_single_value;

        $display("\n\nK1: 8 bits for: hlit_cl:%d (%b)", hlit_cl, hlit_cl);

        input_bits_to_writer_K = hlit_cl;
        input_bits_to_writer_count_K = 8;

        K1_compiler_main_loop_flag = 0;
        // setting and launching K6
        lagger_K6 = 0;
        K6_complier_write_to_bitstream_flag = 1;
        

    end else if (lagger_K1 == 2) begin
        compiler_writer_stage = compiler_writer_stage_cl_cl_ll;

        $display("\n\nK1: starting to write cl_cl_ll");

        K1_compiler_main_loop_flag = 0;
        // setting and launching K2
        lagger_K2 = 0;
        counter_K2 = 0;
        K2_compiler_write_down_compiler_input_cl_cl_ll_pre_bitstream_flag = 1;



    end else if (lagger_K1 == 3) begin

        //     8 bits for: hdist_cl
        compiler_writer_stage = compiler_writer_stage_single_value;

        $display("\n\nK1: 8 bits for: hdist_cl:%d (%b)", hdist_cl, hdist_cl);

        input_bits_to_writer_K = hdist_cl;
        input_bits_to_writer_count_K = 8;

        K1_compiler_main_loop_flag = 0;
        // setting and launching K6
        lagger_K6 = 0;
        K6_complier_write_to_bitstream_flag = 1;
        



    end else if (lagger_K1 == 4) begin
        compiler_writer_stage = compiler_writer_stage_cl_cl_distance;

        $display("\n\nK1: starting to write cl_cl_distance");

        K1_compiler_main_loop_flag = 0;
        // setting and launching K2
        lagger_K3 = 0;
        counter_K3 = 0;
        K3_compiler_write_down_compiler_input_cl_cl_distance_pre_bitstream_flag = 1;





    end else if (lagger_K1 == 5) begin

        //     8 bits for: hlit
        compiler_writer_stage = compiler_writer_stage_single_value;

        $display("\n\nK1: 8 bits for: hlit:%d (%b)", hlit, hlit);

        input_bits_to_writer_K = hlit;
        input_bits_to_writer_count_K = 8;

        K1_compiler_main_loop_flag = 0;
        // setting and launching K6
        lagger_K6 = 0;
        K6_complier_write_to_bitstream_flag = 1;
        



    end else if (lagger_K1 == 6) begin

        //     8 bits for: hdist
        compiler_writer_stage = compiler_writer_stage_single_value;

        $display("\n\nK1: 8 bits for: hdist:%d (%b)", hdist, hdist);

        input_bits_to_writer_K = hdist;
        input_bits_to_writer_count_K = 8;

        K1_compiler_main_loop_flag = 0;
        // setting and launching K6
        lagger_K6 = 0;
        K6_complier_write_to_bitstream_flag = 1;
        



    end else if (lagger_K1 == 7) begin

        //         10 bits for: bit length of ll_cl_fully_encoded
        compiler_writer_stage = compiler_writer_stage_single_value;

        $display("\n\nK1: 10 bits for: recode_cl_total_bits_to_write_ll:%d (%b)", recode_cl_total_bits_to_write_ll, recode_cl_total_bits_to_write_ll);

        input_bits_to_writer_K = recode_cl_total_bits_to_write_ll;
        input_bits_to_writer_count_K = 10;

        K1_compiler_main_loop_flag = 0;
        // setting and launching K6
        lagger_K6 = 0;
        K6_complier_write_to_bitstream_flag = 1;
        


    end else if (lagger_K1 == 8) begin

        //         10 bits for: bit length of dd_cl_fully_encoded
        compiler_writer_stage = compiler_writer_stage_single_value;

        $display("\n\nK1: 10 bits for: recode_cl_total_bits_to_write_distance:%d (%b)", recode_cl_total_bits_to_write_distance, recode_cl_total_bits_to_write_distance);

        input_bits_to_writer_K = recode_cl_total_bits_to_write_distance;
        input_bits_to_writer_count_K = 10;

        K1_compiler_main_loop_flag = 0;
        // setting and launching K6
        lagger_K6 = 0;
        K6_complier_write_to_bitstream_flag = 1;
        

        


    end else if (lagger_K1 == 9) begin
        compiler_writer_stage = compiler_writer_stage_cl_ll;

        $display("\n\nK1: starting to write cl_ll");

        K1_compiler_main_loop_flag = 0;
        // setting and launching K4
        lagger_K4 = 0;
        counter_K4 = 0;
        K4_compiler_write_down_compiler_input_cl_ll_pre_bitstream_flag = 1;







    end else if (lagger_K1 == 10) begin
        compiler_writer_stage = compiler_writer_stage_cl_distance;

        $display("\n\nK1: starting to write cl_distance");

        K1_compiler_main_loop_flag = 0;
        // setting and launching K4
        lagger_K5 = 0;
        counter_K5 = 0;
        K5_compiler_write_down_compiler_input_cl_distance_pre_bitstream_flag = 1;






    end else if (lagger_K1 == 11) begin
        compiler_writer_stage = compiler_writer_stage_encoder;

        $display("\n\nK1: starting the encoder");

        K1_compiler_main_loop_flag = 0;
        // setting and launching K4
        counter_N1 = 0;
        lagger_N1 = 0;
        N1_encoder_main_loop_flag = 1;






    end else if (lagger_K1 == 12) begin
            
        K1_compiler_main_loop_flag = 0;
        //setting and launching K7
        counter_K7 = 0;
        lagger_K7 = 0;
        K7_dump_header_pre_bitstream_flag = 1;
    
    end 
end
end






























// K2

// flag
reg                                                     K2_compiler_write_down_compiler_input_cl_cl_ll_pre_bitstream_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_K2;
reg                 [q_full - 1 : 0]                    lagger_K2;

// K2 variables

//     3 bits per el for el in ll_cl_cl_table

//K2_compiler_write_down_compiler_input_cl_cl_ll_pre_bitstream_flag
always @(negedge clk) begin
if (K2_compiler_write_down_compiler_input_cl_cl_ll_pre_bitstream_flag == 1) begin
    lagger_K2 = lagger_K2 + 1;

    if (lagger_K2 == 1) begin
        compiler_input_cl_cl_ll_pre_bitstream_mem_read_addr = counter_K2;

    end else if (lagger_K2 == 2) begin
        input_bits_to_writer_K = compiler_input_cl_cl_ll_pre_bitstream_mem_read_data[15 : 0];
        input_bits_to_writer_count_K = 3;

        K2_compiler_write_down_compiler_input_cl_cl_ll_pre_bitstream_flag = 0;
        // setting and launching K6
        lagger_K6 = 0;
        K6_complier_write_to_bitstream_flag = 1;
       

    end else if (lagger_K2 == 3) begin

        if (counter_K2 < count_of_pre_bitstream_for_reordered_cl_cl_values_ll - 1) begin
            counter_K2 = counter_K2 + 1;

        end else begin
            K2_compiler_write_down_compiler_input_cl_cl_ll_pre_bitstream_flag = 0;
            
            // $display("K2: finished dumping compiler_input_cl_cl_ll_pre_bitstream at %d", $time);

            K1_compiler_main_loop_flag = 1;

        end

        lagger_K2 = 0;
    
    end 
end
end







// K3

// flag
reg                                                     K3_compiler_write_down_compiler_input_cl_cl_distance_pre_bitstream_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_K3;
reg                 [q_full - 1 : 0]                    lagger_K3;

// K3 variables

//     3 bits per el for el in distance_cl_cl_table

//K3_compiler_write_down_compiler_input_cl_cl_distance_pre_bitstream_flag
always @(negedge clk) begin
if (K3_compiler_write_down_compiler_input_cl_cl_distance_pre_bitstream_flag == 1) begin
    lagger_K3 = lagger_K3 + 1;

    if (lagger_K3 == 1) begin
        compiler_input_cl_cl_distance_pre_bitstream_mem_read_addr = counter_K3;

    end else if (lagger_K3 == 2) begin
        input_bits_to_writer_K = compiler_input_cl_cl_distance_pre_bitstream_mem_read_data[15 : 0];
        input_bits_to_writer_count_K = 3;

        K3_compiler_write_down_compiler_input_cl_cl_distance_pre_bitstream_flag = 0;
        // setting and launching K6
        lagger_K6 = 0;
        K6_complier_write_to_bitstream_flag = 1;
       

    end else if (lagger_K3 == 3) begin

        if (counter_K3 < count_of_pre_bitstream_for_reordered_cl_cl_values_distance - 1) begin
            counter_K3 = counter_K3 + 1;

        end else begin
            K3_compiler_write_down_compiler_input_cl_cl_distance_pre_bitstream_flag = 0;
            
            // $display("K3: finished dumping compiler_input_cl_cl_distance_pre_bitstream at %d", $time);

            K1_compiler_main_loop_flag = 1;

        end

        lagger_K3 = 0;
    
    end 
end
end












































// K4


// flag
reg                                                     K4_compiler_write_down_compiler_input_cl_ll_pre_bitstream_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_K4;
reg                 [q_full - 1 : 0]                    lagger_K4;

// K4 variables

//     var bits for: ll_cl_fully_encoded

//K4_compiler_write_down_compiler_input_cl_ll_pre_bitstream_flag
always @(negedge clk) begin
if (K4_compiler_write_down_compiler_input_cl_ll_pre_bitstream_flag == 1) begin
    lagger_K4 = lagger_K4 + 1;

    if (lagger_K4 == 1) begin
        compiler_input_cl_ll_pre_bitstream_mem_read_addr = counter_K4;

    end else if (lagger_K4 == 2) begin
        input_bits_to_writer_K = compiler_input_cl_ll_pre_bitstream_mem_read_data[15 : 0];
        input_bits_to_writer_count_K = compiler_input_cl_ll_pre_bitstream_mem_read_data[20 : 16];

        K4_compiler_write_down_compiler_input_cl_ll_pre_bitstream_flag = 0;
        // setting and launching K6
        lagger_K6 = 0;
        K6_complier_write_to_bitstream_flag = 1;
       

    end else if (lagger_K4 == 3) begin

        if (counter_K4 < cl_codings_pre_bitstream_words_count_ll - 1) begin
            counter_K4 = counter_K4 + 1;

        end else begin
            K4_compiler_write_down_compiler_input_cl_ll_pre_bitstream_flag = 0;
            
            // $display("K4: finished dumping compiler_input_cl_ll_pre_bitstream at %d", $time);

            K1_compiler_main_loop_flag = 1;

        end

        lagger_K4 = 0;
    
    end 
end
end




// K5


// flag
reg                                                     K5_compiler_write_down_compiler_input_cl_distance_pre_bitstream_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_K5;
reg                 [q_full - 1 : 0]                    lagger_K5;

// K5 variables

//     var bits for: distance_cl_fully_encoded

//K5_compiler_write_down_compiler_input_cl_distance_pre_bitstream_flag
always @(negedge clk) begin
if (K5_compiler_write_down_compiler_input_cl_distance_pre_bitstream_flag == 1) begin
    lagger_K5 = lagger_K5 + 1;

    if (lagger_K5 == 1) begin
        compiler_input_cl_distance_pre_bitstream_mem_read_addr = counter_K5;

    end else if (lagger_K5 == 2) begin
        input_bits_to_writer_K = compiler_input_cl_distance_pre_bitstream_mem_read_data[15 : 0];
        input_bits_to_writer_count_K = compiler_input_cl_distance_pre_bitstream_mem_read_data[20 : 16];

        K5_compiler_write_down_compiler_input_cl_distance_pre_bitstream_flag = 0;
        // setting and launching K6
        lagger_K6 = 0;
        K6_complier_write_to_bitstream_flag = 1;
       

    end else if (lagger_K5 == 3) begin

        if (counter_K5 < cl_codings_pre_bitstream_words_count_distance - 1) begin
            counter_K5 = counter_K5 + 1;

        end else begin
            K5_compiler_write_down_compiler_input_cl_distance_pre_bitstream_flag = 0;
            
            // $display("K5: finished dumping compiler_input_cl_distance_pre_bitstream at %d", $time);

            K1_compiler_main_loop_flag = 1;

        end

        lagger_K5 = 0;
    
    end 
end
end



























// K6

// flag
reg                                                     K6_complier_write_to_bitstream_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    lagger_K6;

// K2 variables
reg                 [input_bits_to_writer_width - 1: 0] input_bits_to_writer_K;
reg                 [6 - 1      : 0]                    input_bits_to_writer_count_K;

    

//K6_complier_write_to_bitstream_flag
always @(negedge clk) begin
if (K6_complier_write_to_bitstream_flag == 1) begin
    lagger_K6 = lagger_K6 + 1;

    if (lagger_K6 == 1) begin
        header_pre_bitstream_mem_write_data = input_bits_to_writer_count_K << 16;
        header_pre_bitstream_mem_write_data = header_pre_bitstream_mem_write_data | input_bits_to_writer_K;

        total_header_bits = total_header_bits + input_bits_to_writer_count_K;

    end else if (lagger_K6 == 2) begin
        header_pre_bitstream_mem_write_enable = 1;

    end else if (lagger_K6 == 3) begin
        header_pre_bitstream_mem_write_enable = 0;

    end else if (lagger_K6 == 4) begin
        header_pre_bitstream_mem_write_addr = header_pre_bitstream_mem_write_addr + 1;
        $display("-\t\t\tK6: wrote: %b,  next addr: %d", header_pre_bitstream_mem_write_data, header_pre_bitstream_mem_write_addr);
    end else if (lagger_K6 == 5) begin
        K6_complier_write_to_bitstream_flag = 0;


        case (compiler_writer_stage)
            compiler_writer_stage_single_value  :       K1_compiler_main_loop_flag                                              = 1;
            compiler_writer_stage_cl_cl_ll      :       K2_compiler_write_down_compiler_input_cl_cl_ll_pre_bitstream_flag       = 1;
            compiler_writer_stage_cl_cl_distance:       K3_compiler_write_down_compiler_input_cl_cl_distance_pre_bitstream_flag = 1;
            compiler_writer_stage_cl_ll         :       K4_compiler_write_down_compiler_input_cl_ll_pre_bitstream_flag          = 1;
            compiler_writer_stage_cl_distance   :       K5_compiler_write_down_compiler_input_cl_distance_pre_bitstream_flag    = 1;
            compiler_writer_stage_encoder       :       N1_encoder_main_loop_flag                                               = 1;
        
        endcase

        
    
    end 
end
end
















// K7

// flag
reg                                                     K7_dump_header_pre_bitstream_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_K7;
reg                 [q_full - 1 : 0]                    lagger_K7;

// K7 variables

//K7_dump_header_pre_bitstream_flag
always @(negedge clk) begin
if (K7_dump_header_pre_bitstream_flag == 1) begin
    lagger_K7 = lagger_K7 + 1;

    if (lagger_K7 == 1) begin
        header_pre_bitstream_mem_read_addr = counter_K7;

    end else if (lagger_K7 == 2) begin
        $fdisplayb(K7_output_file_header_pre_bitstream_mem, header_pre_bitstream_mem_read_data);

    end else if (lagger_K7 == 3) begin

        if (counter_K7 < header_pre_bitstream_mem_write_addr - 1) begin
            counter_K7 = counter_K7 + 1;

        end else begin
            $fclose(K7_output_file_header_pre_bitstream_mem);
            K7_dump_header_pre_bitstream_flag = 0;
            
            // $display("K7: finished dumping header_pre_bitstream at %d", $time);


            $fdisplayb(K_output_file_general, header_pre_bitstream_mem_write_addr);
            $fdisplayb(K_output_file_general, total_header_bits);
            $fclose(K_output_file_general);


            //setting and launching K7
            //counter_K7 = 0;
            //lagger_K7 = 0;
            //next_flag_K7 = 1;


            $display("FINISHED_______________________________________%d", $time);

        end

        lagger_K7 = 0;
    
    end 
end
end








/*

LZSS OUTPUT

    this is what we get from running lzss
    once we have our canonical huffman codes ready, 
    we use them to encode the symbols stored in this ram
    
    bits from left to right:
    bit 0: 
        is zero if the entry is a literal 
        is one if the entry is length-distance description


    length/literal symbol:      9
    length offset bits count:   3
    length offset bits:         5
    distance symbol:            5
    distance offset bits count: 4
    distance offset bits:       13

    sum = 40
        l-sym             l offsetbits c    l offsetbits    d-symbol    d-offsetbtis-c   dis-offset bits-count
    0   000000000          000                 00000          00000          0000          0000000000000
    39  38     30         29 27               26   22        21   17        16  13        12           0






huffman_codes



    bits:
    [40 : 32] starting at  0, len of 9 : symbol value in 9 bits
    [31 : 20] starting at  9, len of 12: code length            ; cl_F
    [19 :  0] starting at 21, len of 20 : huffman code itself

    total width of the bus = 41 (huffman_codes_width)

    40     32  31        20  19                 0
    000000000  000000000000  00000000000000000000
    
    
*/






// N1

// flag
reg                                                     N1_encoder_main_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_N1;
reg                 [q_full - 1 : 0]                    lagger_N1;

// N1 variables
    

//N1_encoder_main_loop_flag
always @(negedge clk) begin
if (N1_encoder_main_loop_flag == 1) begin
    lagger_N1 = lagger_N1 + 1;

    if (lagger_N1 == 1) begin

        compiler_input_lzss_output_mem_read_addr = counter_N1;
        




    end else if (lagger_N1 == 2) begin
        compiler_input_ll_codes_mem_read_addr = compiler_input_lzss_output_mem_read_data[38 : 30];


    end else if (lagger_N1 == 3) begin

        // $display("N1: huffman code for the length/literal. length %d, code:%b", input_bits_to_writer_count_K, input_bits_to_writer_K);

        input_bits_to_writer_K = compiler_input_ll_codes_mem_read_data[19 : 0];
        input_bits_to_writer_count_K = compiler_input_ll_codes_mem_read_data[31 : 20];

        N1_encoder_main_loop_flag = 0;
        // setting and launching K6
        lagger_K6 = 0;
        K6_complier_write_to_bitstream_flag = 1;




    end else if (lagger_N1 == 4) begin

        // length distance pair

        // coding length symbol offset bits

        if (compiler_input_lzss_output_mem_read_data[lzss_output_width - 1]) begin

            input_bits_to_writer_K = compiler_input_lzss_output_mem_read_data[26 : 22];
            input_bits_to_writer_count_K = compiler_input_lzss_output_mem_read_data[29 : 27];

            N1_encoder_main_loop_flag = 0;
            // setting and launching K6
            lagger_K6 = 0;
            K6_complier_write_to_bitstream_flag = 1;

        end 



    end else if (lagger_N1 == 5) begin

        // length distance pair

        if (compiler_input_lzss_output_mem_read_data[lzss_output_width - 1]) begin

            compiler_input_distance_codes_mem_read_addr = compiler_input_lzss_output_mem_read_data[21 : 17];

        end 





    end else if (lagger_N1 == 6) begin

        // length distance pair

        // coding the distance symbol

        if (compiler_input_lzss_output_mem_read_data[lzss_output_width - 1]) begin

            input_bits_to_writer_K = compiler_input_distance_codes_mem_read_data[19 : 0];
            input_bits_to_writer_count_K = compiler_input_distance_codes_mem_read_data[31 : 20];

            N1_encoder_main_loop_flag = 0;
            // setting and launching K6
            lagger_K6 = 0;
            K6_complier_write_to_bitstream_flag = 1;
        end 





    end else if (lagger_N1 == 7) begin

        // length distance pair

        // coding distance symbol offset bits

        if (compiler_input_lzss_output_mem_read_data[lzss_output_width - 1]) begin

            input_bits_to_writer_K = compiler_input_lzss_output_mem_read_data[12 : 0];
            input_bits_to_writer_count_K = compiler_input_lzss_output_mem_read_data[16 : 13];

            N1_encoder_main_loop_flag = 0;
            // setting and launching K6
            lagger_K6 = 0;
            K6_complier_write_to_bitstream_flag = 1;

        end 






    end else if (lagger_N1 == 8) begin

        if (counter_N1 < lzss_outputs_count - 1) begin
            counter_N1 = counter_N1 + 1;

        end else begin
            
            N1_encoder_main_loop_flag = 0;
            
            
            K1_compiler_main_loop_flag = 1;

        end

        lagger_N1 = 0;
    
    end 
end
end




















            

endmodule


            
