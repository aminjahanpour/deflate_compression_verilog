
            

module lzss (
    input                                               clk,
    input                                               reset
);


// Output Files

integer                                                 D6_output_file_ll_symbols_mem;
integer                                                 D6_output_file_distance_symbols_mem;
integer                                                 D6_output_file_lzss_output_mem;
integer                                                 D_output_file_general;



// Reset
always @(posedge reset) begin

    reset_rams_flag                         = 1;


    ram_reset_counter_cap                   = 1;





    
    D6_output_file_ll_symbols_mem =                                $fopen("./dumps/D6_output_file_ll_symbols_mem.txt", "w");
D6_output_file_distance_symbols_mem =                                $fopen("./dumps/D6_output_file_distance_symbols_mem.txt", "w");
D6_output_file_lzss_output_mem =                                $fopen("./dumps/D6_output_file_lzss_output_mem.txt", "w");
D_output_file_general =                                $fopen("./dumps/D_output_file_general.txt", "w");


end


            

localparam                                              address_len                      = 24;
localparam                                              laggers_len                      = 8;
localparam                                              q_full                      = 48;
localparam                                              q_half                      = 24;
localparam                                              input_bytes_count                      = 134;
localparam                                              lzss_future_size                      = 10;
localparam                                              lzss_min_search_len                      = 2;
localparam                                              lzss_history_size                      = 32768;
localparam                                              lzss_mlwbr                      = 3;
localparam                                              length_symbol_counts                      = 255;
localparam                                              distance_symbol_counts                      = 999;
localparam                                              max_length_symbol                      = 286;
localparam                                              max_distance_symbol                      = 30;
localparam                                              freq_list_width                      = 63;
localparam                                              vs_val_for_taken_by_symbol                      = 229;
localparam                                              encoded_mem_width                      = 8;
localparam                                              input_bits_to_writer_width                      = 16;
localparam                                              pre_bitstream_width                      = 21;
localparam                                              cl_cl_count                      = 19;
localparam                                              lzss_output_width                      = 40;
localparam                                              huffman_codes_width                      = 41;
localparam                                              ll_freq_list_depth                      = 573;
localparam                                              distance_freq_list_depth                      = 61;
localparam                                              freq_list_depth                      = 573;
localparam                                              huffman_nodes_count                      = 2860;
localparam                                              compiler_max_output_count                      = 2860;
localparam                                              total_header_bits_width                      = 24;
localparam                                              mem_bits_reader_bus_width                      = 24;




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




                

            reg                                                     reset_rams_flag                     = 0;
    
            reg                 [q_full - 1 : 0]                    ram_reset_counter_cap;
    
            reg                 [q_full - 1 : 0]                    counter_ram_reset_A                 = 0;
            reg                 [q_full - 1 : 0]                    lagger_ram_reset_A                  = 0;
    
    
            always @(negedge clk) begin
                if (reset_rams_flag == 1) begin
                    lagger_ram_reset_A = lagger_ram_reset_A + 1;
    
                    if (lagger_ram_reset_A == 1) begin
    
    
                        
    
    
                    end else if (lagger_ram_reset_A == 2) begin
    
    
                        
    
    
                    end else if (lagger_ram_reset_A == 3) begin
    
    
                        
    
    
                    end else if (lagger_ram_reset_A == 4) begin
    
    
                        
    
    
    
                    end else if (lagger_ram_reset_A == 5) begin
    
                        if (counter_ram_reset_A < ram_reset_counter_cap - 1) begin
                            counter_ram_reset_A = counter_ram_reset_A + 1;
    
                        end else begin
                            counter_ram_reset_A = 0;
                            reset_rams_flag = 0;
                            $display("A: finished reset_rams_flag");
    
    
                            // setting and launching the first flag
                            
                               history_length_D            = 0;
                               ll_symbols_mem_write_addr   = 0;
                               distance_symbols_mem_write_addr = 0;
                               lzss_output_mem_write_addr  = 0;
                               i_counter_D0                = 0;
                               i_lagger_D0                 = 0;
                               D0_lzss_main_loop_flag      = 1;
            
                        end
    
    
                        lagger_ram_reset_A = 0;
    
                    end 
                end
            end
    
            
