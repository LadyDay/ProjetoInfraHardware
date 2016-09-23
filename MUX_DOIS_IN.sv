module MUX_DOIS_IN(
	input[31:0] prm_entrada,
	input[31:0] seg_entrada,
	input controle,
	output[31:0] saida
);

always_comb 
begin
	if(controle)
		saida = seg_entrada;
	else
		saida = prm_entrada; 
end

endmodule: MUX_DOIS_IN
