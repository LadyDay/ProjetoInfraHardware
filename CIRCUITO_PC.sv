module CIRCUITO_PC(
	input zero,
	input EscrevePCCondEQ,
	input EscrevePCCondNE,
	input EscrevePC,
	output saida
);

always_comb 
begin
	if(EscrevePC || (EscrevePCCondEQ && zero) || (EscrevePCCondNE && ~zero))
		saida = 1;
	else
		saida = 0;
end

endmodule: CIRCUITO_PC 