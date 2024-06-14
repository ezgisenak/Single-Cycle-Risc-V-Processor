module datapath (
	//Pyhsical i/o signals.
	input clk, reset, 
	input [4:0] Debug_Source_select,
	output wire [31:0] Debug_out, PC,
	
	// input signals coming from the controller	
	input RegWrite, MemWrite, ALUSrc, ImmSelect, ShamtSelect,
	input [1:0] ImmSrc, ShiftControl, PCSrc,
	input [2:0] ResultSrc, MemControl,
	input [3:0] ALUControl, 
	input [19:0] Imm,
	
	// output signals going to the controller
	output wire CO, OVF, N, Z,	
	output wire [31:0] Instr
);

// Wires
wire [31:0] PCPlus4, PCTarget, PCNext, ALUResult, Result, SrcA, WriteData, ImmExt, ShifterOut, SrcB, ReadData, PCTargetInput;
wire [4:0] shamt;
// Modules
Mux_4to1 #(.WIDTH(32)) pc_mux(
	.select(PCSrc), 
	.input_0(PCPlus4), 
	.input_1(PCTarget), 
	.input_2({ALUResult[31:1], 1'b0}), 
	.input_3(32'b0), 
	.output_value(PCNext)
);
													 
Register_reset	#(.WIDTH(32)) reg_PC(
	.clk(clk),
	.reset(reset), 
	.DATA(PCNext), 
	.OUT(PC)
);

Inst_Memory inst_mem(
	.ADDR(PC), 
	.RD(Instr)
);

Adder pc_adder_4(
	.DATA_A(PC), 
	.DATA_B(32'b0100), 
	.OUT(PCPlus4)
);

Register_file reg_file(
	.clk(clk), 
	.write_enable(RegWrite), 
	.reset(reset),
	.Source_select_0(Instr[19:15]), 
	.Source_select_1(Instr[24:20]), 
	.Destination_select(Instr[11:7]),	
	.DATA(Result), 
	.out_0(SrcA), 
	.out_1(WriteData), 				
	.Debug_out(Debug_out), 
	.Debug_Source_select(Debug_Source_select)
);	
							
Extender extender(
	.select(ImmSrc), 
	.DATA(Imm),
	.Extended_data(ImmExt)
);

Mux_2to1  #(.WIDTH(5)) mux_shamt(
	.select(ShamtSelect), 
	.input_0(ImmExt[4:0]), 
	.input_1(WriteData[4:0]), 
	.output_value(shamt)
);

shifter srcAShifter(
	.control(ShiftControl), 
	.shamt(shamt), 
	.DATA(SrcA), 
	.OUT(ShifterOut)
);

Mux_2to1  #(.WIDTH(32)) mux_srcB(
	.select(ALUSrc), 
	.input_0(WriteData), 
	.input_1(ImmExt), 
	.output_value(SrcB)
);

ALU alu(
	.DATA_A(SrcA), 
	.DATA_B(SrcB), 
	.OUT(ALUResult), 
	.control(ALUControl), 
	.CI(1'b0), 
	.CO(CO), 
	.OVF(OVF), 
	.N(N), 
	.Z(Z)
);

Mux_2to1 #(.WIDTH(32)) mux_PCTarget(
	.select(ImmSelect), 
	.input_0(ImmExt[31:0]), 
	.input_1({ImmExt[19:0],12'b0}), 
	.output_value(PCTargetInput)
);

Adder pc_adder_imm(
	.DATA_A(PC),
	.DATA_B(PCTargetInput), 
	.OUT(PCTarget)
);

// TODO: Memory ADDR_WIDTH 32 mi olacak 8 mi? Su anki hali 32 bit.
Memory data_mem(
	.clk(clk), 
	.WE(MemWrite), 
	.ADDR(ALUResult), 
	.WD(WriteData), 
	.RD(ReadData),
	.MemControl(MemControl)
);

Mux_8to1 rslt_mux(
	.select(ResultSrc), 
	.input_0(ALUResult), 
	.input_1(ReadData),
	.input_2(ShifterOut), 
	.input_3({{31{1'b0}}, N}), 
	.input_4(PCPlus4), 
	.input_5(PCTarget),
	.input_6(PCTargetInput), 
	.input_7(32'b0), 
	.output_value(Result)
);

endmodule
