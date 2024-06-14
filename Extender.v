module Extender (
    output reg [31:0]Extended_data,
    input [19:0]DATA,
    input [1:0]select
);

always @(*) begin
    case (select)
		// 5-bit signed extend.
      2'b00: Extended_data = {{27{DATA[4]}}, DATA[4:0]};
		// 12-bit signed extend.
      2'b01: Extended_data = {{20{DATA[11]}}, DATA[11:0]};
		// 20-bit signed extend.
      2'b10: Extended_data = {{12{DATA[19]}}, DATA[19:0]};
		default: Extended_data = 32'd0;
    endcase
end
    
endmodule