/*
D0 loops over the input bytes. 

at each step, D0 calls D1 to generate `future_full_search_term_D1`
this variable contains all the bytes in our future list.
Once done, D1 then calls D2.

D2 iterates over all the `saerch_len` values.
for each search_len, D2 calls D3.

D3 iterated though the starting seach index all history chunks of the size of `saerch_len`.
It generates `history_start_search_idx_D3` which is the startting point in the history
for each history chunk, D3 calls D4.

D4 reads the chunk described by D3 from the memory.
then D4 makes the comparison via a function call.
if D4 finds a length-distance pair, it calls D5 to store it into ram













LZSS OUTPUT

    this is what we get from running lzss
    once we have our canonical huffman codes ready, 
    we use them to encode the symbols stored in this ram
    
    bits from left to right:
    bit 0: 
        is zero if the entry is a literal 
        is one if the entry is length-distance description

    if it is a literal:
        bits 1 to 8 (inclusive) contain the literal
    
    if it is a length-distance description:
        bits 1 to 9   (inclusive, 9 bits) contain the length symbol
        bits 10 to 12 (inclusive, 3 bits) contain the number of length offset bits
        bits 13 to 17 (inclusive, 5 bits) contain the length symbol offset bits
        bits 17 to 21 (inclusive, 5 bits) contain the distance symbol
        bits 22 to 25 (inclusive, 4 bits) contain the number of distance offset bits
        bits 26 to 38 (inclusive, 13 bits) contain the distance offset bits
*/









// D0

// flag
reg                                                     D0_lzss_main_loop_flag   = 0;


// system reset
reg                 [q_full - 1 : 0]                    history_length_D;        
reg                 [q_full - 1 : 0]                    i_counter_D0                 = 0;
reg                 [q_full - 1 : 0]                    i_lagger_D0                 = 0;


// loop reset

reg                 [q_full - 1 : 0]                    length_D;
reg                 [q_full - 1 : 0]                    distance_D;

reg                 [q_full - 1 : 0]                    found_something_D;
reg                 [q_full - 1 : 0]                    cat_counter_D;
reg                 [q_full - 1 : 0]                    cats_found_D;

reg                 [q_full - 1 : 0]                    ll_symbols_count_D;
reg                 [q_full - 1 : 0]                    distance_symbols_count_D;
reg                 [q_full - 1 : 0]                    lzss_outputs_count_D;


// D0_lzss_main_loop_flag 
always @(negedge clk) begin
    if (D0_lzss_main_loop_flag == 1) begin
        i_lagger_D0 = i_lagger_D0 + 1;

        if (i_lagger_D0 == 1) begin

            // $display("\n\nD0: i_counter_D0: %d, history_length_D:%d", i_counter_D0, history_length_D);


            found_something_D = 0;
            cat_counter_D = 0;
            cats_found_D = 0;

            distance_D = 0;
            length_D = 1;

            if (history_length_D > 0) begin
                D0_lzss_main_loop_flag = 0;

                // resetting and launching D1
                future_full_search_term_D1 = 0;
                counter_D1 = 0;
                lagger_D1 = 0;

                D1_lzss_build_search_term_flag = 1;


            end

        end else if (i_lagger_D0 == 2) begin

            /*
                at this point we have exhausted all search lengths and every history chunk
                for each search length.
                if nothing was found, we store the literal only. 
            */

            if (found_something_D == 0) begin
                input_bits_mem_read_addr = i_counter_D0;
            end

        end else if (i_lagger_D0 == 3) begin

            if (found_something_D == 0) begin
                $display("D0: %d: storing literal: %d", i_counter_D0, input_bits_mem_read_data);
                
                ll_symbols_mem_write_data = input_bits_mem_read_data;

                lzss_output_mem_write_data = 1'b0 << 39;
                lzss_output_mem_write_data[38 : 30] = input_bits_mem_read_data;

            end


        end else if (i_lagger_D0 == 5) begin
            if (found_something_D == 0) begin                
                ll_symbols_mem_write_enable = 1;
                lzss_output_mem_write_enable = 1;
            end

        end else if (i_lagger_D0 == 6) begin
            if (found_something_D == 0) begin                
                ll_symbols_mem_write_enable = 0;
                lzss_output_mem_write_enable = 0;
            end

        end else if (i_lagger_D0 == 7) begin
            if (found_something_D == 0) begin                
                ll_symbols_mem_write_addr = ll_symbols_mem_write_addr + 1;
                lzss_output_mem_write_addr = lzss_output_mem_write_addr + 1;

                found_something_D = 0;

            end


        end else if (i_lagger_D0 == 8) begin


            if (i_counter_D0 < input_bytes_count - 1) begin

                history_length_D = i_counter_D0 + length_D;

                i_counter_D0 = i_counter_D0 + length_D;



            end else begin
                i_counter_D0 = 0;
                D0_lzss_main_loop_flag = 0;

                ll_symbols_count_D = ll_symbols_mem_write_addr;
                distance_symbols_count_D = distance_symbols_mem_write_addr;
                lzss_outputs_count_D = lzss_output_mem_write_addr;

                ll_symbols_mem_write_addr = 0;
                distance_symbols_mem_write_addr = 0;
                lzss_output_mem_write_addr = 0;


                $display("D0:\n total of ll_symbols: %d\n distance_symbols:%d\n total outpus: %d",
                 ll_symbols_count_D, distance_symbols_count_D, lzss_outputs_count_D);

                $fdisplayb(D_output_file_general, ll_symbols_count_D);
                $fdisplayb(D_output_file_general, distance_symbols_count_D);
                $fdisplayb(D_output_file_general, lzss_outputs_count_D);
                $fclose(D_output_file_general);

                 D6_lzss_dumpper_flag = 1;

            end

            i_lagger_D0 = 0;
            

        end 
    end
