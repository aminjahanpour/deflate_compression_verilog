
/*


    """
    ll symbols table: index is (length symbol)

        - [11 : 3] base length:                9 bits        
        - [2 :  0] length offset bits count:   3 bits

    11      3    2 0
    000000000    000
    


    distance symbols table: index is (distance symbol)

        - [18 : 4] base distance:                 15 bits
        - [3  : 0] distance offset bits count:    4  bits

    18            4    3  0
    000000000000000    0000
    
    """






huffman_codes



    bits:
    [40 : 32] starting at  0, len of 9 : symbol value in 9 bits
    [31 : 20] starting at  9, len of 12: code length            ; cl_F
    [19 :  0] starting at 21, len of 20 : huffman code itself

    total width of the bus = 41 (huffman_codes_width)

    40     32  31        20  19                 0
    000000000  000000000000  00000000000000000000
    

*/



reg                 [3 - 1      : 0]                    verbose = 0;



reg                                                     bits_reader_go_O;
wire                                                    bits_reader_finished_O;


reg                 [q_full - 1 : 0]                    bits_count_to_read_O;


reg                 [encoded_mem_width - 1 : 0]         previous_stage_left_over_bus_O;
reg                 [8 - 1 : 0     ]                    previous_stage_left_over_bus_length_O;
reg                 [address_len - 1 : 0     ]          previous_stage_read_addr_O;

wire reg            [encoded_mem_width - 1 : 0]         left_over_bus_O;
wire reg            [8 - 1 : 0     ]                    left_over_bus_length_O;
wire reg            [address_len - 1 : 0]               bits_reader_read_addr_O;                        

wire reg            [mem_bits_reader_bus_width - 1: 0]  read_from_memory_bus_O;




bits_reader #(
    .q_full(q_full),
    .address_len(address_len),
    .mem_bits_reader_bus_width(mem_bits_reader_bus_width),
    .encoded_mem_width(encoded_mem_width),
    .input_bits_to_writer_width(input_bits_to_writer_width),
    .max_length_symbol(max_length_symbol),
    .verbose(0)
)
bits_reader_instance_O (
    .clk                    (clk),
    .go                     (bits_reader_go_O),
    .finished               (bits_reader_finished_O),

    .bits_count_to_read     (bits_count_to_read_O),

    // inputs
    .previous_stage_left_over_bus       (previous_stage_left_over_bus_O),
    .previous_stage_left_over_bus_length(previous_stage_left_over_bus_length_O),
    .previous_read_addr                 (previous_stage_read_addr_O),

    // outputs
    .left_over_bus          (left_over_bus_O),
    .left_over_bus_length   (left_over_bus_length_O),
    .output_read_addr       (bits_reader_read_addr_O),

    .read_from_memory_bus   (read_from_memory_bus_O)
);



// bits_reader collector
always @(posedge bits_reader_finished_O) begin

    bits_reader_go_O = 0;

    previous_stage_left_over_bus_O          = left_over_bus_O;
    previous_stage_left_over_bus_length_O   = left_over_bus_length_O;
    previous_stage_read_addr_O              = bits_reader_read_addr_O;


    O3_loop_over_search_lengths_flag = 1;

end












// OC

// flag
reg                                                     OC_read_config_file_flag   = 0;


// configs
reg                 [encoded_mem_width - 1 : 0]         search_starting_point_left_over_bus_O;
reg                 [8 - 1 : 0     ]                    search_starting_point_left_over_bus_length_O;
reg                 [address_len - 1 : 0     ]          search_starting_point_read_addr_O;
reg                 [q_full - 1 : 0     ]          total_encoded_bits_count_O;


// loop reset
reg                 [q_full - 1 : 0]                    counter_OC;
reg                 [q_full - 1 : 0]                    lagger_OC;


reg                 [total_header_bits_width - 1  : 0]  total_header_bits;

// OC variables

