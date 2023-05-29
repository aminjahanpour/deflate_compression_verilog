

    

reg                                                     bits_reader_go_M;
wire                                                    bits_reader_finished_M;


reg                 [q_full - 1 : 0]                    bits_count_to_read_M;


reg                 [encoded_mem_width - 1 : 0]         previous_stage_left_over_bus_M;
reg                 [8 - 1 : 0     ]                    previous_stage_left_over_bus_length_M;
reg                 [address_len - 1 : 0     ]          previous_stage_read_addr_M;

wire reg            [encoded_mem_width - 1 : 0]         left_over_bus_M;
wire reg            [8 - 1 : 0     ]                    left_over_bus_length_M;
wire reg            [address_len - 1 : 0]               bits_reader_read_addr_M;                        

wire reg            [mem_bits_reader_bus_width - 1: 0]  read_from_memory_bus_M;




bits_reader #(
    .q_full(q_full),
    .address_len(address_len),
    .mem_bits_reader_bus_width(mem_bits_reader_bus_width),
    .encoded_mem_width(encoded_mem_width),
    .input_bits_to_writer_width(input_bits_to_writer_width),
    .max_length_symbol(max_length_symbol),
    .verbose(0)
)
bits_reader_instance_M (
    .clk                    (clk),
    .go                     (bits_reader_go_M),
    .finished               (bits_reader_finished_M),

    .bits_count_to_read     (bits_count_to_read_M),

    // inputs
    .previous_stage_left_over_bus       (previous_stage_left_over_bus_M),
    .previous_stage_left_over_bus_length(previous_stage_left_over_bus_length_M),
    .previous_read_addr                 (previous_stage_read_addr_M),

    // outputs
    .left_over_bus          (left_over_bus_M),
    .left_over_bus_length   (left_over_bus_length_M),
    .output_read_addr       (bits_reader_read_addr_M),

    .read_from_memory_bus   (read_from_memory_bus_M)
);



// bits_reader collector
always @(posedge bits_reader_finished_M) begin

    bits_reader_go_M = 0;

    previous_stage_left_over_bus_M          = left_over_bus_M;
    previous_stage_left_over_bus_length_M   = left_over_bus_length_M;
    previous_stage_read_addr_M              = bits_reader_read_addr_M;


    M1_loop_over_search_lengths_flag = 1;

end


































// MC

// flag
reg                                                     MC_read_config_file_flag   = 0;


// configs
reg                 [total_header_bits_width - 1  : 0]  total_header_bits_M;
reg                 [encoded_mem_width - 1 :       0]   last_entry_bits_count_M;
reg                 [q_full - 1 : 0]                    hlit_cl;
reg                 [q_full - 1 : 0]                    hdist_cl;
reg                 [q_full - 1 : 0]                    hlit;
reg                 [q_full - 1 : 0]                    hdist;
reg                 [q_full - 1 : 0]                    encoded_cl_for_ll_bits_count;
reg                 [q_full - 1 : 0]                    encoded_cl_for_distance_bits_count;

reg                 [q_full - 1 : 0]                    bit_reader_left_over_bus_M;
reg                 [q_full - 1 : 0]                    bit_reader_left_over_bus_length_M;
reg                 [q_full - 1 : 0]                    bit_reader_bits_reader_read_addr_M;

reg                 [3 - 1      : 0]                    ll_cl_cl_min_M;
reg                 [3 - 1      : 0]                    ll_cl_cl_max_M;
reg                 [3 - 1      : 0]                    distance_cl_cl_min_M;
reg                 [3 - 1      : 0]                    distance_cl_cl_max_M;


// loop reset
reg                 [q_full - 1 : 0]                    counter_MC;
reg                 [q_full - 1 : 0]                    lagger_MC;


// MC variables

