`timescale 1ns/1ns
`include "top.v"
`include "image_read.v"
`include "remover.v"
`include "image_write.v"

module tb_top;
    reg HCLK;
    reg HRESETn;
    wire VSYNC;
    wire HSYNC;
    wire [7:0] data;
    wire [7:0] VGA_data;
    wire ctrl_done;
    wire write_done;

    top top_inst(HCLK,HRESETn,VSYNC,HSYNC,data,VGA_data,ctrl_done,write_done);

    always #10 HCLK = ~HCLK;

    initial begin
        HCLK = 0;
        HRESETn = 0;
        #25 HRESETn = 1;
    end

endmodule