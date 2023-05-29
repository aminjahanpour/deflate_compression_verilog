

    

reg                                                     bits_reader_go_L;
wire                                                    bits_reader_finished_L;


reg                 [q_full - 1 : 0]                    bits_count_to_read_L;


reg                 [encoded_mem_width - 1 : 0]         previous_stage_left_over_bus_L;
reg                 [8 - 1 : 0     ]                    previous_stage_left_over_bus_length_L;
reg                 [address_len - 1 : 0     ]          previous_read_addr_L;

wire reg            [encoded_mem_width - 1 : 0]         left_over_bus_L;
wire reg            [8 - 1 : 0     ]                    left_over_bus_length_L;
wire reg            [address_len - 1 : 0]               bits_reader_read_addr_L;                        

wire reg            [mem_bits_reader_bus_width - 1: 0]  read_from_memory_bus_L;




bits_reader #(
    .q_full(q_full),
    .address_len(address_len),
    .mem_bits_reader_bus_width(mem_bits_reader_bus_width),
    .encoded_mem_width(encoded_mem_width),
    .input_bits_to_writer_width(input_bits_to_writer_width),
    .max_length_symbol(max_length_symbol),
    .verbose(0)
)
bits_reader_instance_L (
    .clk                    (clk),
    .go                     (bits_reader_go_L),
    .finished               (bits_reader_finished_L),

    .bits_count_to_read     (bits_count_to_read_L),

    // inputs
    .previous_stage_left_over_bus       (previous_stage_left_over_bus_L),
    .previous_stage_left_over_bus_length(previous_stage_left_over_bus_length_L),
    .previous_read_addr                 (previous_read_addr_L),

    // outputs
    .left_over_bus          (left_over_bus_L),
    .left_over_bus_length   (left_over_bus_length_L),
    .output_read_addr       (bits_reader_read_addr_L),

    .read_from_memory_bus   (read_from_memory_bus_L)
);



// bits_reader collector
always @(posedge bits_reader_finished_L) begin

    bits_reader_go_L = 0;

    previous_stage_left_over_bus_L          = left_over_bus_L;
    previous_stage_left_over_bus_length_L   = left_over_bus_length_L;
    previous_read_addr_L                    = bits_reader_read_addr_L;

    case (header_reader_stage)

        header_reader_stage_single_value  :       L1_interperter_main_loop_flag           = 1;
        header_reader_stage_cl_cl_ll      :       L5_decode_ll_cl_cl_table_flag       = 1;
        header_reader_stage_cl_cl_distance:       L6_decode_distance_cl_cl_table_flag = 1;
        header_reader_stage_cl_ll         :       L5_decode_ll_cl_cl_table_flag       = 1;
        header_reader_stage_cl_distance   :       L5_decode_ll_cl_cl_table_flag       = 1;
    
    endcase


end





reg                 [3 - 1      :0]                     verbose = 0;
















// L1

// flag
reg                                                     L1_interperter_main_loop_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_L1;
reg                 [q_full - 1 : 0]                    lagger_L1;

// L1 variables
reg                 [total_header_bits_width - 1  : 0]  total_header_bits_L;
reg                 [encoded_mem_width - 1 :       0]   last_entry_bits_count_L;

reg                 [q_full - 1 : 0]                    hlit_cl;
reg                 [q_full - 1 : 0]                    hdist_cl;
reg                 [q_full - 1 : 0]                    hlit;
reg                 [q_full - 1 : 0]                    hdist;
reg                 [q_full - 1 : 0]                    recode_cl_total_bits_to_write_ll;
reg                 [q_full - 1 : 0]                    recode_cl_total_bits_to_write_distance;



reg                 [5 - 1      : 0]                    header_reader_stage;
localparam          [5 - 1      : 0]                    header_reader_stage_single_value      = 0;
localparam          [5 - 1      : 0]                    header_reader_stage_cl_cl_ll          = 1;
localparam          [5 - 1      : 0]                    header_reader_stage_cl_cl_distance    = 2;
localparam          [5 - 1      : 0]                    header_reader_stage_cl_ll             = 3;
localparam          [5 - 1      : 0]                    header_reader_stage_cl_distance       = 4;
    

reg                 [5 - 1      : 0]                    cl_cl_order[cl_cl_count - 1 : 0];

