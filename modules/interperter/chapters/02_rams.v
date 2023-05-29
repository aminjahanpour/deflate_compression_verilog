

    reg                                             		interperter_cl_cl_ll_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				interperter_cl_cl_ll_mem_read_addr      ;
    wire                [huffman_codes_width - 1 	 : 0]    				interperter_cl_cl_ll_mem_read_data      ;
    reg                                             		interperter_cl_cl_ll_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				interperter_cl_cl_ll_mem_write_addr     ;
    reg                 [huffman_codes_width - 1 	 : 0]    				interperter_cl_cl_ll_mem_write_data     ;

    memory_list #(
        .mem_width(huffman_codes_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file(0)

    ) interperter_cl_cl_ll_mem(
        .clk(clk),
        .r_en(  interperter_cl_cl_ll_mem_read_enable),
        .r_addr(interperter_cl_cl_ll_mem_read_addr),
        .r_data(interperter_cl_cl_ll_mem_read_data),
        .w_en(  interperter_cl_cl_ll_mem_write_enable),
        .w_addr(interperter_cl_cl_ll_mem_write_addr),
        .w_data(interperter_cl_cl_ll_mem_write_data)
    );




                

    reg                                             		interperter_cl_cl_distance_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				interperter_cl_cl_distance_mem_read_addr      ;
    wire                [huffman_codes_width - 1 	 : 0]    				interperter_cl_cl_distance_mem_read_data      ;
    reg                                             		interperter_cl_cl_distance_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				interperter_cl_cl_distance_mem_write_addr     ;
    reg                 [huffman_codes_width - 1 	 : 0]    				interperter_cl_cl_distance_mem_write_data     ;

    memory_list #(
        .mem_width(huffman_codes_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file(0)

    ) interperter_cl_cl_distance_mem(
        .clk(clk),
        .r_en(  interperter_cl_cl_distance_mem_read_enable),
        .r_addr(interperter_cl_cl_distance_mem_read_addr),
        .r_data(interperter_cl_cl_distance_mem_read_data),
        .w_en(  interperter_cl_cl_distance_mem_write_enable),
        .w_addr(interperter_cl_cl_distance_mem_write_addr),
        .w_data(interperter_cl_cl_distance_mem_write_data)
    );




                