end







// D1

// flag
reg                                                     D1_lzss_build_search_term_flag   = 0;

     
// loop reset
reg                 [q_full - 1 : 0]                    counter_D1;
reg                 [q_full - 1 : 0]                    lagger_D1;
reg                 [(lzss_future_size * 8) - 1 : 0]    future_full_search_term_D1;



// D1_lzss_build_search_term_flag
always @(negedge clk) begin
    if (D1_lzss_build_search_term_flag == 1) begin
        lagger_D1 = lagger_D1 + 1;

        if (lagger_D1 == 1) begin
            // $display("search_len_D2: %d", search_len_D2);
            
        end else if (lagger_D1 == 2) begin
            input_bits_mem_read_addr = i_counter_D0 + counter_D1;

        end else if (lagger_D1 == 3) begin
            // $display("D1: %d", input_bits_mem_read_data);

            future_full_search_term_D1 = future_full_search_term_D1 + (input_bits_mem_read_data << (8 * (lzss_future_size - counter_D1 - 1)));
            // $display("D1: %b", future_full_search_term_D1);


        end else if (lagger_D1 == 5) begin

            if ((counter_D1 < lzss_future_size - 1) && (i_counter_D0 + counter_D1 < input_bytes_count - 1)) begin
                counter_D1 = counter_D1 + 1;

            end else begin
                D1_lzss_build_search_term_flag = 0;
                
                // resetting and luanching D2
                if (i_counter_D0 + lzss_future_size <= input_bytes_count) begin
                    search_len_D2            = lzss_future_size;

                end else begin
                    search_len_D2            = input_bytes_count - i_counter_D0;

                end
                // $display("D1: search_len_D2 starting from: %d downward", search_len_D2);

                search_len_lagger_D2     = 0;
                D2_lzss_search_len_loop_flag = 1;

            end

            lagger_D1 = 0;

        end 
    end
end












// D2

// flag
reg                                                     D2_lzss_search_len_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    search_len_D2;
reg                 [q_full - 1 : 0]                    search_len_lagger_D2;

// system reset
reg                 [q_full - 1 : 0]                    search_term_D1;


// loop over all search_len values
// D2_lzss_search_len_loop_flag
always @(negedge clk) begin
    if (D2_lzss_search_len_loop_flag == 1) begin
        search_len_lagger_D2 = search_len_lagger_D2 + 1;

        if (search_len_lagger_D2 == 1) begin

            if (found_something_D) begin
                $display("D2: assert error D2 !!!!!!!!!!!!!!!!");
            end


            /*
            we start looking into the history only if the search len would fit in it
            */

            // $display("D2: search_len_D2: %d, history_length_D:  %d,  i_counter_D0: %d", search_len_D2, history_length_D, i_counter_D0);

            if ((search_len_D2 <= history_length_D) && (i_counter_D0 >= search_len_D2)) begin
                // $display("D2: ------------------------------- calling D3");
                    
                // reseting and launching D3
                D2_lzss_search_len_loop_flag = 0;

                history_start_search_idx_D3 = i_counter_D0 - search_len_D2;
                lagger_D3 = 0;
                D3_lzss_loop_over_memory_flag = 1;

            end


            // D2_lzss_search_len_loop_flag = 0;
            // D1_lzss_build_search_term_flag = 1;
            // search_term_D1 = 0;
            // counter_D1 = 0;
            // lagger_D1 = 0;
            
        end else if (search_len_lagger_D2 == 2) begin

            if (search_len_D2 > lzss_min_search_len) begin
                search_len_D2 = search_len_D2 - 1;

            end else begin
                D2_lzss_search_len_loop_flag = 0;

                D0_lzss_main_loop_flag = 1;

            end

            search_len_lagger_D2 = 0;

        end 
    end