reg                 [3 - 1      : 0]                    ll_cl_cl_min_L;
reg                 [3 - 1      : 0]                    ll_cl_cl_max_L;
reg                 [3 - 1      : 0]                    distance_cl_cl_min_L;
reg                 [3 - 1      : 0]                    distance_cl_cl_max_L;

//L1_interperter_main_loop_flag
always @(negedge clk) begin
if (L1_interperter_main_loop_flag == 1) begin
    lagger_L1 = lagger_L1 + 1;

    if (lagger_L1 == 1) begin
        cl_cl_order[0] = 5'd16;
        cl_cl_order[1] = 5'd17;
        cl_cl_order[2] = 5'd18;
        cl_cl_order[3] = 5'd0;
        cl_cl_order[4] = 5'd8;
        cl_cl_order[5] = 5'd7;
        cl_cl_order[6] = 5'd9;
        cl_cl_order[7] = 5'd6;
        cl_cl_order[8] = 5'd10;
        cl_cl_order[9] = 5'd5;
        cl_cl_order[10] = 5'd11;
        cl_cl_order[11] = 5'd4;
        cl_cl_order[12] = 5'd12;
        cl_cl_order[13] = 5'd3;
        cl_cl_order[14] = 5'd13;
        cl_cl_order[15] = 5'd2;
        cl_cl_order[16] = 5'd14;
        cl_cl_order[17] = 5'd1;
        cl_cl_order[18] = 5'd15;

        ll_cl_cl_min_L = 7;
        ll_cl_cl_max_L = 0;
        distance_cl_cl_min_L = 7;
        distance_cl_cl_max_L = 0;


    end else if (lagger_L1 == 2) begin

        header_reader_stage = header_reader_stage_single_value;
        
        bits_count_to_read_L = total_header_bits_width;


        L1_interperter_main_loop_flag = 0;
        // setting and launching 
        bits_reader_go_L = 1;



    end else if (lagger_L1 == 3) begin
        total_header_bits_L = read_from_memory_bus_L;

        // $display("L1: read %d bits. read_from_memory_bus_L:%b", bits_count_to_read_L, read_from_memory_bus_L);
        $display("L1: total_header_bits_L:", total_header_bits_L);
        $fdisplayb(L_output_file_general, total_header_bits_L);
        
    end else if (lagger_L1 == 4) begin

        header_reader_stage = header_reader_stage_single_value;

        // encoded_mem_width bits for last_entry_bits_count_L

        bits_count_to_read_L = encoded_mem_width;


        L1_interperter_main_loop_flag = 0;
        // setting and launching 
        bits_reader_go_L = 1;


    end else if (lagger_L1 == 5) begin
        last_entry_bits_count_L = read_from_memory_bus_L;

        // $display("L1: read %d bits. read_from_memory_bus_L:%b", bits_count_to_read_L, read_from_memory_bus_L);
        $display("L1: last_entry_bits_count_L:", last_entry_bits_count_L);
        $fdisplayb(L_output_file_general, last_entry_bits_count_L);


    end else if (lagger_L1 == 6) begin
        header_reader_stage = header_reader_stage_single_value;

        // 8 bits for: hlit_cl

        bits_count_to_read_L = 8;

        L1_interperter_main_loop_flag = 0;
        // setting and launching 
        bits_reader_go_L = 1;

   
    end else if (lagger_L1 == 7) begin
        hlit_cl = read_from_memory_bus_L;
        $display("L1: hlit_cl:", hlit_cl);
        $fdisplayb(L_output_file_general, hlit_cl);


    end else if (lagger_L1 == 8) begin
        // 3 bits per el for el in ll_cl_cl_table
        header_reader_stage = header_reader_stage_cl_cl_ll;

        L1_interperter_main_loop_flag = 0;
        // setting and launching L5
        lagger_L5 = 0;
        counter_L5 = 0;
        L5_decode_ll_cl_cl_table_flag = 1;


    end else if (lagger_L1 == 9) begin
        header_reader_stage = header_reader_stage_single_value;
        // 8 bits for: hdist_cl

        bits_count_to_read_L = 8;

        L1_interperter_main_loop_flag = 0;
        // setting and launching 
        bits_reader_go_L = 1;

   
    end else if (lagger_L1 == 10) begin
        hdist_cl = read_from_memory_bus_L;
        $display("L1: hdist_cl:", hdist_cl);
        $fdisplayb(L_output_file_general, hdist_cl);


    end else if (lagger_L1 == 11) begin
        // 3 bits per el for el in ll_cl_cl_table
        header_reader_stage = header_reader_stage_cl_cl_distance;

        L1_interperter_main_loop_flag = 0;
        // setting and launching L5
        lagger_L6 = 0;
        counter_L6 = 0;
        L6_decode_distance_cl_cl_table_flag = 1;





    end else if (lagger_L1 == 12) begin
        header_reader_stage = header_reader_stage_single_value;
        // 8 bits for: hlit

        bits_count_to_read_L = 8;

        L1_interperter_main_loop_flag = 0;
        // setting and launching 
        bits_reader_go_L = 1;

   
    end else if (lagger_L1 == 13) begin
        hlit = read_from_memory_bus_L;
        $display("L1: hlit:", hlit);
        $fdisplayb(L_output_file_general, hlit);





    end else if (lagger_L1 == 14) begin
        header_reader_stage = header_reader_stage_single_value;
        // 8 bits for: hdist

        bits_count_to_read_L = 8;

        L1_interperter_main_loop_flag = 0;
        // setting and launching 
        bits_reader_go_L = 1;

   
    end else if (lagger_L1 == 15) begin
        hdist = read_from_memory_bus_L;
        $display("L1: hdist:", hdist);
        $fdisplayb(L_output_file_general, hdist);




    end else if (lagger_L1 == 16) begin
        header_reader_stage = header_reader_stage_single_value;
        // 10 bits for: recode_cl_total_bits_to_write_ll

        bits_count_to_read_L = 10;

        L1_interperter_main_loop_flag = 0;
        // setting and launching 
        bits_reader_go_L = 1;

   
    end else if (lagger_L1 == 17) begin
        recode_cl_total_bits_to_write_ll = read_from_memory_bus_L;
        $display("L1: recode_cl_total_bits_to_write_ll:", recode_cl_total_bits_to_write_ll);
        $fdisplayb(L_output_file_general, recode_cl_total_bits_to_write_ll);





    end else if (lagger_L1 == 18) begin
        header_reader_stage = header_reader_stage_single_value;
        // 10 bits for: recode_cl_total_bits_to_write_distance

        bits_count_to_read_L = 10;

        L1_interperter_main_loop_flag = 0;
        // setting and launching 
        bits_reader_go_L = 1;

   
    end else if (lagger_L1 == 19) begin
        recode_cl_total_bits_to_write_distance = read_from_memory_bus_L;
        $display("L1: recode_cl_total_bits_to_write_distance:", recode_cl_total_bits_to_write_distance);
        $fdisplayb(L_output_file_general, recode_cl_total_bits_to_write_distance);


    end else if (lagger_L1 == 20) begin
        $display("L1: to resume reading:");
        $display("L1: left_over_bus_L:", left_over_bus_L);
        $display("L1: left_over_bus_length_L:", left_over_bus_length_L);
        $display("L1: bits_reader_read_addr_L:", bits_reader_read_addr_L);
        $fdisplayb(L_output_file_general, left_over_bus_L);
        $fdisplayb(L_output_file_general, left_over_bus_length_L);
        $fdisplayb(L_output_file_general, bits_reader_read_addr_L);


        $display("L1: ll_cl_cl_min_L:", ll_cl_cl_min_L);
        $display("L1: ll_cl_cl_max_L:", ll_cl_cl_max_L);
        $display("L1: distance_cl_cl_min_L:", distance_cl_cl_min_L);
        $display("L1: distance_cl_cl_max_L:", distance_cl_cl_max_L);
        $fdisplayb(L_output_file_general, ll_cl_cl_min_L);
        $fdisplayb(L_output_file_general, ll_cl_cl_max_L);
        $fdisplayb(L_output_file_general, distance_cl_cl_min_L);
        $fdisplayb(L_output_file_general, distance_cl_cl_max_L);



    end else if (lagger_L1 == 21) begin

        L1_interperter_main_loop_flag = 0;
        
        


        //setting and launching L2
        //counter_L2 = 0;
        //lagger_L2 = 0;
        //next_flag_L2 = 1;


            $display("FINISHED_______________________________________%d", $time);


    
    end 
