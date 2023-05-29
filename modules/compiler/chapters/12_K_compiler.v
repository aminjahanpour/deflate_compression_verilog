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







