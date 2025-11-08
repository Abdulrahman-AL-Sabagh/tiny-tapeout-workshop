// `include "matrix.v"

`default_nettype none
module fourConnect(
	//input reset,
	//	input reset,
	input clk_in,
	input [6:0] buttons,
	output ws_data
);
reg reset = 1;
//reg [6:0]col_index ;
//reg [6:0] buttons_prev;
//reg       start_move;
//reg is_gameover;
//reg [1:0] game_state;
//reg slot_inserted;
//reg player;
reg [23:0] board [0:64-1];
//reg[23:0] color; 
//reg [7:0] inserted_at; 
reg[7:0] led_num = 'bx;
reg write = 0;
reg[23:0] color;
//reg[7:0] counter;
//reg[7:0] prev_col;
reg[2:0] col_index;
//wire [6:0] col_select_in;
localparam EMPTY = 24'h000000;
localparam WHITE = 24'hFFFFFF; // white is for slots, that are not allowe 

//integer row;
//integer column;


localparam BOARD_SIZE = 64;
localparam COLS = 8;
localparam ROWS = 8;

localparam YELLOW = 24'hFF0000;
localparam RED = 24'h0000FF;

//reg [1:0] write_state = W_SETUP;
localparam W_IDLE = 2'b11;
localparam W_DROP = 2'b01;
localparam S_DISPLAY = 2'b10;
localparam W_SETUP = 2'b00;
reg [1:0] write_state = W_SETUP;
//localparam SETUP = 3'b000;
//localparam IDLE = 3'b010;
//localparam INSERTING = 3'b011;
//localparam CHECKING = 3'b100;
//localparam GAME_OVER = 3'b101;
//localparam DISPLAY = 3'b110;

//reg [2:0] State = SETUP;

//reg [5:0] setup_counter;
//
//
// wire any_button_pressed = |buttons;
reg [5:0] buttons_prev; 
wire button_press_event = (buttons != 6'b000000) && (buttons_prev == 6'b000000);
integer row;
reg [7:0] insert_at; 
ws2812 #(.NUM_LEDS(64), .CLK_MHZ(12)) ws2812_inst (
	.rgb_data(color), // Connect external RGB data
	.led_num(led_num),
	.write(write),
	.reset(reset),
	.clk(clk_in),
	.data(ws_data)
);

always @(posedge clk_in) begin
	buttons_prev <= buttons;
	color <= board[led_num];	
	reset <= 0;
	write <= 1'b0;      // Default to not writing
	case (write_state)
		W_SETUP: begin
			if (led_num >= 48 || led_num % 7 == 0  ) begin
				board[led_num] <= WHITE; 
			end else begin
				board[color] <= EMPTY;	
			end	
			led_num <= led_num + 1;
			
			if (led_num >= 64) begin
				led_num <= 0;
				write_state <= S_DISPLAY;
			end

		
		end
		W_IDLE: begin 
		write <= 1'b0;
		if (button_press_event) begin
			write_state <= W_DROP;
			case (buttons)
				7'b0000001: col_index <= 3'd0;
				7'b0000010: col_index <= 3'd1;
				7'b0000100: col_index <= 3'd2;
				7'b0001000: col_index <= 3'd3;
				7'b0010000: col_index <= 3'd4;
				7'b0100000: col_index <= 3'd5;
				7'b1000000: col_index <= 3'd6;
				default: led_num <= led_num;
			endcase
		end
//		if (board[led_num] != EMPTY) begin
//			led_num <= led_num + 8;
//		end else if (board[led_num] == EMPTY) begin
//			board[led_num] <= color;
//		end
	end
	W_DROP: begin
		//TODO: handle dropping in the right index;
		write <= 1'b1;
		write_state <= S_DISPLAY;
	end
	S_DISPLAY: begin	
		write <= 1'b1;
		led_num <= led_num + 1;

		if (led_num >= 63) begin
			led_num <= 0;
		end
		if (button_press_event) begin
		write_state <= W_IDLE;
	end
	end
	default: write_state <= W_SETUP;
	endcase
end	
//loop: for (i = 0 + led_num; i < BOARD_SIZE; i = i + 8) begin 
//               if (board[i] == EMPTY) begin 
//		board[i] <= color;
//		led_num <= i;
//		write <= 1'b1;
//		disable loop;
//	end
//end


//initial begin
//    game_state = 0;
//    player = 0;
//    color = 24'hFF0000;
//    color <= 24'h000000;
//    reset = 0;
//    led_num = 0;
//    counter = 0;
//    write = 0;
//    inserted_at = 'bx;
// for (integer i = 0; i < 42; i = i + 1) begin
//    board[i] = 24'h00_00_00;
// end
// end; 
// genvar r;
// genvar c;




//always @(posedge clk_in) begin
//	prev_col <= col_index;
//	color <= (player == 0) ? 24'hFF0000 : 24'h0000FF;


//	case(State)
//
//		DISPLAY: begin
//			if (led_num < 64) begin
//				color <= board[led_num];
//				write <= 1'b1;
//				led_num <= led_num + 1;
//			end else begin
//				led_num <= 0;
//				write <= 1'b0;
//				State <= CHECKING;
//			end
//		end
//		SETUP: begin
//
//				if (setup_counter == 0 || setup_counter == 7 || setup_counter == 14) begin
//					board[setup_counter] <= 24'h0000FF;
//			end
//			//
//				if (setup_counter % 8 == 0) begin
//						board[setup_counter] <= WHITE;
//					end else begin
//				board[setup_counter] <= EMPTY;
//					end
//					setup_counter <= setup_counter + 1;
//					if (setup_counter >= 63) begin
//						State <= DISPLAY;
//					end
//			State <= IDLE;
//		end
//		INSERTING: begin
//			if (col_index >= BOARD_SIZE) begin
//				State <= IDLE;
//
//			end else if (board[col_index] == EMPTY) begin
//				board[col_index] = color;
//				counter <= counter + 1;
//				State <= CHECKING;
//			end else  begin
//				col_index <= col_index + 8;
//				State <= INSERTING;
//			end 
//		end
//		CHECKING: begin
//			//TODO: CHECK ROWS
//			if (counter == 42) begin
//				State <= GAME_OVER;
//			end
//			State <= DISPLAY;
//		end
//
//		GAME_OVER: begin
//			setup_counter <= 0;
//			counter <= 0;
//			is_gameover <= 1'b0;
//			player <= 1'b0;
//			col_index <= 0;
//			State <= SETUP;
//		end
//
//		
//		IDLE: begin
//			write <= 1'b0;
//			if (col_index != prev_col) begin
//				State <= INSERTING;
//			end 
//		end
//		default: State <= IDLE;
//	endcase
//end

//for (row = 0; row < 6; row = row + 1) 
//    if (board[row * 7 + col] == 24'h00_00_00 && !slot_inserted)  begin
//       slot_inserted <= 1'b1;
//       write <= 1;
//      inserted_at <= row * 7 + col;
//      counter <= counter  + 1;
//      board[inserted_at] <= color;
//     led_num <= inserted_at;
//      color <= color;
//      player <= !player;
//     slot_inserted <= 1'b0;
// end

// GAME OVER CHECKS
//for (row = 0; row < 6; row = row + 1 ) 
//    for (column = 0; column < 7; column = column + 1 ) 
// VERTICAL CHECK
//        if (row < 3) begin
//            is_gameover <= (
//                    board[row * 7 + column] == color &&
//                    board[(row + 1) * 7 + column] == color &&
//                    board[(row + 2) * 7 + column] == color &&
//                   board[(row + 3) * 7 + column] == color 
//             );
// HORIZONTAL CHECKS

//   end else if (column < 4) begin
//   is_gameover <=  (
//           board[row * 7 + column] == color &&
//         board[row * 7 + column + 1] == color &&
//       board[row * 7 + column + 2] == color &&
//     board[row * 7 + column + 3] == color 
// );


// RIGHT_DIAGONAL CHECKS
//  end else if (row < 3 && column < 4 ) begin
//     is_gameover <= (
//            board[row * 7 + column] == color &&
//           board[(row+1) * 7 + column + 1] == color &&
//          board[(row+2) * 7 + column + 2] == color &&
//         board[(row+3) * 7 + column + 3] == color 
//     );
// end else if ( 6 - row >= 2 && 7 - col >= 3 ) begin
//    is_gameover  <= (
//           board[row * 7 + column] == color &&
//          board[(row-1) * 7 + column + 1] == color &&
//         board[(row-2 )* 7 + column + 2] == color &&
//        board[(row-3) * 7 + column  + 3] == color 
//   );
//   end

endmodule




