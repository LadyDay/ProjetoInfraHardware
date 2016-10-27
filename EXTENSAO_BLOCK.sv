module EXTENSAO_BLOCK(
	input[7:0] entrada,
	output[31:0] saida
);

always_comb 
begin
	saida = {24'b000000000000000000000000, entrada};
end

endmodule: EXTENSAO_BLOCK