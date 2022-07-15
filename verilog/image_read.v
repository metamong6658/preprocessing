module image_read #(
    parameter   WIDTH = 768,
                DEPTH = 512,
                ADDRSIZE = 393216,
                INFILE = "dog.hex",
                VSYNC_delay = 5,
                HSYNC_DELAY = 20
) (
    input HCLK,
    input HRESETn,
    output VSYNC,
    output reg HSYNC,
    output reg [7:0] data,
    output ctrl_done
);
    localparam  ST_IDLE = 0,
                ST_VSYNC = 1,
                ST_HSYNC = 2,
                ST_DATA = 3;

    reg [1:0] CSTATE, NSTATE;    
    reg d_HRESETn;
    reg START;
    reg ctrl_vsync_run;
    reg [8:0] ctrl_vsync_cnt;
    reg ctrl_hsync_run;
    reg [8:0] ctrl_hsync_cnt;
    reg ctrl_data_run;
    reg [7:0] mem [0:ADDRSIZE-1];
    reg [9:0] col;
    reg [9:0] row;
    reg [18:0] cnt_data;

    initial begin
        $readmemh(INFILE,mem,0,ADDRSIZE-1);
    end

    always @(posedge HCLK) begin
        if(!HRESETn) begin
            d_HRESETn <= 0;
            START <= 0;
        end
        else begin
            d_HRESETn <= HRESETn;
            if(HRESETn == 1 && d_HRESETn == 0) START <= 1;
            else START <= 0;
        end
    end

    always @(posedge HCLK) begin
        if(!HRESETn) CSTATE <= ST_IDLE;
        else CSTATE <= NSTATE;
    end

    always @(*) begin
        case (CSTATE)
           ST_IDLE : 
            begin
                if(START) NSTATE <= ST_VSYNC;
                else NSTATE <= ST_IDLE;
            end
           ST_VSYNC :
            begin
                if(ctrl_vsync_cnt == VSYNC_delay) NSTATE <= ST_HSYNC;
                else NSTATE <= ST_VSYNC;
            end
           ST_HSYNC :
            begin
                if(ctrl_hsync_cnt == HSYNC_DELAY) NSTATE <= ST_DATA;
                else NSTATE <= ST_HSYNC;
            end
           ST_DATA :
            begin
                if(ctrl_done) NSTATE <= ST_IDLE;
                else begin 
                    if(col == WIDTH - 1) NSTATE <= ST_HSYNC;
                    else NSTATE <= ST_DATA;
                end
            end
        endcase
    end

    always @(*) begin
        ctrl_vsync_run = 0;
        ctrl_hsync_run = 0;
        ctrl_data_run = 0;
        case (CSTATE)
           ST_VSYNC : ctrl_vsync_run = 1;
           ST_HSYNC : ctrl_hsync_run = 1;
           ST_DATA :  ctrl_data_run = 1;
        endcase
    end

    always @(posedge HCLK) begin
        if(!HRESETn) begin
            ctrl_vsync_cnt <= 0;
            ctrl_hsync_cnt <= 0;
        end
        else begin
            if(ctrl_vsync_run) ctrl_vsync_cnt <= ctrl_vsync_cnt + 1;
            else ctrl_vsync_cnt <= 0;
            if(ctrl_hsync_run) ctrl_hsync_cnt <= ctrl_hsync_cnt + 1;
            else ctrl_hsync_cnt <= 0;
        end
    end

    always @(posedge HCLK) begin
        if(!HRESETn) begin
            col <= 0;
            row <= 0;
        end
        else begin
            if(ctrl_data_run) begin
                if(col == WIDTH-1) begin
                    col <= 0;
                    row <= row + 1;
                end
                else col <= col + 1;
            end
        end
    end

    always @(posedge HCLK) begin
        if(!HRESETn) cnt_data <= 0;
        else begin
            if(ctrl_data_run) cnt_data <= cnt_data + 1;
        end
    end

    assign VSYNC = ctrl_vsync_run;
    assign ctrl_done = (cnt_data == ADDRSIZE - 1) ? 1'b1 : 1'b0;

    always @(*) begin
        HSYNC = 0;
        data = 0;
        if(ctrl_data_run) begin
            HSYNC = 1;
            data = mem[WIDTH*row+col];
        end
    end

endmodule