
            reg                                                     reset_rams_flag                     = 0;
    
            reg                 [q_full - 1 : 0]                    ram_reset_counter_cap;
    
            reg                 [q_full - 1 : 0]                    counter_ram_reset_A                 = 0;
            reg                 [q_full - 1 : 0]                    lagger_ram_reset_A                  = 0;
    
    
            always @(negedge clk) begin
                if (reset_rams_flag == 1) begin
                    lagger_ram_reset_A = lagger_ram_reset_A + 1;
    
                    if (lagger_ram_reset_A == 1) begin
    
    
                        
    
                        if (counter_ram_reset_A < max_length_symbol) begin
                            argsrot_idx_for_cl_mem_write_addr                  = counter_ram_reset_A;
                        end
    
                    
    
                        if (counter_ram_reset_A < max_length_symbol) begin
                            clrec_vs_mem_write_addr                  = counter_ram_reset_A;
                        end
    
                    
    
                        if (counter_ram_reset_A < freq_list_depth) begin
                            clrec_freq_list_mem_write_addr                  = counter_ram_reset_A;
                        end
    
                    
    
    
                    end else if (lagger_ram_reset_A == 2) begin
    
    
                        
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              argsrot_idx_for_cl_mem_write_data                  = counter_ram_reset_A;
                          end
    
                      
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              clrec_vs_mem_write_data                  = 0;
                          end
    
                      
    
                          if (counter_ram_reset_A < freq_list_depth) begin
                              clrec_freq_list_mem_write_data                  = 0;
                          end
    
                      
    
    
                    end else if (lagger_ram_reset_A == 3) begin
    
    
                        
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              argsrot_idx_for_cl_mem_write_enable                  = 1;
                          end
    
                      
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              clrec_vs_mem_write_enable                  = 1;
                          end
    
                      
    
                          if (counter_ram_reset_A < freq_list_depth) begin
                              clrec_freq_list_mem_write_enable                  = 1;
                          end
    
                      
    
    
                    end else if (lagger_ram_reset_A == 4) begin
    
    
                        
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              argsrot_idx_for_cl_mem_write_enable                  = 0;
                          end
    
                      
    
                          if (counter_ram_reset_A < max_length_symbol) begin
                              clrec_vs_mem_write_enable                  = 0;
                          end
    
                      
    
                          if (counter_ram_reset_A < freq_list_depth) begin
                              clrec_freq_list_mem_write_enable                  = 0;
                          end
    
                      
    
    
    
                    end else if (lagger_ram_reset_A == 5) begin
    
                        if (counter_ram_reset_A < ram_reset_counter_cap - 1) begin
                            counter_ram_reset_A = counter_ram_reset_A + 1;
    
                        end else begin
                            counter_ram_reset_A = 0;
                            reset_rams_flag = 0;
                            $display("A: finished reset_rams_flag");
    
    
                            // setting and launching the first flag
                            
                                  counter_F0 = 0;
                                  read_lagger_F0 = 0;
                                  write_lagger_F0 = 0;
                                  sorter_bump_flag_F0 = 0;
                                  sorter_stage_F0 = sorter_stage_looping_F0;
                                  F0_argsort_cl_table_flag = 1;
            
                        end
    
    
                        lagger_ram_reset_A = 0;
    
                    end 
                end
            end
    
            