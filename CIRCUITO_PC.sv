module CIRCUITO_PC(
	input zero,
	input EscrevePCCondEQ,
	input EscrevePCCondNE,
	input EscrevePCCond,
	input MenorAlu,
	input IgualAlu,
	input MaiorAlu,
	input EscrevePC,
	input [5:0] opcode,
	input [4:0] RT,
	output saida
);

always_comb 
begin
	if(EscrevePC == 1) saida = 1;
	else
	begin
		case(opcode)
		6'h4:
		begin
			if(EscrevePCCondEQ == 1 && zero == 1) saida = 1;													//BEQ
			else saida = 0;
		end
		6'h5:																						//BNE
		begin
			if(EscrevePCCondNE == 1 && zero == 0) saida = 1;
			else saida = 0;
		end
		6'h1:
		begin
			if(EscrevePCCond == 1 && (MaiorAlu == 1 || IgualAlu == 1) && (RT == 5'h1 || RT == 5'h11)) saida = 1;	//BGEZ ou BGEZAL
			else if(EscrevePCCond == 1 && MenorAlu == 1 && (RT == 5'h0 || RT == 5'h12)) saida = 1;			//BLTZ ou BLTALL
			else saida = 0;
		end
		6'h7:																						//BGTZ
		begin
			if(EscrevePCCond == 1 && MaiorAlu == 1) saida = 1;
			else saida = 0;
		end
		6'h6:																						//BLEZ
		begin
			if(EscrevePCCond == 1 && (MenorAlu == 1 || IgualAlu == 1)) saida = 1;
			else saida = 0;
		end
		default: saida = 0;
		endcase
	end
end

endmodule: CIRCUITO_PC 