module Unidade_Controle(
	input clock, reset ,
	input [5:0] OPcode,
	input [5:0]funct,
	
	output logic EscreveMem,
	output logic EscrevePC,
	output logic RegDst,
	output logic EscreveReg,
	output logic MemparaReg,
	output logic IouD,
	output logic EscreveIR,
	output logic OrigAALU,
	output logic[1:0]OrigBALU,
	output logic[1:0]OpALU,
	
	
	output [5:0]State //( precisamos ter visão do estado)
);




typedef enum logic [5:0]{ 
	MEM_READ,
	ESPERA,
	IR_WRITE,
	BREAK

}st;

st ESTADO;

assign State = ESTADO;

always_ff@(posedge clock, posedge reset)begin
	if(reset)
		ESTADO = MEM_READ;
	else
		case(ESTADO)
			MEM_READ:
			begin	
				ESTADO = ESPERA;
			end
			ESPERA:
			begin
				ESTADO = IR_WRITE;
			end
			IR_WRITE:
			begin
				ESTADO = MEM_READ;
				/*case(OPcode)
					//JUMP
					6'h2: ESTADO = JUMP;
					6'hf: ESTADO = LUI;
					*/
		
			end
			BREAK:
			begin
				ESTADO = BREAK;
			end
			
			LUI:
			begin
			end
				ESTADO = MEM_READ;
			JUMP: 
			begin
				ESTADO = MEM_READ;
			end
		endcase 
end

always_comb 
begin
	case(ESTADO)
			MEM_READ:
			begin
				
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 0;
				EscreveIR = 0;
				
				
			
				/*Variaveis Utilizada*/
				
				IouD = 0;
				EscreveMem = 0;	//Quando for olhar a maquina de estado, modificar
				EscrevePC = 1;
				OrigAALU = 0;
				OrigBALU = 2'b01;
				OpALU = 3'b001;
			end
			
			ESPERA:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 0;
				EscreveIR = 0;
				
				
			
				/*Variaveis Utilizada*/
				IouD = 0;
				EscreveMem = 0; 			
				EscrevePC = 0;
				OrigAALU = 0;
				OrigBALU = 2'b00;
				OpALU = 3'b000;
				
			end
			
			IR_WRITE:
			begin
				
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 0;
				IouD = 0;
				EscreveMem = 0;
				EscrevePC = 0;
	
			
			
				/*Variaveis Utilizada*/
				EscreveIR = 1;
				OrigAALU = 0;
				OrigBALU = 2'b11;
				OpALU = 3'b001;			
			end
			BREAK:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 0;
				IouD = 0;
				EscreveMem = 0;
				EscrevePC = 0;
				EscreveIR = 0;
				OrigAALU = 0;
				OrigBALU = 2'b00;
				OpALU = 3'b000;			
			end
		
			LUI:
			begin
				/*Variaveis NAO Modificadas*/
				IouD = 0;
				EscreveMem = 0;
				OrigAALU = 1;
				EscreveIR = 0;
				OrigBALU = 2'b0;
				OpALU = 3'b000;			
				EscrevePC = 0;
				
				
				
				/*Variaveis Utilizada*/				
				EscreveReg = 1;
				RegDst = 1;
				MemparaReg = 0;// AQUI É PARA ESCREVER LUI, MAS NAO TEM NA ENTRADA DO MUX				
			end
			
			JUMP:
			begin	
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 0;
				IouD = 0;
				EscreveMem = 0;
				OrigAALU = 1;
				EscreveIR = 0;
				OrigBALU = 2'b0;
				OpALU = 3'b000;			
				
				
				/*Variaveis Utilizada*/				
				EscrevePC = 1;
				//FALTA MUX ORIGPC
				
				
			end
			
	endcase
			
end

endmodule: Unidade_Controle
