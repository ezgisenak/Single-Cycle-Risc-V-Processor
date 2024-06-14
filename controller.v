module controller(
	input Z, clk, reset,				 									// input signals coming from the datapath
	input [31:0] InstrD,
	input FlushE,															// input signal coming from the hazard unit
	output wire PCSrcW, RegSrcW, RegWriteW, MemWriteM,	BranchTakenE, ShifterMuxesE, MemtoRegE, MemtoRegW, RegWriteM, PCSrcE, PCSrcM,
	output reg PCSrcD,
	output reg [1:0] RegSrcD, ImmSrcD,
	output wire [1:0] ALUSrcE,
	output wire [3:0] ALUControlE
);

// ESKİLER
wire Flag, CondEx;
assign Flag = FlagWriteE ? Z : FlagsE;

// MNEMONICS
localparam 	ADD=4'b0100,
				SUB=4'b0010,
				AND=4'b0000,
				ORR=4'b1100,
				MOV=4'b1101,
				CMP=4'b1010;
				
// DECODE //
wire [1:0] op;
wire [3:0] cond, rd, condE;
wire [5:0] funct;

assign op = InstrD[27:26];
assign cond = InstrD[31:28];
assign funct = InstrD[25:20];
assign rd = InstrD[15:12];

// Intermediate signals.
reg BranchD, RegWriteD, MemWriteD, MemtoRegD, ShifterMuxesD, FlagWriteD;
reg [1:0] ALUSrcD;
reg [3:0] ALUControlD; 

initial begin
	PCSrcD	  	 	= 1'b0;
	BranchD			= 1'b0;
	RegWriteD  	 	= 1'b0;
	MemWriteD   	= 1'b0;
	MemtoRegD		= 1'b0;
	ShifterMuxesD	= 1'b0;
	ALUControlD		= 4'b0000;
	ALUSrcD    		= 2'b00;
	FlagWriteD  	= 1'b0;
	ImmSrcD    		= 2'b00;
	RegSrcD     	= 2'b00;
end

// Main Decoder		
always@(*) begin
	case (op)
		2'b00: begin
			if (funct == 6'b010010 && rd == 4'b1111) begin
				// Bx Operation
				PCSrcD	  	 	= 1'b0;
				BranchD			= 1'b1;
				RegWriteD  	 	= 1'b0;
				MemWriteD   	= 1'b0;
				MemtoRegD		= 1'b0;
				ShifterMuxesD	= 1'b0;
				ALUControlD		= MOV;
				ALUSrcD    		= 2'b00;
				FlagWriteD  	= 1'b0;
				ImmSrcD    		= 2'b00;
				RegSrcD     	= 2'b00;
			end
			else begin
				// Data-Processing Operations
				RegWriteD   	= (funct[4:1] != CMP); 	// Excluding CMP
				PCSrcD	   	= (&rd) & RegWriteD;		// If R15 is written
				BranchD			= 1'b0;
				MemWriteD   	= 1'b0;
				MemtoRegD		= 1'b0;
				ShifterMuxesD	= funct[5];
				ALUControlD 	= (funct[4:1] == CMP) ? SUB : funct[4:1];
				ALUSrcD    		= 2'b10;
				FlagWriteD		= (funct[4:1] == CMP);
				ImmSrcD    		= 2'b00;
				RegSrcD     	= 2'b00;
			end
		end
		
		2'b01: begin
			// Memory Operations
			PCSrcD	   	= 1'b0;
			BranchD			= 1'b0;
			RegWriteD   	=  funct[0]; // L
			MemWriteD   	= ~funct[0]; // ~L
			MemtoRegD  		=  funct[0]; // L
			ShifterMuxesD	= 1'b0;
			ALUControlD		= funct[3] ? 4'b0100 : 4'b0010; // U ? Addition : Subtraction;
			ALUSrcD     	= 2'b01;
			FlagWriteD  	= 1'b0;
			ImmSrcD     	= 2'b01; 	// 12-bit
			RegSrcD     	= 2'b10; 	// For STR
		end
		
		2'b10: begin
			// Branch Operations
			PCSrcD	  	 	= 1'b0;
			BranchD			= 1'b1;
			RegWriteD  	 	= funct[4]; // L
			MemWriteD   	= 1'b0;
			MemtoRegD		= 1'b0;
			ShifterMuxesD	= 1'b0;
			ALUControlD		= ADD;
			ALUSrcD    		= 2'b01;
			FlagWriteD  	= 1'b0;
			ImmSrcD    		= 2'b10;
			RegSrcD     	= 2'b11;
		end
		
		2'b11: begin
			// Default case
			PCSrcD	  	 	= 1'b0;
			BranchD			= 1'b0;
			RegWriteD  	 	= 1'b0;
			MemWriteD   	= 1'b0;
			MemtoRegD		= 1'b0;
			ShifterMuxesD	= 1'b0;
			ALUControlD		= 4'b0000;
			ALUSrcD    		= 2'b00;
			FlagWriteD  	= 1'b0;
			ImmSrcD    		= 2'b00;
			RegSrcD     	= 2'b00;
		end
	endcase
