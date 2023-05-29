

/*

Task 1)
here we take the pre-bitstream words (output from cl coding)
and apply the huffman coding (generated based on their symbol).
results will again be a pre-bitstream memory.

note that huffman codes will apply only on the 5-bit symbols
which range from 0 to 18 (inclusive).
We do not encode offset bits which follow after symbols 16, 17, and 18.
they are written as they are.


Task 2)
we also take the code length of the cl huffman codes and rearrange them
according to the deflate standard.
then we find the hlit value of the reordered cl values.
outputs:
    - pre-bitstream of the reordered cl values.
    - hlit_cl


*/


// IC

// flag
reg                                                     IC_read_config_file_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    lagger_IC;

reg                 [q_full - 1 : 0]                    config_input_words_count_I;
reg                 [q_full - 1 : 0]                    recode_cl_total_bits_to_write;

//IC_read_config_file_flag
always @(negedge clk) begin
if (IC_read_config_file_flag == 1) begin
    lagger_IC = lagger_IC + 1;

    if (lagger_IC == 1) begin
        recode_config_mem_read_addr = 0;
        
    end else if (lagger_IC == 2) begin
        config_input_words_count_I = recode_config_mem_read_data;
        
    end else if (lagger_IC == 3) begin
        cl_cl_order[0] = 5'd16;
        cl_cl_order[1] = 5'd17;
        cl_cl_order[2] = 5'd18;
        cl_cl_order[3] = 5'd0;
        cl_cl_order[4] = 5'd8;
        cl_cl_order[5] = 5'd7;
        cl_cl_order[6] = 5'd9;
        cl_cl_order[7] = 5'd6;
        cl_cl_order[8] = 5'd10;
        cl_cl_order[9] = 5'd5;
        cl_cl_order[10] = 5'd11;
        cl_cl_order[11] = 5'd4;
        cl_cl_order[12] = 5'd12;
        cl_cl_order[13] = 5'd3;
        cl_cl_order[14] = 5'd13;
        cl_cl_order[15] = 5'd2;
        cl_cl_order[16] = 5'd14;
        cl_cl_order[17] = 5'd1;
        cl_cl_order[18] = 5'd15;

    end else if (lagger_IC == 4) begin
    
        IC_read_config_file_flag = 0;
        
        $display("IC: config file read.");
        $display("IC: config_input_words_count_I: %d", config_input_words_count_I);

        //setting and launching I1
        recoded_cl_encoding_pre_bitstream_mem_write_addr  = 0;
        counter_I1                           = 0;
        lagger_I1                            = 0;
        recode_cl_total_bits_to_write          = 0;
        I1_main_loop_flag                   = 1;
    
    end 
end
end















// I1

// flag
reg                                                     I1_main_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_I1;
reg                 [q_full - 1 : 0]                    lagger_I1;

// I1 variables

    

//I1_main_loop_flag
always @(negedge clk) begin
if (I1_main_loop_flag == 1) begin
    lagger_I1 = lagger_I1 + 1;

    if (lagger_I1 == 1) begin
        recode_input_mem_read_addr = counter_I1;


    end else if (lagger_I1 == 2) begin

        $display("\nI1: counter_I1: %d. read data: %d", counter_I1, recode_input_mem_read_data[15 : 0]);


        I1_main_loop_flag           = 0;
        // setting and launching I2
        lagger_I2                   = 0;
        I2_recode_input_word_flag   = 1;
        

    end else if (lagger_I1 == 3) begin

        if (counter_I1 < config_input_words_count_I - 1) begin
            counter_I1 = counter_I1 + 1;

        end else begin

            
            I1_main_loop_flag = 0;
            // setting and launching I4
            counter_I4                          = 0;
            lagger_I4                           = 0;
            I4_dump_recode_pre_bitstream_flag   = 1;
            
        end

        lagger_I1 = 0;
    
    end 
end
end














// I2

// flag
reg                                                     I2_recode_input_word_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    lagger_I2;
reg                                                     greater_than_15;
// I2 variables

    

