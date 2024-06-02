module datapath (
	input clk, reset, 													// input signals coming from the controller
	input PCSrcW, RegSrcW, RegWriteW, MemWriteM,	BranchTakenE, ShifterMuxesE, MemtoRegW,
	input [1:0] RegSrcD, ImmSrcD, ALUSrcE,
	input [3:0] Debug_Source_select, ALUControlE,
	input StallF, StallD, FlushD,	FlushE,							// input signals coming from the hazard unit
	input [1:0] ForwardAE, ForwardBE,
	output CO, OVF, N, Z,												// outputs for the controller
	output [3:0] RA1D, RA2D, WA3M, WA3W, WA3E, RA1E, RA2E,
	output [31:0] Debug_out, InstrD, PCF, 
);

// Wires
wire [1:0]  ShifterControlE;
wire [3:0]  rf_WA3W;
wire [4:0]  ShifterAmountE;
wire [31:0] RD1E, RD2E;
wire [31:0] PCPrime, PCMuxOut, PCPlus4F8D, PCPlus4F, InstrF, 																// Fetch Wires
				PCPlus4D, RD1D, RD2D, ExtImmD,																						// Decode Wires
				ExtImmE, ShifterOutE, SrcAE, SrcBE, ForwardedSrcBE, ALUResultE, PCPlus4E, ShifterDataE, InstrE,	// Execute Wires
				ALUResultM, PCPlus4M, RD2M, ReadDataM,																				// Memory Wires
				PCPlus4W, WD3W, ResultW, ReadDataW, ALUResultW;																	// Writeback Wires

// FETCH // 

Mux_2to1 		#(.WIDTH(32)) pp_mux_pc 	 (.select(PCSrcW), .input_0(PCPlus4F8D), .input_1(ResultW), .output_value(PCMuxOut));
Mux_2to1 		#(.WIDTH(32)) pp_mux_branch (.select(BranchTakenE), .input_0(PCMuxOut), .input_1(ALUResultE), .output_value(PCPrime));
Register_rsten #(.WIDTH(32)) pp_Fetch_Reg  (.clk(clk), .reset(reset), .we(~StallF), .DATA(PCPrime), .OUT(PCF));

