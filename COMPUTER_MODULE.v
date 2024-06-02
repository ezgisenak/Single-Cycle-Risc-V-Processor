module COMPUTER_MODULE(
	input clk, reset,
	input [3:0] debug_reg_select,
	output [31:0] debug_reg_out, PC
);

// Wires from/to the controller.
wire w_PCSrcW, w_RegSrcW, w_RegWriteW, w_MemWriteM, w_BranchTakenE, w_MemtoRegE, w_MemtoRegW, w_CO, w_OVF, w_N, w_Z, w_ShifterMuxesE, w_RegWriteM;
wire w_PCSrcD, w_PCSrcE, w_PCSrcM;
wire [1:0] w_RegSrcD, w_ImmSrcD, w_ALUSrcE;
wire [3:0] w_ALUControlE;

// Wires from/to the hazard unit.
wire w_StallF, w_StallD, w_FlushD, w_FlushE;
wire [1:0] w_ForwardAE, w_ForwardBE;
wire [3:0] w_RA1D, w_RA2D, w_WA3M, w_WA3W, w_WA3E;

wire [31:0] w_InstrD, w_RD1E, w_RD2E;


datapath		pp_datapath(.clk(clk), .reset(reset), 
								// Input signals from the controller.
								.PCSrcW(w_PCSrcW), .RegSrcW(w_RegSrcW), .RegWriteW(w_RegWriteW), .MemWriteM(w_MemWriteM), 			// 1-bit 
								.BranchTakenE(w_BranchTakenE), .ShifterMuxesE(w_ShifterMuxesE), .MemtoRegW(w_MemtoRegW), 
								.RegSrcD(w_RegSrcD), .ImmSrcD(w_ImmSrcD), .ALUSrcE(w_ALUSrcE), 												// 2-bit 
								.Debug_Source_select(debug_reg_select), .ALUControlE(w_ALUControlE),											// 4-bit 
								// Input signals from the hazard unit.
								.StallF(w_StallF), .StallD(w_StallD), .FlushD(w_FlushD), .FlushE(w_FlushE),								// 1-bit
								.ForwardAE(w_ForwardAE), .ForwardBE(w_ForwardBE),																	// 2-bit 
								// Outputs for the hazard unit
								.RD1E(w_RD1E), .RD2E(w_RD2E), .WA3M(w_WA3M), .WA3W(w_WA3W), .RA1D(w_RA1D), .RA2D(w_RA2D), .WA3E(w_WA3E),
								// Outputs from the datapath.
								.CO(w_CO), .OVF(w_OVF), .N(w_N), .Z(w_Z),																				// 1-bit
								.Debug_out(debug_reg_out), .InstrD(w_InstrD), .PCF(PC)); 														// 32-bit
													

controller 	pp_controller(	.clk(clk), .Z(w_Z), .reset(reset),
									// Output signals from the controller to the datapath.
									.PCSrcW(w_PCSrcW), .RegSrcW(w_RegSrcW), .RegWriteW(w_RegWriteW), .MemWriteM(w_MemWriteM), 		// 1-bit 
									.BranchTakenE(w_BranchTakenE), .ShifterMuxesE(w_ShifterMuxesE), .MemtoRegW(w_MemtoRegW), 
									.RegSrcD(w_RegSrcD), .ImmSrcD(w_ImmSrcD), .ALUSrcE(w_ALUSrcE), 											// 2-bit 
									.ALUControlE(w_ALUControlE),										// 4-bit 
									// Ouput signals from the controller to the hazard unit.
									.RegWriteM(w_RegWriteM), .MemtoRegE(w_MemtoRegE), .PCSrcD(w_PCSrcD), .PCSrcE(w_PCSrcE), .PCSrcM(w_PCSrcM), 
									// Input signal from the datapath.
									.InstrD(w_InstrD),
									// Input signal from the hazard unit.
									.FlushE(w_FlushE));
									
									
hazard_unit pp_hu (	.RegWriteM(w_RegWriteM), .RegWriteW(w_RegWriteW), .MemtoRegE(w_MemtoRegE), .reset(reset),		// inputs
							.RD1E(w_RD1E), .RD2E(w_RD2E), .WA3M(w_WA3M), .WA3W(w_WA3W), .RA1D(w_RA1D), .RA2D(w_RA2D), .WA3E(w_WA3E),
							.PCSrcD(w_PCSrcD), .PCSrcE(w_PCSrcE), .PCSrcM(w_PCSrcM), .PCSrcW(w_PCSrcW), .BranchTakenE(w_BranchTakenE), 
							.StallF(w_StallF), .StallD(w_StallD), .FlushD(w_FlushD), .FlushE(w_FlushE), 						// outputs
							.ForwardAE(w_ForwardAE), .ForwardBE(w_ForwardBE));						
							
endmodule
