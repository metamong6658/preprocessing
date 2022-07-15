module top (
    input HCLK,
    input HRESETn,
    output VSYNC,
    output HSYNC,
    output [7:0] data,
    output [7:0] VGA_data,
    output ctrl_done,
    output write_done
);
    image_read image_read_inst(HCLK,HRESETn,VSYNC,HSYNC,data,ctrl_done);
    remover remover_inst(HCLK,HSYNC,HRESETn,data,VGA_data);
    image_write image_write_inst(HCLK,HRESETn,HSYNC,VGA_data,write_done);

endmodule