//MC_read_config_file_flag
always @(negedge clk) begin
if (MC_read_config_file_flag == 1) begin
    lagger_MC = lagger_MC + 1;

    if (lagger_MC == 1) begin
        cl_decode_config_mem_read_addr = counter_MC;

    end else if (lagger_MC == 2) begin
        case (counter_MC)
            0   :    total_header_bits_M                            = cl_decode_config_mem_read_data;
            1   :    last_entry_bits_count_M                        = cl_decode_config_mem_read_data;
            2   :    hlit_cl                                        = cl_decode_config_mem_read_data;
            3   :    hdist_cl                                       = cl_decode_config_mem_read_data;
            4   :    hlit                                           = cl_decode_config_mem_read_data;
            5   :    hdist                                          = cl_decode_config_mem_read_data;
            6   :    encoded_cl_for_ll_bits_count                   = cl_decode_config_mem_read_data;
            7   :    encoded_cl_for_distance_bits_count             = cl_decode_config_mem_read_data;
            8   :    bit_reader_left_over_bus_M                     = cl_decode_config_mem_read_data;
            9   :    bit_reader_left_over_bus_length_M              = cl_decode_config_mem_read_data;
           10   :    bit_reader_bits_reader_read_addr_M             = cl_decode_config_mem_read_data;
           11   :    ll_cl_cl_min_M                                 = cl_decode_config_mem_read_data;
           12   :    ll_cl_cl_max_M                                 = cl_decode_config_mem_read_data;
           13   :    distance_cl_cl_min_M                           = cl_decode_config_mem_read_data;
           14   :    distance_cl_cl_max_M                           = cl_decode_config_mem_read_data;

        endcase

    end else if (lagger_MC == 3) begin

        if (counter_MC < 20 - 1) begin
            counter_MC = counter_MC + 1;

        end else begin
            MC_read_config_file_flag = 0;
            
            $display("MC: total_header_bits_M: %d", total_header_bits_M);
            $display("MC: last_entry_bits_count_M: %d", last_entry_bits_count_M);
            $display("MC: hlit_cl: %d", hlit_cl);
            $display("MC: hdist_cl: %d", hdist_cl);
            $display("MC: hlit: %d", hlit);
            $display("MC: hdist: %d", hdist);
            $display("MC: encoded_cl_for_ll_bits_count: %d", encoded_cl_for_ll_bits_count);
            $display("MC: encoded_cl_for_distance_bits_count: %d", encoded_cl_for_distance_bits_count);
            $display("MC: bit_reader_left_over_bus_M: %d", bit_reader_left_over_bus_M);
            $display("MC: bit_reader_left_over_bus_length_M: %d", bit_reader_left_over_bus_length_M);
            $display("MC: bit_reader_bits_reader_read_addr_M: %d", bit_reader_bits_reader_read_addr_M);
            $display("MC: ll_cl_cl_min_M: %d", ll_cl_cl_min_M);
            $display("MC: ll_cl_cl_max_M: %d", ll_cl_cl_max_M);
            $display("MC: distance_cl_cl_min_M: %d", distance_cl_cl_min_M);
            $display("MC: distance_cl_cl_max_M: %d", distance_cl_cl_max_M);
            $display("\n\n\n\n");


            search_starting_point_left_over_bus_M          = bit_reader_left_over_bus_M;
            search_starting_point_left_over_bus_length_M   = bit_reader_left_over_bus_length_M;
            search_starting_point_read_addr_M              = bit_reader_bits_reader_read_addr_M;
            
            
            cl_decode_extracted_cl_symbols_mem_write_addr = 0;

            // setting and launching M1

            search_length_up_M1 = ll_cl_cl_max_M;
            search_length_lb_M1 = ll_cl_cl_min_M;
            
            search_length_M1 = search_length_lb_M1;
            total_decoded_bits_M1 = 0;
            total_decoded_ll_cl_values_count_M1 = hlit;
            total_decoded_distance_cl_values_count_M1 = hdist;

            ll_or_distance_M = 0;
            ll_or_distance_switch_has_been_made_M = 0;

            cl_decode_cl_ll_mem_write_addr = 0;
            cl_decode_cl_distance_mem_write_addr = 0;


            lagger_M1 = 0;
            M1_loop_over_search_lengths_flag = 1;

        end

        lagger_MC = 0;
    
    end 
