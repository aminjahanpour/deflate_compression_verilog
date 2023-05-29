

    reg                                             		freq_list_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				freq_list_mem_read_addr      ;
    wire                [freq_list_width - 1 	 : 0]    				freq_list_mem_read_data      ;
    reg                                             		freq_list_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				freq_list_mem_write_addr     ;
    reg                 [freq_list_width - 1 	 : 0]    				freq_list_mem_write_data     ;

    memory_list #(
        .mem_width(freq_list_width),
        .address_len(address_len),
        .mem_depth(freq_list_depth),
        .initial_file("./input.txt")

    ) freq_list_mem(
        .clk(clk),
        .r_en(  freq_list_mem_read_enable),
        .r_addr(freq_list_mem_read_addr),
        .r_data(freq_list_mem_read_data),
        .w_en(  freq_list_mem_write_enable),
        .w_addr(freq_list_mem_write_addr),
        .w_data(freq_list_mem_write_data)
    );




                

    reg                                             		huffman_nodes_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				huffman_nodes_mem_read_addr      ;
    wire                [9 - 1 	 : 0]    				huffman_nodes_mem_read_data      ;
    reg                                             		huffman_nodes_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				huffman_nodes_mem_write_addr     ;
    reg                 [9 - 1 	 : 0]    				huffman_nodes_mem_write_data     ;

    memory_list #(
        .mem_width(9),
        .address_len(address_len),
        .mem_depth(huffman_nodes_count),
        .initial_file(0)

    ) huffman_nodes_mem(
        .clk(clk),
        .r_en(  huffman_nodes_mem_read_enable),
        .r_addr(huffman_nodes_mem_read_addr),
        .r_data(huffman_nodes_mem_read_data),
        .w_en(  huffman_nodes_mem_write_enable),
        .w_addr(huffman_nodes_mem_write_addr),
        .w_data(huffman_nodes_mem_write_data)
    );




                

    reg                                             		huffman_codes_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				huffman_codes_mem_read_addr      ;
    wire                [huffman_codes_width - 1 	 : 0]    				huffman_codes_mem_read_data      ;
    reg                                             		huffman_codes_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				huffman_codes_mem_write_addr     ;
    reg                 [huffman_codes_width - 1 	 : 0]    				huffman_codes_mem_write_data     ;

    memory_list #(
        .mem_width(huffman_codes_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file(0)

    ) huffman_codes_mem(
        .clk(clk),
        .r_en(  huffman_codes_mem_read_enable),
        .r_addr(huffman_codes_mem_read_addr),
        .r_data(huffman_codes_mem_read_data),
        .w_en(  huffman_codes_mem_write_enable),
        .w_addr(huffman_codes_mem_write_addr),
        .w_data(huffman_codes_mem_write_data)
    );




                