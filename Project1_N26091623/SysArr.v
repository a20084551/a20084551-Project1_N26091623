`include "define.v"
`include "pe.v"

module SysArr(
    input clk,
    input rst,
    input start,
    input [3:0] m,n,k,
    input [`WORD_SIZE-1:0] data_out_a, //data from gubff_A and gubff_B
    input [`WORD_SIZE-1:0] data_out_b,

    output reg done, //interrupt to reset pe

	output reg wr_en_a,
	output reg wr_en_b,
	output reg wr_en_out,

    output reg [`DATA_SIZE-1:0] index_a, //use to assign data in gbuff
    output reg [`DATA_SIZE-1:0] index_b,
    output reg [`DATA_SIZE-1:0] index_out,

    output reg [`WORD_SIZE-1:0] data_in_o //output result to gubff_OUT
);

reg [`DATA_SIZE-1:0] data_r1 , data_r2 , data_r3 , data_r4 , data_r5 , data_r6; //buffer input data from gubff_A and gubff_B to delay input
reg [`DATA_SIZE-1:0] weight_w1 , weight_w2 , weight_w3 , weight_w4 , weight_w5 , weight_w6;

reg [`DATA_SIZE-1:0] data_1; //gbuff_a and gbuff_b input data to pe
reg [`DATA_SIZE-1:0] data_2;
reg [`DATA_SIZE-1:0] data_3;
reg [`DATA_SIZE-1:0] data_4;
reg [`DATA_SIZE-1:0] weight_1;
reg [`DATA_SIZE-1:0] weight_2;
reg [`DATA_SIZE-1:0] weight_3;
reg [`DATA_SIZE-1:0] weight_4;

wire [`DATA_SIZE-1:0] p11d , p11w; //pe dataflow signal
wire [`DATA_SIZE-1:0] p12d , p12w;
wire [`DATA_SIZE-1:0] p13d , p13w;
wire [`DATA_SIZE-1:0] p14d , p14w;
wire [`DATA_SIZE-1:0] p21d , p21w; 
wire [`DATA_SIZE-1:0] p22d , p22w;
wire [`DATA_SIZE-1:0] p23d , p23w;
wire [`DATA_SIZE-1:0] p24d , p24w;
wire [`DATA_SIZE-1:0] p31d , p31w; 
wire [`DATA_SIZE-1:0] p32d , p32w;
wire [`DATA_SIZE-1:0] p33d , p33w;
wire [`DATA_SIZE-1:0] p34d , p34w;
wire [`DATA_SIZE-1:0] p41d , p41w; 
wire [`DATA_SIZE-1:0] p42d , p42w;
wire [`DATA_SIZE-1:0] p43d , p43w;
wire [`DATA_SIZE-1:0] p44d , p44w;

wire [`DATA_SIZE-1:0] p11o , p12o , p13o , p14o; //pe output result
wire [`DATA_SIZE-1:0] p21o , p22o , p23o , p24o;
wire [`DATA_SIZE-1:0] p31o , p32o , p33o , p34o;
wire [`DATA_SIZE-1:0] p41o , p42o , p43o , p44o;

reg [`DATA_SIZE-1:0] p11_out , p12_out , p13_out , p14_out; //Fixed the correct output of pe, easy to arrange in rows
reg [`DATA_SIZE-1:0] p21_out , p22_out , p23_out , p24_out;
reg [`DATA_SIZE-1:0] p31_out , p32_out , p33_out , p34_out;
reg [`DATA_SIZE-1:0] p41_out , p42_out , p43_out , p44_out;