end
end













/*
set a starting point

for every search length:
    - keep the starting point of reading fixed until we find a match

    - read the bits from the starting point for a given search length
    - loop over huffman codes
        - make comparison only if the code lengths match

    if found a match:
        - display symbol
        - update the starting point
        - reset search_length to its min value
        - break

    if nothing found:
        read the bits (from the same starting point) for the next search length

*/


// M1

// flag
reg                                                     M1_loop_over_search_lengths_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    lagger_M1;

// M1 variables
reg                 [3 - 1      : 0]                    search_length_lb_M1;
reg                 [3 - 1      : 0]                    search_length_up_M1;
reg                 [3 - 1      : 0]                    search_length_M1;

reg                 [encoded_mem_width - 1 : 0]         search_starting_point_left_over_bus_M;
reg                 [8 - 1 : 0     ]                    search_starting_point_left_over_bus_length_M;
reg                 [address_len - 1 : 0     ]          search_starting_point_read_addr_M;

reg                 [q_full - 1 : 0]                    total_decoded_bits_M1;
reg                 [q_full - 1 : 0]                    total_decoded_ll_cl_values_count_M1;
reg                 [q_full - 1 : 0]                    total_decoded_distance_cl_values_count_M1;
reg                 [mem_bits_reader_bus_width - 1: 0]  cl_offset_bits_M;
reg                 [mem_bits_reader_bus_width - 1: 0]  cl_repeat_count_M;

reg                                                     ll_or_distance_M;
reg                                                     ll_or_distance_switch_has_been_made_M;