//OC_read_config_file_flag
always @(negedge clk) begin
if (OC_read_config_file_flag == 1) begin
    lagger_OC = lagger_OC + 1;

    if (lagger_OC == 1) begin
        decoder_config_mem_read_addr = counter_OC;

    end else if (lagger_OC == 2) begin
        case (counter_OC)
            0   :    search_starting_point_left_over_bus_O          = decoder_config_mem_read_data;
            1   :    search_starting_point_left_over_bus_length_O   = decoder_config_mem_read_data;
            2   :    search_starting_point_read_addr_O              = decoder_config_mem_read_data;
            3   :    total_encoded_bits_count_O                     = decoder_config_mem_read_data;
        endcase

    end else if (lagger_OC == 3) begin

        if (counter_OC < 20 - 1) begin
            counter_OC = counter_OC + 1;

        end else begin
            OC_read_config_file_flag = 0;
            
            $display("OC: search_starting_point_left_over_bus_O: %d", search_starting_point_left_over_bus_O);
            $display("OC: search_starting_point_left_over_bus_length_O: %d", search_starting_point_left_over_bus_length_O);
            $display("OC: search_starting_point_read_addr_O: %d", search_starting_point_read_addr_O);
            $display("OC: total_encoded_bits_count_O: %d", total_encoded_bits_count_O);


            decoded_bits_mem_write_addr = 0;

            //setting and launching O2
            ll_code_length_lb_O = 100;
            ll_code_length_ub_O = 0;
            distance_code_length_lb_O = 100;
            distance_code_length_ub_O = 0;
            counter_O2 = 0;
            lagger_O2 = 0;
            O2_get_codes_length_range_flag = 1;


        end

        lagger_OC = 0;
    
    end 
end
end














// O2

// flag
reg                                                     O2_get_codes_length_range_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_O2;
reg                 [q_full - 1 : 0]                    lagger_O2;

// O2 variables
reg                 [8 - 1 :      0]                    ll_code_length_ub_O;
reg                 [8 - 1 :      0]                    ll_code_length_lb_O;
reg                 [8 - 1 :      0]                    distance_code_length_ub_O;
reg                 [8 - 1 :      0]                    distance_code_length_lb_O;


//O2_get_codes_length_range_flag
always @(negedge clk) begin
if (O2_get_codes_length_range_flag == 1) begin
    lagger_O2 = lagger_O2 + 1;

    if (lagger_O2 == 1) begin
        decoder_input_ll_codes_mem_read_addr        = counter_O2;
        decoder_input_distance_codes_mem_read_addr  = counter_O2;

    end else if (lagger_O2 == 2) begin

        if (ll_code_length_ub_O < decoder_input_ll_codes_mem_read_data[31 : 20]) begin
            ll_code_length_ub_O = decoder_input_ll_codes_mem_read_data[31 : 20];
        end

        if (distance_code_length_ub_O < decoder_input_distance_codes_mem_read_data[31 : 20]) begin
            distance_code_length_ub_O = decoder_input_distance_codes_mem_read_data[31 : 20];
        end


    end else if (lagger_O2 == 3) begin

        if ((ll_code_length_lb_O > decoder_input_ll_codes_mem_read_data[31 : 20]) && (decoder_input_ll_codes_mem_read_data[31 : 20] > 0)) begin
            ll_code_length_lb_O = decoder_input_ll_codes_mem_read_data[31 : 20];
        end


        if ((distance_code_length_lb_O > decoder_input_distance_codes_mem_read_data[31 : 20]) && (decoder_input_distance_codes_mem_read_data[31 : 20] > 0)) begin
            distance_code_length_lb_O = decoder_input_distance_codes_mem_read_data[31 : 20];
        end


    end else if (lagger_O2 == 4) begin

        if (counter_O2 < max_length_symbol - 1) begin
            counter_O2 = counter_O2 + 1;

        end else begin
            O2_get_codes_length_range_flag = 0;
            
            $display("\nO2: ll_code_length_lb_O %d", ll_code_length_lb_O);
            $display("O2: ll_code_length_ub_O %d", ll_code_length_ub_O);
            $display("O2: distance_code_length_lb_O %d", distance_code_length_lb_O);
            $display("O2: distance_code_length_ub_O %d\n", distance_code_length_ub_O);

            //setting and launching O4

            search_length_ub_O3 = ll_code_length_ub_O;
            search_length_lb_O3 = ll_code_length_lb_O;
            
            search_length_O3 = search_length_lb_O3;
            total_decoded_bits_O3 = 0;

            ll_or_distance_O = 0;

            decoded_content_mem_write_addr = 0;

            lagger_O3 = 0;
            O3_loop_over_search_lengths_flag = 1;



        end

        lagger_O2 = 0;
    
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


