module INTERRUPTION (
	input entrada,
	output[31:0] saida
);

always_comb 
begin
	if(entrada) saida = 32'b00000000000000000000000011111111; //255
	else saida = 32'b00000000000000000000000011111110;	//254
end

endmodule: INTERRUPTION