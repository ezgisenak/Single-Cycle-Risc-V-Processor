module ALU #(parameter WIDTH=32)
(
  input [3:0] control,
  input CI,
  input [WIDTH-1:0] DATA_A,
  input [WIDTH-1:0] DATA_B,
  output reg [WIDTH-1:0] OUT,
  output reg CO,
  output reg OVF,
  output Z, N
 );
localparam AND=4'b0000,
		  EXOR=4'b0001,
		  SubtractionAB=4'b0010,
		  SubtractionBA=4'b0011,
		  Addition=4'b0100,
		  Addition_Carry=4'b0101,
		  SubtractionAB_Carry=4'b0110,
		  SubtractionBA_Carry=4'b0111,
		  XORID=4'b1000,
		  SUBU=4'b1001,
		  ORR=4'b1100,
		  Move=4'b1101,
		  Bit_Clear=4'b1110,
		  Move_Not=4'b1111;

// Assign the zero and negative flasg here since it is very simple
assign N = (control == SUBU) ? (DATA_A < DATA_B) : OUT[WIDTH-1];
assign Z = ~(|OUT);
	 
always@(*) begin
	case(control)
		AND:begin
			OUT = DATA_A & DATA_B;
			CO = 1'b0;
			OVF = 1'b0;
		end
		EXOR:begin
			OUT = DATA_A ^ DATA_B;
			CO = 1'b0;
			OVF = 1'b0;
		end
		SubtractionAB:begin
			{CO,OUT} =  DATA_A +  $unsigned(~DATA_B) +  1'b1;
			OVF = (DATA_A[WIDTH-1] & ~DATA_B[WIDTH-1] & ~OUT[WIDTH-1]) | (~DATA_A[WIDTH-1] & DATA_B[WIDTH-1] & OUT[WIDTH-1]);
		end
		SubtractionBA:begin
			{CO,OUT} =  DATA_B +  $unsigned(~DATA_A) +  1'b1;
			OVF = (DATA_B[WIDTH-1] & ~DATA_A[WIDTH-1] & ~OUT[WIDTH-1]) | (~DATA_B[WIDTH-1] & DATA_A[WIDTH-1] & OUT[WIDTH-1]);
		end
		Addition:begin
			{CO,OUT} = DATA_A + DATA_B;
			OVF = (DATA_A[WIDTH-1] & DATA_B[WIDTH-1] & ~OUT[WIDTH-1]) | (~DATA_A[WIDTH-1] & ~DATA_B[WIDTH-1] & OUT[WIDTH-1]);
		end
		Addition_Carry:begin
			{CO,OUT} = DATA_A + DATA_B + CI;
			OVF = (DATA_A[WIDTH-1] & DATA_B[WIDTH-1] & ~OUT[WIDTH-1]) | (~DATA_A[WIDTH-1] & ~DATA_B[WIDTH-1] & OUT[WIDTH-1]);
		end
		SubtractionAB_Carry:begin
			{CO,OUT} =  DATA_A +  $unsigned(~DATA_B) + CI;
			OVF = (DATA_A[WIDTH-1] & ~DATA_B[WIDTH-1] & ~OUT[WIDTH-1]) | (~DATA_A[WIDTH-1] & DATA_B[WIDTH-1] & OUT[WIDTH-1]);
		end
		SubtractionBA_Carry:begin
			{CO,OUT} =  DATA_B +  $unsigned(~DATA_A) + CI;
			OVF = (DATA_B[WIDTH-1] & ~DATA_A[WIDTH-1] & ~OUT[WIDTH-1]) | (~DATA_B[WIDTH-1] & DATA_A[WIDTH-1] & OUT[WIDTH-1]);
		end
		XORID:begin
			OUT = DATA_A ^ (32'd2375178 ^ 32'd2376242);
			CO = 1'b0;
			OVF = 1'b0;
		end
		SUBU:begin
			{CO, OUT} = DATA_A + $unsigned(~(~DATA_B + 1));
			OVF = (DATA_A < DATA_B);
		end
		ORR:begin
			OUT = DATA_A | DATA_B;
			CO = 1'b0;
			OVF = 1'b0;
		end
		Move:begin
			OUT = DATA_B;
			CO = 1'b0;
			OVF = 1'b0;
		end
		Bit_Clear:begin
			OUT = DATA_A ^ ~DATA_B;
			CO = 1'b0;
			OVF = 1'b0;
		end
		Move_Not:begin
			OUT = ~DATA_B;
			CO = 1'b0;
			OVF = 1'b0;
		end
		default:begin
		OUT = {WIDTH{1'b0}};
		CO = 1'b0;
		OVF = 1'b0;
		end
	endcase
end
	 
endmodule	 