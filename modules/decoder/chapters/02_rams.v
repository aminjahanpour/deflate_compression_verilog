

    reg                                             		decoder_input_ll_codes_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				decoder_input_ll_codes_mem_read_addr      ;
    wire                [huffman_codes_width - 1 	 : 0]    				decoder_input_ll_codes_mem_read_data      ;
    reg                                             		decoder_input_ll_codes_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				decoder_input_ll_codes_mem_write_addr     ;
    reg                 [huffman_codes_width - 1 	 : 0]    				decoder_input_ll_codes_mem_write_data     ;

    memory_list #(
        .mem_width(huffman_codes_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file("./input_ll_codes.txt")

    ) decoder_input_ll_codes_mem(
        .clk(clk),
        .r_en(  decoder_input_ll_codes_mem_read_enable),
        .r_addr(decoder_input_ll_codes_mem_read_addr),
        .r_data(decoder_input_ll_codes_mem_read_data),
        .w_en(  decoder_input_ll_codes_mem_write_enable),
        .w_addr(decoder_input_ll_codes_mem_write_addr),
        .w_data(decoder_input_ll_codes_mem_write_data)
    );




                

    reg                                             		decoder_input_distance_codes_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				decoder_input_distance_codes_mem_read_addr      ;
    wire                [huffman_codes_width - 1 	 : 0]    				decoder_input_distance_codes_mem_read_data      ;
    reg                                             		decoder_input_distance_codes_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				decoder_input_distance_codes_mem_write_addr     ;
    reg                 [huffman_codes_width - 1 	 : 0]    				decoder_input_distance_codes_mem_write_data     ;

    memory_list #(
        .mem_width(huffman_codes_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file("./input_distance_codes.txt")

    ) decoder_input_distance_codes_mem(
        .clk(clk),
        .r_en(  decoder_input_distance_codes_mem_read_enable),
        .r_addr(decoder_input_distance_codes_mem_read_addr),
        .r_data(decoder_input_distance_codes_mem_read_data),
        .w_en(  decoder_input_distance_codes_mem_write_enable),
        .w_addr(decoder_input_distance_codes_mem_write_addr),
        .w_data(decoder_input_distance_codes_mem_write_data)
    );




                

    reg                                             		ll_symbols_table_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				ll_symbols_table_mem_read_addr      ;
    wire                [12 - 1 	 : 0]    				ll_symbols_table_mem_read_data      ;
    reg                                             		ll_symbols_table_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				ll_symbols_table_mem_write_addr     ;
    reg                 [12 - 1 	 : 0]    				ll_symbols_table_mem_write_data     ;

    memory_list #(
        .mem_width(12),
        .address_len(address_len),
        .mem_depth(29),
        .initial_file("./ll_symbols_table.mem")

    ) ll_symbols_table_mem(
        .clk(clk),
        .r_en(  ll_symbols_table_mem_read_enable),
        .r_addr(ll_symbols_table_mem_read_addr),
        .r_data(ll_symbols_table_mem_read_data),
        .w_en(  ll_symbols_table_mem_write_enable),
        .w_addr(ll_symbols_table_mem_write_addr),
        .w_data(ll_symbols_table_mem_write_data)
    );




                

    reg                                             		distance_symbols_table_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				distance_symbols_table_mem_read_addr      ;
    wire                [19 - 1 	 : 0]    				distance_symbols_table_mem_read_data      ;
    reg                                             		distance_symbols_table_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				distance_symbols_table_mem_write_addr     ;
    reg                 [19 - 1 	 : 0]    				distance_symbols_table_mem_write_data     ;

    memory_list #(
        .mem_width(19),
        .address_len(address_len),
        .mem_depth(30),
        .initial_file("./distance_symbols_table.mem")

    ) distance_symbols_table_mem(
        .clk(clk),
        .r_en(  distance_symbols_table_mem_read_enable),
        .r_addr(distance_symbols_table_mem_read_addr),
        .r_data(distance_symbols_table_mem_read_data),
        .w_en(  distance_symbols_table_mem_write_enable),
        .w_addr(distance_symbols_table_mem_write_addr),
        .w_data(distance_symbols_table_mem_write_data)
    );




                

    reg                                             		decoder_config_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				decoder_config_mem_read_addr      ;
    wire                [q_full - 1 	 : 0]    				decoder_config_mem_read_data      ;
    reg                                             		decoder_config_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				decoder_config_mem_write_addr     ;
    reg                 [q_full - 1 	 : 0]    				decoder_config_mem_write_data     ;

    memory_list #(
        .mem_width(q_full),
        .address_len(address_len),
        .mem_depth(20),
        .initial_file("./config.txt")

    ) decoder_config_mem(
        .clk(clk),
        .r_en(  decoder_config_mem_read_enable),
        .r_addr(decoder_config_mem_read_addr),
        .r_data(decoder_config_mem_read_data),
        .w_en(  decoder_config_mem_write_enable),
        .w_addr(decoder_config_mem_write_addr),
        .w_data(decoder_config_mem_write_data)
    );




                

    reg                                             		decoded_content_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				decoded_content_mem_read_addr      ;
    wire                [8 - 1 	 : 0]    				decoded_content_mem_read_data      ;
    reg                                             		decoded_content_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				decoded_content_mem_write_addr     ;
    reg                 [8 - 1 	 : 0]    				decoded_content_mem_write_data     ;

    memory_list #(
        .mem_width(8),
        .address_len(address_len),
        .mem_depth(input_bytes_count),
        .initial_file(0)

    ) decoded_content_mem(
        .clk(clk),
        .r_en(  decoded_content_mem_read_enable),
        .r_addr(decoded_content_mem_read_addr),
        .r_data(decoded_content_mem_read_data),
        .w_en(  decoded_content_mem_write_enable),
        .w_addr(decoded_content_mem_write_addr),
        .w_data(decoded_content_mem_write_data)
    );




                

    reg                                             		decoded_bits_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				decoded_bits_mem_read_addr      ;
    wire                [8 - 1 	 : 0]    				decoded_bits_mem_read_data      ;
    reg                                             		decoded_bits_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				decoded_bits_mem_write_addr     ;
    reg                 [8 - 1 	 : 0]    				decoded_bits_mem_write_data     ;

    memory_list #(
        .mem_width(8),
        .address_len(address_len),
        .mem_depth(input_bytes_count),
        .initial_file(0)

    ) decoded_bits_mem(
        .clk(clk),
        .r_en(  decoded_bits_mem_read_enable),
        .r_addr(decoded_bits_mem_read_addr),
        .r_data(decoded_bits_mem_read_data),
        .w_en(  decoded_bits_mem_write_enable),
        .w_addr(decoded_bits_mem_write_addr),
        .w_data(decoded_bits_mem_write_data)
    );




                