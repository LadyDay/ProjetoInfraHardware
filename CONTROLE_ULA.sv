module CONTROLE_ULA (
	input[5:0] funct,
	input[1:0] controle,
	output[2:0] saida
);

always_comb 
begin
	case(controle)
		2'b00: saida = 3'b001;
		2'b01: saida = 3'b010;
		2'b10: 
		begin
			//implementar lógica do controle da ALU aqui.
			saida = 3'b000;
		end
		2'b11: saida = 3'b000;
	endcase
		
end

endmodule: CONTROLE_ULA 