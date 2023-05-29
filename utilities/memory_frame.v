
module memory_list
    #(
        parameter                                       mem_width                       = 0,
        parameter                                       address_len                     = 0,
        parameter                                       mem_depth                       = 0,
        parameter                                       initial_file                    = ""

        )
    (
        input                                           clk     ,
        input       [mem_width - 1 : 0]                 w_data  ,
        input       [address_len - 1 : 0]               w_addr  ,
        input       [address_len - 1 : 0]               r_addr  ,
        input                                           w_en    ,
        input                                           r_en    ,

        output  reg [mem_width - 1 : 0]                 r_data
    );



    reg signed      [mem_width - 1 : 0]              mem [mem_depth - 1 : 0];


    integer i;

    initial begin

        if (initial_file != 0) begin
            $display("\n\n____ Creating rom_async from init file '%s'.", initial_file);
            $readmemb(initial_file, mem, 0, mem_depth - 1);
        end

    end


    always @(posedge clk) begin

        if (w_en == 1) begin
            mem[w_addr] <= w_data;
        end

        if (r_en == 1) begin
            r_data <= mem[r_addr];
        end
        
    end




endmodule