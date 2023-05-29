module bits_reader #(
    parameter                                           q_full                      = 0,
    parameter                                           address_len                 = 0,
    parameter                                           mem_bits_reader_bus_width   = 0,
    parameter                                           encoded_mem_width           = 0,
    parameter                                           input_bits_to_writer_width  = 0,
    parameter                                           max_length_symbol           = 0,
    parameter                                           verbose                     = 0
) (
    input                                               clk,
    input                                               go,
    output reg                                          finished,
    
    input           [q_full - 1 : 0]                    bits_count_to_read,


    input           [encoded_mem_width - 1 : 0]         previous_stage_left_over_bus,
    input           [8 - 1 : 0     ]                    previous_stage_left_over_bus_length,
    input           [address_len - 1 : 0     ]          previous_read_addr,

    output reg      [encoded_mem_width - 1 : 0]         left_over_bus,
    output reg      [8 - 1 : 0     ]                    left_over_bus_length,
    output reg      [address_len - 1 : 0]               output_read_addr,



    output reg      [mem_bits_reader_bus_width - 1: 0]  read_from_memory_bus
                                           
);
    




reg                                             		bits_reader_mem_read_enable    = 1 ;
reg                 [address_len - 1 : 0]				bits_reader_mem_read_addr      ;
wire                [encoded_mem_width - 1 	 : 0]    	bits_reader_mem_read_data      ;
reg                                             		bits_reader_mem_write_enable   ;
reg                 [address_len - 1 : 0]				bits_reader_mem_write_addr     ;
reg                 [encoded_mem_width - 1 	 : 0]    	bits_reader_mem_write_data     ;

memory_list #(
    .mem_width(encoded_mem_width),
    .address_len(address_len),
    .mem_depth(max_length_symbol),
    .initial_file("./input.txt")

) bits_reader_mem(
    .clk(clk),
    .r_en(  bits_reader_mem_read_enable),
    .r_addr(bits_reader_mem_read_addr),
    .r_data(bits_reader_mem_read_data),
    .w_en(  bits_reader_mem_write_enable),
    .w_addr(bits_reader_mem_write_addr),
    .w_data(bits_reader_mem_write_data)
);





always @(posedge go) begin


    bits_reader_mem_read_addr   = previous_read_addr;
    left_over_bus               = previous_stage_left_over_bus;
    left_over_bus_length        = previous_stage_left_over_bus_length;

    
    finished = 0;


    read_from_memory_bus        = 0;
    counter_L3                  = 0;
    lagger_L3                   = 0;
    need_more_bits_L            = 1;

    L3_read_from_bitstream_mem_flag = 1;
    L4_mem_bit_reader_while_loop_flag = 0;


    if (verbose>1) $display("bits_reader: go");
    if (verbose>1) $display("bits_reader: bits_count_to_read:%d", bits_count_to_read);
    if (verbose>1) $display("bits_reader: previous_stage_left_over_bus:%b", previous_stage_left_over_bus);
    if (verbose>1) $display("bits_reader: previous_stage_left_over_bus_length:%d", previous_stage_left_over_bus_length);
    if (verbose>1) $display("bits_reader: previous_read_addr:%d", previous_read_addr);

end





reg                                                     L3_read_from_bitstream_mem_flag = 0;

// loop reset
reg                 [q_full - 1 : 0]                    counter_L3;
reg                 [q_full - 1 : 0]                    lagger_L3;

// L3 variables


reg                 [q_full - 1 : 0]                    remaining_bits_L;

reg                                                     need_more_bits_L;


reg                 [input_bits_to_writer_width - 1: 0] bits_reader_mask_L;
reg                 [24 - 1 :      0]                   total_bits_read_count_D;



