module LH_LB (
	input[31:0] B,
	input[31:0] MDR,
	output[31:0] saida,
	input controle
);

always_comb 
begin
	case(controle)
		
		0: saida = {MDR[31:8], B[7:0]};		//LB
		1: saida = {MDR[31:16], B[15:0]};	//LH
	endcase
		
end

endmodule: LH_LB