
`timescale 1ps/1ps
`default_nettype none
`define DUMPSTR(x) `"x.vcd`"


module huffman_tb ();



    reg                                                     clk;
    reg                                                     reset;



    huffman huffman_inst (
        .clk(clk),
        .reset(reset)
    );


    always #1 clk = ~clk;


    parameter DURATION = 5000000;

    initial begin
        clk = 0;

        #1;
        $display("\n running...");

        reset = 0;
        #1;
        reset = 1;
        
    end


    initial begin

        #(DURATION);
        $display("End of simulation at:%d", $time);
        $finish;

    end


endmodule



