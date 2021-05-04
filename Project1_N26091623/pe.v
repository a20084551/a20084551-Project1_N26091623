`include "define.v"

module pe(
    input clk,
    input rst,
    input done,
    input [`DATA_SIZE-1:0] data_in,
    input [`DATA_SIZE-1:0] weight_in,

    output reg [`DATA_SIZE-1:0] data_out,
    output reg [`DATA_SIZE-1:0] weight_out,
    output [`DATA_SIZE-1:0] pe_out
);

wire [`DATA_SIZE*2-1:0] product;
reg [`DATA_SIZE-1:0] add_reg;

assign product = data_in * weight_in;
assign pe_out = product[`DATA_SIZE-1:0] + add_reg; //only allow 8-bit result output

always @ (posedge clk) begin 
    if(rst) begin 
        data_out <= 8'b0;
        weight_out <= 8'b0;
        add_reg <= 8'b0;
    end else begin 
        if(done) begin 
            data_out <= 8'b0;
            weight_out <= 8'b0;
            add_reg <= 8'b0;
        end else begin 
            data_out <= data_in;
            weight_out <= weight_in;
            add_reg <= pe_out;
        end
    end
end

endmodule


