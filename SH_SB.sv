module SH_SB (
	input[31:0] B,
	input[31:0] MDR,
	output[31:0] saida,
	input controle
);

always_comb 
begin
	case(controle)
		
		0: saida = {B[31:8], MDR[7:0]};		//SB
		1: saida = {B[31:16], MDR[15:0]};	//SH
	endcase
		
end

endmodule: SH_SB