module bullets(
	input [9:0] x,
	input [8:0] y,
	input [9:0] player_x,
	input [9:0] player_y,
	input clk,
	input reset,
	output reg do_draw,
	output reg hit_player
);

parameter X_MIN = 20;
parameter X_MAX = 600;
parameter Y_MIN = 20;
parameter Y_MAX = 400;
parameter NUM_BULLETS = 6;
parameter BULLETS_RESET_DIST = 95;

reg [9:0] bullets_x[NUM_BULLETS-1:0];
reg [9:0] bullets_y[NUM_BULLETS-1:0];
reg [7:0] bullets_size[NUM_BULLETS-1:0];
reg [7:0] bullets_vel_x[NUM_BULLETS-1:0];
reg [7:0] bullets_vel_y[NUM_BULLETS-1:0];
reg bullets_do_reset[NUM_BULLETS-1:0]; //active low

reg [18:0] mov_ctr;
reg [7:0] rand_ctr;

reg [3:0] i;
reg found;
reg do_hit_player;

always @(posedge clk) begin
	mov_ctr <= mov_ctr + 1;
	if (mov_ctr == 0) begin
		rand_ctr = rand_ctr + 1;
		for (i = 0; i < NUM_BULLETS; i = i + 1) begin
			bullets_x[i] <= bullets_x[i] + bullets_vel_x[i];
			bullets_y[i] <= bullets_y[i] + bullets_vel_y[i];
			if (bullets_x[i] > X_MAX) begin
				bullets_x[i] <= X_MIN;
				bullets_do_reset[i] <= 0;
			end
			if (bullets_x[i] < X_MIN) begin
				bullets_x[i] <= X_MAX;
				bullets_do_reset[i] <= 0;
			end
			if (bullets_y[i] > Y_MAX) begin
				bullets_y[i] <= Y_MIN;
				bullets_do_reset[i] <= 0;
			end
			if (bullets_y[i] < Y_MIN) begin
				bullets_y[i] <= Y_MAX;
				bullets_do_reset[i] <= 0;
			end
			if (reset == 1) begin
				bullets_x[i] <= i*BULLETS_RESET_DIST + 5;
				bullets_y[i] <= Y_MIN + 5;
				bullets_do_reset[i] <= 0;
			end
			if (bullets_do_reset[i] == 0) begin
				bullets_size[i] <= ((rand_ctr%70)+10);
				bullets_vel_x[i] <= ((rand_ctr^(i*21))%7);
				bullets_vel_y[i] <= ((~rand_ctr^(i*35))%7);
				bullets_do_reset[i] <= 1;
			end
			if (bullets_vel_x[i] == 0 && bullets_vel_y[i] == 0) begin
				bullets_do_reset[i] <= 0;
			end
		end
	end
	
	found <= 0;
	do_hit_player <= 0;
	for (i = 0; i < NUM_BULLETS; i = i + 1) begin
		if ((x > bullets_x[i] ) && 
			 (x < bullets_x[i] + bullets_size[i] ) && 
			 (y > bullets_y[i] ) &&
			 (y < bullets_y[i] + bullets_size[i])) begin
			found <= 1;
		end
		
		if (player_x > bullets_x[i] && player_x < bullets_x[i] + bullets_size[i] &&
			 player_y > bullets_y[i] && player_y < bullets_y[i] + bullets_size[i]) begin
			do_hit_player <= 1; 
		end
	end
	do_draw <= found;
	hit_player <= do_hit_player;
end


endmodule