wire [`WORD_SIZE-1:0] data_out_0 , data_out_1 , data_out_2 , data_out_3; //SysArr output to gubff_OUT (row type)

reg [4:0] counter; //control signal

/*setting SysArr output of row type*/
assign data_out_0 = {p14_out , p13_out , p12_out , p11_out};
assign data_out_1 = {p24_out , p23_out , p22_out , p21_out};
assign data_out_2 = {p34_out , p33_out , p32_out , p31_out};
assign data_out_3 = {p44_out , p43_out , p42_out , p41_out};

/*setting controller*/
always @ (posedge clk , posedge rst) begin 
    if(rst) begin 
        counter <= 5'd24; 
    end else begin 
        if((k==9) && (counter==5'd17)) begin 
            counter <= 5'b0;
        end else if((k<9) && (counter==5'd12)) begin 
            counter <= 5'b0;
        end else begin 
            counter <= counter + 5'b1;
        end
    end
end

/*setting interrupt to reset pe*/
always @ (*) begin 
    if((k==9) && (counter ==5'd17) && (start==1'd1)) begin 
        done <= 1'b1;
    end else if ((k<9) && (counter==5'd12)) begin 
        done <= 1'b1;
    end else begin 
        done <= 1'b0;
    end
end

/*use buffer to arrange the data before send in pe*/
//data
always@(posedge clk or posedge rst)begin
	if(rst)begin
	data_r1 <=8'b0;
	end
	
	else begin
	data_r1 <= data_out_a[23:16];
	end
end


always@(posedge clk or posedge rst)begin
	if(rst)begin
	data_r2 <=8'b0;
	end
	
	else begin
	data_r2 <= data_out_a[15:8];
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
	data_r3 <=8'b0;
	end
	
	else begin
	data_r3 <= data_r2;
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
	data_r4 <=8'b0;
	end
	
	else begin
	data_r4 <= data_out_a[7:0];
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
	data_r5 <=8'b0;
	end
	
	else begin
	data_r5 <= data_r4;
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
	data_r6 <=8'b0;
	end
	
	else begin
	data_r6 <= data_r5;
	end
end

//weight
always@(posedge clk or posedge rst)begin
	if(rst)begin
	    weight_w1 <=8'b0;
	end else begin
	    weight_w1 <= data_out_b[23:16];
	end
end


always@(posedge clk or posedge rst)begin
	if(rst)begin
	    weight_w2 <=8'b0;
	end else begin
	    weight_w2 <= data_out_b[15:8];
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
	    weight_w3 <=8'b0;
	end else begin
	    weight_w3 <= weight_w2;
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
	    weight_w4 <=8'b0;
	end else begin
	    weight_w4 <= data_out_b[7:0];
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
	    weight_w5 <=8'b0;
	end else begin
	    weight_w5 <= weight_w4;
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
	    weight_w6 <=8'b0;
	end else begin
	    weight_w6 <= weight_w5;
	end
end

/*receive the correct output of pe*/
always @ (*) begin 
    if((k==9) && (counter ==5'd13)) begin 
        p11_out = p11o;
		p12_out = p12o;
		p13_out = p13o;
		p14_out = p14o;
    end else begin 
        if(counter==5'd8) begin 
            p11_out = p11o;
		    p12_out = p12o;
		    p13_out = p13o;
		    p14_out = p14o;
        end else begin 
            p11_out = 8'b0;
			p12_out = 8'b0;
			p13_out = 8'b0;
			p14_out = 8'b0;
        end
    end
end

always @ (*) begin 
    if((k==9) && (counter ==5'd14)) begin 
        p21_out = p21o;
		p22_out = p22o;
		p23_out = p23o;
		p24_out = p24o;
    end else begin 
        if(counter==5'd9) begin 
            p21_out = p21o;
		    p22_out = p22o;
		    p23_out = p23o;
		    p24_out = p24o;
        end else begin 
            p21_out = 8'b0;
			p22_out = 8'b0;
			p23_out = 8'b0;
			p24_out = 8'b0;
        end
    end
end

always @ (*) begin 
    if((k==9) && (counter ==5'd15)) begin 
        p31_out = p31o;
		p32_out = p32o;
		p33_out = p33o;
		p34_out = p34o;
    end else begin 
        if(counter==5'd10) begin 
            p31_out = p31o;
		    p32_out = p32o;
		    p33_out = p33o;
		    p34_out = p34o;
        end else begin 
            p31_out = 8'b0;
			p32_out = 8'b0;
			p33_out = 8'b0;
			p34_out = 8'b0;
        end
    end
end

always @ (*) begin 
    if((k==9) && (counter ==5'd16)) begin 
        p41_out = p41o;
		p22_out = p42o;
		p23_out = p43o;
		p24_out = p44o;
    end else begin 
        if(counter==5'd11) begin 
            p41_out = p41o;
		    p42_out = p42o;
		    p43_out = p43o;
		    p44_out = p44o;
        end else begin 
            p41_out = 8'b0;
			p42_out = 8'b0;
			p43_out = 8'b0;
			p44_out = 8'b0;
        end
    end
end

/*control dataflow and all enable signal in SysArr*/
always @ (*) begin 
    if((k==9) && (start==1'b1)) begin 
        case (counter)
			5'd0 : begin 
				data_1    = 8'd0;//data_out_a[31:24];
				data_2    = 8'd0;//data_r1;
				data_3    = 8'd0;//data_r3;
				data_4    = 8'd0;//data_r6;
				weight_1  = 8'd0;//data_out_b[31:24];
				weight_2  = 8'd0;//weight_w1;
				weight_3  = 8'd0;//weight_w3;
				weight_4  = 8'd0;//weight_w6;
				wr_en_a   = 1'b0;
				wr_en_b   = 1'b0;
				wr_en_out = 1'b0;
				index_a   = 8'd0;
				index_b   = 8'b0;
				index_out = 8'd0;
			end
            5'd1 : begin 
                data_1    = data_out_a[31:24];
			    data_2    = 8'd0;//data_r1;
			    data_3    = 8'd0;//data_r3;
			    data_4    = 8'd0;//data_r6;
			    weight_1  = data_out_b[31:24];
			    weight_2  = 8'd0;//weight_w1;
			    weight_3  = 8'd0;//weight_w3;
			    weight_4  = 8'd0;//weight_w6;
			    wr_en_a   = 1'b0;
			    wr_en_b   = 1'b0;
			    wr_en_out = 1'b0;
			    index_a   = 8'd1;
			    index_b   = 8'd1;
			    index_out = 8'd0;
            end

            5'd2 : begin 
                data_1    = data_out_a[31:24];
			    data_2    = data_r1;
			    data_3    = 8'd0;//data_r3;
			    data_4    = 8'd0;//data_r6;
			    weight_1  = data_out_b[31:24];
			    weight_2  = weight_w1;
			    weight_3  = 8'd0;//weight_w3;
			    weight_4  = 8'd0;//weight_w6;
			    wr_en_a   = 1'b0;
			    wr_en_b   = 1'b0;
			    wr_en_out = 1'b0;
			    index_a   = 8'd2;
			    index_b   = 8'd2;
			    index_out = 8'd0;
            end

            5'd3 : begin 
                data_1    = data_out_a[31:24];
			    data_2    = data_r1;
			    data_3    = data_r3;
			    data_4    = 8'd0;//data_r6;
			    weight_1  = data_out_b[31:24];
			    weight_2  = weight_w1;
			    weight_3  = weight_w3;
			    weight_4  = 8'd0;//weight_w6;
			    wr_en_a   = 1'b0;
			    wr_en_b   = 1'b0;
			    wr_en_out = 1'b0;
			    index_a   = 8'd3;
			    index_b   = 8'd3;
			    index_out = 8'd0;
            end

            5'd4 : begin 
                data_1    = data_out_a[31:24];
			    data_2    = data_r1;
			    data_3    = data_r3;
			    data_4    = data_r6;
			    weight_1  = data_out_b[31:24];
			    weight_2  = weight_w1;
			    weight_3  = weight_w3;
			    weight_4  = weight_w6;
			    wr_en_a   = 1'b0;
			    wr_en_b   = 1'b0;
			    wr_en_out = 1'b0;
			    index_a   = 8'd4;
			    index_b   = 8'd4;
			    index_out = 8'd0; 
            end

            5'd5 : begin 
                data_1    = data_out_a[31:24];
			    data_2    = data_r1;
			    data_3    = data_r3;
			    data_4    = data_r6;
			    weight_1  = data_out_b[31:24];
			    weight_2  = weight_w1;
			    weight_3  = weight_w3;
			    weight_4  = weight_w6;
			    wr_en_a   = 1'b0;
			    wr_en_b   = 1'b0;
			    wr_en_out = 1'b0;
			    index_a   = 8'd5;
			    index_b   = 8'd5;
			    index_out = 8'd0; 
            end

            5'd6 : begin 
                data_1    = data_out_a[31:24];
			    data_2    = data_r1;
			    data_3    = data_r3;
			    data_4    = data_r6;
			    weight_1  = data_out_b[31:24];
			    weight_2  = weight_w1;
			    weight_3  = weight_w3;
			    weight_4  = weight_w6;
			    wr_en_a   = 1'b0;
			    wr_en_b   = 1'b0;
			    wr_en_out = 1'b0;
			    index_a   = 8'd6;
			    index_b   = 8'd6;
			    index_out = 8'd0; 
            end

            5'd7 : begin 
                data_1    = data_out_a[31:24];
			    data_2    = data_r1;
			    data_3    = data_r3;
			    data_4    = data_r6;
			    weight_1  = data_out_b[31:24];
			    weight_2  = weight_w1;
			    weight_3  = weight_w3;
			    weight_4  = weight_w6;
			    wr_en_a   = 1'b0;
			    wr_en_b   = 1'b0;
			    wr_en_out = 1'b0;
			    index_a   = 8'd7;
			    index_b   = 8'd7;
			    index_out = 8'd0; 
            end

            5'd8 : begin 
                data_1    = data_out_a[31:24];
			    data_2    = data_r1;
			    data_3    = data_r3;
			    data_4    = data_r6;
			    weight_1  = data_out_b[31:24];
			    weight_2  = weight_w1;
			    weight_3  = weight_w3;
			    weight_4  = weight_w6;
			    wr_en_a   = 1'b0;
			    wr_en_b   = 1'b0;
			    wr_en_out = 1'b0;
			    index_a   = 8'd8;
			    index_b   = 8'd8;
			    index_out = 8'd0;  
            end

            5'd9 : begin 
                data_1    = data_out_a[31:24];
			    data_2    = data_r1;
			    data_3    = data_r3;
			    data_4    = data_r6;
			    weight_1  = data_out_b[31:24];
			    weight_2  = weight_w1;
			    weight_3  = weight_w3;
			    weight_4  = weight_w6;
			    wr_en_a   = 1'b0;
			    wr_en_b   = 1'b0;
			    wr_en_out = 1'b0;
			    index_a   = 8'd9;
			    index_b   = 8'd9;
			    index_out = 8'd0; 
            end

            5'd10 : begin 
                data_1    = 8'b0;
			    data_2    = data_r1;
			    data_3    = data_r3;
			    data_4    = data_r6;
			    weight_1  = 8'b0;
			    weight_2  = weight_w1;
			    weight_3  = weight_w3;
			    weight_4  = weight_w6;
			    wr_en_a   = 1'b0;
			    wr_en_b   = 1'b0;
			    wr_en_out = 1'b0;
			    index_a   = 8'd0;
			    index_b   = 8'd0;
			    index_out = 8'd0;
            end

            5'd11 : begin 
                data_1    = 8'b0;
			    data_2    = 8'b0;
			    data_3    = data_r3;
			    data_4    = data_r6;
			    weight_1  = 8'b0;
			    weight_2  = 8'b0;
			    weight_3  = weight_w3;
			    weight_4  = weight_w6;
			    wr_en_a   = 1'b0;
			    wr_en_b   = 1'b0;
			    wr_en_out = 1'b0;
			    index_a   = 8'd0;
			    index_b   = 8'd0;
			    index_out = 8'd0;
            end

            5'd12 : begin 
                data_1    = 8'b0;
			    data_2    = 8'b0;
			    data_3    = 8'b0;
			    data_4    = data_r6;
			    weight_1  = 8'b0;
			    weight_2  = 8'b0;
			    weight_3  = 8'b0;
			    weight_4  = weight_w6;
			    wr_en_a   = 1'b0;
			    wr_en_b   = 1'b0;
			    wr_en_out = 1'b1;
			    index_a   = 8'd0;
			    index_b   = 8'd0;
			    index_out = 8'd0;
            end

            default : begin 
                data_1    = 8'd0;//data_out_a[31:24];
			    data_2    = 8'd0;//data_r1;
			    data_3    = 8'd0;//data_r3;
			    data_4    = 8'd0;//data_r6;
			    weight_1  = 8'd0;//data_out_b[31:24];
			    weight_2  = 8'd0;//weight_w1;
			    weight_3  = 8'd0;//weight_w3;
			    weight_4  = 8'd0;//weight_w6;
			    wr_en_a   = 1'b0;
			    wr_en_b   = 1'b0;
			    wr_en_out = 1'b0;
			    index_a   = 8'd255;
			    index_b   = 8'd255;
			    index_out = 8'd0;
            end

            endcase

    end else begin 
        if(start==1'b1) begin 
            case (counter) 
				5'd0 : begin 
					data_1    = 8'd0;//data_out_a[31:24];
					data_2    = 8'd0;//data_r1;
					data_3    = 8'd0;//data_r3;
					data_4    = 8'd0;//data_r6;
					weight_1  = 8'd0;//data_out_b[31:24];
					weight_2  = 8'd0;//weight_w1;
					weight_3  = 8'd0;//weight_w3;
					weight_4  = 8'd0;//weight_w6;
					wr_en_a   = 1'b0;
					wr_en_b   = 1'b0;
					wr_en_out = 1'b0;
					index_a   = 8'd0;
					index_b   = 8'b0;
					index_out = 8'd0;
				end

                5'd1 : begin 
                    data_1    = data_out_a[31:24];
			        data_2    = 8'd0;//data_r1;
			        data_3    = 8'd0;//data_r3;
			        data_4    = 8'd0;//data_r6;
			        weight_1  = data_out_b[31:24];
			        weight_2  = 8'd0;//weight_w1;
			        weight_3  = 8'd0;//weight_w3;
			        weight_4  = 8'd0;//weight_w6;
			        wr_en_a   = 1'b0;
			        wr_en_b   = 1'b0;
			        wr_en_out = 1'b0;
			        index_a   = 8'd1;
			        index_b   = 8'd1;
			        index_out = 8'd0;
                end

                5'd2 : begin 
                    data_1    = data_out_a[31:24];
			        data_2    = data_r1;
			        data_3    = 8'd0;//data_r3;
			        data_4    = 8'd0;//data_r6;
			        weight_1  = data_out_b[31:24];
			        weight_2  = weight_w1;
			        weight_3  = 8'd0;//weight_w3;
			        weight_4  = 8'd0;//weight_w6;
			        wr_en_a   = 1'b0;
			        wr_en_b   = 1'b0;
			        wr_en_out = 1'b0;
			        index_a   = 8'd2;
			        index_b   = 8'd2;
			        index_out = 8'd0;
                end

                5'd3 : begin
                    data_1    = data_out_a[31:24];
			        data_2    = data_r1;
			        data_3    = data_r3;
			        data_4    = 8'd0;//data_r6;
			        weight_1  = data_out_b[31:24];
			        weight_2  = weight_w1;
			        weight_3  = weight_w3;
			        weight_4  = 8'd0;//weight_w6;
			        wr_en_a   = 1'b0;
			        wr_en_b   = 1'b0;
			        wr_en_out = 1'b0;
			        index_a   = 8'd3;
			        index_b   = 8'd3;
			        index_out = 8'd0;
                end

                5'd4 : begin 
                    data_1    = data_out_a[31:24];
			        data_2    = data_r1;
			        data_3    = data_r3;
			        data_4    = data_r6;
			        weight_1  = data_out_b[31:24];
			        weight_2  = weight_w1;
			        weight_3  = weight_w3;
			        weight_4  = weight_w6;
			        wr_en_a   = 1'b0;
			        wr_en_b   = 1'b0;
			        wr_en_out = 1'b0;
			        index_a   = 8'd3;
			        index_b   = 8'd3;
			        index_out = 8'd0; 
                end

                5'd5 : begin 
                    data_1    = 8'b0;
			        data_2    = data_r1;
			        data_3    = data_r3;
			        data_4    = data_r6;
			        weight_1  = 8'b0;
			        weight_2  = weight_w1;
			        weight_3  = weight_w3;
			        weight_4  = weight_w6;
			        wr_en_a   = 1'b0;
			        wr_en_b   = 1'b0;
			        wr_en_out = 1'b0;
			        index_a   = 8'd0;
			        index_b   = 8'd0;
			        index_out = 8'd0;
                end

                5'd6 : begin 
                    data_1    = 8'b0;
			        data_2    = 8'b0;
			        data_3    = data_r3;
			        data_4    = data_r6;
			        weight_1  = 8'b0;
			        weight_2  = 8'b0;
			        weight_3  = weight_w3;
			        weight_4  = weight_w6;
			        wr_en_a   = 1'b0;
			        wr_en_b   = 1'b0;
			        wr_en_out = 1'b0;
			        index_a   = 8'd0;
			        index_b   = 8'd0;
			        index_out = 8'd0;
                end 

                5'd7 : begin 
                    data_1    = 8'b0;
			        data_2    = 8'b0;
			        data_3    = 8'b0;
			        data_4    = data_r6;
			        weight_1  = 8'b0;
			        weight_2  = 8'b0;
			        weight_3  = 8'b0;
			        weight_4  = weight_w6;
			        wr_en_a   = 1'b0;
			        wr_en_b   = 1'b0;
			        wr_en_out = 1'b0;
			        index_a   = 8'd0;
			        index_b   = 8'd0;
			        index_out = 8'd0;
                end

                default : begin 
                    data_1    = 8'd0;//data_out_a[31:24];
			        data_2    = 8'd0;//data_r1;
			        data_3    = 8'd0;//data_r3;
			        data_4    = 8'd0;//data_r6;
			        weight_1  = 8'd0;//data_out_b[31:24];
			        weight_2  = 8'd0;//weight_w1;
			        weight_3  = 8'd0;//weight_w3;
			        weight_4  = 8'd0;//weight_w6;
			        wr_en_a   = 1'b1;
			        wr_en_b   = 1'b1;
			        wr_en_out = 1'b0;
			        index_a   = 8'd255;
			        index_b   = 8'd255;
			        index_out = 8'd0;
                end

                endcase
        end
    end
end

always @ (*) begin 
    if((k==9) && (start ==1'b1)) begin 
        case (counter)
            5'd13 : begin 
                wr_en_out = 1'b1;
		        index_out = 8'd0;
		        data_in_o = data_out_0;
            end

            5'd14 : begin 
                wr_en_out = 1'b1;
		        index_out = 8'd1;
		        data_in_o = data_out_1;
            end

            5'd15 : begin 
                wr_en_out = 1'b1;
		        index_out = 8'd2;
		        data_in_o = data_out_2;
            end

            5'd16 : begin 
                wr_en_out = 1'b1;
		        index_out = 8'd3;
		        data_in_o = data_out_3;
            end

            default : begin 
                wr_en_out = 1'b0;
		        data_in_o = 32'b0;
            end

            endcase
    
    end else begin 
        if(start==1'b1) begin 
            case (counter)
                5'd8 : begin 
                    wr_en_out = 1'b1;
		            index_out = 8'd0;
		            data_in_o = data_out_0;
                end

                5'd9 : begin 
                    wr_en_out = 1'b1;
		            index_out = 8'd1;
		            data_in_o = data_out_1;
                end

                5'd10 : begin 
                    wr_en_out = 1'b1;
		            index_out = 8'd2;
		            data_in_o = data_out_2;
                end

                5'd11 : begin 
                    wr_en_out = 1'b1;
		            index_out = 8'd3;
		            data_in_o = data_out_3;
                end

                default : begin 
                    wr_en_out = 1'b0;
		            data_in_o = 32'b0;
                end
                
                endcase

        end
    end
end

/*connected pe module*/
//row1
pe pe11(.clk            (clk),
	    .rst            (rst),
        .done           (done),
		.data_in        (data_1),
		.weight_in      (weight_1),
		.data_out       (p11d),
		.weight_out     (p11w),
		.pe_out         (p11o));

pe pe12(.clk            (clk),
	    .rst            (rst),
        .done           (done),
		.data_in        (p11d),
		.weight_in      (weight_2),
		.data_out       (p12d),
		.weight_out     (p12w),
		.pe_out         (p12o));

pe pe13(.clk            (clk),
	    .rst            (rst),
        .done           (done),
		.data_in        (p12d),
		.weight_in      (weight_3),
		.data_out       (p13d),
		.weight_out     (p13w),
		.pe_out         (p13o));

pe pe14(.clk            (clk),
	    .rst            (rst),
        .done           (done),
		.data_in        (p13d),
		.weight_in      (weight_4),
		.data_out       (p14d),
		.weight_out     (p14w),
		.pe_out         (p14o));

//row2
pe pe21(.clk            (clk),
	    .rst            (rst),
        .done           (done),
		.data_in        (data_2),
		.weight_in      (p11w),
		.data_out       (p21d),
		.weight_out     (p21w),
		.pe_out         (p21o));

pe pe22(.clk            (clk),
	    .rst            (rst),
        .done           (done),
		.data_in        (p21d),
		.weight_in      (p12w),
		.data_out       (p22d),
		.weight_out     (p22w),
		.pe_out         (p22o));


pe pe23(.clk            (clk),
	    .rst            (rst),
        .done           (done),
		.data_in        (p22d),
		.weight_in      (p13w),
		.data_out       (p23d),
		.weight_out     (p23w),
		.pe_out         (p23o));

pe pe24(.clk            (clk),
	    .rst            (rst),
        .done           (done),
		.data_in        (p23d),
		.weight_in      (p14w),
		.data_out       (p24d),
		.weight_out     (p24w),
		.pe_out         (p24o));

//row3
pe pe31(.clk            (clk),
	    .rst            (rst),
        .done           (done),
		.data_in        (data_3),
		.weight_in      (p21w),
		.data_out       (p31d),
		.weight_out     (p31w),
		.pe_out         (p31o));
        
pe pe32(.clk            (clk),
	    .rst            (rst),
        .done           (done),
		.data_in        (p31d),
		.weight_in      (p22w),
		.data_out       (p32d),
		.weight_out     (p32w),
		.pe_out         (p32o));

pe pe33(.clk            (clk),
	    .rst            (rst),
        .done           (done),
		.data_in        (p32d),
		.weight_in      (p23w),
		.data_out       (p33d),
		.weight_out     (p33w),
		.pe_out         (p33o));

pe pe34(.clk            (clk),
	    .rst            (rst),
        .done           (done),
		.data_in        (p33d),
		.weight_in      (p24w),
		.data_out       (p34d),
		.weight_out     (p34w),
		.pe_out         (p34o));

//row4
pe pe41(.clk            (clk),
	    .rst            (rst),
        .done           (done),
		.data_in        (data_4),
		.weight_in      (p31w),
		.data_out       (p41d),
		.weight_out     (p41w),
		.pe_out         (p41o));

pe pe42(.clk            (clk),
	    .rst            (rst),
        .done           (done),
		.data_in        (p41d),
		.weight_in      (p32w),
		.data_out       (p42d),
		.weight_out     (p42w),
		.pe_out         (p42o));

pe pe43(.clk            (clk),
	    .rst            (rst),
        .done           (done),
		.data_in        (p42d),
		.weight_in      (p33w),
		.data_out       (p43d),
		.weight_out     (p43w),
		.pe_out         (p43o));

pe pe44(.clk            (clk),
	    .rst            (rst),
        .done           (done),
		.data_in        (p43d),
		.weight_in      (p34w),
		.data_out       (p44d),
		.weight_out     (p44w),
		.pe_out         (p44o));

endmodule