Inst_Memory 					  pp_im 			 (.ADDR(PCF), .RD(InstrF));
Adder 							  pp_adder	  	 (.DATA_A(PCF), .DATA_B(32'b100), .OUT(PCPlus4F8D));

// DECODE // 

Register_rsten #(.WIDTH(32)) pp_DecReg_PCPlus4(.clk(clk), .reset(FlushD), .we(~StallD), .DATA(PCPlus4F8D), .OUT(PCPlus4D));
Register_rsten #(.WIDTH(32)) pp_DecReg_Instr  (.clk(clk), .reset(FlushD), .we(~StallD), .DATA(InstrF), .OUT(InstrD));

Mux_2to1 						  pp_mux_RA1D 	 (.select(RegSrcD[0]), .input_0(InstrD[19:16]), .input_1(4'b1111), .output_value(RA1D));
Mux_2to1 						  pp_mux_RA2D 	 (.select(RegSrcD[1]), .input_0(InstrD[3:0]), .input_1(InstrD[15:12]), .output_value(RA2D));
Mux_2to1 						  pp_mux_RA3W 	 (.select(RegSrcW), .input_0(WA3W), .input_1(4'b1110), .output_value(rf_WA3W));
Mux_2to1 		#(.WIDTH(32)) pp_mux_WD3W   (.select(RegSrcW), .input_0(ResultW), .input_1(PCPlus4W), .output_value(WD3W));

Register_file pp_rf (.clk(clk), .write_enable(RegWriteW), .reset(reset),
							.Source_select_0(RA1D), .Source_select_1(RA2D), .Destination_select(rf_WA3W),	
							.DATA(WD3W), .Reg_15(PCPlus4F8D), .out_0(RD1D), .out_1(RD2D), 				
							.Debug_out(Debug_out), .Debug_Source_select(Debug_Source_select));	

Extender pp_ext (.select(ImmSrcD), .DATA(InstrD[23:0]), .Extended_data(ExtImmD));

// EXECUTE // 

Register_reset #(.WIDTH(32)) pp_ExeReg_PCPlus4	(.clk(clk), .reset(FlushE), .DATA(PCPlus4D), .OUT(PCPlus4E));
Register_reset #(.WIDTH(32)) pp_ExeReg_Instr		(.clk(clk), .reset(FlushE), .DATA(InstrD), .OUT(InstrE));
Register_reset #(.WIDTH(32)) pp_ExeReg_RD1D		(.clk(clk), .reset(FlushE), .DATA(RD1D), .OUT(RD1E));
Register_reset #(.WIDTH(32)) pp_ExeReg_RD2D		(.clk(clk), .reset(FlushE), .DATA(RD2D), .OUT(RD2E));
Register_reset #(.WIDTH(4))  pp_ExeReg_WA3D		(.clk(clk), .reset(FlushE), .DATA(InstrD[15:12]), .OUT(WA3E));
Register_reset #(.WIDTH(32)) pp_ExeReg_ExtImm	(.clk(clk), .reset(FlushE), .DATA(ExtImmD), .OUT(ExtImmE));
Register_reset #(.WIDTH(32)) pp_ExeReg_RA1D	(.clk(clk), .reset(FlushE), .DATA(RA1D), .OUT(RA1E));
Register_reset #(.WIDTH(32)) pp_ExeReg_RA2D	(.clk(clk), .reset(FlushE), .DATA(RA2D), .OUT(RA2E));

Mux_4to1 #(.WIDTH(32)) pp_mux_ForwardAE (.select(ForwardAE), .input_0(RD1E), .input_1(ResultW), .input_2(ALUResultM), .input_3(32'b0), .output_value(SrcAE));
Mux_4to1 #(.WIDTH(32)) pp_mux_ForwardBE (.select(ForwardBE), .input_0(RD2E), .input_1(ResultW), .input_2(ALUResultM), .input_3(32'b0), .output_value(ForwardedSrcBE));

// Input_0's are for a register shifted data processing instruction.
// Input_1's are for a MOV immediate operation.
Mux_2to1 #(.WIDTH(2))  pp_mux_shiftctrl (.select(ShifterMuxesE), .input_0(InstrE[6:5]), .input_1(2'b11), .output_value(ShifterControlE));
Mux_2to1 #(.WIDTH(32)) pp_mux_shiftdata (.select(ShifterMuxesE), .input_0(ForwardedSrcBE), .input_1(ExtImmE), .output_value(ShifterDataE));
Mux_2to1 #(.WIDTH(5))  pp_mux_shiftamnt (.select(ShifterMuxesE), .input_0(InstrE[11:7]), .input_1({InstrE[11:8], 1'b0}), .output_value(ShifterAmountE));

shifter  #(.WIDTH(32)) pp_shifter (.control(ShifterControlE), .shamt(ShifterAmountE), .DATA(ShifterDataE), .OUT(ShifterOutE));

Mux_4to1 #(.WIDTH(32)) pp_mux_srcBE (.select(ALUSrcE), .input_0(ForwardedSrcBE), .input_1(ExtImmE), .input_2(ShifterOutE), .input_3(32'b0), .output_value(SrcBE));

ALU 		#(.WIDTH(32)) pp_alu 		(.DATA_A(SrcAE), .DATA_B(SrcBE), .OUT(ALUResultE), .control(ALUControlE), .CI(1'b0), .CO(CO), .OVF(OVF), .N(N), .Z(Z));

// MEMORY // 				

Register_reset #(.WIDTH(32)) pp_MemReg_PCPlus4	 (.clk(clk), .reset(reset), .DATA(PCPlus4E), .OUT(PCPlus4M));
Register_reset #(.WIDTH(32)) pp_MemReg_ALUResult (.clk(clk), .reset(reset), .DATA(ALUResultE), .OUT(ALUResultM));
Register_reset #(.WIDTH(32)) pp_MemReg_WriteData (.clk(clk), .reset(reset), .DATA(ForwardedSrcBE), .OUT(RD2M));
Register_reset #(.WIDTH(4))  pp_MemReg_WA3E		 (.clk(clk), .reset(reset), .DATA(WA3E), .OUT(WA3M));

Memory 	  #(.ADDR_WIDTH(8)) pp_mem (.clk(clk), .WE(MemWriteM), .ADDR(ALUResultM[7:0]), .WD(RD2M), .RD(ReadDataM));

// WRITEBACK // 

Register_reset #(.WIDTH(32)) pp_WBReg_PCPlus4	(.clk(clk), .reset(reset), .DATA(PCPlus4M), .OUT(PCPlus4W));
Register_reset #(.WIDTH(32)) pp_WBReg_ReadData	(.clk(clk), .reset(reset), .DATA(ReadDataM), .OUT(ReadDataW));
Register_reset #(.WIDTH(32)) pp_WBReg_ALUResult (.clk(clk), .reset(reset), .DATA(ALUResultM), .OUT(ALUResultW));
Register_reset #(.WIDTH(4))  pp_WBReg_WA3E		(.clk(clk), .reset(reset), .DATA(WA3M), .OUT(WA3W));

Mux_2to1 #(.WIDTH(32)) PP_mux_rslt (.select(MemtoRegW), .input_0(ALUResultW), .input_1(ReadDataW), .output_value(ResultW));

endmodule