//M1_loop_over_search_lengths_flag
always @(negedge clk) begin
if (M1_loop_over_search_lengths_flag == 1) begin
    lagger_M1 = lagger_M1 + 1;

    if (lagger_M1 == 1) begin

        // $display("M1: search_length_M1:%d", search_length_M1);
        bits_count_to_read_M = search_length_M1;

        previous_stage_left_over_bus_M          = search_starting_point_left_over_bus_M;
        previous_stage_left_over_bus_length_M   = search_starting_point_left_over_bus_length_M;
        previous_stage_read_addr_M              = search_starting_point_read_addr_M;


    end else if (lagger_M1 == 2) begin

        M1_loop_over_search_lengths_flag = 0;
        // setting and launching bits reader
        bits_reader_go_M = 1;

    end else if (lagger_M1 == 3) begin
        // $display("M1: read_from_memory_bus_M:%b", read_from_memory_bus_M);

        M1_loop_over_search_lengths_flag = 0;
        // setting and launching M2
        found_a_matching_symbol_M2 = 0;
        matching_symbol_M2 = 0;
        lagger_M2 = 0;
        counter_M2 = 0;
        M2_loop_over_huffman_codes_flag  = 1;


    end else if (lagger_M1 == 4) begin
        if (found_a_matching_symbol_M2) begin

            if (matching_symbol_M2 == 16) begin
                // need to read another two bits
                bits_count_to_read_M = 2;
                total_decoded_bits_M1 =total_decoded_bits_M1 + bits_count_to_read_M;

                M1_loop_over_search_lengths_flag = 0;
                // setting and launching bits reader
                bits_reader_go_M = 1;

            end else if (matching_symbol_M2 == 17) begin
                // need to read another two bits
                bits_count_to_read_M = 3;
                total_decoded_bits_M1 =total_decoded_bits_M1 + bits_count_to_read_M;


                M1_loop_over_search_lengths_flag = 0;
                // setting and launching bits reader
                bits_reader_go_M = 1;

            end else if (matching_symbol_M2 == 18) begin
                // need to read another two bits
                bits_count_to_read_M = 7;
                total_decoded_bits_M1 =total_decoded_bits_M1 + bits_count_to_read_M;


                M1_loop_over_search_lengths_flag = 0;
                // setting and launching bits reader
                bits_reader_go_M = 1;
            end

        end




    end else if (lagger_M1 == 5) begin

        if (found_a_matching_symbol_M2) begin


            if ((matching_symbol_M2 == 16) | (matching_symbol_M2 == 17) | matching_symbol_M2 == 18) begin
                cl_offset_bits_M = read_from_memory_bus_M & (((2 << (bits_count_to_read_M - 1)) - 1)) ;
                $display("M1: cl_offset_bits_M for symbol %d was found to be:%d", matching_symbol_M2, cl_offset_bits_M);

                // update search start point
                search_starting_point_left_over_bus_M          = left_over_bus_M;
                search_starting_point_left_over_bus_length_M   = left_over_bus_length_M;
                search_starting_point_read_addr_M              = bits_reader_read_addr_M;
            
            end else begin
                cl_repeat_count_M = 1;
            end
            



        end




    end else if (lagger_M1 == 6) begin

        if (found_a_matching_symbol_M2) begin

            if (matching_symbol_M2 == 16) begin
                cl_repeat_count_M = cl_offset_bits_M + 3;
                $display("M1: repeats for symbol %d becomes:%d+3 = %d", matching_symbol_M2, cl_offset_bits_M, cl_repeat_count_M);

            end else if (matching_symbol_M2 == 17) begin
                cl_repeat_count_M = cl_offset_bits_M + 3;
                $display("M1: repeats for symbol %d becomes:%d+3 = %d", matching_symbol_M2, cl_offset_bits_M, cl_repeat_count_M);

            end else if (matching_symbol_M2 == 18) begin
                cl_repeat_count_M = cl_offset_bits_M + 11;
                $display("M1: repeats for symbol %d becomes:%d+11 = %d", matching_symbol_M2, cl_offset_bits_M, cl_repeat_count_M);

            end



        end



    end else if (lagger_M1 == 7) begin

        if (found_a_matching_symbol_M2) begin

            if ((matching_symbol_M2 <= 15)) begin
                if (ll_or_distance_M == 0) begin
                    total_decoded_ll_cl_values_count_M1 = total_decoded_ll_cl_values_count_M1 + 1;
                end else begin
                    total_decoded_distance_cl_values_count_M1 = total_decoded_distance_cl_values_count_M1 + 1;
                end



            end else begin
                
                if (ll_or_distance_M == 0) begin
                    total_decoded_ll_cl_values_count_M1 = total_decoded_ll_cl_values_count_M1 + cl_repeat_count_M;
                end else begin
                    total_decoded_distance_cl_values_count_M1 = total_decoded_distance_cl_values_count_M1 + cl_repeat_count_M;
                end


            end


        end



    end else if (lagger_M1 == 8) begin

        if (found_a_matching_symbol_M2) begin
            if (matching_symbol_M2 <=15) begin
                cl_value_to_write_M3 = matching_symbol_M2;

            end else if (matching_symbol_M2 >=17) begin
                cl_value_to_write_M3 = 0;
            end
            
        end


    end else if (lagger_M1 == 9) begin

        if (found_a_matching_symbol_M2) begin

            $display("going to write %d, for %d times", cl_value_to_write_M3, cl_repeat_count_M) ;
            $display("total_decoded_ll_cl_values_count_M1: %d, cl_decode_cl_ll_mem_write_addr:%d", total_decoded_ll_cl_values_count_M1, cl_decode_cl_ll_mem_write_addr + hlit + 1 );

            M1_loop_over_search_lengths_flag = 0;
            // setting and launching M3
            counter_M3 = 0;
            lagger_M3 = 0;
            M3_store_decoded_cl_values_flag = 1;

        end



    end else if (lagger_M1 == 11) begin

        if (total_decoded_bits_M1 == (encoded_cl_for_ll_bits_count + encoded_cl_for_distance_bits_count)) begin


            M1_loop_over_search_lengths_flag = 0;

            // store the state of the reader into the general file
            $fdisplayb(M_output_file_general, search_starting_point_left_over_bus_M);
            $fdisplayb(M_output_file_general, search_starting_point_left_over_bus_length_M);
            $fdisplayb(M_output_file_general, search_starting_point_read_addr_M);
            $fdisplayb(M_output_file_general, total_header_bits_M - total_decoded_bits_M1);
            
            
            $fclose(M_output_file_general);

            // resetting and launching 
            counter_M4 = 0;
            lagger_M4 = 0;
            M4_dump_cl_decode_cl_ll_flag = 1;

        end

    end else if (lagger_M1 == 12) begin


        if ((total_decoded_ll_cl_values_count_M1 == max_length_symbol ) && (ll_or_distance_switch_has_been_made_M == 0)) begin

            $display("\n----------------------------------------------------------------------------switching from ll to distance\n");

            search_length_up_M1 = distance_cl_cl_max_M;
            search_length_lb_M1 = distance_cl_cl_min_M;
            
            search_length_M1 = search_length_lb_M1;

            ll_or_distance_M = 1;
            ll_or_distance_switch_has_been_made_M = 1;
        end


    end else if (lagger_M1 == 13) begin

        if (found_a_matching_symbol_M2) begin
            search_length_M1 = search_length_lb_M1;
        end else begin
            
        if (search_length_M1 < search_length_up_M1) begin
            search_length_M1 = search_length_M1 + 1;

        end else begin
            
            M1_loop_over_search_lengths_flag = 0;
            
            
            $display("!!!!!!!! did not  total_decoded_bits_M1:(%d) == (encoded_cl_for_ll_bits_count + encoded_cl_for_distance_bits_count)(%d)", total_decoded_bits_M1, encoded_cl_for_ll_bits_count + encoded_cl_for_distance_bits_count);

        end
        end


        lagger_M1 = 0;
    
    end 