// O3

// flag
reg                                                     O3_loop_over_search_lengths_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    lagger_O3;

// O3 variables
reg                 [3 - 1      : 0]                    search_length_lb_O3;
reg                 [3 - 1      : 0]                    search_length_ub_O3;
reg                 [3 - 1      : 0]                    search_length_O3;


reg                 [q_full - 1 : 0]                    total_decoded_bits_O3;
reg                 [q_full - 1 : 0]                    total_decoded_ll_cl_values_count_O3;
reg                 [q_full - 1 : 0]                    total_decoded_distance_cl_values_count_O3;
reg                 [mem_bits_reader_bus_width - 1: 0]  cl_repeat_count_O;

reg                                                     ll_or_distance_O;
reg                                                     literal_or_pair_O;
reg                                                     cat_or_dog_O;

reg                 [9 - 1 : 0     ]                    decoded_literal_value_O;
reg                 [9 - 1 : 0     ]                    decoded_length_value_O;
reg                 [9 - 1 : 0     ]                    decoded_distance_value_O;


//O3_loop_over_search_lengths_flag
always @(negedge clk) begin
if (O3_loop_over_search_lengths_flag == 1) begin
    lagger_O3 = lagger_O3 + 1;

    if (lagger_O3 == 1) begin

        if (ll_or_distance_O == 0) begin

            bits_count_to_read_O = search_length_O3;

            


            previous_stage_left_over_bus_O          = search_starting_point_left_over_bus_O;
            previous_stage_left_over_bus_length_O   = search_starting_point_left_over_bus_length_O;
            previous_stage_read_addr_O              = search_starting_point_read_addr_O;

        end

    end else if (lagger_O3 == 2) begin

        if (ll_or_distance_O == 0) begin

            O3_loop_over_search_lengths_flag = 0;
            // setting and launching bits reader
            bits_reader_go_O = 1;

            

        end

    end else if (lagger_O3 == 3) begin

        if (ll_or_distance_O == 0) begin

            // $display("O3: starting to look for huffman code for: %b of len: %d", read_from_memory_bus_O, bits_count_to_read_O);

            O3_loop_over_search_lengths_flag = 0;
            // setting and launching O4
            found_a_matching_symbol_O4 = 0;
            matching_symbol_O4 = 0;
            lagger_O4 = 0;
            counter_O4 = 0;
            O4_loop_over_huffman_codes_flag  = 1;

        end



    end else if (lagger_O3 == 4) begin
        if (ll_or_distance_O == 0) begin

            if (found_a_matching_symbol_O4) begin

                if (matching_symbol_O4 <= 255) begin
                    if(verbose > 0) $display("O3: decoded a literal symbol: %d\t\t\t(%d)", matching_symbol_O4, total_decoded_bits_O3);
                    decoded_literal_value_O = matching_symbol_O4;
                    search_length_O3 = search_length_lb_O3 - 1;
                    literal_or_pair_O = 0;

                end else begin
                    if(verbose > 1) $display("O3: decoded a length symbol: %d\t\t\t(%d)", matching_symbol_O4, total_decoded_bits_O3);

                    ll_symbols_table_mem_read_addr = matching_symbol_O4 - 257;

                    literal_or_pair_O = 1;

                end


            end

        end



    end else if (lagger_O3 == 5) begin
        if (ll_or_distance_O == 0) begin

            if (found_a_matching_symbol_O4) begin

                if (matching_symbol_O4 > 255) begin


                    decoded_length_value_O = ll_symbols_table_mem_read_data[11 : 3];

                    if(verbose > 1) $display("O3:\t\t base length is:%d", decoded_length_value_O);
                    if(verbose > 1) $display("O3:\t\t offset bits count is:%d", ll_symbols_table_mem_read_data[2 : 0]);
                        

                    if (ll_symbols_table_mem_read_data[2 : 0] > 0) begin

                        bits_count_to_read_O = ll_symbols_table_mem_read_data[2 : 0];

                        

                        previous_stage_left_over_bus_O          = search_starting_point_left_over_bus_O;
                        previous_stage_left_over_bus_length_O   = search_starting_point_left_over_bus_length_O;
                        previous_stage_read_addr_O              = search_starting_point_read_addr_O;

                    end

                end 

            end
        end





    end else if (lagger_O3 == 6) begin
        if (ll_or_distance_O == 0) begin

            if (found_a_matching_symbol_O4) begin

                if (matching_symbol_O4 > 255) begin

                    if (ll_symbols_table_mem_read_data[2 : 0] > 0) begin

                        O3_loop_over_search_lengths_flag  =0;
                        bits_reader_go_O = 1;
                        total_decoded_bits_O3 = total_decoded_bits_O3 + bits_count_to_read_O;

                    end

                end 

            end
        end



    end else if (lagger_O3 == 7) begin
        if (ll_or_distance_O == 0) begin

            if (found_a_matching_symbol_O4) begin

                if (matching_symbol_O4 > 255) begin
                    if (ll_symbols_table_mem_read_data[2 : 0] > 0) begin


                        search_starting_point_left_over_bus_O          = left_over_bus_O;
                        search_starting_point_left_over_bus_length_O   = left_over_bus_length_O;
                        search_starting_point_read_addr_O              = bits_reader_read_addr_O;
            

                        decoded_length_value_O = decoded_length_value_O + read_from_memory_bus_O;
                        if(verbose > 1) $display("O3:\t\t after adding the offset bits (%d), length becomes:%d\t\t\t(%d)", read_from_memory_bus_O, decoded_length_value_O, total_decoded_bits_O3);

                    end
                end

            end 
        end 

    end else if (lagger_O3 == 8) begin
        if (ll_or_distance_O == 0) begin

            if (found_a_matching_symbol_O4) begin

                if (matching_symbol_O4 > 255) begin

                    // next one would be a distance symbol
                    ll_or_distance_O = 1;

                    search_length_lb_O3 = distance_code_length_lb_O;
                    search_length_ub_O3 = distance_code_length_ub_O;
                    
                    search_length_O3 = search_length_lb_O3;

                end
            end

        end





































    end else if (lagger_O3 == 9) begin
        if (ll_or_distance_O == 1) begin

            bits_count_to_read_O = search_length_O3;

            

            previous_stage_left_over_bus_O          = search_starting_point_left_over_bus_O;
            previous_stage_left_over_bus_length_O   = search_starting_point_left_over_bus_length_O;
            previous_stage_read_addr_O              = search_starting_point_read_addr_O;

        end 


    end else if (lagger_O3 == 10) begin
        if (ll_or_distance_O == 1) begin

            O3_loop_over_search_lengths_flag = 0;
            // setting and launching bits reader
            bits_reader_go_O = 1;


        end



    end else if (lagger_O3 == 11) begin

        if (ll_or_distance_O == 1) begin

            O3_loop_over_search_lengths_flag = 0;
            // setting and launching O4
            found_a_matching_symbol_O4 = 0;
            matching_symbol_O4 = 0;
            lagger_O4 = 0;
            counter_O4 = 0;
            O4_loop_over_huffman_codes_flag  = 1;

        end



    end else if (lagger_O3 == 12) begin
        if (ll_or_distance_O == 1) begin

            if (found_a_matching_symbol_O4) begin

                if(verbose > 1) $display("O3: decoded a distance symbol: %d\t\t\t(%d)", matching_symbol_O4, total_decoded_bits_O3);

                distance_symbols_table_mem_read_addr = matching_symbol_O4;

            end

        end



    end else if (lagger_O3 == 13) begin

        if (ll_or_distance_O == 1) begin

            if (found_a_matching_symbol_O4) begin

                decoded_distance_value_O = distance_symbols_table_mem_read_data[18 : 4];


                if(verbose > 1) $display("O3:\t\t base distance is:%d", decoded_distance_value_O);
                if(verbose > 1) $display("O3:\t\t offset bits count is:%d", distance_symbols_table_mem_read_data[3 : 0]);

                if (distance_symbols_table_mem_read_data[3 : 0] > 0) begin

                    bits_count_to_read_O = distance_symbols_table_mem_read_data[3 : 0];

                    


                    previous_stage_left_over_bus_O          = search_starting_point_left_over_bus_O;
                    previous_stage_left_over_bus_length_O   = search_starting_point_left_over_bus_length_O;
                    previous_stage_read_addr_O              = search_starting_point_read_addr_O;

                end


            end
        end


    end else if (lagger_O3 == 14) begin

        if (ll_or_distance_O == 1) begin

            if (found_a_matching_symbol_O4) begin

                if (distance_symbols_table_mem_read_data[3 : 0] > 0) begin

                    O3_loop_over_search_lengths_flag  =0;
                    bits_reader_go_O = 1;
                    total_decoded_bits_O3 = total_decoded_bits_O3 + bits_count_to_read_O;

                end


            end
        end



    end else if (lagger_O3 == 15) begin

        if (ll_or_distance_O == 1) begin

            if (found_a_matching_symbol_O4) begin
                if (distance_symbols_table_mem_read_data[3 : 0] > 0) begin

                    search_starting_point_left_over_bus_O          = left_over_bus_O;
                    search_starting_point_left_over_bus_length_O   = left_over_bus_length_O;
                    search_starting_point_read_addr_O              = bits_reader_read_addr_O;
            


                    decoded_distance_value_O = decoded_distance_value_O + read_from_memory_bus_O;
                    if(verbose > 1) $display("O3:\t\t after adding the offset bits (%d), distance is:%d\t\t\(%d)", read_from_memory_bus_O, decoded_distance_value_O, total_decoded_bits_O3);

                end

            end 

        end 




    end else if (lagger_O3 == 16) begin
        if (ll_or_distance_O == 1) begin

            if (found_a_matching_symbol_O4) begin


                if(verbose > 0) $display("O3: decoded (distance, length):(%d,%d)\t\t\t(%d)", decoded_distance_value_O, decoded_length_value_O, total_decoded_bits_O3);

                // next one would be a length symbol
                ll_or_distance_O = 0;

                search_length_lb_O3 = ll_code_length_lb_O;
                search_length_ub_O3 = ll_code_length_ub_O;
                
                search_length_O3 = search_length_lb_O3 - 1;

                // $display("setting search_length_O3 to %d", search_length_O3);

            end

        end







    end else if (lagger_O3 == 17) begin


        if (found_a_matching_symbol_O4) begin


            cat_or_dog_O = (decoded_distance_value_O < decoded_length_value_O) ? 0 : 1;

            O3_loop_over_search_lengths_flag = 0;
            // setting and launching O5
            finished_writing_to_mem_O5 = 0;
            lagger_O5 = 0;
            counter_O5 = 0;
            O5_store_decoded_values_main_loop_flag = 1;
        

            if (literal_or_pair_O == 0) begin
                $display("\n\nO3: going to write literal: %d", decoded_literal_value_O);
            end else begin
                $display("\n\nO3: going to write pair(%d, %d), cat_dog:%d", decoded_distance_value_O, decoded_length_value_O, cat_or_dog_O);

            end


        end


    end else if (lagger_O3 == 18) begin

        if (search_length_O3 < search_length_ub_O3) begin
            search_length_O3 = search_length_O3 + 1;

        end else begin
            
            O3_loop_over_search_lengths_flag = 0;
            // setting and launching O10
            lagger_O10 = 0;
            counter_O10 = 0;
            O10_dump_decoded_bits_flag     = 1;

        end



        lagger_O3 = 0;
    
    end 
