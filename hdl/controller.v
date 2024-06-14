module controller(
	input Z, N, clk, reset,				 									// input signals coming from the datapath
	input [31:0] Instr,												
	output reg RegWrite, MemWrite, ALUSrc, ImmSelect, ShamtSelect,
	output reg [1:0] ImmSrc, ShiftControl, PCSrc,
	output reg [2:0] ResultSrc, MemControl,
	output reg [3:0] ALUControl,
	output reg [19:0] Imm
);

// MNEMONICS
localparam 	ADD=4'b0100,
				SUB=4'b0010,
				AND=4'b0000,
				ORR=4'b1100,
				MOV=4'b1101,
				CMP=4'b1010,
				EXOR=4'b0001,
				SUBU=4'b1001,
				XORID=4'b1000;
				
localparam  EXT5=2'b00,
				EXT12=2'b01,
				EXT20=2'b10;
				
	 
localparam LSL=2'b00,
			  LSR=2'b01,
			  ASR=2'b10,
			  RR=2'b11;
			  
localparam 	W =3'b000,
				HU=3'b001,
				H =3'b010,
				BU=3'b011,
				B =3'b100;		 
		
// DECODE //
wire [6:0] op, funct7;
wire [5:0] funct;
wire [2:0] funct3;
assign op = Instr[6:0];
assign funct7 = Instr[31:25];
assign funct3 = Instr[14:12];

initial begin
	PCSrc	  	 		= 2'b00;
	RegWrite  	 	= 1'b0;
	MemWrite	   	= 1'b0;
	ALUControl		= MOV;
	ALUSrc    		= 1'b0;
	ImmSrc    		= EXT5;
	ResultSrc		= 3'b000;
	ImmSelect		= 1'b0;
	ShiftControl	= LSL;
	Imm				= 20'b0;
	MemControl     = W;
	ShamtSelect		= 0;
end

