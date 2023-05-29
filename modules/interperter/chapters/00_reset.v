
            

module interperter (
    input                                               clk,
    input                                               reset
);


// Output Files

integer                                                 L_output_file_general;
integer                                                 L15_output_file_interperter_cl_cl_ll_mem;
integer                                                 L16_output_file_interperter_cl_cl_distance_mem;



// Reset
always @(posedge reset) begin

    reset_rams_flag                         = 1;


    ram_reset_counter_cap                   = 286;





    
    L_output_file_general =                                $fopen("./dumps/L_output_file_general.txt", "w");
L15_output_file_interperter_cl_cl_ll_mem =                                $fopen("./dumps/L15_output_file_interperter_cl_cl_ll_mem.txt", "w");
L16_output_file_interperter_cl_cl_distance_mem =                                $fopen("./dumps/L16_output_file_interperter_cl_cl_distance_mem.txt", "w");


end


            