reg                 [8 - 1 :     0]                     verbose = 3;

/*

bytes:
    0 : 2   -> total_header_bits_H
    3       -> last_entry_bits_count_H
    4 :     -> bit stream
*/








// HC

// flag
reg                                                     HC_load_writer_input_config_flag   = 0;
reg                 [q_full - 1      : 0]               input_words_count_H;
    

// loop reset
reg                 [q_full - 1 : 0]                    counter_HC;
reg                 [q_full - 1 : 0]                    lagger_HC;

// HC variables
reg                 [total_header_bits_width - 1  : 0]  total_header_bits_H;

//HC_load_writer_input_config_flag
always @(negedge clk) begin
if (HC_load_writer_input_config_flag == 1) begin
    lagger_HC = lagger_HC + 1;

    if (lagger_HC == 1) begin
        writer_input_config_mem_read_addr = counter_HC;

    end else if (lagger_HC == 2) begin
        if (counter_HC == 0) begin
            input_words_count_H = writer_input_config_mem_read_data;
            $display("HC: input_words_count_H:%d", input_words_count_H);
        end else if (counter_HC == 1) begin
            total_header_bits_H = writer_input_config_mem_read_data;
            $display("HC: total_header_bits_H:%d", total_header_bits_H);
        end


    end else if (lagger_HC == 3) begin

        if (counter_HC < 10 - 1) begin
            counter_HC = counter_HC + 1;

        end else begin
            HC_load_writer_input_config_flag = 0;



            // setting and launching H0
            counter_H0 = 0;
            lagger_H0 = 0;
            H0_write_write_total_header_bits_H_flag = 1;



        end

        lagger_HC = 0;
    
    end 
end
end











// H0

// flag
reg                                                     H0_write_write_total_header_bits_H_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_H0;
reg                 [q_full - 1 : 0]                    lagger_H0;

// H0 variables

    

//H0_write_write_total_header_bits_H_flag
always @(negedge clk) begin
if (H0_write_write_total_header_bits_H_flag == 1) begin
    lagger_H0 = lagger_H0 + 1;


    if (lagger_H0 == 1) begin
        bit_stream_mem_write_data = total_header_bits_H[24 - 1 : 16];

    end else if (lagger_H0 == 2) begin
        bit_stream_mem_write_enable = 1;

    end else if (lagger_H0 == 3) begin
        bit_stream_mem_write_enable = 0;

    end else if (lagger_H0 == 4) begin
        bit_stream_mem_write_addr = 1;




    end else if (lagger_H0 == 5) begin
        bit_stream_mem_write_data = total_header_bits_H[16 - 1 : 8];

    end else if (lagger_H0 == 6) begin
        bit_stream_mem_write_enable = 1;

    end else if (lagger_H0 == 7) begin
        bit_stream_mem_write_enable = 0;

    end else if (lagger_H0 == 8) begin
        bit_stream_mem_write_addr = 2;




    end else if (lagger_H0 == 9) begin
        bit_stream_mem_write_data = total_header_bits_H[8 - 1 : 0];

    end else if (lagger_H0 == 10) begin
        bit_stream_mem_write_enable = 1;


    end else if (lagger_H0 == 11) begin
        bit_stream_mem_write_enable = 0;

    end else if (lagger_H0 == 12) begin
        bit_stream_mem_write_addr = 4;









    end else if (lagger_H0 == 13) begin

            
        H0_write_write_total_header_bits_H_flag = 0;
        
        

        //setting and launching H2
        left_over_bus_H                 = 0;
        left_over_bus_length_H          = 0; // way to infer that left over is null
        last_entry_bits_count_H           = 0;
        counter_H2 = 0;
        lagger_H2 = 0;
        total_bits_written_count_D = 0;
        H2_get_bitstream_flag = 1;




        lagger_H0 = 0;
    
    end 
end
end













// H2

// flag
reg                                                     H2_get_bitstream_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_H2;
reg                 [q_full - 1 : 0]                    lagger_H2;

// H2 variables

