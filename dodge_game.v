module dodge_game(
	input clk,
	input [3:0] keys_in,
	input reset,
	output vga_h_sync,
	output vga_v_sync, 
	output reg [3:0] vga_R, 
	output reg [3:0] vga_G, 
	output reg [3:0] vga_B,
	output [6:0] hex_0,
	output [6:0] hex_1,
	output [6:0] hex_2,
	output [6:0] hex_3
);

parameter RIGHT = 0;
parameter UP = 1;
parameter DOWN = 2;
parameter LEFT = 3;
parameter X_MIN = 20;
parameter X_MAX = 600;
parameter Y_MIN = 20;
parameter Y_MAX = 400;

wire inDisplayArea;
wire [9:0] x;
wire [8:0] y;

wire sur_x;
wire sur_y;

assign sur_x = x > X_MIN-1 && x < X_MAX+1;
assign sur_y = y > Y_MIN-1 && y < Y_MAX+1;

hvsync_generator syncgen(
	.clk(clk), 
	.vga_h_sync(vga_h_sync), 
	.vga_v_sync(vga_v_sync),
   .inDisplayArea(inDisplayArea), 
	.CounterX(x), 
	.CounterY(y)
);

wire do_draw_red;
wire hit_player;

bullets bs( 
	.x(x),
	.y(y),
	.player_x(player_x),
	.player_y(player_y),
	.clk(clk),
	.reset(reset),
	.do_draw(do_draw_red),
	.hit_player(hit_player)
);

score_disp disp(
	.score(score_ctr),
	.hex_0(hex_0),
	.hex_1(hex_1),
	.hex_2(hex_2),
	.hex_3(hex_3)
);

reg [9:0] player_x;
reg [9:0] player_y;
reg [15:0] mov_ctr;
reg game_over;
wire R,G,B;

assign R = do_draw_red;
assign G = (x > player_x - 5) && (x < player_x + 10 - 5) && (y > player_y - 5) && (y < player_y + 10 - 5);
assign B = (x == X_MIN && y > Y_MIN && y < Y_MAX) || (x == X_MAX && y > Y_MIN && y < Y_MAX) ||
				(y == Y_MIN && x > X_MIN && x < X_MAX) || (y == Y_MAX && x > X_MIN && x < X_MAX);
				
reg [12:0] score_ctr;
reg [7:0] score_delay_ctr;

always @(posedge clk) begin
	if (reset == 1) begin
		game_over <= 0;
		player_x <= X_MAX/2 + X_MIN;
		player_y <= Y_MAX/2 + Y_MIN;
		score_ctr = 0;

	end else begin
		if (hit_player == 1) begin
			game_over <= 1;
		end
	end

	mov_ctr = mov_ctr + 1;
	if (mov_ctr == 0) begin
		score_delay_ctr = score_delay_ctr + 1;
		if (score_delay_ctr % 64 == 0) begin
			if (game_over == 0 && reset == 0) begin
				score_ctr = score_ctr + 1;
			end
		end
	
		if (keys_in[RIGHT] == 0) begin
			player_x <= player_x + 1;
		end
		if (keys_in[LEFT] == 0) begin
			player_x <= player_x - 1;
		end
		if (keys_in[UP] == 0) begin
			player_y <= player_y - 1;
		end
		if (keys_in[DOWN] == 0) begin
			player_y <= player_y + 1;
		end
	end
	
	if (player_x > X_MAX) begin
		player_x <= X_MIN;
	end
	if (player_x < X_MIN) begin
		player_x <= X_MAX;
	end
	if (player_y > Y_MAX) begin
		player_y <= Y_MIN;
	end
	if (player_y < Y_MIN) begin
		player_y <= Y_MAX;
	end

	vga_R[0] <= R & sur_x & sur_y;
	vga_R[1] <= R & sur_x & sur_y;
	vga_R[2] <= R & sur_x & sur_y;
	vga_R[3] <= R & sur_x & sur_y;
  
	vga_G[0] <= G & sur_x & sur_y & ~game_over;
	vga_G[1] <= G & sur_x & sur_y & ~game_over;
	vga_G[2] <= G & sur_x & sur_y & ~game_over;
	vga_G[3] <= G & sur_x & sur_y & ~game_over;
  
	vga_B[0] <= B & sur_x & sur_y;
	vga_B[1] <= B & sur_x & sur_y;
	vga_B[2] <= B & sur_x & sur_y;
	vga_B[3] <= B & sur_x & sur_y;
end

endmodule