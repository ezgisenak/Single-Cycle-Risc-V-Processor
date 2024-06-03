module Memory#(BYTE_SIZE=4, ADDR_WIDTH=32)(
input clk,WE,
input [2:1] MemControl,
input [ADDR_WIDTH-1:0] ADDR,
input [(BYTE_SIZE*8)-1:0] WD,
output reg [(BYTE_SIZE*8)-1:0] RD 
);

reg [7:0] mem [255:0];

localparam 	W =3'b000,
				HU=3'b001,
				H =3'b010,
				BU=3'b011,
				B =3'b100;

// Signed/Unsigned load operations of different sizes.
genvar i;
always@(*) begin

	case (MemControl)
	
		W: begin
			RD = {mem[ADDR+3], mem[ADDR+2], mem[ADDR+1], mem[ADDR]};
		end
		
		HU: begin
			RD = {16'd0, mem[ADDR+1], mem[ADDR]};
		end
		
		H: begin
			RD = {{16{mem[ADDR+1][7]}}, mem[ADDR+1], mem[ADDR]};
		end
		
		BU: begin
			RD = {24'd0, mem[ADDR]};
		end
		
		B: begin
			RD = {{24{mem[ADDR][7]}}, mem[ADDR]};
		end
		
		default: begin
         RD = 0;
      end
		
	endcase
	
end

// Store operations of different sizes.
integer k;
always @(posedge clk) begin
	
	case (MemControl)
	
		W: begin
			if(WE == 1'b1) begin	
				for (k = 0; k < BYTE_SIZE; k = k + 1) begin
					mem[ADDR+k] <= WD[8*k+:8];
				end
			end
		end
		
		H: begin
			if(WE == 1'b1) begin	
				for (k = 0; k < BYTE_SIZE / 2; k = k + 1) begin
					mem[ADDR+k] <= WD[8*k+:8];
				end
			end
		end
		
		B: begin
			if(WE == 1'b1) begin	
				for (k = 0; k < BYTE_SIZE / 4; k = k + 1) begin
					mem[ADDR+k] <= WD[8*k+:8];
				end
			end
		end
	endcase
	
end

endmodule
