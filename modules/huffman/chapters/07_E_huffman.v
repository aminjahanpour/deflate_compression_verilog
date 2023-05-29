
/*
E0:
we calculate the frequency of symbols.
we populate huff_freq_mem. this ram has a depth of `max_length_symbol = 286`
so we store frequency values for symbols 0 to 285
frequency values are store in q_full bits



E3:
here we sort the freq_list mem per its freq values.
note that there are many 0 rows in the this ram.
this is because we know that the entries of this ram
will double (at max) while we run the huffman code.
because new nodes will be added to this ram.

E4:
here we find the index of the first none zero freqency for the sorted freq_list.


E5:
here we look for a left in freq_list_mem.
simply the next free netry with a non zero frequency
when we find a left, we store its index in index_of_left_E.



E7:
here we look for a right.
again simply the next free netry with a non zero frequency.
when we find it, we create a new entry to the freq_list which discribes the new node.
then we call E8 and E9 to build the node itself.

E8, E9:
here we need to loops to store both left and right sides of the new_node_freq_list_E.
each loop writes 9-bit terms one by one to huffman_nodes_mem
E8 write the left side and E9 write the right side.
the write address of the ram is already set to zero so we start from the top

E10:
simple dumper for huffman_nodes_mem


E12:
huffman_codes



    bits:
    [40 : 32] starting at  0, len of 9 : symbol value in 9 bits
    [31 : 20] starting at  9, len of 12: code length            ; cl_F
    [19 :  0] starting at 21, len of 20 : huffman code itself

    total width of the bus = 41 (huffman_codes_width)

    40     32  31        20  19                 0
    000000000  000000000000  00000000000000000000
    
    
    
    
    0   ..  8  9   ..    20  21                40 

*/


reg                 [8 -1 : 0]                          verbose = 2;

/*
we go through huff_freq_mem, which is max_length_symbol deep.
we create a freq list for it.
also we record the count of unique symbol values `unique_symbols_count`.
`symbols_count` is used as a cap to read and dump the huffman codes.

*/














// E11


// begining of the loop --------------------------------------

// flag
reg                                                     E11_find_count_of_free_freq_list_entries_flag   = 0;



// loop reset
reg                 [q_full - 1 : 0]                    counter_E11;
reg                 [q_full - 1 : 0]                    lagger_E11;
reg                 [q_full - 1 : 0]                    count_of_free_freq_list_entries;
reg                                                     this_is_the_last_node_E11;
// system reset