end
end













// M2

// flag
reg                                                     M2_loop_over_huffman_codes_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_M2;
reg                 [q_full - 1 : 0]                    lagger_M2;

// M2 variables
reg                                                     found_a_matching_symbol_M2;
reg                 [9 - 1      : 0]                    matching_symbol_M2;
reg                 [huffman_codes_width - 1 	 : 0]   cl_decode_codes_cl_mem_read_data      ;

//M2_loop_over_huffman_codes_flag
always @(negedge clk) begin
if (M2_loop_over_huffman_codes_flag == 1) begin
    lagger_M2 = lagger_M2 + 1;

    if (lagger_M2 == 1) begin

        if (ll_or_distance_M == 0) begin
            cl_decode_codes_cl_ll_mem_read_addr = counter_M2;
            
        end else begin
            cl_decode_codes_cl_distance_mem_read_addr = counter_M2;
        end

    end else if (lagger_M2 == 2) begin

        if (ll_or_distance_M == 0) begin
            cl_decode_codes_cl_mem_read_data = cl_decode_codes_cl_ll_mem_read_data;

        end else begin
            cl_decode_codes_cl_mem_read_data = cl_decode_codes_cl_distance_mem_read_data;
        end


    end else if (lagger_M2 == 3) begin

        // $display("-\t\t M2: counter_M2:%d, cl:%d, code: %b, read: %b", counter_M2, cl_decode_codes_cl_mem_read_data[31 : 20], cl_decode_codes_cl_mem_read_data[19 : 0], read_from_memory_bus_M);

        if (
            (read_from_memory_bus_M & (((2 << (search_length_M1 - 1)) - 1))) == (cl_decode_codes_cl_mem_read_data & (((2 << (cl_decode_codes_cl_mem_read_data[31 : 20] - 1)) - 1)))
            &&  
            (cl_decode_codes_cl_mem_read_data[31 : 20] == search_length_M1)
        ) begin

            found_a_matching_symbol_M2 = 1;
            matching_symbol_M2 = cl_decode_codes_cl_mem_read_data[40 : 32];

            // update search start point
            search_starting_point_left_over_bus_M          = left_over_bus_M;
            search_starting_point_left_over_bus_length_M   = left_over_bus_length_M;
            search_starting_point_read_addr_M              = bits_reader_read_addr_M;
            

            total_decoded_bits_M1 = total_decoded_bits_M1 + search_length_M1;

            $display("\nM2: (%d) found a match: %d         for search_length_M1:%d", cl_decode_extracted_cl_symbols_mem_write_addr, matching_symbol_M2, search_length_M1);

        end



    end else if (lagger_M2 == 5) begin

        if (found_a_matching_symbol_M2) begin

            cl_decode_extracted_cl_symbols_mem_write_data = matching_symbol_M2;
        end


    end else if (lagger_M2 == 6) begin

        if (found_a_matching_symbol_M2) begin
            cl_decode_extracted_cl_symbols_mem_write_enable = 1;
        end


    end else if (lagger_M2 == 7) begin

        if (found_a_matching_symbol_M2) begin
            cl_decode_extracted_cl_symbols_mem_write_enable = 1;
        end


    end else if (lagger_M2 == 8) begin

        if (found_a_matching_symbol_M2) begin
            cl_decode_extracted_cl_symbols_mem_write_addr = cl_decode_extracted_cl_symbols_mem_write_addr + 1;
        end


    end else if (lagger_M2 == 9) begin

        if ((found_a_matching_symbol_M2 == 0) && (counter_M2 < max_length_symbol - 1)) begin
            counter_M2 = counter_M2 + 1;

        end else begin
            if (found_a_matching_symbol_M2 == 0) begin
                $display("M2: XX found nothing for search_len: %d", search_length_M1);
            end
            M2_loop_over_huffman_codes_flag = 0;
            M1_loop_over_search_lengths_flag = 1;
        end

        lagger_M2 = 0;
    
    end 
