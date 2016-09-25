module CIRCUITO_PC(
	input zero,
	input EscrevePCCond,
	input EscrevePC,
	output saida
);

always_comb 
begin
	if(EscrevePC || (EscrevePCCond && zero))
		saida = 1;
	else
		saida = 0;
end

endmodule: CIRCUITO_PC 