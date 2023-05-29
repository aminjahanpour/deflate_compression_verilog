

// J0

// flag
reg                                                     J0_apply_encoding_order_to_code_length_table_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_J0;
reg                 [q_full - 1 : 0]                    lagger_J0;

// J0 variables
reg                 [5 - 1      : 0]                    cl_cl_order[cl_cl_count - 1 : 0];
reg                 [8 - 1      : 0]                    hlit_cl;

//J0_apply_encoding_order_to_code_length_table_flag
always @(negedge clk) begin
if (J0_apply_encoding_order_to_code_length_table_flag == 1) begin
    lagger_J0 = lagger_J0 + 1;

    if (lagger_J0 == 1) begin
        recode_codes_mem_read_addr = cl_cl_order[counter_J0];
        hlit_cl = hlit_cl + 1;

    end else if (lagger_J0 == 2) begin
        $display("J0: counter_J0:%d, cl_cl_order[counter_J0]:%d, cl:%d", counter_J0, cl_cl_order[counter_J0], recode_codes_mem_read_data[31 : 20]);

        recode_cl_cl_reordered_pre_bitstream_mem_write_data = 5 << 16;
        recode_cl_cl_reordered_pre_bitstream_mem_write_data = recode_cl_cl_reordered_pre_bitstream_mem_write_data | recode_codes_mem_read_data[31 : 20];

        if (recode_codes_mem_read_data[31 : 20] > 0) begin
            hlit_cl = 0;
        end

    end else if (lagger_J0 == 3) begin
        recode_cl_cl_reordered_pre_bitstream_mem_write_enable = 1;


    end else if (lagger_J0 == 4) begin
        recode_cl_cl_reordered_pre_bitstream_mem_write_enable = 0;


    end else if (lagger_J0 == 5) begin
        recode_cl_cl_reordered_pre_bitstream_mem_write_addr = recode_cl_cl_reordered_pre_bitstream_mem_write_addr + 1;



    end else if (lagger_J0 == 6) begin

        if (counter_J0 < cl_cl_count - 1) begin
            counter_J0 = counter_J0 + 1;

        end else begin
            

            
            $fdisplayb(I_output_file_general, hlit_cl);
            $fdisplayb(I_output_file_general, recode_cl_cl_reordered_pre_bitstream_mem_write_addr - hlit_cl);
            $fdisplayb(I_output_file_general, recode_cl_total_bits_to_write);
            

            $fclose(I_output_file_general);

            $display("J0: hlit_cl: %d", hlit_cl);
            $display("J0: pre-bitstream count: %d", recode_cl_cl_reordered_pre_bitstream_mem_write_addr - hlit_cl);


            J0_apply_encoding_order_to_code_length_table_flag = 0;
            // reseting and launching
            J1_dump_recode_cl_cl_reordered_pre_bitstream_flag = 1;
            counter_J1 = 0;
            lagger_J1  = 0;




        end

        lagger_J0 = 0;
    
    end 
end
end














// J1

// flag
reg                                                     J1_dump_recode_cl_cl_reordered_pre_bitstream_flag   = 0;


// loop reset
reg                 [q_full - 1 : 0]                    counter_J1;
reg                 [q_full - 1 : 0]                    lagger_J1;

// J1 variables

//J1_dump_recode_cl_cl_reordered_pre_bitstream_flag
always @(negedge clk) begin
if (J1_dump_recode_cl_cl_reordered_pre_bitstream_flag == 1) begin
    lagger_J1 = lagger_J1 + 1;

    if (lagger_J1 == 1) begin
        recode_cl_cl_reordered_pre_bitstream_mem_read_addr = counter_J1;

    end else if (lagger_J1 == 2) begin
        $fdisplayb(J1_output_file_recode_cl_cl_reordered_pre_bitstream_mem, recode_cl_cl_reordered_pre_bitstream_mem_read_data);

    end else if (lagger_J1 == 3) begin

        if (counter_J1 < recode_cl_cl_reordered_pre_bitstream_mem_write_addr - hlit_cl - 1) begin
            counter_J1 = counter_J1 + 1;

        end else begin
            $fclose(J1_output_file_recode_cl_cl_reordered_pre_bitstream_mem);
            J1_dump_recode_cl_cl_reordered_pre_bitstream_flag = 0;
            
            $display("J1: finished dumping recode_cl_cl_reordered_pre_bitstream at %d", $time);


            //setting and launching J2
            //counter_J2 = 0;
            //lagger_J2 = 0;
            //next_flag_J2 = 1;


            $display("FINISHED_______________________________________%d", $time);

        end

        lagger_J1 = 0;
    
    end 
end
end
