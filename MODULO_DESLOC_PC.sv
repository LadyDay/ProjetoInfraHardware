module MODULO_DESLOC_PC(
	input[31:0] IR,
	input[31:0] PC,
	output[31:0] saida
);

always_comb 
begin
	saida = {PC[31:28], 2'b00, IR[25:0]};
end

endmodule: MODULO_DESLOC_PC 