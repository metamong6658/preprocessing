module remover (
    input HCLK,
    input HSYNC,
    input HRESETn,
    input [7:0] data,
    output reg [7:0] VGA_data
);
    reg [15:0] comparator;
    reg IGNITION;
    reg STATE;
    reg [1:0] COUNTER;

    always @(posedge HCLK) begin
        if(!HRESETn) begin
        comparator = 0;
        STATE = 0;
        IGNITION = 0;
        VGA_data = 0; 
        end
        else begin
        if(HSYNC) begin
        comparator[15:8] = comparator[7:0];
        comparator[7:0] = data;
        if(COUNTER != 2) COUNTER = COUNTER + 1;
        else STATE = 1;
        case (STATE)
           0 :
            begin
                VGA_data = 0;
            end
           1 : 
            begin
                if(comparator[15] == comparator[7]) IGNITION = IGNITION;
                else IGNITION = ~IGNITION;
                if(IGNITION == 0) VGA_data = 0;
                else VGA_data = data;
            end
        endcase
        end
        end
    end

endmodule