//E11_find_count_of_free_freq_list_entries_flag
always @(negedge clk) begin
if (E11_find_count_of_free_freq_list_entries_flag == 1) begin
    lagger_E11 = lagger_E11 + 1;

    if (lagger_E11 == 1) begin
        freq_list_mem_read_addr = counter_E11;

    end else if (lagger_E11 == 2) begin


        if ((freq_list_mem_read_data[41] == 1'b0) && (freq_list_mem_read_data[53:42] > 0) )begin
            count_of_free_freq_list_entries = count_of_free_freq_list_entries + 1;
        end
        

    end else if (lagger_E11 == 3) begin

        if (counter_E11 < freq_list_depth - 1) begin
            counter_E11 = counter_E11 + 1;

        end else begin

            $display("E11: count_of_free_freq_list_entries: %d", count_of_free_freq_list_entries);
            
            E11_find_count_of_free_freq_list_entries_flag = 0;
            
            if (count_of_free_freq_list_entries > 0) begin
                $display("E11: sorting freq_list..");

                if (count_of_free_freq_list_entries == 1) begin
                    // this is the last ll node
                    this_is_the_last_node_E11 = 1;
                    $display("E11: --------------- this_is_the_last_node_E11");
                end


                //setting and launching E3
                counter_E3 = 0;
                read_lagger_E3 = 0;
                write_lagger_E3 = 0;
                sorter_bump_flag_E3 = 0;
                sorter_stage_E3                   = sorter_stage_looping_E3;
                E3_sort_freq_list_flag = 1;



            end 





            


        end

        lagger_E11 = 0;
    
    end 
end
end






















































// E3

// flag
reg                                                     E3_sort_freq_list_flag   = 0;


//system reset
reg                 [q_full - 1 : 0]                    counter_E3;
reg                 [q_full - 1 : 0]                    read_lagger_E3;
reg                 [q_full - 1 : 0]                    write_lagger_E3;



reg                 [freq_list_width - 1 : 0]           sorter_v1_E3;
reg                 [freq_list_width - 1 : 0]           sorter_v2_E3;


reg                                                     sorter_bump_flag_E3;

// Stages
reg                                                     sorter_stage_E3;
localparam                                              sorter_stage_looping_E3           = 0;
localparam                                              sorter_stage_swapping_E3          = 1;



// E3_sort_freq_list_flag
always @(negedge clk) begin

    if (E3_sort_freq_list_flag == 1) begin



        if (sorter_stage_E3 == sorter_stage_looping_E3) begin
            read_lagger_E3 = read_lagger_E3 + 1;

            if (read_lagger_E3 == 1) begin
                freq_list_mem_read_addr =counter_E3;    

            end else if (read_lagger_E3 == 2) begin
                sorter_v1_E3 = freq_list_mem_read_data;

            end else if (read_lagger_E3 == 3) begin
                freq_list_mem_read_addr =counter_E3 + 1;    

            end else if (read_lagger_E3 == 4) begin
                sorter_v2_E3 = freq_list_mem_read_data;

            end else if (read_lagger_E3 == 5) begin

                // $display("%b, %b, %b, %b", 
                // sorter_v1_E3,
                // sorter_v1_E3[freq_list_width - 9 - 1 -: 12] , 
                // sorter_v2_E3,
                // sorter_v2_E3[freq_list_width - 9 - 1 -: 12]
                // );

                if (sorter_v1_E3[freq_list_width - 9 - 1 -: 12] > sorter_v2_E3[freq_list_width - 9 - 1 -: 12]) begin

                    // $display("bump");
                    sorter_bump_flag_E3 = 1;
                    sorter_stage_E3= sorter_stage_swapping_E3;
                end 
                
                read_lagger_E3 = 0;

                if (counter_E3 < freq_list_depth - 2) begin
                    counter_E3 = counter_E3 + 1;

                end else begin

                    counter_E3 = 0;

                    if (sorter_bump_flag_E3 == 0) begin
                        E3_sort_freq_list_flag = 0;
                        $display("E3: SORTING FINISHED");

                        // setting and launching E4
                        counter_E4 = 0;
                        lagger_E4 = 0;
                        have_already_found_first_none_zero_el_in_freq_list_E4 = 0;
                        E4_dump_sorted_freq_list_flag = 1;

                    end
                    sorter_bump_flag_E3 = 0;

                end

            end

        end else if (sorter_stage_E3 == sorter_stage_swapping_E3) begin

            write_lagger_E3 = write_lagger_E3 + 1;

            if (write_lagger_E3 == 1) begin
                if (counter_E3 == 0) begin
                    freq_list_mem_write_addr = (freq_list_depth - 2);
                end else begin
                    freq_list_mem_write_addr =counter_E3 - 1;
                end



            end else if (write_lagger_E3 == 2) begin
                freq_list_mem_write_data = sorter_v2_E3;                

            end else if (write_lagger_E3 == 3) begin
                freq_list_mem_write_enable = 1;

            end else if (write_lagger_E3 == 4) begin
                freq_list_mem_write_enable = 0;

            end else if (write_lagger_E3 == 5) begin
                if (counter_E3 == 0) begin
                    freq_list_mem_write_addr = freq_list_depth - 1;
                end else begin
                    freq_list_mem_write_addr =counter_E3;
                end


            end else if (write_lagger_E3 == 6) begin
                freq_list_mem_write_data = sorter_v1_E3;


            end else if (write_lagger_E3 == 7) begin
                freq_list_mem_write_enable = 1;

            end else if (write_lagger_E3 == 8) begin
                freq_list_mem_write_enable = 0;

            end else if (write_lagger_E3 == 9) begin
                write_lagger_E3 = 0;
                sorter_stage_E3= sorter_stage_looping_E3;
            end

        end
    end

end










// E4

// flag
reg                                                     E4_dump_sorted_freq_list_flag   = 0;



//loop reset
reg                 [q_full - 1 : 0]                    counter_E4;
reg                 [q_full - 1 : 0]                    lagger_E4;

reg                 [q_full - 1 : 0]                    index_of_first_none_zero_el_in_freq_list_E4;
reg                                                     have_already_found_first_none_zero_el_in_freq_list_E4;


//E4_dump_sorted_freq_list_flag
always @(negedge clk) begin
 if (E4_dump_sorted_freq_list_flag == 1) begin
     lagger_E4 = lagger_E4 + 1;

     if (lagger_E4 == 1) begin
        freq_list_mem_read_addr = counter_E4;

     end else if (lagger_E4 == 2) begin
        if ((have_already_found_first_none_zero_el_in_freq_list_E4 == 0) && (freq_list_mem_read_data[freq_list_width - 9 - 1 -: 12] >= 1)) begin
            index_of_first_none_zero_el_in_freq_list_E4 = counter_E4;
            have_already_found_first_none_zero_el_in_freq_list_E4 = 1;
        end

        if (counter_E4 >= index_of_first_none_zero_el_in_freq_list_E4 - 1) begin

            if (verbose > 1) begin
                display_reg = nt_deflate.display_freq_list_entry(freq_list_mem_read_data, counter_E4);
            end
        end
        // $fdisplayb(E4_output_file_freq_list_mem, freq_list_mem_read_data);

     end else if (lagger_E4 == 3) begin

        if (counter_E4 < freq_list_depth - 1) begin
            counter_E4 = counter_E4 + 1;

        end else begin
            counter_E4 = 0;
            lagger_E4 = 0;


            E4_dump_sorted_freq_list_flag = 0;

            $display("E4: index_of_first_none_zero_el_in_freq_list_E4: %d", index_of_first_none_zero_el_in_freq_list_E4);

            if (this_is_the_last_node_E11) begin



                $display("\n-------------------------------------------\nE4: finished building the nodes.");
                $display("E4: starting to build the codes");
                $display("E4: setting and launching E12\n\n");

                // setting and launching E12

                counter_E12 = freq_list_depth - 1;
                lagger_E12 = 0;
                total_node_count = 0;
                E12_build_huffman_codes_flag = 1;

                
            end else begin
                
                // settin and launching E5
                counter_E5 = index_of_first_none_zero_el_in_freq_list_E4;
                lagger_E5 = 0;
                found_a_left_E = 0;

                index_of_candidate_left_E = 0;
                candidate_left_bits_E = 0;
                left_wanted_freq_already_identified = 0;

                E5_find_a_left_flag = 1;

            end




        end

        lagger_E4 = 0;
        
     end 
 end
end













// E5

// flag
reg                                                     E5_find_a_left_flag   = 0;

//loop reset
reg                 [q_full - 1 : 0]                    counter_E5                 ;
reg                 [q_full - 1 : 0]                    lagger_E5                  ;
reg                                                     found_a_left_E              ;


reg                 [q_full - 1 : 0]                    index_of_candidate_left_E             ;
reg                 [freq_list_width - 1 : 0]           candidate_left_bits_E                 ;
reg                                                     left_wanted_freq_already_identified;

// no need to reset
reg                 [12 -1 : 0]                         left_wanted_freq;
reg                 [q_full - 1 : 0]                    index_of_left_E             ;
reg                 [freq_list_width - 1 : 0]           left_bits_E                 ;




//E5_find_a_left_flag
always @(negedge clk) begin
 if (E5_find_a_left_flag == 1) begin
     lagger_E5 = lagger_E5 + 1;

     if (lagger_E5 == 1) begin
        if (found_a_left_E == 0) begin
           freq_list_mem_read_addr = counter_E5;
        end
     
     end else if (lagger_E5 == 2) begin

        if (found_a_left_E == 0) begin

            if (freq_list_mem_read_data[41] == 1'b0) begin


                if (left_wanted_freq_already_identified == 0) begin
                    index_of_candidate_left_E = counter_E5;
                    candidate_left_bits_E = freq_list_mem_read_data;
                    left_wanted_freq = freq_list_mem_read_data[53 : 42];
                    left_wanted_freq_already_identified = 1;

                end

            end

        end

     end else if (lagger_E5 == 3) begin

        if (found_a_left_E == 0) begin

            if (freq_list_mem_read_data[41] == 1'b0) begin

                if (
                    (freq_list_mem_read_data[53 : 42] == left_wanted_freq) &&
                    (freq_list_mem_read_data[40] == 1'b0)  ) begin

                        found_a_left_E = 1;
                        index_of_left_E = counter_E5;
                        left_bits_E = freq_list_mem_read_data;


                        if (verbose > 1) $display("E5: found a left.   index_of_left_E: %d, left_freq_E: %d, left symbol: %d",
                        index_of_left_E, left_bits_E[53 : 42], left_bits_E[62:54]);

                    end

            end

        end

     end else if (lagger_E5 == 4) begin
        if (found_a_left_E) begin
            freq_list_mem_read_addr = index_of_left_E;

        end


     end else if (lagger_E5 == 5) begin
        if (found_a_left_E) begin
            freq_list_mem_write_addr =  freq_list_mem_read_addr;
            freq_list_mem_write_data =  freq_list_mem_read_data;
            freq_list_mem_write_data[41] = 1'b1;
        end


     end else if (lagger_E5 == 6) begin
        if (found_a_left_E) begin
            freq_list_mem_write_enable =  1;
        end

     end else if (lagger_E5 == 7) begin
        if (found_a_left_E) begin
            freq_list_mem_write_enable =  0;
        end

     end else if (lagger_E5 == 8) begin
        if (found_a_left_E) begin
            E5_find_a_left_flag = 0;

            //setting and launching E7
            counter_E7 = index_of_first_none_zero_el_in_freq_list_E4;
            lagger_E7 = 0;
            found_a_right_E = 0;

            index_of_candidate_right_E = 0;
            candidate_right_bits_E = 0;
            right_wanted_freq_already_identified = 0;

            E7_find_a_right_flag = 1;

        
        end

     end else if (lagger_E5 == 9) begin

        if (counter_E5 < freq_list_depth - 1) begin
            counter_E5 = counter_E5 + 1;
        
        end else begin
            if (found_a_left_E == 0) begin
                // using the candidate
                found_a_left_E = 1;
                index_of_left_E = index_of_candidate_left_E;
                left_bits_E = candidate_left_bits_E;

                if (verbose > 1) $display("E5: found a left.  index_of_left_E: %d, left_freq_E: %d, left symbol: %d",
                index_of_left_E, left_bits_E[53 : 42], left_bits_E[62:54]);

            end


        end


        lagger_E5 = 0;
        
     end 
 end
end










// E7

// flag
reg                                                     E7_find_a_right_flag   = 0;

//loop reset
reg                 [q_full - 1 : 0]                    counter_E7                 ;
reg                 [q_full - 1 : 0]                    lagger_E7                  ;
reg                                                     found_a_right_E;


reg                 [q_full - 1 : 0]                    index_of_candidate_right_E             ;
reg                 [freq_list_width - 1 : 0]           candidate_right_bits_E                 ;
reg                                                     right_wanted_freq_already_identified;


// no need to reset
reg                 [12 -1 : 0]                         right_wanted_freq;
reg                 [q_full - 1 : 0]                    index_of_right_E;
reg                 [freq_list_width - 1 : 0]           right_bits_E;



reg                 [freq_list_width - 1 : 0]           new_node_freq_list_E;
reg                                                     display_reg;



//E7_find_a_right_flag
always @(negedge clk) begin
if (E7_find_a_right_flag == 1) begin
    lagger_E7 = lagger_E7 + 1;

    if (lagger_E7 == 1) begin
        if (found_a_right_E == 0) begin
            freq_list_mem_read_addr = counter_E7;
            if (verbose > 1) $display("counter_E7: %d", counter_E7);
            
        end

    end else if (lagger_E7 == 2) begin

        if (found_a_right_E == 0) begin

            if (freq_list_mem_read_data[41] == 1'b0)  begin

                if (right_wanted_freq_already_identified == 0) begin
                    index_of_candidate_right_E = counter_E7;
                    candidate_right_bits_E = freq_list_mem_read_data;
                    right_wanted_freq = freq_list_mem_read_data[53 : 42];
                    right_wanted_freq_already_identified = 1;

                end

            end

        end



    end else if (lagger_E7 == 3) begin

        if (found_a_right_E == 0) begin

            if (freq_list_mem_read_data[41] == 1'b0) begin

                if (
                    (freq_list_mem_read_data[53 : 42] == right_wanted_freq) &&
                    (freq_list_mem_read_data[40] == 1'b0)  ) begin

                        found_a_right_E = 1;
                        index_of_right_E = counter_E7;
                        right_bits_E = freq_list_mem_read_data;

                        if (verbose > 1) $display("E5: found a right.  index_of_right_E: %d, right_freq_E: %d, right symbol: %d",
                        index_of_right_E, right_bits_E[53 : 42], right_bits_E[62:54]);

                    end

            end

        end

    end else if (lagger_E7 == 4) begin
        if (found_a_right_E) begin
            freq_list_mem_read_addr = index_of_right_E;

        end





    end else if (lagger_E7 == 5) begin
        if (found_a_right_E) begin
            freq_list_mem_write_addr =  freq_list_mem_read_addr;
            freq_list_mem_write_data =  freq_list_mem_read_data;
            freq_list_mem_write_data[41] = 1'b1;
        end

    end else if (lagger_E7 == 6) begin
        if (found_a_right_E) begin
            freq_list_mem_write_enable =  1;
        end

    end else if (lagger_E7 == 7) begin
        if (found_a_right_E) begin
            freq_list_mem_write_enable =  0;
        end

    end else if (lagger_E7 == 8) begin
        if (found_a_right_E) begin
            /* 
            now we start building a new entry to the freq_list based on the left and right 
            the left or the right each may be a node themselves.
            in that case both sides of the reference node becomes
            either the left or the right side of the new node.
            
            we write the new node at last row of freq_list mem.
            */
            // freq_list_mem_write_addr = freq_list_depth - 1;
            freq_list_mem_write_addr = 0;
            new_node_freq_list_E = 9'b111111111 << 54;

            // frequency adds up
            new_node_freq_list_E[53 : 42] =  left_bits_E[53 : 42] + right_bits_E[53 : 42];

            // indicading the new entry is a node
            new_node_freq_list_E[40] = 1'b1;


            // new node left side
            if (left_bits_E[40] == 1'b0) begin 
                // the left side itself is not a node
                new_node_freq_list_E[39 : 32] = 1;

            end else begin
                // thel left side itself is a node
                new_node_freq_list_E[39 : 32] = left_bits_E[39 : 32] + left_bits_E[19 : 12];
            end

            new_node_freq_list_E[31 : 20] = huffman_nodes_mem_write_addr[12 : 0];


            // new node right
            if (right_bits_E[40] == 1'b0) begin 
                // the right side itself is not a node
                new_node_freq_list_E[19 : 12] = 1;

            end else begin
                new_node_freq_list_E[19 : 12] = right_bits_E[39 : 32] + right_bits_E[19 : 12];


            end
            new_node_freq_list_E[11 : 0] = huffman_nodes_mem_write_addr[12 - 1 : 0] + new_node_freq_list_E[39 : 32];


            // $display("left side bits         : %b", left_bits_E);
            // $display("right side bits        : %b", right_bits_E);
            // $display("the new freq_list entry: %b", new_node_freq_list_E);

            // $display("");
            // display_reg = nt_deflate.display_freq_list_entry(left_bits_E, 0);
            // display_reg = nt_deflate.display_freq_list_entry(right_bits_E, 1);
            // display_reg = nt_deflate.display_freq_list_entry(new_node_freq_list_E, 2);
            // $display("");

            


            freq_list_mem_write_data = new_node_freq_list_E;

        end


    end else if (lagger_E7 == 9) begin
        if (found_a_right_E) begin
            freq_list_mem_write_enable = 1;
        end


    end else if (lagger_E7 == 10) begin
        if (found_a_right_E) begin
            freq_list_mem_write_enable = 0;
        end


    end else if (lagger_E7 == 11) begin
        if (found_a_right_E) begin
            E7_find_a_right_flag = 0;

            // setting and launching E8
            counter_E8 = 0;
            lagger_E8 = 0;
            finished_with_left_side = 0;
            E8_store_new_node_left_side_flag = 1;
        end


    end else if (lagger_E7 == 12) begin

        if (counter_E7 < freq_list_depth - 1) begin
            counter_E7 = counter_E7 + 1;

        end else begin
            
            if (found_a_right_E == 0) begin
                if (verbose > 1) $display("using the candidate");
                // using the candidate
                found_a_right_E = 1;
                index_of_right_E = index_of_candidate_right_E;
                right_bits_E = candidate_right_bits_E;

                if (verbose > 1) $display("E7: found a right.  index_of_right_E: %d, right_freq_E: %d, right symbol: %d",
                index_of_right_E, right_bits_E[53 : 42], right_bits_E[62:54]);

            end


        end

    
        lagger_E7 = 0;
        
    end 
end
end











    
    
// E8

// flag
reg                                                     E8_store_new_node_left_side_flag   = 0;



//system reset
reg                 [q_full - 1 : 0]                    counter_E8;
reg                 [q_full - 1 : 0]                    lagger_E8;
reg                                                     finished_with_left_side;


//E8_store_new_node_left_side_flag
always @(negedge clk) begin
if (E8_store_new_node_left_side_flag == 1) begin
    lagger_E8 = lagger_E8 + 1;





    // the left entry is not a node

    if (lagger_E8 == 1) begin
        if (left_bits_E[40] == 1'b0) begin
            huffman_nodes_mem_write_data = left_bits_E[62 : 54];
            finished_with_left_side = 1;
        end

    end else if (lagger_E8 == 2) begin
        if (left_bits_E[40] == 1'b0) begin
            huffman_nodes_mem_write_enable = 1;
        end
        
    end else if (lagger_E8 == 3) begin
        if (left_bits_E[40] == 1'b0) begin
            huffman_nodes_mem_write_enable = 0;
        end









    // the left entry is a node itself
    end else if (lagger_E8 == 4) begin
        if (left_bits_E[40] == 1'b1) begin
            huffman_nodes_mem_read_addr = left_bits_E[31 : 20] + counter_E8;
        end
        
    end else if (lagger_E8 == 5) begin
        if (left_bits_E[40] == 1'b1) begin
            huffman_nodes_mem_write_data = huffman_nodes_mem_read_data;

        end
        
    end else if (lagger_E8 == 6) begin
        if (left_bits_E[40] == 1'b1) begin
            huffman_nodes_mem_write_enable = 1;

        end

    end else if (lagger_E8 == 7) begin
        if (left_bits_E[40] == 1'b1) begin
            huffman_nodes_mem_write_enable = 0;

        end

    end else if (lagger_E8 == 8) begin
        if (left_bits_E[40] == 1'b1) begin
            if (counter_E8 == left_bits_E[39 : 32] + left_bits_E[19 : 12] - 1) begin
                finished_with_left_side = 1;
            end
        end











    end else if (lagger_E8 == 9) begin
        huffman_nodes_mem_write_addr = huffman_nodes_mem_write_addr + 1;
        

    end else if (lagger_E8 == 10) begin

        if (finished_with_left_side == 0) begin
            // $display("counter_E8:%d, new_node_freq_list_E[39 : 32]:%d", counter_E8, new_node_freq_list_E[39 : 32]);
            counter_E8 = counter_E8 + 1;



        end else begin

            $display("E8: finished storing the left terms of the node");
            
            E8_store_new_node_left_side_flag = 0;

            // setting and launching E9
            counter_E9 = 0;
            lagger_E9 = 0;
            finished_with_right_side = 0;
            E9_store_new_node_right_side_flag = 1;

        end

        lagger_E8 = 0;
    
    end 
end
end
























// E9

// flag
reg                                                     E9_store_new_node_right_side_flag   = 0;



//system reset
reg                 [q_full - 1 : 0]                    counter_E9;
reg                 [q_full - 1 : 0]                    lagger_E9;
reg                                                     finished_with_right_side;


//E9_store_new_node_right_side_flag
always @(negedge clk) begin
if (E9_store_new_node_right_side_flag == 1) begin
    lagger_E9 = lagger_E9 + 1;





    // the right entry is not a node

    if (lagger_E9 == 1) begin
        if (right_bits_E[40] == 1'b0) begin
            huffman_nodes_mem_write_data = right_bits_E[62 : 54];
            finished_with_right_side = 1;
        end

    end else if (lagger_E9 == 2) begin
        if (right_bits_E[40] == 1'b0) begin
            huffman_nodes_mem_write_enable = 1;
        end
        
    end else if (lagger_E9 == 3) begin
        if (right_bits_E[40] == 1'b0) begin
            huffman_nodes_mem_write_enable = 0;
        end









    // the right entry is a node itself
    end else if (lagger_E9 == 4) begin
        if (right_bits_E[40] == 1'b1) begin
            huffman_nodes_mem_read_addr = right_bits_E[31 : 20] + counter_E9;
        end
        
    end else if (lagger_E9 == 5) begin
        if (right_bits_E[40] == 1'b1) begin
            huffman_nodes_mem_write_data = huffman_nodes_mem_read_data;

        end
        
    end else if (lagger_E9 == 6) begin
        if (right_bits_E[40] == 1'b1) begin
            huffman_nodes_mem_write_enable = 1;

        end

    end else if (lagger_E9 == 7) begin
        if (right_bits_E[40] == 1'b1) begin
            huffman_nodes_mem_write_enable = 0;

        end

    end else if (lagger_E9 == 8) begin
        if (right_bits_E[40] == 1'b1) begin
            if (counter_E9 == right_bits_E[39 : 32] + right_bits_E[19 : 12] - 1) begin
                finished_with_right_side = 1;
            end
        end











    end else if (lagger_E9 == 9) begin
        huffman_nodes_mem_write_addr = huffman_nodes_mem_write_addr + 1;
        

    end else if (lagger_E9 == 10) begin

        if (finished_with_right_side == 0) begin
            // $display("counter_E9:%d, new_node_freq_list_E[39 : 32]:%d", counter_E9, new_node_freq_list_E[39 : 32]);
            counter_E9 = counter_E9 + 1;



        end else begin

            $display("E9: finished storing the right terms of the node");
            
            E9_store_new_node_right_side_flag = 0;

            // setting and launching E10
            counter_E10 = 0;
            lagger_E10 = 0;
            E10_dump_huffman_nodes_flag = 1;

        end

        lagger_E9 = 0;
    
    end 
end
end























// E10

// flag
reg                                                     E10_dump_huffman_nodes_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_E10;
reg                 [q_full - 1 : 0]                    lagger_E10;

// system reset


//E10_dump_huffman_nodes_flag
always @(negedge clk) begin
if (E10_dump_huffman_nodes_flag == 1) begin
    lagger_E10 = lagger_E10 + 1;

    if (lagger_E10 == 1) begin
        huffman_nodes_mem_read_addr = counter_E10;

    end else if (lagger_E10 == 2) begin
        // $fdisplayb(E10_output_file_huffman_nodes_mem, huffman_nodes_mem_read_data);
        // $display("counter: %d, node: %d",counter_E10  , huffman_nodes_mem_read_data);

    end else if (lagger_E10 == 3) begin

        if (counter_E10 < huffman_nodes_mem_write_addr - 1) begin
            counter_E10 = counter_E10 + 1;

        end else begin
            // $fclose(E10_output_file_huffman_nodes_mem);
            E10_dump_huffman_nodes_flag = 0;
            
            $display("E10: finished dumping huffman_nodes");


            // setting and launching E11
            counter_E11 = 0;
            lagger_E11 = 0;
            count_of_free_freq_list_entries = 0;
            this_is_the_last_node_E11 = 0;
            E11_find_count_of_free_freq_list_entries_flag = 1;
            


        end

        lagger_E10 = 0;
    
    end 
end
end









    
// E12

// flag
reg                                                     E12_build_huffman_codes_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_E12;
reg                 [q_full - 1 : 0]                    lagger_E12;

// E12 variables
reg                 [q_full - 1 : 0]                    total_node_count;
    
/*
this counter goes backward 
from (freq_list_depth - 1)
to index_of_first_none_zero_el_in_freq_list_E4 to 572 
inclusive
*/

//E12_build_huffman_codes_flag
always @(negedge clk) begin
if (E12_build_huffman_codes_flag == 1) begin
    lagger_E12 = lagger_E12 + 1;

    if (lagger_E12 == 1) begin

        freq_list_mem_read_addr = counter_E12;


    end else if (lagger_E12 == 2) begin

        if (freq_list_mem_read_data[40] == 1'b1) begin
            if (verbose > 1) begin
                display_reg = nt_deflate.display_freq_list_entry(freq_list_mem_read_data, counter_E12);
            end
            // this is a node
            total_node_count = total_node_count + 1;


            E12_build_huffman_codes_flag = 0;

            // setting and launching E13
            counter_E13 = 0;
            lagger_E13 = 0;
            E13_assign_binaries_to_symbols_flag = 1;

        end
        

    end else if (lagger_E12 == 3) begin

        if (counter_E12 > index_of_first_none_zero_el_in_freq_list_E4) begin
            counter_E12 = counter_E12 - 1;

        end else begin
            
            E12_build_huffman_codes_flag = 0;
            
            $display("total_node_count: %d", total_node_count);



            //setting and launching E15
            counter_E14 = 0;
            lagger_E14 = 0;

            E14_dump_huffman_codes_flag = 1;
            

        end

        lagger_E12 = 0;
    
    end 
end
end







    
// E13

// flag
reg                                                     E13_assign_binaries_to_symbols_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_E13;
reg                 [q_full - 1 : 0]                    lagger_E13;

// E13 variables

    

//E13_assign_binaries_to_symbols_flag
always @(negedge clk) begin
if (E13_assign_binaries_to_symbols_flag == 1) begin
    lagger_E13 = lagger_E13 + 1;

    if (lagger_E13 == 1) begin

        huffman_nodes_mem_read_addr = freq_list_mem_read_data[31 : 20] + counter_E13;


    // end else if (lagger_E13 == 2) begin

        // if (counter_E13 < freq_list_mem_read_data[39 : 32]) begin
        //     $display("iterating through left  terms %d, %d", counter_E13, huffman_nodes_mem_read_data);
        // end else begin
        //     $display("iterating through right terms %d, %d", counter_E13, huffman_nodes_mem_read_data);
        // end


    end else if (lagger_E13 == 3) begin

        huffman_codes_mem_read_addr  = huffman_nodes_mem_read_data;
        huffman_codes_mem_write_addr = huffman_nodes_mem_read_data;


    end else if (lagger_E13 == 4) begin

        
        huffman_codes_mem_write_data = huffman_nodes_mem_read_data << 32;

        huffman_codes_mem_write_data[31 : 20] = huffman_codes_mem_read_data[31 : 20] + 1;

        huffman_codes_mem_write_data[19 : 0] = huffman_codes_mem_read_data[19 : 0] << 1;

        if (counter_E13 < freq_list_mem_read_data[39 : 32]) begin
            huffman_codes_mem_write_data[0] = 1'b0;
        end else begin
            huffman_codes_mem_write_data[0] = 1'b1;
        end

        // $display("addr:%d, data: %b",huffman_codes_mem_write_addr,  huffman_codes_mem_write_data);

    end else if (lagger_E13 == 5) begin
        huffman_codes_mem_write_enable = 1;

    end else if (lagger_E13 == 6) begin
        huffman_codes_mem_write_enable = 0;

    end else if (lagger_E13 == 7) begin

        if (counter_E13 < freq_list_mem_read_data[39 : 32] + freq_list_mem_read_data[19 : 12] - 1) begin
            counter_E13 = counter_E13 + 1;

        end else begin
            
            E13_assign_binaries_to_symbols_flag = 0;
            
            

            // $display("finished iterating");

            E12_build_huffman_codes_flag = 1;


        end

        lagger_E13 = 0;
    
    end 
end
end















    
// E14

// flag
reg                                                     E14_dump_huffman_codes_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_E14;
reg                 [q_full - 1 : 0]                    lagger_E14;

// E14 variables

//E14_dump_huffman_codes_flag
always @(negedge clk) begin
if (E14_dump_huffman_codes_flag == 1) begin
    lagger_E14 = lagger_E14 + 1;

    if (lagger_E14 == 1) begin
        huffman_codes_mem_read_addr = counter_E14;

    end else if (lagger_E14 == 2) begin
        // if (huffman_codes_mem_read_data > 0) begin
                $fdisplayb(E14_output_file_huffman_codes_mem, huffman_codes_mem_read_data);
            display_reg = nt_deflate.display_huffman_code(huffman_codes_mem_read_data, counter_E14);
        // end

    end else if (lagger_E14 == 3) begin

        if (counter_E14 < max_length_symbol - 1) begin
            counter_E14 = counter_E14 + 1;

        end else begin
            $fclose(E14_output_file_huffman_codes_mem);

            E14_dump_huffman_codes_flag = 0;
            
            $display("E14: finished dumping huffman_codes at %d", $time);


            // setting and launching F0


            $display("FINISHED_______________________________________%d", $time);


        end

        lagger_E14 = 0;
    
    end 
end
end