end
end













// O4

// flag
reg                                                     O4_loop_over_huffman_codes_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_O4;
reg                 [q_full - 1 : 0]                    lagger_O4;

// O4 variables
reg                                                     found_a_matching_symbol_O4;
reg                 [9 - 1      : 0]                    matching_symbol_O4;
reg                 [huffman_codes_width - 1 	 : 0]   huffman_code_read_from_mem_O      ;

//O4_loop_over_huffman_codes_flag
always @(negedge clk) begin
if (O4_loop_over_huffman_codes_flag == 1) begin
    lagger_O4 = lagger_O4 + 1;

    if (lagger_O4 == 1) begin

        if (ll_or_distance_O == 0) begin
            decoder_input_ll_codes_mem_read_addr = counter_O4;
            
        end else begin
            decoder_input_distance_codes_mem_read_addr = counter_O4;
        end

    end else if (lagger_O4 == 2) begin

        if (ll_or_distance_O == 0) begin
            huffman_code_read_from_mem_O = decoder_input_ll_codes_mem_read_data;

        end else begin
            huffman_code_read_from_mem_O = decoder_input_distance_codes_mem_read_data;
        end


    end else if (lagger_O4 == 3) begin

        if (
            (read_from_memory_bus_O & (((2 << (search_length_O3 - 1)) - 1))) == (huffman_code_read_from_mem_O & (((2 << (huffman_code_read_from_mem_O[31 : 20] - 1)) - 1)))
            &&  
            (huffman_code_read_from_mem_O[31 : 20] == search_length_O3)
        ) begin


            found_a_matching_symbol_O4 = 1;
            matching_symbol_O4 = huffman_code_read_from_mem_O[40 : 32];

            // update search start point
            search_starting_point_left_over_bus_O          = left_over_bus_O;
            search_starting_point_left_over_bus_length_O   = left_over_bus_length_O;
            search_starting_point_read_addr_O              = bits_reader_read_addr_O;
            

            total_decoded_bits_O3 = total_decoded_bits_O3 + search_length_O3;
            // $display("O4: \t\t\t\t\t\t\t\t\t found a match:    search_length:%d,   ll_or_dis:%d", search_length_O3,ll_or_distance_O);

        end


    end else if (lagger_O4 == 5) begin

        if ((found_a_matching_symbol_O4 == 0) && (counter_O4 < max_length_symbol - 1)) begin

            counter_O4 = counter_O4 + 1;

        end else begin


            O4_loop_over_huffman_codes_flag = 0;
            O3_loop_over_search_lengths_flag = 1;


            if (found_a_matching_symbol_O4 == 0) begin
                // $display("O4: \t\t\t\t\t\t\t\t\t nothing found for search_length:%d,   ll_or_dis:%d", search_length_O3,ll_or_distance_O);
            end

        end

        lagger_O4 = 0;
    
    end 