// Main Decoder		
always@(*) begin
	PCSrc	  	 		= 2'b00;
	RegWrite  	 	= 1'b0;
	MemWrite	   	= 1'b0;
	ALUControl		= MOV;
	ALUSrc    		= 1'b0;
	ImmSrc    		= EXT5;
	ResultSrc		= 3'b000;
	ImmSelect		= 1'b0;
	ShiftControl	= LSL;
	Imm				= 20'b0;
	MemControl     = W;
	ShamtSelect		= 0;
	case (op)
		7'b0110011: begin // R-Type
			if (funct7 == 7'b0000000 && funct3 == 3'b000) begin // ADD
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= ADD;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= 20'b0;
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct7 == 7'b0100000 && funct3 == 3'b000) begin // SUB
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= SUB;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= 20'b0;
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct7 == 7'b0000000 && funct3 == 3'b111) begin // AND
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= AND;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= 20'b0;
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct7 == 7'b0000000 && funct3 == 3'b110) begin // OR
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= ORR;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= 20'b0;
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct7 == 7'b0000000 && funct3 == 3'b100) begin // XOR
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= EXOR;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= 20'b0;
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct7 == 7'b0000000 && funct3 == 3'b001) begin // SLL
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= MOV;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b010;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= 20'b0;
				MemControl     = W;
				ShamtSelect		= 1;
			end else if (funct7 == 7'b0000000 && funct3 == 3'b101) begin // SRL
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= MOV;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b010;
				ImmSelect		= 1'b0;
				ShiftControl	= LSR;
				Imm				= 20'b0;
				MemControl     = W;
				ShamtSelect		= 1;
			end else if (funct7 == 7'b0100000 && funct3 == 3'b101) begin // SRA
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= MOV;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b010;
				ImmSelect		= 1'b0;
				ShiftControl	= ASR;
				Imm				= 20'b0;
				MemControl     = W;
				ShamtSelect		= 1;
			end else if (funct7 == 7'b0000000 && funct3 == 3'b010) begin // SLT
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= SUB;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b011;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= 20'b0;
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct7 == 7'b0000000 && funct3 == 3'b011) begin // SLTU
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= SUBU;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b011;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= 20'b0;
				MemControl     = W;
				ShamtSelect		= 0;
			end
			else begin
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b0;
				MemWrite	   	= 1'b0;
				ALUControl		= MOV;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= 20'b0;
				MemControl     = W;
				ShamtSelect		= 0;
			end
		end
		
		7'b0010011: begin // I-Type:
			if (funct3 == 3'b000) begin // ADDI
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= ADD;
				ALUSrc    		= 1'b1;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {8'b0,Instr[31:20]};
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct3 == 3'b111) begin // ANDI
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= AND;
				ALUSrc    		= 1'b1;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {8'b0,Instr[31:20]};
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct3 == 3'b110) begin // ORI
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= ORR;
				ALUSrc    		= 1'b1;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {8'b0,Instr[31:20]};
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct3 == 3'b100) begin // XORI
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= EXOR;
				ALUSrc    		= 1'b1;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {8'b0,Instr[31:20]};
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct7 == 7'b0000000 && funct3 == 3'b001) begin // SLLI
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= MOV;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b010;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {15'b0,Instr[24:20]};
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct7 == 7'b0000000 && funct3 == 3'b101) begin // SRLI
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= MOV;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b010;
				ImmSelect		= 1'b0;
				ShiftControl	= LSR;
				Imm				= {15'b0,Instr[24:20]};
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct7 == 7'b0100000 && funct3 == 3'b101) begin // SRAI
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= MOV;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b010;
				ImmSelect		= 1'b0;
				ShiftControl	= ASR;
				Imm				= {15'b0,Instr[24:20]};
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct3 == 3'b010) begin // SLTI
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= SUB;
				ALUSrc    		= 1'b1;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b011;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {8'b0,Instr[31:20]};
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct3 == 3'b011) begin // SLTIU
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= SUBU;
				ALUSrc    		= 1'b1;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b011;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {8'b0,Instr[31:20]};
				MemControl     = W;
				ShamtSelect		= 0;
			end else begin
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b0;
				MemWrite	   	= 1'b0;
				ALUControl		= MOV;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= 20'b0;
				MemControl     = W;
				ShamtSelect		= 0;
			end
		end
		
		7'b1100111: begin 
			if (funct3 == 3'b000) begin // JALR
				PCSrc	  	 		= 2'b10;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= ADD;
				ALUSrc    		= 1'b1;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b100;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {8'b0,Instr[31:20]};
				MemControl     = W;
				ShamtSelect		= 0;
			end
			else begin
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b0;
				MemWrite	   	= 1'b0;
				ALUControl		= MOV;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= 20'b0;
				MemControl     = W;
				ShamtSelect		= 0;
			end
		end
		7'b1101111: begin // JAL
			PCSrc	  	 		= 2'b01;
			RegWrite  	 	= 1'b1;
			MemWrite	   	= 1'b0;
			ALUControl		= MOV;
			ALUSrc    		= 1'b0;
			ImmSrc    		= EXT20;
			ResultSrc		= 3'b100;
			ImmSelect		= 1'b0;
			ShiftControl	= LSL;
			Imm				= {Instr[31],Instr[19:12],Instr[20],Instr[30:21]} << 1;
			MemControl     = W;
			ShamtSelect		= 0;
		end
		
		7'b1100011: begin // B-Type
			if (funct3 == 3'b000) begin // BEQ
				PCSrc	  	 		= {1'b0,Z};
				RegWrite  	 	= 1'b0;
				MemWrite	   	= 1'b0;
				ALUControl		= SUB;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {6'b0,Instr[31],Instr[7],Instr[30:25],Instr[11:8]} << 1;
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct3 == 3'b001) begin // BNE
				PCSrc	  	 		= {1'b0,~Z};
				RegWrite  	 	= 1'b0;
				MemWrite	   	= 1'b0;
				ALUControl		= SUB;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {6'b0,Instr[31],Instr[7],Instr[30:25],Instr[11:8]} << 1;
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct3 == 3'b100) begin // BLT
				PCSrc	  	 		= {1'b0,N};
				RegWrite  	 	= 1'b0;
				MemWrite	   	= 1'b0;
				ALUControl		= SUB;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {6'b0,Instr[31],Instr[7],Instr[30:25],Instr[11:8]} << 1;
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct3 == 3'b101) begin // BGE
				PCSrc	  	 		= {1'b0,~N};
				RegWrite  	 	= 1'b0;
				MemWrite	   	= 1'b0;
				ALUControl		= SUB;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {6'b0,Instr[31],Instr[7],Instr[30:25],Instr[11:8]} << 1;
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct3 == 3'b110) begin // BLTU
				PCSrc	  	 		= {1'b0,N};
				RegWrite  	 	= 1'b0;
				MemWrite	   	= 1'b0;
				ALUControl		= SUBU;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {6'b0,Instr[31],Instr[7],Instr[30:25],Instr[11:8]} << 1;
				MemControl     = W;
				ShamtSelect		= 0;
			end else if (funct3 == 3'b111) begin // BGEU
				PCSrc	  	 		= {1'b0,~N};
				RegWrite  	 	= 1'b0;
				MemWrite	   	= 1'b0;
				ALUControl		= SUBU;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {6'b0,Instr[31],Instr[7],Instr[30:25],Instr[11:8]} << 1;
				MemControl     = W;
				ShamtSelect		= 0;
			end else begin
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b0;
				MemWrite	   	= 1'b0;
				ALUControl		= MOV;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= 20'b0;
				MemControl     = W;
				ShamtSelect		= 0;
			end
		end
		7'b0000011: begin // L-Type
			if (funct3 == 3'b000) begin // LB
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= ADD;
				ALUSrc    		= 1'b1;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b001;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {8'b0,Instr[31:20]};
				MemControl     = B;
				ShamtSelect		= 0;
			end else if (funct3 == 3'b100) begin // LBU
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= ADD;
				ALUSrc    		= 1'b1;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b001;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {8'b0,Instr[31:20]};
				MemControl     = BU;
				ShamtSelect		= 0;
			end else if (funct3 == 3'b001) begin // LH
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= ADD;
				ALUSrc    		= 1'b1;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b001;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {8'b0,Instr[31:20]};
				MemControl     = H;
				ShamtSelect		= 0;
			end else if (funct3 == 3'b101) begin // LHU
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= ADD;
				ALUSrc    		= 1'b1;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b001;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {8'b0,Instr[31:20]};
				MemControl     = HU;
				ShamtSelect		= 0;
			end else if (funct3 == 3'b010) begin // LW
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b1;
				MemWrite	   	= 1'b0;
				ALUControl		= ADD;
				ALUSrc    		= 1'b1;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b001;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {8'b0,Instr[31:20]};
				MemControl     = W;
				ShamtSelect		= 0;
			end else begin
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b0;
				MemWrite	   	= 1'b0;
				ALUControl		= MOV;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= 20'b0;
				MemControl     = W;
				ShamtSelect		= 0;
			end
		end
		7'b0100011: begin // S-Type
			if (funct3 == 3'b000) begin // SB
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b0;
				MemWrite	   	= 1'b1;
				ALUControl		= ADD;
				ALUSrc    		= 1'b1;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {8'b0,Instr[31:25],Instr[11:7]};
				MemControl     = B;
				ShamtSelect		= 0;
			end else if (funct3 == 3'b001) begin // SH
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b0;
				MemWrite	   	= 1'b1;
				ALUControl		= ADD;
				ALUSrc    		= 1'b1;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {8'b0,Instr[31:25],Instr[11:7]};
				MemControl     = H;
				ShamtSelect		= 0;
			end else if (funct3 == 3'b010) begin // SW
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b0;
				MemWrite	   	= 1'b1;
				ALUControl		= ADD;
				ALUSrc    		= 1'b1;
				ImmSrc    		= EXT12;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= {8'b0,Instr[31:25],Instr[11:7]};
				MemControl     = W;
				ShamtSelect		= 0;
			end else begin
				PCSrc	  	 		= 2'b00;
				RegWrite  	 	= 1'b0;
				MemWrite	   	= 1'b0;
				ALUControl		= MOV;
				ALUSrc    		= 1'b0;
				ImmSrc    		= EXT5;
				ResultSrc		= 3'b000;
				ImmSelect		= 1'b0;
				ShiftControl	= LSL;
				Imm				= 20'b0;
				MemControl     = W;
				ShamtSelect		= 0;
			end
		end
		7'b0010111: begin // AUIPC
			PCSrc	  	 		= 2'b00;
			RegWrite  	 	= 1'b1;
			MemWrite	   	= 1'b0;
			ALUControl		= MOV;
			ALUSrc    		= 1'b0;
			ImmSrc    		= EXT20;
			ResultSrc		= 3'b101;
			ImmSelect		= 1'b1;
			ShiftControl	= LSL;
			Imm				= Instr[31:12];
			MemControl     = W;
			ShamtSelect		= 0;
		end
		7'b0110111: begin // LUI
			PCSrc	  	 		= 2'b00;
			RegWrite  	 	= 1'b1;
			MemWrite	   	= 1'b0;
			ALUControl		= MOV;
			ALUSrc    		= 1'b1;
			ImmSrc    		= EXT20;
			ResultSrc		= 3'b110;
			ImmSelect		= 1'b1;
			ShiftControl	= LSL;
			Imm				= Instr[31:12];
			MemControl     = W;
			ShamtSelect		= 0;
		end
		7'b0001011: begin // XORID
			PCSrc	  	 		= 2'b00;
			RegWrite  	 	= 1'b1;
			MemWrite	   	= 1'b0;
			ALUControl		= XORID;
			ALUSrc    		= 1'b0;
			ImmSrc    		= EXT5;
			ResultSrc		= 3'b000;
			ImmSelect		= 1'b0;
			ShiftControl	= LSL;
			Imm				= 20'b0;
			MemControl     = W;
			ShamtSelect		= 0;
		end
		default: begin
			PCSrc	  	 		= 2'b00;
			RegWrite  	 	= 1'b0;
			MemWrite	   	= 1'b0;
			ALUControl		= MOV;
			ALUSrc    		= 1'b0;
			ImmSrc    		= EXT5;
			ResultSrc		= 3'b000;
			ImmSelect		= 1'b0;
			ShiftControl	= LSL;
			Imm				= 20'b0;
			MemControl     = W;
			ShamtSelect		= 0;
		end
	endcase
end

endmodule