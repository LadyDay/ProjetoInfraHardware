module MUX_DOIS_IN(
	input[31:0] prm_entrada,
	input[31:0] seg_entrada,
	input controle,
	output[31:0] saida
);

always_comb 
begin
	case(controle)
		1'b0: saida = prm_entrada;
		1'b1: saida = seg_entrada;
	endcase
end

endmodule: MUX_DOIS_IN