end
end











































































// L5

// flag
reg                                                     L5_decode_ll_cl_cl_table_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_L5;
reg                 [q_full - 1 : 0]                    lagger_L5;

// L5 variables

    

//L5_decode_ll_cl_cl_table_flag
always @(negedge clk) begin
if (L5_decode_ll_cl_cl_table_flag == 1) begin
    lagger_L5 = lagger_L5 + 1;

    if (lagger_L5 == 1) begin
        if (counter_L5 < cl_cl_count - hlit_cl) begin
            bits_count_to_read_L = 3;

            L5_decode_ll_cl_cl_table_flag = 0;
            // setting and launching 
            bits_reader_go_L = 1;


        end 

    
    end else if (lagger_L5 == 2) begin
        $display("-\t\t L5: counter_L5:%d, ll_cl_cl:%d", counter_L5, (counter_L5 < cl_cl_count - hlit_cl) ? read_from_memory_bus_L : 0);

        interperter_cl_cl_ll_mem_write_addr = cl_cl_order[counter_L5];

        interperter_cl_cl_ll_mem_write_data = interperter_cl_cl_ll_mem_write_addr << 32;
        interperter_cl_cl_ll_mem_write_data[31 : 20] = (counter_L5 < cl_cl_count - hlit_cl) ? read_from_memory_bus_L : 0;

    end else if (lagger_L5 == 3) begin
        interperter_cl_cl_ll_mem_write_enable = 1;

    end else if (lagger_L5 == 4) begin
        interperter_cl_cl_ll_mem_write_enable = 0;

    end else if (lagger_L5 == 5) begin
        if ((interperter_cl_cl_ll_mem_write_data[31 : 20] > 0) && (interperter_cl_cl_ll_mem_write_data[31 : 20] < ll_cl_cl_min_L)) begin
            ll_cl_cl_min_L = interperter_cl_cl_ll_mem_write_data[31 : 20];
        end
        if (interperter_cl_cl_ll_mem_write_data[31 : 20] > ll_cl_cl_max_L) begin
            ll_cl_cl_max_L = interperter_cl_cl_ll_mem_write_data[31 : 20];
        end



    end else if (lagger_L5 == 6) begin

        if (counter_L5 < cl_cl_count - 1) begin
            counter_L5 = counter_L5 + 1;

        end else begin
            
            L5_decode_ll_cl_cl_table_flag = 0;
            // setting and launching L5
            counter_L15 = 0;
            lagger_L15 = 0;
            L15_dump_ll_cl_cl_mem_flag = 1;



        end

        lagger_L5 = 0;
    
    end 