end

// EXECUTE // 

wire BranchE, FlagsE, RegWriteE, MemWriteE, RegSrcE, PCSrcE_YES, RegWriteE_YES, MemWriteE_YES, FlagWriteE;

Register_reset #(.WIDTH(1)) pp_ExeReg_ShifterMuxes	(.clk(clk), .reset(FlushE), .DATA(ShifterMuxesD), .OUT(ShifterMuxesE));
Register_reset #(.WIDTH(1)) pp_ExeReg_PCSrc			(.clk(clk), .reset(FlushE), .DATA(PCSrcD), .OUT(PCSrcE));
Register_reset #(.WIDTH(1)) pp_ExeReg_Branch			(.clk(clk), .reset(FlushE), .DATA(BranchD), .OUT(BranchE));
Register_reset #(.WIDTH(1)) pp_ExeReg_RegWrite		(.clk(clk), .reset(FlushE), .DATA(RegWriteD), .OUT(RegWriteE));
Register_reset #(.WIDTH(1)) pp_ExeReg_MemWrite		(.clk(clk), .reset(FlushE), .DATA(MemWriteD), .OUT(MemWriteE));
Register_reset #(.WIDTH(1)) pp_ExeReg_MemtoReg		(.clk(clk), .reset(FlushE), .DATA(MemtoRegD), .OUT(MemtoRegE));
Register_reset #(.WIDTH(4)) pp_ExeReg_ALUControl	(.clk(clk), .reset(FlushE), .DATA(ALUControlD), .OUT(ALUControlE));
Register_reset #(.WIDTH(2)) pp_ExeReg_ALUSrc			(.clk(clk), .reset(FlushE), .DATA(ALUSrcD), .OUT(ALUSrcE));
Register_reset #(.WIDTH(1)) pp_ExeReg_FlagWrite		(.clk(clk), .reset(FlushE), .DATA(FlagWriteD), .OUT(FlagWriteE));
Register_reset #(.WIDTH(1)) pp_ExeReg_RegSrc			(.clk(clk), .reset(FlushE), .DATA(RegSrcD[0]), .OUT(RegSrcE));
Register_rsten #(.WIDTH(1)) pp_ExeReg_Flags			(.clk(clk), .reset(FlushE), .DATA(Z), .OUT(FlagsE), .we(FlagWriteE));

assign CondEx = ((cond==4'b0000) & FlagsE==1) | ((cond==4'b0001) & FlagsE==0) | (cond==4'b1110);
assign PCSrcE_YES 	= PCSrcE  && CondEx;
assign BranchTakenE 	= BranchE && CondEx;
assign RegWriteE_YES	= RegWriteE && CondEx;
assign MemWriteE_YES	= MemWriteE && CondEx;

// MEMORY // 

wire MemtoRegM, RegSrcM;
 
Register_reset #(.WIDTH(1)) pp_MemReg_PCSrc			(.clk(clk), .reset(reset), .DATA(PCSrcE_YES), .OUT(PCSrcM));
Register_reset #(.WIDTH(1)) pp_MemReg_RegWrite		(.clk(clk), .reset(reset), .DATA(RegWriteE_YES), .OUT(RegWriteM));
Register_reset #(.WIDTH(1)) pp_MemReg_MemWrite		(.clk(clk), .reset(reset), .DATA(MemWriteE_YES), .OUT(MemWriteM));
Register_reset #(.WIDTH(1)) pp_MemReg_MemtoReg		(.clk(clk), .reset(reset), .DATA(MemtoRegE), .OUT(MemtoRegM));
Register_reset #(.WIDTH(1)) pp_MemReg_RegSrc			(.clk(clk), .reset(reset), .DATA(RegSrcE), .OUT(RegSrcM));

// WRITEBACK // 

Register_reset #(.WIDTH(1)) pp_WBReg_PCSrc			(.clk(clk), .reset(reset), .DATA(PCSrcM), .OUT(PCSrcW));
Register_reset #(.WIDTH(1)) pp_WBReg_RegWrite		(.clk(clk), .reset(reset), .DATA(RegWriteM), .OUT(RegWriteW));
Register_reset #(.WIDTH(1)) pp_WBReg_MemtoReg		(.clk(clk), .reset(reset), .DATA(MemtoRegM), .OUT(MemtoRegW));
Register_reset #(.WIDTH(1)) pp_WBReg_RegSrc			(.clk(clk), .reset(reset), .DATA(RegSrcM), .OUT(RegSrcW));

endmodule
