

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




                