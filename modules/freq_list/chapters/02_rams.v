

    reg                                             		fl_input_symbols_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				fl_input_symbols_mem_read_addr      ;
    wire                [9 - 1 	 : 0]    				fl_input_symbols_mem_read_data      ;
    reg                                             		fl_input_symbols_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				fl_input_symbols_mem_write_addr     ;
    reg                 [9 - 1 	 : 0]    				fl_input_symbols_mem_write_data     ;

    memory_list #(
        .mem_width(9),
        .address_len(address_len),
        .mem_depth(input_bytes_count),
        .initial_file("./input.txt")

    ) fl_input_symbols_mem(
        .clk(clk),
        .r_en(  fl_input_symbols_mem_read_enable),
        .r_addr(fl_input_symbols_mem_read_addr),
        .r_data(fl_input_symbols_mem_read_data),
        .w_en(  fl_input_symbols_mem_write_enable),
        .w_addr(fl_input_symbols_mem_write_addr),
        .w_data(fl_input_symbols_mem_write_data)
    );




                

    reg                                             		fl_config_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				fl_config_mem_read_addr      ;
    wire                [q_full - 1 	 : 0]    				fl_config_mem_read_data      ;
    reg                                             		fl_config_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				fl_config_mem_write_addr     ;
    reg                 [q_full - 1 	 : 0]    				fl_config_mem_write_data     ;

    memory_list #(
        .mem_width(q_full),
        .address_len(address_len),
        .mem_depth(20),
        .initial_file("./config.txt")

    ) fl_config_mem(
        .clk(clk),
        .r_en(  fl_config_mem_read_enable),
        .r_addr(fl_config_mem_read_addr),
        .r_data(fl_config_mem_read_data),
        .w_en(  fl_config_mem_write_enable),
        .w_addr(fl_config_mem_write_addr),
        .w_data(fl_config_mem_write_data)
    );




                

    reg                                             		fl_freq_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				fl_freq_mem_read_addr      ;
    wire                [q_full - 1 	 : 0]    				fl_freq_mem_read_data      ;
    reg                                             		fl_freq_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				fl_freq_mem_write_addr     ;
    reg                 [q_full - 1 	 : 0]    				fl_freq_mem_write_data     ;

    memory_list #(
        .mem_width(q_full),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file(0)

    ) fl_freq_mem(
        .clk(clk),
        .r_en(  fl_freq_mem_read_enable),
        .r_addr(fl_freq_mem_read_addr),
        .r_data(fl_freq_mem_read_data),
        .w_en(  fl_freq_mem_write_enable),
        .w_addr(fl_freq_mem_write_addr),
        .w_data(fl_freq_mem_write_data)
    );




                

    reg                                             		fl_freq_list_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				fl_freq_list_mem_read_addr      ;
    wire                [freq_list_width - 1 	 : 0]    				fl_freq_list_mem_read_data      ;
    reg                                             		fl_freq_list_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				fl_freq_list_mem_write_addr     ;
    reg                 [freq_list_width - 1 	 : 0]    				fl_freq_list_mem_write_data     ;

    memory_list #(
        .mem_width(freq_list_width),
        .address_len(address_len),
        .mem_depth(freq_list_depth),
        .initial_file(0)

    ) fl_freq_list_mem(
        .clk(clk),
        .r_en(  fl_freq_list_mem_read_enable),
        .r_addr(fl_freq_list_mem_read_addr),
        .r_data(fl_freq_list_mem_read_data),
        .w_en(  fl_freq_list_mem_write_enable),
        .w_addr(fl_freq_list_mem_write_addr),
        .w_data(fl_freq_list_mem_write_data)
    );




                