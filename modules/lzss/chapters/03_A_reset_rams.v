
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
    
            