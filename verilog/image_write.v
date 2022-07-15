module image_write #(
    parameter   WIDTH = 768,
                DEPTH = 512,
                ADDRSIZE = 393216,
                FILESIZE = 1179648,
                OUTFILE = "dog.bmp",
                BMP_HEADER_NUM = 54 
) (
    input HCLK,
    input HRESETn,
    input HSYNC,
    input [7:0] VGA_data,
    output reg write_done
);
    integer BMP_HEADER [0:BMP_HEADER_NUM-1];
    integer l, m;
    integer k;
    integer i;
    integer fd;
    reg [7:0] out_BMP [0:FILESIZE-1];
    reg [18:0] cnt_data;
    wire done;

    //----------------------------------------------------------//
    //-------Header data for bmp image--------------------------//
    //----------------------------------------------------------//
    // Windows BMP files begin with a 54-byte header: 
    // Check the website to see the value of this header: http://www.fastgraph.com/help/bmp_HEADER_format.html
    // https://www.fpga4student.com/2016/11/image-processing-on-fpga-verilog.html
    initial begin
    	BMP_HEADER[ 0] = 66;            BMP_HEADER[28] =24;
    	BMP_HEADER[ 1] = 77;            BMP_HEADER[29] = 0;
        // You should change data 3*640*480+54 = 921654, convert hex 0x000E1036
        // 0x36 = 54, 0x10 = 16, 0x0E = 15, 0x00 = 0                           
    	BMP_HEADER[ 2] = 54;            BMP_HEADER[30] = 0;
    	BMP_HEADER[ 3] = 0;             BMP_HEADER[31] = 0;
    	BMP_HEADER[ 4] = 18;            BMP_HEADER[32] = 0;
    	BMP_HEADER[ 5] = 0;             BMP_HEADER[33] = 0;
        //                              
    	BMP_HEADER[ 6] = 0;             BMP_HEADER[34] = 0;
    	BMP_HEADER[ 7] = 0;             BMP_HEADER[35] = 0;
    	BMP_HEADER[ 8] = 0;             BMP_HEADER[36] = 0;
    	BMP_HEADER[ 9] = 0;             BMP_HEADER[37] = 0;
    	BMP_HEADER[10] = 54;            BMP_HEADER[38] = 0;
    	BMP_HEADER[11] = 0;             BMP_HEADER[39] = 0;
    	BMP_HEADER[12] = 0;             BMP_HEADER[40] = 0;
    	BMP_HEADER[13] = 0;             BMP_HEADER[41] = 0;
    	BMP_HEADER[14] = 40;            BMP_HEADER[42] = 0;
    	BMP_HEADER[15] = 0;             BMP_HEADER[43] = 0;
    	BMP_HEADER[16] = 0;             BMP_HEADER[44] = 0;
    	BMP_HEADER[17] = 0;             BMP_HEADER[45] = 0;
        // 640 = 0x0280
    	BMP_HEADER[18] = 0;             BMP_HEADER[46] = 0;
    	BMP_HEADER[19] = 3;             BMP_HEADER[47] = 0;
    	BMP_HEADER[20] = 0;             BMP_HEADER[48] = 0;
    	BMP_HEADER[21] = 0;             BMP_HEADER[49] = 0;
        // 480 = 0x01E0
    	BMP_HEADER[22] = 0;             BMP_HEADER[50] = 0;
    	BMP_HEADER[23] = 2;             BMP_HEADER[51] = 0;	
    	BMP_HEADER[24] = 0;            BMP_HEADER[52] = 0;
    	BMP_HEADER[25] = 0;             BMP_HEADER[53] = 0;
        //
    	BMP_HEADER[26] = 1;
    	BMP_HEADER[27] = 0;
    end

    always @(posedge HCLK) begin
        if(!HRESETn) begin
            l <= 0;
            m <= 0;
        end
        else begin
            if(HSYNC) begin
                if(m == WIDTH -1) begin
                    m <= 0;
                    l <= l+1;
                end
                else m <= m + 1;
            end
        end
    end

    always @(posedge HCLK) begin
        if(!HRESETn) begin
            for(k=0;k<FILESIZE;k=k+1) begin
                out_BMP[k] <= 0;
            end
        end
        else begin
            if(HSYNC) begin
                out_BMP[3*WIDTH*(DEPTH-l-1)+3*m+2] <= VGA_data; // R
                out_BMP[3*WIDTH*(DEPTH-l-1)+3*m+1] <= VGA_data; // G
                out_BMP[3*WIDTH*(DEPTH-l-1)+3*m+0] <= VGA_data; // B
            end
        end
    end

    always @(posedge HCLK) begin
        if(!HRESETn) cnt_data <= 0;
        else begin
            if(HSYNC) cnt_data <= cnt_data + 1;
        end
    end

    assign done = (cnt_data == ADDRSIZE - 1) ? 1'b1 : 1'b0;

    always @(posedge HCLK) begin
        if(!HRESETn) write_done <= 0;
        else write_done <= done;
    end

    initial begin
        fd = $fopen(OUTFILE, "wb+");
    end

    always @(write_done) begin
        if(write_done) begin
            for(i=0;i<BMP_HEADER_NUM;i=i+1) begin
                $fwrite(fd,"%c",BMP_HEADER[i][7:0]);
            end
            for(i=0;i<FILESIZE;i=i+12) begin
                $fwrite(fd, "%c", out_BMP[i+0][7:0]);
                $fwrite(fd, "%c", out_BMP[i+1][7:0]);
                $fwrite(fd, "%c", out_BMP[i+2][7:0]);
                $fwrite(fd, "%c", out_BMP[i+3][7:0]);
                $fwrite(fd, "%c", out_BMP[i+4][7:0]);
                $fwrite(fd, "%c", out_BMP[i+5][7:0]);
                $fwrite(fd, "%c", out_BMP[i+6][7:0]);
                $fwrite(fd, "%c", out_BMP[i+7][7:0]);
                $fwrite(fd, "%c", out_BMP[i+8][7:0]);
                $fwrite(fd, "%c", out_BMP[i+9][7:0]);
                $fwrite(fd, "%c", out_BMP[i+10][7:0]);
                $fwrite(fd, "%c", out_BMP[i+11][7:0]);
            end
            $fclose(fd);
        end
    end

endmodule