end








// D3

// flag
reg                                                     D3_lzss_loop_over_memory_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    history_start_search_idx_D3;
reg                 [q_full - 1 : 0]                    lagger_D3;

// system reset


// D3_lzss_loop_over_memory_flag
always @(negedge clk) begin
    if (D3_lzss_loop_over_memory_flag == 1) begin
        lagger_D3 = lagger_D3 + 1;

        if (lagger_D3 == 1) begin
            // $display("D3: i_counter_D0: %d, search_len_D2:%d", i_counter_D0, search_len_D2);
            // $display("D3: history_start_search_idx_D3: %d", history_start_search_idx_D3);


            // resetting and launching D4
            D3_lzss_loop_over_memory_flag = 0;

            counter_D4 = 0;
            lagger_D4 = 0;
            history_chunk_D4 = 0;
            cat_string_D4 = 0;
            cats_found_D4 = 0;

            D4_lzss_build_history_chunk_flag = 1;
            
        end else if (lagger_D3 == 2) begin

            if (history_start_search_idx_D3 >= 1 ) begin
                history_start_search_idx_D3 = history_start_search_idx_D3 - 1;

            end else begin
                D3_lzss_loop_over_memory_flag = 0;
                D2_lzss_search_len_loop_flag = 1;

            end

            lagger_D3 = 0;

        end 
    end
end







// D4

// flag
reg                                                     D4_lzss_build_history_chunk_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_D4;
reg                 [q_full - 1 : 0]                    lagger_D4;
reg                 [(lzss_future_size * 8) - 1 : 0]    history_chunk_D4;
reg                 [(lzss_future_size * 8) - 1 : 0]    cat_string_D4;
reg                                                     cats_found_D4;

// dynamic assignment
reg                 [lzss_future_size - 1 : 0]          number_of_shared_bytes_found_D4;
reg                 [lzss_future_size - 1 : 0]          cats_count_D4;



integer                                                 i;


/*
here we build chunks of history to be compared with the future.
we also build cat-strings for a given chunk of history.
a cat-string is a string of given bytes that repeat itself over and over.
a cat-string is the same size of the future string.
*/

