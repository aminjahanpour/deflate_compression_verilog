

    reg                                             		cl_decode_codes_cl_ll_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				cl_decode_codes_cl_ll_mem_read_addr      ;
    wire                [huffman_codes_width - 1 	 : 0]    				cl_decode_codes_cl_ll_mem_read_data      ;
    reg                                             		cl_decode_codes_cl_ll_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				cl_decode_codes_cl_ll_mem_write_addr     ;
    reg                 [huffman_codes_width - 1 	 : 0]    				cl_decode_codes_cl_ll_mem_write_data     ;

    memory_list #(
        .mem_width(huffman_codes_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file("./codes_cl_ll.txt")

    ) cl_decode_codes_cl_ll_mem(
        .clk(clk),
        .r_en(  cl_decode_codes_cl_ll_mem_read_enable),
        .r_addr(cl_decode_codes_cl_ll_mem_read_addr),
        .r_data(cl_decode_codes_cl_ll_mem_read_data),
        .w_en(  cl_decode_codes_cl_ll_mem_write_enable),
        .w_addr(cl_decode_codes_cl_ll_mem_write_addr),
        .w_data(cl_decode_codes_cl_ll_mem_write_data)
    );




                

    reg                                             		cl_decode_codes_cl_distance_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				cl_decode_codes_cl_distance_mem_read_addr      ;
    wire                [huffman_codes_width - 1 	 : 0]    				cl_decode_codes_cl_distance_mem_read_data      ;
    reg                                             		cl_decode_codes_cl_distance_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				cl_decode_codes_cl_distance_mem_write_addr     ;
    reg                 [huffman_codes_width - 1 	 : 0]    				cl_decode_codes_cl_distance_mem_write_data     ;

    memory_list #(
        .mem_width(huffman_codes_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file("./codes_cl_distance.txt")

    ) cl_decode_codes_cl_distance_mem(
        .clk(clk),
        .r_en(  cl_decode_codes_cl_distance_mem_read_enable),
        .r_addr(cl_decode_codes_cl_distance_mem_read_addr),
        .r_data(cl_decode_codes_cl_distance_mem_read_data),
        .w_en(  cl_decode_codes_cl_distance_mem_write_enable),
        .w_addr(cl_decode_codes_cl_distance_mem_write_addr),
        .w_data(cl_decode_codes_cl_distance_mem_write_data)
    );




                

    reg                                             		cl_decode_config_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				cl_decode_config_mem_read_addr      ;
    wire                [q_full - 1 	 : 0]    				cl_decode_config_mem_read_data      ;
    reg                                             		cl_decode_config_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				cl_decode_config_mem_write_addr     ;
    reg                 [q_full - 1 	 : 0]    				cl_decode_config_mem_write_data     ;

    memory_list #(
        .mem_width(q_full),
        .address_len(address_len),
        .mem_depth(20),
        .initial_file("./config.txt")

    ) cl_decode_config_mem(
        .clk(clk),
        .r_en(  cl_decode_config_mem_read_enable),
        .r_addr(cl_decode_config_mem_read_addr),
        .r_data(cl_decode_config_mem_read_data),
        .w_en(  cl_decode_config_mem_write_enable),
        .w_addr(cl_decode_config_mem_write_addr),
        .w_data(cl_decode_config_mem_write_data)
    );




                

    reg                                             		cl_decode_cl_ll_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				cl_decode_cl_ll_mem_read_addr      ;
    wire                [huffman_codes_width - 1 	 : 0]    				cl_decode_cl_ll_mem_read_data      ;
    reg                                             		cl_decode_cl_ll_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				cl_decode_cl_ll_mem_write_addr     ;
    reg                 [huffman_codes_width - 1 	 : 0]    				cl_decode_cl_ll_mem_write_data     ;

    memory_list #(
        .mem_width(huffman_codes_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file(0)

    ) cl_decode_cl_ll_mem(
        .clk(clk),
        .r_en(  cl_decode_cl_ll_mem_read_enable),
        .r_addr(cl_decode_cl_ll_mem_read_addr),
        .r_data(cl_decode_cl_ll_mem_read_data),
        .w_en(  cl_decode_cl_ll_mem_write_enable),
        .w_addr(cl_decode_cl_ll_mem_write_addr),
        .w_data(cl_decode_cl_ll_mem_write_data)
    );




                

    reg                                             		cl_decode_cl_distance_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				cl_decode_cl_distance_mem_read_addr      ;
    wire                [huffman_codes_width - 1 	 : 0]    				cl_decode_cl_distance_mem_read_data      ;
    reg                                             		cl_decode_cl_distance_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				cl_decode_cl_distance_mem_write_addr     ;
    reg                 [huffman_codes_width - 1 	 : 0]    				cl_decode_cl_distance_mem_write_data     ;

    memory_list #(
        .mem_width(huffman_codes_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file(0)

    ) cl_decode_cl_distance_mem(
        .clk(clk),
        .r_en(  cl_decode_cl_distance_mem_read_enable),
        .r_addr(cl_decode_cl_distance_mem_read_addr),
        .r_data(cl_decode_cl_distance_mem_read_data),
        .w_en(  cl_decode_cl_distance_mem_write_enable),
        .w_addr(cl_decode_cl_distance_mem_write_addr),
        .w_data(cl_decode_cl_distance_mem_write_data)
    );




                

    reg                                             		cl_decode_extracted_cl_symbols_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				cl_decode_extracted_cl_symbols_mem_read_addr      ;
    wire                [9 - 1 	 : 0]    				cl_decode_extracted_cl_symbols_mem_read_data      ;
    reg                                             		cl_decode_extracted_cl_symbols_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				cl_decode_extracted_cl_symbols_mem_write_addr     ;
    reg                 [9 - 1 	 : 0]    				cl_decode_extracted_cl_symbols_mem_write_data     ;

    memory_list #(
        .mem_width(9),
        .address_len(address_len),
        .mem_depth(input_bytes_count),
        .initial_file(0)

    ) cl_decode_extracted_cl_symbols_mem(
        .clk(clk),
        .r_en(  cl_decode_extracted_cl_symbols_mem_read_enable),
        .r_addr(cl_decode_extracted_cl_symbols_mem_read_addr),
        .r_data(cl_decode_extracted_cl_symbols_mem_read_data),
        .w_en(  cl_decode_extracted_cl_symbols_mem_write_enable),
        .w_addr(cl_decode_extracted_cl_symbols_mem_write_addr),
        .w_data(cl_decode_extracted_cl_symbols_mem_write_data)
    );




                