module Unidade_Controle(
	input clock, reset ,
	input [5:0] OPcode,
	input [5:0] funct,
	
	output logic EscreveMem,
	output logic EscrevePC,
	output logic EscrevePCCond,
	output logic[1:0]OrigPC,
	output logic RegDst,
	output logic EscreveReg,
	output logic MemparaReg,
	output logic IouD,
	output logic EscreveIR,
	output logic EscreveAluOut,
	output logic OrigAALU,
	output logic[1:0]OrigBALU,
	output logic[1:0]OpALU,
	
	
	output [5:0]State //( precisamos ter visão do estado)
);




typedef enum logic [5:0]{ 
	MEM_READ,
	ESPERA,
	IR_WRITE,
	CLASSE_R,
	WRITE_RD,
	BREAK,
	NOP,
	LUI,
	JUMP
}st;

st ESTADO;

assign State = ESTADO;

always_ff@(posedge clock, posedge reset)
begin
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
				case(OPcode)
					6'h0:
					begin
						if(funct == 6'hd)
							ESTADO = BREAK;
						else if(funct == 6'h0)
							ESTADO = NOP;
						else
							ESTADO = CLASSE_R;
					end
					6'h2: ESTADO = JUMP;
					//6'h4: ESTADO = BEQ;
					//6'h5: ESTADO = BNE;
					//6'h23: ESTADO = LW;
					//6'h2b: ESTADO = SW;
					6'hf: ESTADO = LUI;
				endcase
			end
			
			BREAK:
			begin
				ESTADO = BREAK;
			end
			
			CLASSE_R:
			begin
				ESTADO = WRITE_RD;
			end
			
			WRITE_RD:
			begin
				ESTADO = MEM_READ;
			end
			
			LUI:
			begin
				ESTADO = MEM_READ;
			end
			
			JUMP: 
			begin
				ESTADO = MEM_READ;
			end
			
			NOP: 
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
				EscrevePCCond = 0;
				EscreveAluOut = 0;				
			
				/*Variaveis Utilizada*/
				IouD = 0;
				EscreveMem = 0;	//Quando for olhar a maquina de estado, modificar
				EscrevePC = 1;
				OrigAALU = 0;
				OrigBALU = 2'b01;
				OpALU = 2'b00;
				OrigPC = 00;
			end
			
			ESPERA:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 0;
				EscreveIR = 0;
				EscrevePCCond = 0;				
				IouD = 0;
				EscreveMem = 0;
				EscrevePC = 0;
				OrigAALU = 0;
				OrigBALU = 2'b00;
				OpALU = 2'b00;
				EscreveAluOut = 0;
				OrigPC = 00;
				
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
				EscrevePCCond = 0;
				OrigPC = 00;
	
				/*Variaveis Utilizada*/
				EscreveIR = 1;
				OrigAALU = 0;
				OrigBALU = 2'b11;
				OpALU = 2'b00;
				EscreveAluOut = 1;		
			end
			
			CLASSE_R:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 0;
				IouD = 0;
				EscreveMem = 0;
				EscrevePC = 0;
				EscrevePCCond = 0;
				OrigPC = 00;
				EscreveIR = 0;
	
				/*Variaveis Utilizada*/
				OrigAALU = 1;
				OrigBALU = 2'b00;
				OpALU = 2'b10;
				EscreveAluOut = 1;
			end
			
			WRITE_RD:
			begin
				/*Variaveis NAO Modificadas*/
				IouD = 0;
				EscreveMem = 0;
				EscrevePC = 0;
				EscrevePCCond = 0;
				OrigPC = 00;
				EscreveIR = 0;
				OrigAALU = 0;
				OrigBALU = 2'b00;
				OpALU = 2'b10;
	
				/*Variaveis Utilizada*/
				MemparaReg = 0;
				RegDst = 1;
				EscreveReg = 1;
				EscreveAluOut = 0;
			end
			
			BREAK:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 0;
				EscreveIR = 0;
				EscrevePCCond = 0;
				EscreveAluOut = 0;				
				IouD = 0;
				EscreveMem = 0;
				EscrevePC = 0;
				OrigAALU = 0;
				OrigBALU = 2'b00;
				OpALU = 2'b00;
				OrigPC = 00;		
			end
			
			NOP:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 0;
				EscreveIR = 0;
				EscrevePCCond = 0;
				EscreveAluOut = 0;			
				IouD = 0;
				EscreveMem = 0;
				EscrevePC = 0;
				OrigAALU = 0;
				OrigBALU = 2'b00;
				OpALU = 2'b00;
				OrigPC = 00;		
			end
		
			LUI:
			begin
				/*Variaveis NAO Modificadas*/
				IouD = 0;
				EscreveMem = 0;
				OrigAALU = 1;
				EscreveIR = 0;
				OrigBALU = 2'b0;
				OpALU = 2'b00;			
				EscrevePC = 0;
				EscrevePCCond = 0;
				OrigPC = 00;
				EscreveAluOut = 0;
				
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
				OpALU = 2'b00;
				OrigPC = 00;
				EscrevePCCond = 0;
				EscreveAluOut = 0;		
				
				/*Variaveis Utilizada*/				
				EscrevePC = 1;
				//FALTA MUX ORIGPC
			end
			
	endcase
			
end

endmodule: Unidade_Controle
