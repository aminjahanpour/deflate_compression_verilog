

    reg                                             		input_bits_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				input_bits_mem_read_addr      ;
    wire                [8 - 1 	 : 0]    				input_bits_mem_read_data      ;
    reg                                             		input_bits_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				input_bits_mem_write_addr     ;
    reg                 [8 - 1 	 : 0]    				input_bits_mem_write_data     ;

    memory_list #(
        .mem_width(8),
        .address_len(address_len),
        .mem_depth(input_bytes_count),
        .initial_file("./input_bitstring.mem")

    ) input_bits_mem(
        .clk(clk),
        .r_en(  input_bits_mem_read_enable),
        .r_addr(input_bits_mem_read_addr),
        .r_data(input_bits_mem_read_data),
        .w_en(  input_bits_mem_write_enable),
        .w_addr(input_bits_mem_write_addr),
        .w_data(input_bits_mem_write_data)
    );




                

    reg                                             		ll_table_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				ll_table_mem_read_addr      ;
    wire                [17 - 1 	 : 0]    				ll_table_mem_read_data      ;
    reg                                             		ll_table_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				ll_table_mem_write_addr     ;
    reg                 [17 - 1 	 : 0]    				ll_table_mem_write_data     ;

    memory_list #(
        .mem_width(17),
        .address_len(address_len),
        .mem_depth(length_symbol_counts),
        .initial_file("./ll_table.mem")

    ) ll_table_mem(
        .clk(clk),
        .r_en(  ll_table_mem_read_enable),
        .r_addr(ll_table_mem_read_addr),
        .r_data(ll_table_mem_read_data),
        .w_en(  ll_table_mem_write_enable),
        .w_addr(ll_table_mem_write_addr),
        .w_data(ll_table_mem_write_data)
    );




                

    reg                                             		distance_table_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				distance_table_mem_read_addr      ;
    wire                [22 - 1 	 : 0]    				distance_table_mem_read_data      ;
    reg                                             		distance_table_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				distance_table_mem_write_addr     ;
    reg                 [22 - 1 	 : 0]    				distance_table_mem_write_data     ;

    memory_list #(
        .mem_width(22),
        .address_len(address_len),
        .mem_depth(distance_symbol_counts),
        .initial_file("./distance_table.mem")

    ) distance_table_mem(
        .clk(clk),
        .r_en(  distance_table_mem_read_enable),
        .r_addr(distance_table_mem_read_addr),
        .r_data(distance_table_mem_read_data),
        .w_en(  distance_table_mem_write_enable),
        .w_addr(distance_table_mem_write_addr),
        .w_data(distance_table_mem_write_data)
    );




                

    reg                                             		ll_symbols_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				ll_symbols_mem_read_addr      ;
    wire                [9 - 1 	 : 0]    				ll_symbols_mem_read_data      ;
    reg                                             		ll_symbols_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				ll_symbols_mem_write_addr     ;
    reg                 [9 - 1 	 : 0]    				ll_symbols_mem_write_data     ;

    memory_list #(
        .mem_width(9),
        .address_len(address_len),
        .mem_depth(input_bytes_count),
        .initial_file(0)

    ) ll_symbols_mem(
        .clk(clk),
        .r_en(  ll_symbols_mem_read_enable),
        .r_addr(ll_symbols_mem_read_addr),
        .r_data(ll_symbols_mem_read_data),
        .w_en(  ll_symbols_mem_write_enable),
        .w_addr(ll_symbols_mem_write_addr),
        .w_data(ll_symbols_mem_write_data)
    );




                

    reg                                             		distance_symbols_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				distance_symbols_mem_read_addr      ;
    wire                [9 - 1 	 : 0]    				distance_symbols_mem_read_data      ;
    reg                                             		distance_symbols_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				distance_symbols_mem_write_addr     ;
    reg                 [9 - 1 	 : 0]    				distance_symbols_mem_write_data     ;

    memory_list #(
        .mem_width(9),
        .address_len(address_len),
        .mem_depth(input_bytes_count),
        .initial_file(0)

    ) distance_symbols_mem(
        .clk(clk),
        .r_en(  distance_symbols_mem_read_enable),
        .r_addr(distance_symbols_mem_read_addr),
        .r_data(distance_symbols_mem_read_data),
        .w_en(  distance_symbols_mem_write_enable),
        .w_addr(distance_symbols_mem_write_addr),
        .w_data(distance_symbols_mem_write_data)
    );




                

    reg                                             		lzss_output_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				lzss_output_mem_read_addr      ;
    wire                [lzss_output_width - 1 	 : 0]    				lzss_output_mem_read_data      ;
    reg                                             		lzss_output_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				lzss_output_mem_write_addr     ;
    reg                 [lzss_output_width - 1 	 : 0]    				lzss_output_mem_write_data     ;

    memory_list #(
        .mem_width(lzss_output_width),
        .address_len(address_len),
        .mem_depth(input_bytes_count),
        .initial_file(0)

    ) lzss_output_mem(
        .clk(clk),
        .r_en(  lzss_output_mem_read_enable),
        .r_addr(lzss_output_mem_read_addr),
        .r_data(lzss_output_mem_read_data),
        .w_en(  lzss_output_mem_write_enable),
        .w_addr(lzss_output_mem_write_addr),
        .w_data(lzss_output_mem_write_data)
    );




                