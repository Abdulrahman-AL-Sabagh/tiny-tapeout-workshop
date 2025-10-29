`include "rgb.v"
module matrix(
    input   clk,
    input [2:0] col,
    output reg ready,
    output reg led
    
);
reg is_gameover;
reg [1:0] game_state;
reg slot_inserted;
reg player;
reg [23:0] board [41:0];
reg is_valid;
reg[23:0] color; 
initial begin
    slot_inserted = 0;
    game_state = 0;
    player = 0;
    is_valid = 1'b1;
    color = 24'hFF0000;
end; 
genvar r;
genvar c;
integer row;
integer column;
generate
    
for( r = 0; r < 6; r = r+1)
    for ( c = 0; c < 7; c = c + 1)
        ws2812b rgb(
            .clk20(clk),
            .reset(1'b0),
            .data_in(board[r*7+c]),
            .valid(is_valid),
            .latch(1'b1)
        );
endgenerate

always @(posedge clk) begin
if (player == 0) begin
    color <= 24'hFF0000;
end else begin
    color <= 24'h0000FF;

end
for (row = 0; row < 6 && slot_inserted; row = row + 1) 
    if (board[row][col] != 0) 
        board[row  * 7  + col] = color;
        player = ~player;
        slot_inserted <= 1'b1;
        is_valid <= ~is_valid;    

// GAME OVER CHECKS
for (row = 0; row < 6 && ~is_gameover; row = row + 1 ) 
    for (column = 0; column < 7 && ~is_gameover; column = column + 1 ) 
        // VERTICAL CHECK
        if (row < 3) begin
            is_gameover <= (
                    board[row * 7 + column] == color &&
                    board[(row + 1) * 7 + column] == color &&
                    board[(row + 2) * 7 + column] == color &&
                    board[(row + 3) * 7 + column] == color 
                );
        // HORIZONTAL CHECKS

        end else if (column < 4) begin
          is_gameover <=  (
                    board[row * 7 + column] == color &&
                    board[row * 7 + column + 1] == color &&
                    board[row * 7 + column + 2] == color &&
                    board[row * 7 + column + 3] == color 
                );
         

        // RIGHT_DIAGONAL CHECKS
        end else if (row < 3 && column < 4 ) begin
            is_gameover <= (
                    board[row * 7 + column] == color &&
                    board[(row+1) * 7 + column + 1] == color &&
                    board[(row+2) * 7 + column + 2] == color &&
                    board[(row+3) * 7 + column + 3] == color 
                );
        end else if ( 6 - row >= 2 && 7 - col >= 3 ) begin
            is_gameover  <= (
                    board[row * 7 + column] == color &&
                    board[(row-1) * 7 + column + 1] == color &&
                    board[(row-2 )* 7 + column + 2] == color &&
                    board[(row-3) * 7 + column  + 3] == color 
                );
        end

        
     
        
end


endmodule
