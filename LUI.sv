module LUI(
	
	input  logic [15:0] Imediato,
	
	output logic [31:0] ImediatoLuizado
	
);

	always_comb 
	begin
		//ImediatoLuizado = {Im, 16'b0};// Coloca o imediato nos bits mais significativos e 0 nos menos
	end
	
	
endmodule: LUI