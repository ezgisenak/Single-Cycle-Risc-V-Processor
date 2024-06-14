module COMPUTER_MODULE(
	input clk, reset,
	input [4:0] debug_reg_select,
	output [31:0] debug_reg_out, PC
);

wire RegWrite, MemWrite, ALUSrc, ImmSelect, CO, OVF, N, Z;
wire [1:0] ImmSrc, ShiftControl, PCSrc;
wire [2:0] ResultSrc, MemControl;
wire [3:0] ALUControl;
wire ShamtSelect;
wire [19:0] Imm;
wire [31:0] Instr;

datapath		my_datapath(
	.clk(clk),
	.reset(reset),
	.Debug_Source_select(debug_reg_select),
	.Debug_out(debug_reg_out),
	.PC(PC),
	.RegWrite(RegWrite),
	.MemWrite(MemWrite),
	.ALUSrc(ALUSrc),
	.ImmSelect(ImmSelect),
	.ImmSrc(ImmSrc),
	.ShiftControl(ShiftControl),
	.PCSrc(PCSrc),
	.ResultSrc(ResultSrc),
	.MemControl(MemControl),
	.ALUControl(ALUControl),
	.Imm(Imm),
	.CO(CO),
	.OVF(OVF),
	.N(N),
	.Z(Z),
	.Instr(Instr),
	.ShamtSelect(ShamtSelect)
); 															

controller 	my_controller(	
	.clk(clk), 
	.Z(Z), 
	.N(N),
	.reset(reset),
	.Instr(Instr),
	.RegWrite(RegWrite),
	.MemWrite(MemWrite),
	.ALUSrc(ALUSrc),
	.ImmSelect(ImmSelect),
	.ImmSrc(ImmSrc),
	.ShiftControl(ShiftControl),
	.PCSrc(PCSrc),
	.ResultSrc(ResultSrc),
	.MemControl(MemControl),
	.ALUControl(ALUControl),
	.Imm(Imm),
	.ShamtSelect(ShamtSelect)
);
									
endmodule
