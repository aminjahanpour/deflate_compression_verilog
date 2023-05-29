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


















