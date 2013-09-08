module score_disp(
	input [12:0] score,
	output [6:0] hex_0,
	output [6:0] hex_1,
	output [6:0] hex_2,
	output [6:0] hex_3
);

seg7 h0(score%10,hex_0);
seg7 h1(score/10%10,hex_1);
seg7 h2(score/100%10,hex_2);
seg7 h3(score/1000%10,hex_3);

endmodule