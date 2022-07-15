`timescale 1ns/1ns
`include "remover.v"

module tb_remover;
    reg clk;
    reg rstn;
    reg [7:0] data;
    wire [7:0] VGA_data;

    remover remover_inst(clk,rstn,data,VGA_data);

    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_remover.vcd");
        $dumpvars(0);
        clk = 0;
        rstn = 1;
        data = 0;
        #10
        rstn = 0;
        #10
        rstn = 1;
        #5
        data = 8'b0_1111111;
        #10
        data = 8'b0_1110110;
        #10
        data = 8'b0_1011011;
        #10
        data = 8'b1_0100101;
        #10
        data = 8'b1_0010111;
        #10
        data = 8'b0_0010111;
        #10
        data = 8'b0_1011010;
        #20
        $finish;
    end

endmodule