end
end
















// L6

// flag
reg                                                     L6_decode_distance_cl_cl_table_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_L6;
reg                 [q_full - 1 : 0]                    lagger_L6;

// L6 variables

    

//L6_decode_distance_cl_cl_table_flag
always @(negedge clk) begin
if (L6_decode_distance_cl_cl_table_flag == 1) begin
    lagger_L6 = lagger_L6 + 1;

    if (lagger_L6 == 1) begin
        if (counter_L6 < cl_cl_count - hdist_cl) begin
            bits_count_to_read_L = 3;

            L6_decode_distance_cl_cl_table_flag = 0;
            // setting and launching 
            bits_reader_go_L = 1;


        end 
        


    end else if (lagger_L6 == 2) begin
        $display("-\t\t L6: counter_L6:%d, distance_cl_cl:%d", counter_L6, (counter_L6 < cl_cl_count - hdist_cl) ? read_from_memory_bus_L : 0);

        interperter_cl_cl_distance_mem_write_addr = cl_cl_order[counter_L6];

        interperter_cl_cl_distance_mem_write_data = interperter_cl_cl_distance_mem_write_addr << 32;
        interperter_cl_cl_distance_mem_write_data[31 : 20] = (counter_L6 < cl_cl_count - hdist_cl) ? read_from_memory_bus_L : 0;


    end else if (lagger_L6 == 3) begin
        interperter_cl_cl_distance_mem_write_enable = 1;

    end else if (lagger_L6 == 4) begin
        interperter_cl_cl_distance_mem_write_enable = 0;

    end else if (lagger_L6 == 5) begin
        if ((interperter_cl_cl_distance_mem_write_data[31 : 20] > 0) && (interperter_cl_cl_distance_mem_write_data[31 : 20] < distance_cl_cl_min_L)) begin
            distance_cl_cl_min_L = interperter_cl_cl_distance_mem_write_data[31 : 20];
        end
        if (interperter_cl_cl_distance_mem_write_data[31 : 20] > distance_cl_cl_max_L) begin
            distance_cl_cl_max_L = interperter_cl_cl_distance_mem_write_data[31 : 20];
        end


    end else if (lagger_L6 == 6) begin

        if (counter_L6 < cl_cl_count - 1) begin
            counter_L6 = counter_L6 + 1;

        end else begin
            
            L6_decode_distance_cl_cl_table_flag = 0;
            // setting and launching L6
            counter_L16 = 0;
            lagger_L16 = 0;
            L16_dump_distance_cl_cl_mem_flag = 1;



        end

        lagger_L6 = 0;
    
    end 