end
end



































    
// O5

// flag
reg                                                     O5_store_decoded_values_main_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_O5;
reg                 [q_full - 1 : 0]                    lagger_O5;
reg                                                     finished_writing_to_mem_O5;

// O5 variables

    

//O5_store_decoded_values_main_loop_flag
always @(negedge clk) begin
if (O5_store_decoded_values_main_loop_flag == 1) begin
    lagger_O5 = lagger_O5 + 1;

    if (lagger_O5 == 1) begin
        if (literal_or_pair_O == 0) begin
            decoded_bits_mem_write_data = decoded_literal_value_O;
        end

    end else if (lagger_O5 == 2) begin
        if (literal_or_pair_O == 0) begin
            decoded_bits_mem_write_enable = 1;
        end

    end else if (lagger_O5 == 3) begin
        if (literal_or_pair_O == 0) begin
            decoded_bits_mem_write_enable = 0;
        end


    end else if (lagger_O5 == 5) begin
        if (literal_or_pair_O == 0) begin
            finished_writing_to_mem_O5 = 1;
            $display("O5:\t\t\t\t\t\t\t\t\t\t\t\t\t\ wrote:%d, on addr:%d", decoded_bits_mem_write_data,decoded_bits_mem_write_addr);
            decoded_bits_mem_write_addr = decoded_bits_mem_write_addr + 1;

        end









    // SINGLE DOG
    end else if (lagger_O5 == 6) begin
        
        if ((finished_writing_to_mem_O5 == 0) && (cat_or_dog_O == 1)) begin
            if (decoded_distance_value_O == 1) begin
                decoded_bits_mem_read_addr = decoded_bits_mem_write_addr - 1;
            end
        end

    end else if (lagger_O5 == 7) begin
        
        if ((finished_writing_to_mem_O5 == 0) && (cat_or_dog_O == 1)) begin
            if (decoded_distance_value_O == 1) begin
                decoded_bits_mem_write_data = decoded_bits_mem_read_data;
            end
        end


    end else if (lagger_O5 == 8) begin
        
        if ((finished_writing_to_mem_O5 == 0) && (cat_or_dog_O == 1)) begin
            if (decoded_distance_value_O == 1) begin
                decoded_bits_mem_write_enable = 1;
            end
        end



    end else if (lagger_O5 == 9) begin
        
        if ((finished_writing_to_mem_O5 == 0) && (cat_or_dog_O == 1)) begin
            if (decoded_distance_value_O == 1) begin
                decoded_bits_mem_write_enable = 0;
            end
        end



    end else if (lagger_O5 == 10) begin
        
        if ((finished_writing_to_mem_O5 == 0) && (cat_or_dog_O == 1)) begin
            if (decoded_distance_value_O == 1) begin
                finished_writing_to_mem_O5 = 1;
                $display("O5:\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t wrote:%d, on addr:%d", decoded_bits_mem_write_data,decoded_bits_mem_write_addr);
                decoded_bits_mem_write_addr = decoded_bits_mem_write_addr - 1;

            end
        end














    // DOGS
    end else if (lagger_O5 == 11) begin
        
        if ((finished_writing_to_mem_O5 == 0) && (cat_or_dog_O == 1)) begin
            if (decoded_distance_value_O > 1) begin


                O5_store_decoded_values_main_loop_flag = 0;
                // setting and launching D6
                counter_O6 = decoded_bits_mem_write_addr - decoded_distance_value_O;
                counter_cap_O6 = counter_O6 + decoded_length_value_O;
                lagger_O6 = 0;
                O6_dog_writer_flag = 1;

            end
        end



    end else if (lagger_O5 == 12) begin
        
        if ((finished_writing_to_mem_O5 == 0) && (cat_or_dog_O == 1)) begin
            if (decoded_distance_value_O > 1) begin

                finished_writing_to_mem_O5 = 1;

            end
        end























    // CATS
    end else if (lagger_O5 == 13) begin
        
        if ((finished_writing_to_mem_O5 == 0) && (cat_or_dog_O == 0)) begin

            $display("O5: starting the cat counter");

            O5_store_decoded_values_main_loop_flag = 0;
            // setting and launching O7
            counter_O7 = 0;
            lagger_O7 = 0;
            O7_cats_counter_flag = 1;

        end







    end else if (lagger_O5 == 30) begin



        O5_store_decoded_values_main_loop_flag = 0;
        
        O3_loop_over_search_lengths_flag = 1;

    
    end 
