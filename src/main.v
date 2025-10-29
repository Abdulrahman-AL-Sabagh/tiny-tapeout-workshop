
/*
A clock divider in Verilog, using the cascading
flip-flop method.
*/

module fourConnect(
  	
	input clk,
  input [7:0] pins,
  	output [2:0] row,
  	output [2:0] col,
  output [1:0] final_state
);
  
  
  reg [1:0]player_state = 2'b_01;
  reg row_stored = 0;
  reg [2:0]row_index = 0;
  reg [2:0]col_index = 0;
  reg [1:0] board [7:0][7:0];
  reg row_updated = 0;
  reg [1:0]state = 2'b00;

  
  always @(posedge clk) begin
    if (row_index == 0) begin
  
    case(pins)
      8'b_0000000: row_index <= 1;
      8'b_0000001: row_index <= 2;
      8'b_0000010: row_index <= 3;
      8'b_0000100: row_index <= 4;
      8'b_0001000: row_index <= 5;
      8'b_0010000: row_index <= 6;
      default:
        row_index <= 0;
    	endcase 
    end
    	row_updated <= !row_updated;
    	col_index <= 0;
    if (row_updated == 1 ) begin
      case(pins)
      8'b_0000000: col_index <= 1;
      8'b_0000001: col_index <= 2;
      8'b_0000010: col_index <= 3;
      8'b_0000100: col_index <= 4;
      8'b_0001000: col_index <= 5;
      8'b_0010000: col_index <= 6;
      8'b_0100000: col_index <= 7;
         default:
           col_index <= 0;
     endcase
    
       end

    if (col_index != 0 && row_index != 0) begin
    
    if (board[row_index][col_index] == 2'b_00 ) begin 
      board[row_index][col_index] <= player_state;
	player_state <= player_state ^ 2'b_11;
      	row <=  row_index;
    	col <=  col_index; 
      	row_index <= 0;
      	col_index <= 0;
      	row_updated <= 0;
    end
      final_state <= state;    
    end
    
    
  
       
   
  end
 
  
      
 endmodule
 
  