// D4_lzss_build_history_chunk_flag
always @(negedge clk) begin
    if (D4_lzss_build_history_chunk_flag == 1) begin
        lagger_D4 = lagger_D4 + 1;

        if (lagger_D4 == 1) begin
            input_bits_mem_read_addr = history_start_search_idx_D3 + counter_D4;
            
        end else if (lagger_D4 == 2) begin

            // $display("D4: %d", input_bits_mem_read_data);

            history_chunk_D4            = history_chunk_D4              + (input_bits_mem_read_data << (8 * (lzss_future_size - counter_D4 - 1)));
            // $display("D4: history_chunk_D4: %b", history_chunk_D4);

        end else if (lagger_D4 == 3) begin
            // /* 
            // if this is the last lagger, build a cat-string for the history chunk
            // the cat-string will then be used to find cats
            // */

            // $display("D4: history_chunk_D4: %b", history_chunk_D4);

            // if (counter_D4 >= search_len_D2 - 1 ) begin
            // end


            for (i = 0; i < lzss_future_size; i = i + 1) begin

                // cat_string_D4            = cat_string_D4              + (input_bits_mem_read_data << (8 * (lzss_future_size - counter_D4 - 1))); // i = 0

                cat_string_D4            = cat_string_D4              + (input_bits_mem_read_data << (8 * (lzss_future_size - counter_D4 - 1 - search_len_D2 * i))); // i = 1

                // cat_string_D4[search_len_D2] = 0;
                
            end


        end else if (lagger_D4 == 4) begin

            if (counter_D4 < search_len_D2 - 1 ) begin
                counter_D4 = counter_D4 + 1;

            end else begin

                // $display("D4: cat_string_D4   : %b", cat_string_D4);


                /*
                    here we check to see if we have found a match
                    first we need to figure out where in `future_full_search_term_D1` our search_term begins

                // bus[s-x-1    -:   b]);     //[size - start_index_from_left   -:    shift count to the right (inclusive)]
                // future_full_search_term_D1[lzss_future_size * 8 - 0 - 1 -: search_len_D2]

                */

                // number_of_shared_bytes_found_D4 = nt_in

                // if (future_full_search_term_D1[lzss_future_size * 8 - 0 - 1 -: search_len_D2]   ==  history_chunk_D4[lzss_future_size * 8 - 0 - 1 -: search_len_D2]) begin
                //     $display("matchi found");
                // end

                number_of_shared_bytes_found_D4 = nt_deflate.number_of_bytes_shared(future_full_search_term_D1, history_chunk_D4);

                // $display("number_of_shared_bytes_found_D4: %d", number_of_shared_bytes_found_D4);
                
                if (number_of_shared_bytes_found_D4 == search_len_D2) begin
                    // $display("======================MATCHI FOUND for i_counter_D0:%d, search_len_D2:%d, history_start_search_idx_D3:%d",
                    //  i_counter_D0, search_len_D2, history_start_search_idx_D3);
                    //  history_start_search_idx_D3 - i_counter_D0 + search_len_D2);

                    found_something_D = 1;
                    length_D = search_len_D2;
                    distance_D = i_counter_D0 - history_start_search_idx_D3;


                    if (history_start_search_idx_D3 == i_counter_D0 - search_len_D2) begin
                        // $display("cat possibility");

                        cats_count_D4 = nt_deflate.number_of_bytes_shared(future_full_search_term_D1, cat_string_D4);

                        if (cats_count_D4 > 0) begin
                            cats_found_D4 = 1;
                            length_D = cats_count_D4;
                            // $display("found %d / (%d) cats", cats_count_D4, search_len_D2);
                        end
                    end

                end


                if ((found_something_D == 1)&& (length_D >= lzss_mlwbr)) begin
                    
                    /*
                        do the back reference
                    */
                    $display("D4: %d, [length:%d, distance:%d]", i_counter_D0, length_D, distance_D);

                    // resetting and launching D5
                    lagger_D5 = 0;
                    D5_lzss_store_length_distance_pair_flag = 1;

                    D4_lzss_build_history_chunk_flag = 0;


                end else begin
                    found_something_D = 0;
                    length_D = 1;
                    D3_lzss_loop_over_memory_flag = 1;

                end


                D4_lzss_build_history_chunk_flag = 0;




            end

            lagger_D4 = 0;

        end 
    end
end






// D5

// flag
reg                                                     D5_lzss_store_length_distance_pair_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    lagger_D5;

// system reset

// D5_lzss_store_length_distance_pair_flag
always @(negedge clk) begin
    if (D5_lzss_store_length_distance_pair_flag == 1) begin
        lagger_D5 = lagger_D5 + 1;

        if (lagger_D5 == 1) begin

            ll_table_mem_read_addr       = length_D - 3;          // because the table starts from 3
            distance_table_mem_read_addr = distance_D - 1;  // because the table starts from 1


        end else if (lagger_D5 == 2) begin
            ll_symbols_mem_write_data       = ll_table_mem_read_data        [17 - 1 -: 9];
            distance_symbols_mem_write_data = distance_table_mem_read_data  [22 - 1 -: 5];

            lzss_output_mem_write_data = 1'b1 << 39;
            lzss_output_mem_write_data[40 - 1 - 1 -: 17] = ll_table_mem_read_data;
            lzss_output_mem_write_data[40 - 18 - 1 -: 22] = distance_table_mem_read_data;

        end else if (lagger_D5 == 3) begin
            ll_symbols_mem_write_enable = 1;
            distance_symbols_mem_write_enable = 1;
            lzss_output_mem_write_enable = 1;


        end else if (lagger_D5 == 4) begin
            ll_symbols_mem_write_enable = 0;
            distance_symbols_mem_write_enable = 0;
            lzss_output_mem_write_enable = 0;

        end else if (lagger_D5 == 5) begin
            ll_symbols_mem_write_addr       = ll_symbols_mem_write_addr         + 1;
            distance_symbols_mem_write_addr = distance_symbols_mem_write_addr   + 1;
            lzss_output_mem_write_addr      = lzss_output_mem_write_addr        + 1;


        end else if (lagger_D5 == 6) begin

            D5_lzss_store_length_distance_pair_flag = 0;
            D0_lzss_main_loop_flag = 1;


        end 
    end