//H2_get_bitstream_flag
always @(negedge clk) begin
if (H2_get_bitstream_flag == 1) begin
    lagger_H2 = lagger_H2 + 1;

    if (lagger_H2 == 1) begin
        input_pre_bitstream_mem_read_addr = counter_H2;

    end else if (lagger_H2 == 2) begin
        $display("H2: counter_H2:%d", counter_H2);
        H2_get_bitstream_flag = 0;
        // setting and launching H3
        input_bits_to_writer_H = input_pre_bitstream_mem_read_data[15 :  0];
        input_bits_to_writer_count_H = input_pre_bitstream_mem_read_data[20 : 16];

        counter_H3 = 0;
        lagger_H3 = 0;
        starting_index_H3 = 0;
        allowed_to_write_H3 = 1;
        
        if (counter_H2 == input_words_count_H - 1) begin
            last_load_H = 1;
        end else begin
            last_load_H = 0;
        end
        
        H3_write_output_bitstream_flag = 1;


    end else if (lagger_H2 == 3) begin

        if (counter_H2 < input_words_count_H - 1) begin
            counter_H2 = counter_H2 + 1;

        end else begin
            $fclose(H_output_file_general);



            H2_get_bitstream_flag = 0;
            // setting and launhing H22
            counter_H22 = 0;
            lagger_H22 = 0;
            H22_write_last_entry_bits_count_flag = 1;
            
        end

        lagger_H2 = 0;
    
    end 
end
end














// H22

// flag
reg                                                     H22_write_last_entry_bits_count_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_H22;
reg                 [q_full - 1 : 0]                    lagger_H22;

// H22 variables
reg                 [address_len - 1: 0 ]               last_bit_stream_mem_write_addr;
    

//H22_write_last_entry_bits_count_flag
always @(negedge clk) begin
if (H22_write_last_entry_bits_count_flag == 1) begin
    lagger_H22 = lagger_H22 + 1;

    if (lagger_H22 == 1) begin
        last_bit_stream_mem_write_addr = bit_stream_mem_write_addr;
        
    end else if (lagger_H22 == 2) begin
        bit_stream_mem_write_addr = 3;

    end else if (lagger_H22 == 3) begin
        bit_stream_mem_write_data = last_entry_bits_count_H;
        
    end else if (lagger_H22 == 4) begin
        bit_stream_mem_write_enable = 1;
        
    end else if (lagger_H22 == 5) begin
        bit_stream_mem_write_enable = 0;
        
    end else if (lagger_H22 == 6) begin
        bit_stream_mem_write_addr = last_bit_stream_mem_write_addr;
        
    end else if (lagger_H22 == 7) begin

        if (counter_H22 < 10 - 1) begin
            counter_H22 = counter_H22 + 1;

        end else begin
            
            H22_write_last_entry_bits_count_flag = 0;
        
            // setting and launhing H4
            counter_H4 = 0;
            lagger_H4 = 0;
            H4_dump_bit_stream_mem_flag = 1;

        end

        lagger_H22 = 0;
    
    end 
end
end















































































// H3

/*
this module writes busses of any length to 8-bit wide memory.
it does all the cutting and appendings required to fit the data in the memory.
we keep a left-over (if nesacery)
and we use it together with the incoming bits
that last entry (byte) may or may not contain leftovers.
in the case of leftover:
    we shift the bits to the most left side.
    also we use last_entry_bits_count_H register to store the number of bits in the left over.
*/




// flag
reg                                                     H3_write_output_bitstream_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_H3;
reg                 [q_full - 1 : 0]                    lagger_H3;

// H3 variables
reg                 [input_bits_to_writer_width - 1: 0] input_bits_to_writer_H;
reg                 [6 - 1      : 0]                    input_bits_to_writer_count_H;


reg                 [encoded_mem_width - 1 : 0]         left_over_bus_H;
reg                 [8 - 1 : 0     ]                    left_over_bus_length_H;
reg                                                     last_load_H;
reg                 [6 - 1      : 0]                    remaining_bits_H;
reg                 [q_full - 1 : 0]                    starting_index_H3;
reg                                                     allowed_to_write_H3;


