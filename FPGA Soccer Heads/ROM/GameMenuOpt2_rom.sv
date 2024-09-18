module GameMenuOpt2_rom (
	input logic clock,
	input logic [18:0] address,
	output logic [2:0] q
);

logic [2:0] memory [0:307199] /* synthesis ram_init_file = "./GameMenuOpt2/GameMenuOpt2.COE" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