end









// D6


// flag
reg                                                     D6_lzss_dumpper_flag   = 0;

// system reset
reg                 [q_full - 1 : 0]                    counter_D6            = 0;
reg                 [q_full - 1 : 0]                    lagger_D6    = 0;

reg                 [5 - 1 : 0]                         length_offset_bits_mask_D;
reg                 [13 - 1 : 0]                        distance_offset_bits_mask_D;

reg                 [q_full - 1 : 0]                    length_symbol_offset;
reg                 [q_full - 1 : 0]                    distance_symbol_offset;

// dumpper
always @(negedge clk) begin
    if (D6_lzss_dumpper_flag == 1) begin
        lagger_D6 = lagger_D6 + 1;

        if (lagger_D6 == 1) begin

            if (counter_D6 < ll_symbols_count_D) begin
                ll_symbols_mem_read_addr = counter_D6;
            end

            if (counter_D6 < distance_symbols_count_D) begin
                distance_symbols_mem_read_addr = counter_D6;
            end

            lzss_output_mem_read_addr = counter_D6;

            
        end else if (lagger_D6 == 2) begin

            if (counter_D6 < ll_symbols_count_D) begin
                $fdisplayb(D6_output_file_ll_symbols_mem, ll_symbols_mem_read_data);
            end

            if (counter_D6 < distance_symbols_count_D) begin
                $fdisplayb(D6_output_file_distance_symbols_mem, distance_symbols_mem_read_data);
            end

            $fdisplayb(D6_output_file_lzss_output_mem, lzss_output_mem_read_data);

            if (lzss_output_mem_read_data[39] == 1'b0) begin
                $display("D6: [%d]", lzss_output_mem_read_data[40 - 1 - 1 -: 9]);
                // $display("[%b]", lzss_output_mem_read_data);
            end else begin


                length_offset_bits_mask_D = (2 << (lzss_output_mem_read_data[40 - 10 - 1 -: 3])) - 1;
                length_symbol_offset = length_offset_bits_mask_D & lzss_output_mem_read_data[40 - 13 - 1 -: 5];
                // $display("bit counts =%d, length_offset_bits_mask: %b, length_symbol_offset:%d",lzss_output_mem_read_data[40 - 10 - 1 -: 3],  length_offset_bits_mask_D, length_symbol_offset);


                distance_offset_bits_mask_D = (2 << (lzss_output_mem_read_data[40 - 23 - 1 -: 4])) - 1;
                distance_symbol_offset = distance_offset_bits_mask_D & lzss_output_mem_read_data[40 - 27 - 1 -: 13];
                // $display("bit counts =%d, distance_offset_bits_mask_D: %b, distance_symbol_offset: %d",lzss_output_mem_read_data[40 - 23 - 1 -: 4],  distance_offset_bits_mask_D, distance_symbol_offset);


                $display("D6: length-distance pair: [%d, %d, %d, %d]", 
                lzss_output_mem_read_data[40 - 1 - 1 -: 9],
                length_symbol_offset,
                lzss_output_mem_read_data[40 - 18 - 1 -: 5],
                distance_symbol_offset
                );




            end
            

            


        end else if (lagger_D6 == 3) begin

            if (counter_D6 < lzss_outputs_count_D - 1) begin
                counter_D6 = counter_D6 + 1;

            end else begin




                $fclose(D6_output_file_ll_symbols_mem);  
                $fclose(D6_output_file_distance_symbols_mem); 
                $fclose(D6_output_file_lzss_output_mem); 


                $display("D6: finished dumping. at %d", $time);
                $display("D6: ll_symbols_count_D: %d, distance_symbols_count_D:%d", ll_symbols_count_D,distance_symbols_count_D);

                $display("FINISHED_______________________________________%d", $time);



                D6_lzss_dumpper_flag            = 0;

            end


            lagger_D6 = 0;

        end 
    end
end










            

endmodule


            