always @(negedge clk) begin
if (L3_read_from_bitstream_mem_flag) begin

    lagger_L3 = lagger_L3 + 1;

    if (lagger_L3 == 1) begin

        remaining_bits_L = bits_count_to_read;
        if (verbose > 2) $display("\n-\t\tL3: l1: reading %d bits", bits_count_to_read);
        if (verbose > 2) $display("-\t\tL3: l1: leftover: %b, leftover count:%d", left_over_bus, left_over_bus_length);
        if (verbose > 2) $display("-\t\tL3: l1: remaining_bits_L: %d", remaining_bits_L);
        

    end else if (lagger_L3 == 2) begin
        
        if (left_over_bus_length > 0) begin
            if (remaining_bits_L > left_over_bus_length) begin

                if (verbose > 2) $display("-\t\tL3: l2: not enough left over(%d) to make up for the remaining bits(%d)", left_over_bus_length,remaining_bits_L);
                if (verbose > 2) $display("-\t\tL3: l2: using all of the left over");
                
                
                read_from_memory_bus = left_over_bus;

                if (verbose > 2) $display("-\t\tL3: l2: so we get: read_from_memory_bus:%b", read_from_memory_bus);


                remaining_bits_L = remaining_bits_L - left_over_bus_length;

                if (verbose > 2) $display("-\t\tL3: l2: still need %d bits", remaining_bits_L);

                left_over_bus = 0;
                left_over_bus_length = 0;

                bits_reader_mem_read_addr = bits_reader_mem_read_addr + 1;


                total_bits_read_count_D = total_bits_read_count_D + left_over_bus_length;

            end
        end


    end else if (lagger_L3 == 3) begin
        
        if (left_over_bus_length > 0) begin
            if (remaining_bits_L <= left_over_bus_length) begin
                if (verbose > 2) $display("-\t\tL3: l2: there are enough left over(%d) to make up for the remaining bits(%d)", left_over_bus_length,remaining_bits_L);
                if (verbose > 2) $display("-\t\tL3: l2: using the first (%d) bits of the leftover", remaining_bits_L);

                if (verbose > 2) $display("-\t\tL3: l2: shifting left_over_bus %d bits to the right", left_over_bus_length - remaining_bits_L);

                read_from_memory_bus = left_over_bus >> (left_over_bus_length - remaining_bits_L);
                
                if (verbose > 2) $display("-\t\tL3: l2: so we get read_from_memory_bus: %b", read_from_memory_bus);

                // we need a mask for left over. it needs to have ones on the right side as many as (left_over_bus_length - remaining_bits_L)
                bits_reader_mask_L = ((2 << ((left_over_bus_length - remaining_bits_L) - 1)) - 1);

                if (verbose > 2) $display("-\t\tL3: l2: now we need to reduce the leftover. we use this mask: %b", bits_reader_mask_L);

                left_over_bus = left_over_bus & bits_reader_mask_L;
                left_over_bus_length = left_over_bus_length - remaining_bits_L;


                if (verbose > 2) $display("-\t\tL3: l2:so the left over becomes: %b", left_over_bus);

                remaining_bits_L = 0;

                need_more_bits_L = 0;

                total_bits_read_count_D = total_bits_read_count_D + left_over_bus_length;


                if (left_over_bus_length == 0) begin
                    bits_reader_mem_read_addr = bits_reader_mem_read_addr + 1;
                end

            end
        end







    // start of the while loop

    end else if (lagger_L3 == 4) begin
        if ((need_more_bits_L) && (remaining_bits_L >= encoded_mem_width)) begin

            L3_read_from_bitstream_mem_flag = 0;
            // setting and launching L4
            counter_L4 = 0;
            lagger_L4 = 0;
            L4_mem_bit_reader_while_loop_flag = 1;

        end

    // end of the while loop








    end else if (lagger_L3 == 5) begin
        if (verbose > 2) $display("-\t\tL3: l11: finished with the loop");

        if (need_more_bits_L) begin
            if(remaining_bits_L > 0) begin

                if (verbose > 2) $display("-\t\tL3: l11: still need more bits. left shifting read_from_memory_bus, %d bits", remaining_bits_L);

                read_from_memory_bus = read_from_memory_bus << remaining_bits_L;
                
                if (verbose > 2) $display("-\t\tL3: l11: so we get: %b", read_from_memory_bus);
                if (verbose > 2) $display("-\t\tL3: l11: now appending remaining_bits_L(%d) via filter", remaining_bits_L, (bits_reader_mem_read_data >> (encoded_mem_width - remaining_bits_L)));


                read_from_memory_bus = read_from_memory_bus | (bits_reader_mem_read_data >> (encoded_mem_width - remaining_bits_L));



                // we need a mask for left over. it needs to have ones on the right side as many as (encoded_mem_width - remaining_bits_L)
                bits_reader_mask_L = ((2 << ((encoded_mem_width - remaining_bits_L) - 1)) - 1);

                if (verbose > 2) $display("-\t\tL3: l2: now we need to create a leftover. we use this mask: %b", bits_reader_mask_L);

                left_over_bus = bits_reader_mem_read_data & bits_reader_mask_L;
                left_over_bus_length = encoded_mem_width - remaining_bits_L;



                if (verbose > 2) $display("-\t\tL3: l11: leftover: %b, leftover count:%d", left_over_bus, left_over_bus_length);



            end

        end







    end else if (lagger_L3 == 6) begin

        if (verbose > 2) $display("-\t\tL3: l16: going back to caller.");

        L3_read_from_bitstream_mem_flag = 0;


        output_read_addr = bits_reader_mem_read_addr;



        finished = 1;
        


    end 
end
end





// L4

// flag
reg                                                     L4_mem_bit_reader_while_loop_flag;


// loop reset
reg                 [q_full - 1 : 0]                    counter_L4;
reg                 [q_full - 1 : 0]                    lagger_L4;

// L4 variables

    

//L4_mem_bit_reader_while_loop_flag
always @(negedge clk) begin
if (L4_mem_bit_reader_while_loop_flag == 1) begin
    lagger_L4 = lagger_L4 + 1;

    if (lagger_L4 == 1) begin
        
            if (verbose > 2) $display("-\t\t\tL3: we need so many bits more. enough to read them in the while loop.");

            if (verbose > 2) $display("-\t\t\tL3: remaining_bits_L:%d", remaining_bits_L);

            if (verbose > 2) $display("-\t\t\tL3: left shifting read_from_memory_bus (%b) %d bits ", read_from_memory_bus, encoded_mem_width);

            read_from_memory_bus = read_from_memory_bus << encoded_mem_width;

            if (verbose > 2) $display("-\t\t\tL3: so we get: %b , now adding next word:%b", read_from_memory_bus, bits_reader_mem_read_data);

            read_from_memory_bus = read_from_memory_bus | bits_reader_mem_read_data;

            if (verbose > 2) $display("-\t\t\tL3: so we get: %b", read_from_memory_bus);

            bits_reader_mem_read_addr = bits_reader_mem_read_addr + 1;

            remaining_bits_L = remaining_bits_L - encoded_mem_width;


            total_bits_read_count_D = total_bits_read_count_D + encoded_mem_width;


    end else if (lagger_L4 == 2) begin

        if ((need_more_bits_L) && (remaining_bits_L >= encoded_mem_width)) begin
            lagger_L4 = 0;

        end else begin
            
            L4_mem_bit_reader_while_loop_flag = 0;
            
            L3_read_from_bitstream_mem_flag = 1;

        end

        
    
    end 
end
end








endmodule
