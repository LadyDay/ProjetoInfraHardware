module EXTENSAO_SINAL (
	input[15:0] entrada,
	output[31:0] saida
);

always_comb 
begin
	saida = {15'b000000000000000, entrada};	
end

endmodule: EXTENSAO_SINAL