end
end





















// O6

// flag
reg                                                     O6_dog_writer_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_O6;
reg                 [q_full - 1 : 0]                    counter_cap_O6;
reg                 [q_full - 1 : 0]                    lagger_O6;

// O6 variables

    

//O6_dog_writer_flag
always @(negedge clk) begin
if (O6_dog_writer_flag == 1) begin
    lagger_O6 = lagger_O6 + 1;

    if (lagger_O6 == 1) begin
        decoded_bits_mem_read_addr = counter_O6;

    end else if (lagger_O6 == 2) begin
        decoded_bits_mem_write_data = decoded_bits_mem_read_data;

    end else if (lagger_O6 == 3) begin
        decoded_bits_mem_write_enable = 1;

    end else if (lagger_O6 == 4) begin
        decoded_bits_mem_write_enable = 0;

    end else if (lagger_O6 == 5) begin

        $display("O5:\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t wrote:%d, on addr:%d", decoded_bits_mem_write_data,decoded_bits_mem_write_addr);

        decoded_bits_mem_write_addr = decoded_bits_mem_write_addr + 1;

    end else if (lagger_O6 == 6) begin

        if (counter_O6 < counter_cap_O6 - 1) begin
            counter_O6 = counter_O6 + 1;

        end else begin
            
            O6_dog_writer_flag = 0;
            O5_store_decoded_values_main_loop_flag = 1;


        end

        lagger_O6 = 0;
    
    end 