reg                 [input_bits_to_writer_width - 1: 0] input_bits_mask_H;
reg                 [encoded_mem_width - 1 :       0]   last_entry_bits_count_H;
reg                 [24 - 1 :      0]                   total_bits_written_count_D;


//H3_write_output_bitstream_flag
always @(negedge clk) begin
if (H3_write_output_bitstream_flag == 1) begin
    lagger_H3 = lagger_H3 + 1;

    if (lagger_H3 == 1) begin

        remaining_bits_H = input_bits_to_writer_count_H;
        if (verbose > 2) $display("\n-\t\tH3: l1: writing %d(%b) with length: %d", input_bits_to_writer_H, input_bits_to_writer_H, input_bits_to_writer_count_H);
        if (verbose > 2) $display("-\t\tH3: l1: leftover: %b, leftover count:%d", left_over_bus_H, left_over_bus_length_H);
        if (verbose > 2) $display("-\t\tH3: l1: remaining_bits_H: %d", remaining_bits_H);
        

    end else if (lagger_H3 == 2) begin
        
        if (left_over_bus_length_H > 0) begin
            if (left_over_bus_length_H + remaining_bits_H >= encoded_mem_width) begin

                if (verbose > 2) $display("-\t\tH3: l2: our leftovers together with the new bits constitude a new entry.");
                
                if (verbose > 2) $display("-\t\tH3: l2: shifting left_over_bus_H %d bits to the left", encoded_mem_width - left_over_bus_length_H);
                    bit_stream_mem_write_data = left_over_bus_H << (encoded_mem_width - left_over_bus_length_H);

                if (verbose > 2) $display("-\t\tH3: l2: so we get: bit_stream_mem_write_data:%b", bit_stream_mem_write_data);

                // few_most_left_bits_mask
                /*
                a mask for filtering m most left bits out of mask_width:
                mask = ((2 << (mask_width - 1)) - 1);
                mask = mask & (mask << (mask_width - m));
                then we need to shift right this mask to the start position of the incoming bits.
                */

                input_bits_mask_H = ((2 << (input_bits_to_writer_width - 1)) - 1);
                input_bits_mask_H = input_bits_mask_H & (input_bits_mask_H << (input_bits_to_writer_width - (encoded_mem_width - left_over_bus_length_H)));
                input_bits_mask_H = input_bits_mask_H >> (input_bits_to_writer_width - input_bits_to_writer_count_H);

                
                if (verbose > 2) $display("-\t\tH3: l2: then applying input_bits_mask_H:%b to input bits to get %b", input_bits_mask_H, (input_bits_mask_H & input_bits_to_writer_H));
                
                bit_stream_mem_write_data = bit_stream_mem_write_data + ((input_bits_mask_H & input_bits_to_writer_H) >> (input_bits_to_writer_count_H - encoded_mem_width + left_over_bus_length_H));

                total_bits_written_count_D = total_bits_written_count_D + encoded_mem_width;
                
                if (verbose > 2) $display("-\t\tH3: ~~~~~~~~~~ l2: finally we get: bit_stream_mem_write_data:%b", bit_stream_mem_write_data);

            end
        end


    end else if (lagger_H3 == 3) begin
        
        if (left_over_bus_length_H > 0) begin
            if (left_over_bus_length_H + remaining_bits_H >= encoded_mem_width) begin
                bit_stream_mem_write_enable = 1;
            end
        end


    end else if (lagger_H3 == 4) begin
        
        if (left_over_bus_length_H > 0) begin
            if (left_over_bus_length_H + remaining_bits_H >= encoded_mem_width) begin
                bit_stream_mem_write_enable = 0;
            end
        end



    end else if (lagger_H3 == 5) begin
        
        if (left_over_bus_length_H > 0) begin
            if (left_over_bus_length_H + remaining_bits_H >= encoded_mem_width) begin
                bit_stream_mem_write_addr = bit_stream_mem_write_addr + 1;
                remaining_bits_H = remaining_bits_H - (encoded_mem_width - left_over_bus_length_H);
                starting_index_H3 = encoded_mem_width - left_over_bus_length_H;
                left_over_bus_H = 0;
                left_over_bus_length_H = 0;

            
            end else begin
                if (verbose > 2) $display("-\t\tH3: our leftovers together with the new bits DO NOT constitude new entries.");
                
                left_over_bus_H = left_over_bus_H << input_bits_to_writer_count_H;
                left_over_bus_H = left_over_bus_H | input_bits_to_writer_H;
                left_over_bus_length_H = left_over_bus_length_H + input_bits_to_writer_count_H;

                allowed_to_write_H3 = 0;

            end
        end



    // start of the while loop



    end else if (lagger_H3 == 6) begin
        if ((allowed_to_write_H3) && (remaining_bits_H >= encoded_mem_width)) begin

            H3_write_output_bitstream_flag = 0;
            // setting and launching H33
            counter_H33 = 0;
            lagger_H33 = 0;
            H33_mem_bit_writer_while_loop_flag = 1;

        end


    // end of the while loop




    end else if (lagger_H3 == 7) begin
        if (verbose > 2) $display("-\t\tH3: l11: finished with the loop");

        if (allowed_to_write_H3) begin
            if(remaining_bits_H > 0) begin


                
                input_bits_mask_H = ((2 << (remaining_bits_H - 1)) - 1);
                left_over_bus_H = input_bits_to_writer_H & input_bits_mask_H;
                left_over_bus_length_H = remaining_bits_H;

                if (verbose > 2) $display("-\t\tH3: l11: we need to store lefovers.");
                if (verbose > 2) $display("-\t\tH3: l11: input_bits_mask_H:%b", input_bits_mask_H);
                if (verbose > 2) $display("-\t\tH3: l11: leftover: %b, leftover count:%d", left_over_bus_H, left_over_bus_length_H);



            end

        end



    end else if (lagger_H3 == 8) begin
        if ((last_load_H) && (left_over_bus_length_H > 0)) begin
            last_entry_bits_count_H = left_over_bus_length_H;
            bit_stream_mem_write_data = left_over_bus_H << (encoded_mem_width - left_over_bus_length_H);
            if (verbose > 2) $display("-\t\tH3: l12: @@@@@@@@@@@@@@@@@@@@ this is the last load. we store the left over anyway.");
            if (verbose > 2) $display("-\t\tH3: ~~~~~~~~~~ bit_stream_mem_write_data:%b", bit_stream_mem_write_data);
            if (verbose > 2) $display("-\t\tH3: last_entry_bits_count_H:%d", last_entry_bits_count_H);



            total_bits_written_count_D = total_bits_written_count_D + last_entry_bits_count_H;


            $fdisplayb(H_output_file_general, last_entry_bits_count_H);
            $fdisplayb(H_output_file_general, total_bits_written_count_D);

        end 

    end else if (lagger_H3 == 9) begin

        if ((last_load_H) && (left_over_bus_length_H > 0)) begin
            bit_stream_mem_write_enable = 1;
        end 

    end else if (lagger_H3 == 10) begin

        if ((last_load_H) && (left_over_bus_length_H > 0)) begin
            bit_stream_mem_write_enable = 0;
        end 

    end else if (lagger_H3 == 11) begin

        if ((last_load_H) && (left_over_bus_length_H > 0)) begin
            bit_stream_mem_write_addr = bit_stream_mem_write_addr + 1;

            $fdisplayb(H_output_file_general, bit_stream_mem_write_addr);

        end 



    end else if (lagger_H3 ==12) begin

        if (verbose > 2) $display("-\t\tH3: l16: going back to caller.");

        H3_write_output_bitstream_flag = 0;
        H2_get_bitstream_flag = 1;



    end 
