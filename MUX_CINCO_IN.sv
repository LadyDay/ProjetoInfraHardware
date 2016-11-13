module MUX_CINCO_IN (
	input[31:0] prm_entrada,
	input[31:0] seg_entrada,
	input[31:0] ter_entrada,
	input[31:0] qrt_entrada,
	input[31:0] qui_entrada,
	input[2:0] controle,
	output[31:0] saida
);

always_comb 
begin
	case(controle)
		3'b000: saida = prm_entrada;
		3'b001: saida = seg_entrada;
		3'b010: saida = ter_entrada;
		3'b011: saida = qrt_entrada;
		3'b100: saida = qui_entrada;
		default:saida = prm_entrada;
	endcase
		
end

endmodule: MUX_CINCO_IN 