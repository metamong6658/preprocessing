`timescale 1ns/1ns
`include "image_read.v"

module tb_image_read;
    reg HCLK;
    reg HRESETn;
    wire VSYNC;
    wire HSYNC;
    wire [7:0] data;
    wire ctrl_done;

    image_read image_read_inst(HCLK,HRESETn,VSYNC,HSYNC,data,ctrl_done);

    always #10 HCLK = ~HCLK;

    initial begin
        $dumpfile("tb_image_read.vcd");
        $dumpvars(0);
        HCLK = 0;
        HRESETn = 0;
        #25
        HRESETn = 1;
        #1000
        $finish;
    end

endmodule