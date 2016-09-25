module EXTENSAO_SINAL (
	input[15:0] entrada,
	output[31:0] saida
);

always_comb 
begin
	saida = entrada;	
end

endmodule: EXTENSAO_SINAL