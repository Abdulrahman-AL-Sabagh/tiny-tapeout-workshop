`include "matrix.v"

module fourConnect(
	input clk,
	input [6:0] pins,
  output reg [2:0] col
);

  reg [2:0]col_index ;
 
  initial begin
	  col_index = 0;
  end 
  always @(posedge clk) begin
      case(pins)
      8'b0000000: col_index <= 0;
      8'b0000001: col_index <= 1;
      8'b0000010: col_index <= 2;
      8'b0000100: col_index <= 3;
      8'b0001000: col_index <= 4;
      8'b0010000: col_index <= 5;
      8'b0100000: col_index <= 6;
         default:
           col_index <= 0;
     endcase
     col <= col_index;   
  end

  matrix led_matrix(
    .clk(clk),
    .col(col_index)
  );
  
      
 endmodule
 
 
 
  