end
end





























// O7

// flag
reg                                                     O7_cats_counter_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_O7;
reg                 [q_full - 1 : 0]                    lagger_O7;

// O7 variables

    

//O7_cats_counter_flag
always @(negedge clk) begin
if (O7_cats_counter_flag == 1) begin
    lagger_O7 = lagger_O7 + 1;

    if (lagger_O7 == 1) begin

        if (counter_O7 < decoded_length_value_O) begin
        
            $display("O7: starting the cat writer");

            O7_cats_counter_flag = 0;
            // setting and launching O8;
            lagger_O8 = 0;

            counter_O8 = decoded_bits_mem_write_addr - decoded_distance_value_O;
            counter_cap_O8 = decoded_bits_mem_write_addr;

            O8_cats_writer_flag = 1;


        end else begin
            

            O7_cats_counter_flag = 0;

            O5_store_decoded_values_main_loop_flag = 1;

        end        

    end else if (lagger_O7 == 2) begin

        counter_O7 = counter_O7 + decoded_distance_value_O;


        lagger_O7 = 0;
    
    end 
end
end









// O8

// flag
reg                                                     O8_cats_writer_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_O8;
reg                 [q_full - 1 : 0]                    counter_cap_O8;
reg                 [q_full - 1 : 0]                    lagger_O8;