end
end















// L15

// flag
reg                                                     L15_dump_ll_cl_cl_mem_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_L15;
reg                 [q_full - 1 : 0]                    lagger_L15;

// L15 variables

//L15_dump_ll_cl_cl_mem_flag
always @(negedge clk) begin
if (L15_dump_ll_cl_cl_mem_flag == 1) begin
    lagger_L15 = lagger_L15 + 1;

    if (lagger_L15 == 1) begin
        interperter_cl_cl_ll_mem_read_addr = counter_L15;

    // end else if (lagger_L15 == 2) begin
    //     if (counter_L15 < cl_cl_count) begin
    //     $display("counter_L15:%d, cl:%d", counter_L15, interperter_cl_cl_ll_mem_read_data[31 : 20]);
            
    //     end

    end else if (lagger_L15 == 3) begin
        $fdisplayb(L15_output_file_interperter_cl_cl_ll_mem, interperter_cl_cl_ll_mem_read_data);

        $display("L15: counter_L15:%d,     cl_cl_ll: %d ", counter_L15,  interperter_cl_cl_ll_mem_read_data[31:20]);

    end else if (lagger_L15 == 4) begin

        if (counter_L15 < max_length_symbol - 1) begin
            counter_L15 = counter_L15 + 1;

        end else begin
            $fclose(L15_output_file_interperter_cl_cl_ll_mem);
            L15_dump_ll_cl_cl_mem_flag = 0;
            
            $display("L15: finished dumping interperter_cl_cl_ll at %d", $time);

            L1_interperter_main_loop_flag = 1;



        end

        lagger_L15 = 0;
    
    end 
end
end





// L16

// flag
reg                                                     L16_dump_distance_cl_cl_mem_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_L16;
reg                 [q_full - 1 : 0]                    lagger_L16;

// L16 variables

//L16_dump_distance_cl_cl_mem_flag
always @(negedge clk) begin
if (L16_dump_distance_cl_cl_mem_flag == 1) begin
    lagger_L16 = lagger_L16 + 1;

    if (lagger_L16 == 1) begin
        interperter_cl_cl_distance_mem_read_addr = counter_L16;

    // end else if (lagger_L16 == 2) begin
    //     if (counter_L16 < cl_cl_count) begin
    //     $display("counter_L16:%d, cl:%d", counter_L16, interperter_cl_cl_distance_mem_read_data[31 : 20]);
            
    //     end

    end else if (lagger_L16 == 3) begin
        $fdisplayb(L16_output_file_interperter_cl_cl_distance_mem, interperter_cl_cl_distance_mem_read_data);

    end else if (lagger_L16 == 4) begin

        if (counter_L16 < max_length_symbol - 1) begin
            counter_L16 = counter_L16 + 1;

        end else begin
            $fclose(L16_output_file_interperter_cl_cl_distance_mem);
            L16_dump_distance_cl_cl_mem_flag = 0;
            
            $display("L16: finished dumping interperter_cl_cl_distance at %d", $time);

            L1_interperter_main_loop_flag = 1;



        end

        lagger_L16 = 0;
    
    end 
end
end