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
			case(funct)
				6'h0: saida = 3'b010; //sll
				6'h4: saida = 3'b010; //sllv
				6'h3: saida = 3'b100; //sra
				6'h7: saida = 3'b100; //srav
				6'h2: saida = 3'b011; //srl
				
				6'h20: saida = 3'b001; //soma
				6'h24: saida = 3'b011; //and
				6'h22: saida = 3'b010; //subtra��o
				6'h26: saida = 3'b110; //xor
				default: saida = 3'b000;
			endcase
		end
		2'b11: saida = 3'b000;
	endcase
		
end

endmodule: CONTROLE_ULA 