// O8 variables

    

//O8_cats_writer_flag
always @(negedge clk) begin
if (O8_cats_writer_flag == 1) begin
    lagger_O8 = lagger_O8 + 1;

    if (lagger_O8 == 1) begin
        decoded_bits_mem_read_addr = counter_O8;
        

    end else if (lagger_O8 == 2) begin
        decoded_bits_mem_write_data = decoded_bits_mem_read_data;

    end else if (lagger_O8 == 3) begin
        decoded_bits_mem_write_enable = 1;

    end else if (lagger_O8 == 4) begin
        decoded_bits_mem_write_enable = 0;

    end else if (lagger_O8 == 5) begin

        $display("O8:\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t wrote:%d, on addr:%d", decoded_bits_mem_write_data,decoded_bits_mem_write_addr);

        decoded_bits_mem_write_addr = decoded_bits_mem_write_addr + 1;


    end else if (lagger_O8 == 6) begin

        if (counter_O8 < counter_cap_O8 - 1) begin
            counter_O8 = counter_O8 + 1;

        end else begin
            
            O8_cats_writer_flag = 0;
            O7_cats_counter_flag = 1;
            

        end

        lagger_O8 = 0;
    
    end 
end
end



























// O10

// flag
reg                                                     O10_dump_decoded_bits_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_O10;
reg                 [q_full - 1 : 0]                    lagger_O10;

// O10 variables

//O10_dump_decoded_bits_flag
always @(negedge clk) begin
if (O10_dump_decoded_bits_flag == 1) begin
    lagger_O10 = lagger_O10 + 1;

    if (lagger_O10 == 1) begin
        decoded_bits_mem_read_addr = counter_O10;

    end else if (lagger_O10 == 2) begin
        $fdisplayb(O10_output_file_decoded_bits_mem, decoded_bits_mem_read_data);

    end else if (lagger_O10 == 3) begin

        if (counter_O10 < input_bytes_count - 1) begin
            counter_O10 = counter_O10 + 1;

        end else begin
            $fclose(O10_output_file_decoded_bits_mem);
            O10_dump_decoded_bits_flag = 0;
            
            $display("O10: finished dumping decoded_bits at %d", $time);


            //setting and launching O7
            //counter_O7 = 0;
            //lagger_O7 = 0;
            //next_flag_O7 = 1;


            $display("FINISHED_______________________________________%d", $time);

        end

        lagger_O10 = 0;
    
    end 
end
end
