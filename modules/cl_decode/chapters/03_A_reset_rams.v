
            reg                                                     reset_rams_flag                     = 0;
    
            reg                 [q_full - 1 : 0]                    ram_reset_counter_cap;
    
            reg                 [q_full - 1 : 0]                    counter_ram_reset_A                 = 0;
            reg                 [q_full - 1 : 0]                    lagger_ram_reset_A                  = 0;
    
    
            always @(negedge clk) begin
                if (reset_rams_flag == 1) begin
                    lagger_ram_reset_A = lagger_ram_reset_A + 1;
    
                    if (lagger_ram_reset_A == 1) begin
    
    
                        
    
                        if (counter_ram_reset_A < max_length_symbol) begin
                            cl_decode_cl_ll_mem_write_addr                  = counter_ram_reset_A;
                        end
    
                    
    
                        if (counter_ram_reset_A < max_length_symbol) begin
                            cl_decode_cl_distance_mem_write_addr                  = counter_ram_reset_A;
                        end
    
                    
    
    
                    end else if (lagger_ram_reset_A == 2) begin
    
    
                        
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              cl_decode_cl_ll_mem_write_data                  = 0;
                          end
    
                      
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              cl_decode_cl_distance_mem_write_data                  = 0;
                          end
    
                      
    
    
                    end else if (lagger_ram_reset_A == 3) begin
    
    
                        
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              cl_decode_cl_ll_mem_write_enable                  = 1;
                          end
    
                      
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              cl_decode_cl_distance_mem_write_enable                  = 1;
                          end
    
                      
    
    
                    end else if (lagger_ram_reset_A == 4) begin
    
    
                        
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              cl_decode_cl_ll_mem_write_enable                  = 0;
                          end
    
                      
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              cl_decode_cl_distance_mem_write_enable                  = 0;
                          end
    
                      
    
    
    
                    end else if (lagger_ram_reset_A == 5) begin
    
                        if (counter_ram_reset_A < ram_reset_counter_cap - 1) begin
                            counter_ram_reset_A = counter_ram_reset_A + 1;
    
                        end else begin
                            counter_ram_reset_A = 0;
                            reset_rams_flag = 0;
                            $display("A: finished reset_rams_flag");
    
    
                            // setting and launching the first flag
                            
                    MC_read_config_file_flag    = 1;
                    counter_MC                  = 0;
                    lagger_MC                  = 0;
                    

            
                        end
    
    
                        lagger_ram_reset_A = 0;
    
                    end 
                end
            end
    
            