end
end























// M3

// flag
reg                                                     M3_store_decoded_cl_values_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_M3;
reg                 [q_full - 1 : 0]                    lagger_M3;

// M3 variables
reg                 [12 - 1 :     0]                    cl_value_to_write_M3;



//M3_store_decoded_cl_values_flag
always @(negedge clk) begin
if (M3_store_decoded_cl_values_flag == 1) begin
    lagger_M3 = lagger_M3 + 1;

    if (lagger_M3 == 1) begin
        
        if (ll_or_distance_M == 0) begin
            cl_decode_cl_ll_mem_write_data = cl_value_to_write_M3 << 20;
            // cl_decode_cl_ll_mem_write_data = cl_value_to_write_M3;
            
        end else begin
            cl_decode_cl_distance_mem_write_data = cl_value_to_write_M3 << 20;
            // cl_decode_cl_distance_mem_write_data = cl_value_to_write_M3;

        end


    end else if (lagger_M3 == 2) begin
        
        if (ll_or_distance_M == 0) begin
            cl_decode_cl_ll_mem_write_enable = 1;
            
        end else begin
            cl_decode_cl_distance_mem_write_enable = 1;

        end


    end else if (lagger_M3 == 3) begin
        
        if (ll_or_distance_M == 0) begin
            cl_decode_cl_ll_mem_write_enable = 0;
            
        end else begin
            cl_decode_cl_distance_mem_write_enable = 0;

        end


    end else if (lagger_M3 == 4) begin
        
        if (ll_or_distance_M == 0) begin
            cl_decode_cl_ll_mem_write_addr = cl_decode_cl_ll_mem_write_addr + 1;
            
        end else begin
            cl_decode_cl_distance_mem_write_addr = cl_decode_cl_distance_mem_write_addr + 1;

        end


    end else if (lagger_M3 == 5) begin

        if (counter_M3 < cl_repeat_count_M - 1) begin
            counter_M3 = counter_M3 + 1;

        end else begin
            
            M3_store_decoded_cl_values_flag = 0;
            
            M1_loop_over_search_lengths_flag = 1;


        end

        lagger_M3 = 0;
    
    end 
end
end

















// M4