//I2_recode_input_word_flag
always @(negedge clk) begin
if (I2_recode_input_word_flag == 1) begin
    lagger_I2 = lagger_I2 + 1;

    if (lagger_I2 == 1) begin
        if (recode_input_mem_read_data[15 : 0] > 15) begin
            greater_than_15 = 1;
        end else begin
            greater_than_15 = 0;
        end


    end else if (lagger_I2 == 2) begin
        recode_codes_mem_read_addr = recode_input_mem_read_data[15 : 0];


    end else if (lagger_I2 == 3) begin

        I2_recode_input_word_flag               = 0;
        // setting and launching I3
        input_bits_to_writer_I                  = recode_codes_mem_read_data[19 : 0];
        input_bits_to_writer_count_I            = recode_codes_mem_read_data[31 : 20];
        lagger_I3                               = 0;
        I3_write_to_pre_bitstream_clcoding_flag = 1;

        $display("-\t\t\tI2: huffman code for %d is %d(%b)", recode_input_mem_read_data[15 : 0], recode_codes_mem_read_data[19 : 0],recode_codes_mem_read_data[19 : 0]);
        // $display("-\t\t\t\tI2: huffman code: %d", recode_codes_mem_read_data[19 : 0]);
        // $display("-\t\tI2: going to write %d, count: %d", input_bits_to_writer_I, input_bits_to_writer_count_I);

    end else if (lagger_I2 == 4) begin

        if (greater_than_15) begin
            counter_I1 = counter_I1+ 1;
            recode_input_mem_read_addr = counter_I1;


        end


    end else if (lagger_I2 == 5) begin

        if (greater_than_15) begin
            I2_recode_input_word_flag               = 0;
            // setting and launching I3
            input_bits_to_writer_I                  = recode_input_mem_read_data[15 :  0];
            input_bits_to_writer_count_I            = recode_input_mem_read_data[20 : 16];
            lagger_I3                               = 0;
            I3_write_to_pre_bitstream_clcoding_flag = 1;


            // $display("-\t\tI2: symbol is greater than 15. also writing %b, count: %d", input_bits_to_writer_I, input_bits_to_writer_count_I);

        end


    end else if (lagger_I2 == 6) begin

        I2_recode_input_word_flag   = 0;
        I1_main_loop_flag           = 1;

    end 
end
end













// I2

// flag
reg                                                     I3_write_to_pre_bitstream_clcoding_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    lagger_I3;

// I2 variables
reg                 [input_bits_to_writer_width - 1: 0] input_bits_to_writer_I;
reg                 [6 - 1      : 0]                    input_bits_to_writer_count_I;

    

//I3_write_to_pre_bitstream_clcoding_flag
always @(negedge clk) begin
if (I3_write_to_pre_bitstream_clcoding_flag == 1) begin
    lagger_I3 = lagger_I3 + 1;

    if (lagger_I3 == 1) begin
        recoded_cl_encoding_pre_bitstream_mem_write_data = input_bits_to_writer_count_I << 16;
        recoded_cl_encoding_pre_bitstream_mem_write_data = recoded_cl_encoding_pre_bitstream_mem_write_data | input_bits_to_writer_I;

        if (input_bits_to_writer_I > 2 << (input_bits_to_writer_count_I - 1)) begin
            
            $display("\n\n\n\n !!!!!!  writing a value larger than its bus width! \n\n\n\n");

        end



        recode_cl_total_bits_to_write = recode_cl_total_bits_to_write + input_bits_to_writer_count_I;

    end else if (lagger_I3 == 2) begin
        recoded_cl_encoding_pre_bitstream_mem_write_enable = 1;

    end else if (lagger_I3 == 3) begin
        recoded_cl_encoding_pre_bitstream_mem_write_enable = 0;

    end else if (lagger_I3 == 4) begin
        recoded_cl_encoding_pre_bitstream_mem_write_addr = recoded_cl_encoding_pre_bitstream_mem_write_addr + 1;
        $display("-\t\t\t\t\t\tI3: wrote: %b, total_bits:%d,  next addr: %d", recoded_cl_encoding_pre_bitstream_mem_write_data, recode_cl_total_bits_to_write, recoded_cl_encoding_pre_bitstream_mem_write_addr);
    end else if (lagger_I3 == 5) begin
        I3_write_to_pre_bitstream_clcoding_flag = 0;
        I2_recode_input_word_flag = 1;
    
    end 
end
end














    
// I4

// flag
reg                                                     I4_dump_recode_pre_bitstream_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_I4;
reg                 [q_full - 1 : 0]                    lagger_I4;

// I4 variables

//I4_dump_recode_pre_bitstream_flag
always @(negedge clk) begin
if (I4_dump_recode_pre_bitstream_flag == 1) begin
    lagger_I4 = lagger_I4 + 1;

    if (lagger_I4 == 1) begin
        recoded_cl_encoding_pre_bitstream_mem_read_addr = counter_I4;

    end else if (lagger_I4 == 2) begin
        $fdisplayb(I4_output_file_recoded_cl_encoding_pre_bitstream_mem, recoded_cl_encoding_pre_bitstream_mem_read_data);

    end else if (lagger_I4 == 3) begin

        if (counter_I4 < recoded_cl_encoding_pre_bitstream_mem_write_addr - 1) begin
            counter_I4 = counter_I4 + 1;

        end else begin
            $fclose(I4_output_file_recoded_cl_encoding_pre_bitstream_mem);
            I4_dump_recode_pre_bitstream_flag = 0;
            
            $display("I4: finished dumping recode_pre_bitstream at %d", $time);


            //setting and launching J0
            counter_J0 = 0;
            lagger_J0 = 0;
            recode_cl_cl_reordered_pre_bitstream_mem_write_addr = 0;
            hlit_cl = 0;
            J0_apply_encoding_order_to_code_length_table_flag = 1;



        end

        lagger_I4 = 0;
    
    end 
end
end