end
end


























// H33

// flag
reg                                                     H33_mem_bit_writer_while_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_H33;
reg                 [q_full - 1 : 0]                    lagger_H33;

// H33 variables

    

//H33_mem_bit_writer_while_loop_flag
always @(negedge clk) begin
if (H33_mem_bit_writer_while_loop_flag == 1) begin
    lagger_H33 = lagger_H33 + 1;

    if (lagger_H33 == 1) begin
        
        if (verbose > 2) $display("-\t\t\tH3: we have enought to write full rows in a loop.");

        /*
        a mask for filtering m most left bits out of mask_width:
        mask = ((2 << (mask_width - 1)) - 1);
        mask = mask & (mask << (mask_width - m));
        then we need to shift right this mask to the start position of the incoming bits.
        */

        if (verbose > 2) $display("-\t\t\tH3: remaining_bits_H:%d", remaining_bits_H);

        
        // input_bits_mask_H = ((2 << (input_bits_to_writer_width - 1)) - 1);
        // input_bits_mask_H = input_bits_mask_H >> (input_bits_to_writer_width - input_bits_to_writer_count_H);


        // input_bits_mask_H = ((2 << ((input_bits_to_writer_width - (starting_index_H3 + counter_H3 * encoded_mem_width)) - 1)) - 1);
        // input_bits_mask_H = input_bits_mask_H & (~((2 << ((encoded_mem_width - (starting_index_H3 +  (counter_H3 + 1) * encoded_mem_width)) - 1)) - 1));


        bit_stream_mem_write_data = input_bits_to_writer_H[remaining_bits_H - 1 -: encoded_mem_width];

        // if (verbose > 2) $display("-\t\t\tH3: input_bits_mask_H:%b", input_bits_mask_H);
        if (verbose > 2) $display("-\t\t\tH3: ~~~~~~~~~~ bit_stream_mem_write_data:%b", bit_stream_mem_write_data);

        total_bits_written_count_D = total_bits_written_count_D + encoded_mem_width;


    end else if (lagger_H33 == 2) begin
            bit_stream_mem_write_enable = 1;

    end else if (lagger_H33 == 3) begin
            bit_stream_mem_write_enable = 0;

    end else if (lagger_H33 == 4) begin
            bit_stream_mem_write_addr = bit_stream_mem_write_addr + 1;

            remaining_bits_H = remaining_bits_H - encoded_mem_width;

    end else if (lagger_H33 == 5) begin

            counter_H3 = counter_H3 + 1;

            lagger_H3 = 5;

    end else if (lagger_H33 == 6) begin

        if ((allowed_to_write_H3) && (remaining_bits_H >= encoded_mem_width)) begin
            lagger_H33 = 0;

        end else begin
            
            H33_mem_bit_writer_while_loop_flag = 0;
            
            H3_write_output_bitstream_flag = 1;
        end

        
    
    end 
end
end






























    
// H4

// flag
reg                                                     H4_dump_bit_stream_mem_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_H4;
reg                 [q_full - 1 : 0]                    lagger_H4;

// H4 variables

//H4_dump_bit_stream_mem_flag
always @(negedge clk) begin
if (H4_dump_bit_stream_mem_flag == 1) begin
    lagger_H4 = lagger_H4 + 1;

    if (lagger_H4 == 1) begin
        bit_stream_mem_read_addr = counter_H4;

    end else if (lagger_H4 == 2) begin
        $fdisplayb(H4_output_file_bit_stream_mem, bit_stream_mem_read_data);

    end else if (lagger_H4 == 3) begin

        if (counter_H4 <  bit_stream_mem_write_addr - 1) begin
            counter_H4 = counter_H4 + 1;

        end else begin
            $fclose(H4_output_file_bit_stream_mem);
            H4_dump_bit_stream_mem_flag = 0;
            
            $display("H4: total_bits_written_count_D:%d, last_entry_bits_count_H:%d", total_bits_written_count_D, last_entry_bits_count_H);



            $display("H4: finished dumping bit_stream at %d", $time);


            $display("FINISHED_______________________________________%d", $time);

        end

        lagger_H4 = 0;
    
    end 
end
end
