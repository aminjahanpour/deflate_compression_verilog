

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




                