module GoalPostNormal_palette (
	input logic [1:0] index,
	output logic [3:0] red, green, blue
);

localparam [0:3][11:0] palette = {
	{4'hF, 4'h6, 4'hE},
	{4'hD, 4'hD, 4'hD},
	{4'hB, 4'hB, 4'hB},
	{4'hF, 4'h7, 4'hE}
};

assign {red, green, blue} = palette[index];

endmodule
