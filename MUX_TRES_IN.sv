module MUX_TRES_IN (
	input[31:0] prm_entrada,
	input[31:0] seg_entrada,
	input[31:0] ter_entrada,
	input[1:0] controle,
	output[31:0] saida
);

always_comb 
begin
	case(controle)
		2'b00: saida = prm_entrada;
		2'b01: saida = seg_entrada;
		2'b10: saida = ter_entrada;
		default: saida = prm_entrada;
	endcase
		
end

endmodule: MUX_TRES_IN 