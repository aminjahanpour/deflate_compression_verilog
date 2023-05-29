

    reg                                             		input_pre_bitstream_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				input_pre_bitstream_mem_read_addr      ;
    wire                [pre_bitstream_width - 1 	 : 0]    				input_pre_bitstream_mem_read_data      ;
    reg                                             		input_pre_bitstream_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				input_pre_bitstream_mem_write_addr     ;
    reg                 [pre_bitstream_width - 1 	 : 0]    				input_pre_bitstream_mem_write_data     ;

    memory_list #(
        .mem_width(pre_bitstream_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file("./input.txt")

    ) input_pre_bitstream_mem(
        .clk(clk),
        .r_en(  input_pre_bitstream_mem_read_enable),
        .r_addr(input_pre_bitstream_mem_read_addr),
        .r_data(input_pre_bitstream_mem_read_data),
        .w_en(  input_pre_bitstream_mem_write_enable),
        .w_addr(input_pre_bitstream_mem_write_addr),
        .w_data(input_pre_bitstream_mem_write_data)
    );




                

    reg                                             		writer_input_config_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				writer_input_config_mem_read_addr      ;
    wire                [16 - 1 	 : 0]    				writer_input_config_mem_read_data      ;
    reg                                             		writer_input_config_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				writer_input_config_mem_write_addr     ;
    reg                 [16 - 1 	 : 0]    				writer_input_config_mem_write_data     ;

    memory_list #(
        .mem_width(16),
        .address_len(address_len),
        .mem_depth(10),
        .initial_file("./config.txt")

    ) writer_input_config_mem(
        .clk(clk),
        .r_en(  writer_input_config_mem_read_enable),
        .r_addr(writer_input_config_mem_read_addr),
        .r_data(writer_input_config_mem_read_data),
        .w_en(  writer_input_config_mem_write_enable),
        .w_addr(writer_input_config_mem_write_addr),
        .w_data(writer_input_config_mem_write_data)
    );




                

    reg                                             		bit_stream_mem_read_enable    = 1 ;
    reg                 [address_len - 1 : 0]				bit_stream_mem_read_addr      ;
    wire                [encoded_mem_width - 1 	 : 0]    				bit_stream_mem_read_data      ;
    reg                                             		bit_stream_mem_write_enable   ;
    reg                 [address_len - 1 : 0]				bit_stream_mem_write_addr     ;
    reg                 [encoded_mem_width - 1 	 : 0]    				bit_stream_mem_write_data     ;

    memory_list #(
        .mem_width(encoded_mem_width),
        .address_len(address_len),
        .mem_depth(max_length_symbol),
        .initial_file(0)

    ) bit_stream_mem(
        .clk(clk),
        .r_en(  bit_stream_mem_read_enable),
        .r_addr(bit_stream_mem_read_addr),
        .r_data(bit_stream_mem_read_data),
        .w_en(  bit_stream_mem_write_enable),
        .w_addr(bit_stream_mem_write_addr),
        .w_data(bit_stream_mem_write_data)
    );




                