// flag
reg                                                     M4_dump_cl_decode_cl_ll_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_M4;
reg                 [q_full - 1 : 0]                    lagger_M4;

// M4 variables



//M4_dump_cl_decode_cl_ll_flag
always @(negedge clk) begin
if (M4_dump_cl_decode_cl_ll_flag == 1) begin
    lagger_M4 = lagger_M4 + 1;

    if (lagger_M4 == 1) begin
        cl_decode_cl_ll_mem_read_addr = counter_M4;

    end else if (lagger_M4 == 2) begin
        $fdisplayb(M4_output_file_cl_decode_cl_ll_mem, cl_decode_cl_ll_mem_read_data);

    end else if (lagger_M4 == 3) begin

        if (counter_M4 < max_length_symbol - 1) begin
            counter_M4 = counter_M4 + 1;

        end else begin
            $fclose(M4_output_file_cl_decode_cl_ll_mem);
            M4_dump_cl_decode_cl_ll_flag = 0;
            
            $display("M4: finished dumping cl_decode_cl_ll at %d", $time);


            //setting and launching M5
            counter_M5 = 0;
            lagger_M5 = 0;
            M5_dump_cl_decode_cl_distance_flag = 1;



        end

        lagger_M4 = 0;
    
    end 
end
end












// M5

// flag
reg                                                     M5_dump_cl_decode_cl_distance_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_M5;
reg                 [q_full - 1 : 0]                    lagger_M5;

// M5 variables

//M5_dump_cl_decode_cl_distance_flag
always @(negedge clk) begin
if (M5_dump_cl_decode_cl_distance_flag == 1) begin
    lagger_M5 = lagger_M5 + 1;

    if (lagger_M5 == 1) begin
        cl_decode_cl_distance_mem_read_addr = counter_M5;

    end else if (lagger_M5 == 2) begin
        $fdisplayb(M5_output_file_cl_decode_cl_distance_mem, cl_decode_cl_distance_mem_read_data);

    end else if (lagger_M5 == 3) begin

        if (counter_M5 < max_length_symbol - 1) begin
            counter_M5 = counter_M5 + 1;

        end else begin
            $fclose(M5_output_file_cl_decode_cl_distance_mem);
            M5_dump_cl_decode_cl_distance_flag = 0;
            
            $display("M5: finished dumping cl_decode_cl_distance at %d", $time);


            //setting and launching M5
            counter_M6 = 0;
            lagger_M6 = 0;
            M6_dump_extracted_cl_symbols_flag = 1;



        end

        lagger_M5 = 0;
    
    end 
end
end

















// M6

// flag
reg                                                     M6_dump_extracted_cl_symbols_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_M6;
reg                 [q_full - 1 : 0]                    lagger_M6;

// M6 variables

//M6_dump_extracted_cl_symbols_flag
always @(negedge clk) begin
if (M6_dump_extracted_cl_symbols_flag == 1) begin
    lagger_M6 = lagger_M6 + 1;

    if (lagger_M6 == 1) begin
        cl_decode_extracted_cl_symbols_mem_read_addr = counter_M6;

    end else if (lagger_M6 == 2) begin
        $fdisplayb(M6_output_file_cl_decode_extracted_cl_symbols_mem, cl_decode_extracted_cl_symbols_mem_read_data);

    end else if (lagger_M6 == 3) begin

        if (counter_M6 < cl_decode_extracted_cl_symbols_mem_write_addr - 1) begin
            counter_M6 = counter_M6 + 1;

        end else begin
            $fclose(M6_output_file_cl_decode_extracted_cl_symbols_mem);
            M6_dump_extracted_cl_symbols_flag = 0;
            
            $display("M6: finished dumping cl_decode_extracted_cl_symbols at %d", $time);


            //setting and launching M7
            //counter_M7 = 0;
            //lagger_M7 = 0;
            //next_flag_M7 = 1;


            $display("FINISHED_______________________________________%d", $time);

        end

        lagger_M6 = 0;
    
    end 
end
end

