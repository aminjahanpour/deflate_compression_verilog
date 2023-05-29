

    reg                                             		recode_input_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				recode_input_mem_read_addr      ;
    wire                [pre_bitstream_width - 1 	 : 0]    				recode_input_mem_read_data      ;
    reg                                             		recode_input_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				recode_input_mem_write_addr     ;
    reg                 [pre_bitstream_width - 1 	 : 0]    				recode_input_mem_write_data     ;

    memory_list #(
        .mem_width(pre_bitstream_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file("./input.txt")

    ) recode_input_mem(
        .clk(clk),
        .r_en(  recode_input_mem_read_enable),
        .r_addr(recode_input_mem_read_addr),
        .r_data(recode_input_mem_read_data),
        .w_en(  recode_input_mem_write_enable),
        .w_addr(recode_input_mem_write_addr),
        .w_data(recode_input_mem_write_data)
    );




                

    reg                                             		recode_config_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				recode_config_mem_read_addr      ;
    wire                [q_full - 1 	 : 0]    				recode_config_mem_read_data      ;
    reg                                             		recode_config_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				recode_config_mem_write_addr     ;
    reg                 [q_full - 1 	 : 0]    				recode_config_mem_write_data     ;

    memory_list #(
        .mem_width(q_full),
        .address_len(address_len),
        .mem_depth(5),
        .initial_file("./config.txt")

    ) recode_config_mem(
        .clk(clk),
        .r_en(  recode_config_mem_read_enable),
        .r_addr(recode_config_mem_read_addr),
        .r_data(recode_config_mem_read_data),
        .w_en(  recode_config_mem_write_enable),
        .w_addr(recode_config_mem_write_addr),
        .w_data(recode_config_mem_write_data)
    );




                

    reg                                             		recode_codes_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				recode_codes_mem_read_addr      ;
    wire                [huffman_codes_width - 1 	 : 0]    				recode_codes_mem_read_data      ;
    reg                                             		recode_codes_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				recode_codes_mem_write_addr     ;
    reg                 [huffman_codes_width - 1 	 : 0]    				recode_codes_mem_write_data     ;

    memory_list #(
        .mem_width(huffman_codes_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file("./codes.txt")

    ) recode_codes_mem(
        .clk(clk),
        .r_en(  recode_codes_mem_read_enable),
        .r_addr(recode_codes_mem_read_addr),
        .r_data(recode_codes_mem_read_data),
        .w_en(  recode_codes_mem_write_enable),
        .w_addr(recode_codes_mem_write_addr),
        .w_data(recode_codes_mem_write_data)
    );




                

    reg                                             		recoded_cl_encoding_pre_bitstream_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				recoded_cl_encoding_pre_bitstream_mem_read_addr      ;
    wire                [pre_bitstream_width - 1 	 : 0]    				recoded_cl_encoding_pre_bitstream_mem_read_data      ;
    reg                                             		recoded_cl_encoding_pre_bitstream_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				recoded_cl_encoding_pre_bitstream_mem_write_addr     ;
    reg                 [pre_bitstream_width - 1 	 : 0]    				recoded_cl_encoding_pre_bitstream_mem_write_data     ;

    memory_list #(
        .mem_width(pre_bitstream_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file(0)

    ) recoded_cl_encoding_pre_bitstream_mem(
        .clk(clk),
        .r_en(  recoded_cl_encoding_pre_bitstream_mem_read_enable),
        .r_addr(recoded_cl_encoding_pre_bitstream_mem_read_addr),
        .r_data(recoded_cl_encoding_pre_bitstream_mem_read_data),
        .w_en(  recoded_cl_encoding_pre_bitstream_mem_write_enable),
        .w_addr(recoded_cl_encoding_pre_bitstream_mem_write_addr),
        .w_data(recoded_cl_encoding_pre_bitstream_mem_write_data)
    );




                

    reg                                             		recode_cl_cl_reordered_pre_bitstream_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				recode_cl_cl_reordered_pre_bitstream_mem_read_addr      ;
    wire                [pre_bitstream_width - 1 	 : 0]    				recode_cl_cl_reordered_pre_bitstream_mem_read_data      ;
    reg                                             		recode_cl_cl_reordered_pre_bitstream_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				recode_cl_cl_reordered_pre_bitstream_mem_write_addr     ;
    reg                 [pre_bitstream_width - 1 	 : 0]    				recode_cl_cl_reordered_pre_bitstream_mem_write_data     ;

    memory_list #(
        .mem_width(pre_bitstream_width),
        .address_len(address_len),
        .mem_depth(cl_cl_count),
        .initial_file(0)

    ) recode_cl_cl_reordered_pre_bitstream_mem(
        .clk(clk),
        .r_en(  recode_cl_cl_reordered_pre_bitstream_mem_read_enable),
        .r_addr(recode_cl_cl_reordered_pre_bitstream_mem_read_addr),
        .r_data(recode_cl_cl_reordered_pre_bitstream_mem_read_data),
        .w_en(  recode_cl_cl_reordered_pre_bitstream_mem_write_enable),
        .w_addr(recode_cl_cl_reordered_pre_bitstream_mem_write_addr),
        .w_data(recode_cl_cl_reordered_pre_bitstream_mem_write_data)
    );




                