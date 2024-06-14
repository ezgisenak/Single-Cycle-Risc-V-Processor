module hazard_unit (
	input reset, RegWriteM, RegWriteW, MemtoRegE, PCSrcD, PCSrcE, PCSrcM, PCSrcW, BranchTakenE,
	input [3:0] RA1D, RA2D, WA3E, WA3M, WA3W, 
	input [31:0] RD1E, RD2E, 
	output wire StallF, StallD, FlushD, FlushE,
	output reg [1:0] ForwardAE, ForwardBE
);

wire Match_1E_M, Match_2E_M, Match_1E_W, Match_2E_W, Match_12D_E, LDRStall, PCWrPendingF;

assign Match_1E_M = (RD1E == WA3M);
assign Match_1E_W = (RD1E == WA3W);
assign Match_2E_M = (RD2E == WA3M);
assign Match_2E_W = (RD2E == WA3W);

always @* begin
    if (Match_1E_M && RegWriteM) begin
        ForwardAE = 2'b10; // SrcAE = ALUOutM
    end else if (Match_1E_W && RegWriteW) begin
        ForwardAE = 2'b01; // SrcAE = ResultW
    end else begin
        ForwardAE = 2'b00; // SrcAE from regfile
    end

    if (Match_2E_M && RegWriteM) begin
        ForwardBE = 2'b10; // SrcBE = ALUOutM
    end else if (Match_2E_W && RegWriteW) begin
        ForwardBE = 2'b01; // SrcBE = ResultW
    end else begin
        ForwardBE = 2'b00; // SrcBE from regfile
    end
end

assign Match_12D_E = (RA1D == WA3E) || (RA2D && WA3E);
assign LDRStall = (Match_12D_E && MemtoRegE);

assign PCWrPendingF = PCSrcD || PCSrcE || PCSrcM;
assign StallF = LDRStall || PCWrPendingF;
assign StallD = LDRStall;
assign FlushD = PCWrPendingF || PCSrcW || BranchTakenE || reset;
assign FlushE = LDRStall || BranchTakenE || reset;


endmodule
