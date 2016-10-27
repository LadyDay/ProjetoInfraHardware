module Unidade_Controle(
	input clock, reset ,
	input [5:0] OPcode,
	input [5:0] funct,
	
	output logic EscreveMem,
	output logic EscrevePC,
	output logic EscrevePCCondEQ,
	output logic EscrevePCCondNE,
	output logic [1:0] OrigPC,
	output logic RegDst,
	output logic EscreveReg,
	output logic [1:0]MemparaReg,
	output logic [1:0] IouD,
	output logic EscreveIR,
	output logic EscreveMDR,
	output logic EscreveAluOut,
	output logic [1:0] OrigAALU,
	output logic [1:0] OrigBALU,
	output logic [2:0] OpAlu,
	output logic IntCause,
	output logic CauseWrite,
	output logic EPCWrite,
	
	
	output [5:0]State //( precisamos ter visão do estado)
);




typedef enum logic [5:0]{ 
	MEM_READ,	//0
	ESPERA,		//1
	IR_WRITE,	//2
	DECOD,		//3
	CLASSE_R,	//4
	WRITE_RD,	//5
	REF_MEM,	//6
	LOAD,		//7
	STORE,		//8
	END_REF_MEM,//9
	BREAK,		//10
	NOP,		//11
	BEQ,		//12
	BNE,		//13
	LUI,		//14
	JUMP,		//15
	JR,
	RTE,
	LOAD_ESPERA1, //16
	LOAD_ESPERA2, //17
	INEXISTENTE,
	OVERFLOW,
	INTERRUPCAO_ESPERA,
	INTERRUPCAO
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
				ESTADO = DECOD;
			end
			
			DECOD:
			begin
				case(OPcode)
					6'h0:
					begin
						case(funct)
							6'hd: ESTADO = BREAK;
							6'h0: ESTADO = NOP;
							6'h20: ESTADO = CLASSE_R;	//ADD
							6'h21: ESTADO = CLASSE_R;	//ADDU
							6'h22: ESTADO = CLASSE_R;	//SUB
							6'h23: ESTADO = CLASSE_R;	//SUBU
							6'h24: ESTADO = CLASSE_R;	//AND
							6'h26: ESTADO = CLASSE_R;	//XOR
							6'h8: ESTADO = JR;
							default: ESTADO = INEXISTENTE;
						endcase
					end
					6'h10:
					begin
						if(funct == 6'h10) ESTADO = RTE;
						else ESTADO = INEXISTENTE;
					end
					6'h2: ESTADO = JUMP;
					6'h4: ESTADO = BEQ;
					6'h5: ESTADO = BNE;
					6'h23: ESTADO = REF_MEM; //LW
					6'h2b: ESTADO = REF_MEM; //SW
					6'hf: ESTADO = LUI;
					default: ESTADO = INEXISTENTE;
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
			
			REF_MEM:
			begin
				case(OPcode)
					6'h23: ESTADO = LOAD; //LW
					6'h2b: ESTADO = STORE; //SW
				endcase
			end
			
			LOAD:
			begin
				ESTADO = LOAD_ESPERA1;
			end
			
			LOAD_ESPERA1:
			begin
				ESTADO = LOAD_ESPERA2;
			end
			
			LOAD_ESPERA2:
			begin
				ESTADO = END_REF_MEM;
			end
			
			END_REF_MEM:
			begin
				ESTADO = MEM_READ;
			end
			
			STORE:
			begin
				ESTADO = MEM_READ;
			end
			
			BEQ:
			begin
				ESTADO = MEM_READ;
			end
			
			BNE:
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
			
			JR: 
			begin
				ESTADO = MEM_READ;
			end
			
			RTE: 
			begin
				ESTADO = MEM_READ;
			end
			
			NOP: 
			begin
				ESTADO = MEM_READ;
			end
			
			INEXISTENTE: 
			begin
				ESTADO = INTERRUPCAO_ESPERA;
			end
			
			OVERFLOW: 
			begin
				ESTADO = INTERRUPCAO_ESPERA;
			end
			
			INTERRUPCAO_ESPERA: 
			begin
				ESTADO = INTERRUPCAO;
			end
			
			INTERRUPCAO: 
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
				MemparaReg = 2'b00;
				EscreveIR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveAluOut = 0;
				EscreveMDR = 0;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;		
			
				/*Variaveis Utilizada*/
				IouD = 2'b00;
				EscreveMem = 0;	//Quando for olhar a maquina de estado, modificar
				EscrevePC = 1;
				OrigAALU = 2'b00;
				OrigBALU = 2'b01;
				OpAlu = 2'b00;
				OrigPC = 2'b00;
			end
			
			ESPERA:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveIR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveMDR = 0;			
				IouD = 2'b00;
				EscreveMem = 0;
				EscrevePC = 0;
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				OpAlu = 2'b00;
				EscreveAluOut = 0;
				OrigPC = 2'b00;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
				
			end
			
			IR_WRITE:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				IouD = 2'b00;
				EscreveMem = 0;
				EscreveMDR = 0;
				EscrevePC = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				OrigPC = 2'b00;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
	
				/*Variaveis Utilizada*/
				EscreveIR = 1;
				OrigAALU = 2'b00;
				OrigBALU = 2'b11;
				OpAlu = 2'b00;
				EscreveAluOut = 1;		
			end
			
			DECOD:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveIR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveMDR = 0;			
				IouD = 2'b00;
				EscreveMem = 0;
				EscrevePC = 0;
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				OpAlu = 2'b00;
				EscreveAluOut = 0;
				OrigPC = 2'b00;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
				
			end
			
			CLASSE_R:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				IouD = 2'b00;
				EscreveMem = 0;
				EscreveMDR = 0;
				EscrevePC = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				OrigPC = 00;
				EscreveIR = 0;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
	
				/*Variaveis Utilizada*/
				OrigAALU = 2'b01;
				OrigBALU = 2'b00;
				OpAlu = 2'b10;
				EscreveAluOut = 1;
			end
			
			WRITE_RD:
			begin
				/*Variaveis NAO Modificadas*/
				IouD = 2'b00;
				EscreveMem = 0;
				EscrevePC = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveMDR = 0;
				OrigPC = 00;
				EscreveIR = 0;
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				OpAlu = 2'b10;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
	
				/*Variaveis Utilizada*/
				MemparaReg = 2'b00;
				RegDst = 1;
				EscreveReg = 1;
				EscreveAluOut = 0;
			end
			
			BREAK:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveIR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveMDR = 0;
				EscreveAluOut = 0;				
				IouD = 2'b00;
				EscreveMem = 0;
				EscrevePC = 0;
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				OpAlu = 2'b00;
				OrigPC = 00;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;		
			end
			
			NOP:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveIR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveMDR = 0;
				EscreveAluOut = 0;			
				IouD = 2'b00;
				EscreveMem = 0;
				EscrevePC = 0;
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				OpAlu = 2'b00;
				OrigPC = 00;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;	
			end
			
			REF_MEM:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveIR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveMDR = 0;			
				EscreveMem = 0;
				EscrevePC = 0;
				OrigPC = 00;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
				
				/*Variaveis Utilizada*/
				OrigAALU = 2'b01;
				OrigBALU = 2'b10;
				IouD = 2'b01;
				OpAlu = 2'b00;
				EscreveAluOut = 1;
			end
			
			LOAD:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveIR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveAluOut = 0;
				EscrevePC = 0;
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				OpAlu = 2'b00;
				OrigPC = 00;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
				
				/*Variaveis Utilizada*/		
				IouD = 2'b01;
				EscreveMem = 0;
				EscreveMDR = 0;
			end
			
			LOAD_ESPERA1:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveIR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveAluOut = 0;
				EscrevePC = 0;
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				OpAlu = 2'b00;
				OrigPC = 00;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
				
				/*Variaveis Utilizada*/		
				IouD = 2'b01;
				EscreveMem = 0;
				EscreveMDR = 0;
			end
			
			LOAD_ESPERA2:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveIR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveAluOut = 0;
				EscrevePC = 0;
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				OpAlu = 2'b00;
				OrigPC = 00;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
				
				/*Variaveis Utilizada*/		
				IouD = 2'b01;
				EscreveMem = 0;
				EscreveMDR = 1;
			end
			
			STORE:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveIR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveMDR = 0;
				EscreveAluOut = 0;
				EscrevePC = 0;
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				OpAlu = 2'b00;
				OrigPC = 00;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
				
				/*Variaveis Utilizada*/		
				IouD = 2'b01;
				EscreveMem = 1;		
			end
			
			END_REF_MEM:
			begin
				/*Variaveis NAO Modificadas*/
				EscreveIR = 0;
				EscreveMDR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveAluOut = 0;			
				IouD = 2'b00;
				EscreveMem = 0;
				EscrevePC = 0;
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				OpAlu = 2'b00;
				OrigPC = 00;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
				
				/*Variaveis Utilizada*/
				MemparaReg = 2'b01;
				RegDst = 0;
				EscreveReg = 1;
						
			end
			
			BEQ:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveIR = 0;
				EscrevePCCondNE = 0;
				EscreveMDR = 0;			
				IouD = 2'b00;
				EscreveMem = 0;
				EscrevePC = 0;
				EscreveAluOut = 0;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
				
				/*Variaveis Utilizada*/
				OrigAALU = 2'b01;
				OrigBALU = 2'b00;
				OpAlu = 2'b01;
				EscrevePCCondEQ = 1;
				OrigPC = 01;
			end
			
			BNE:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveIR = 0;
				EscrevePCCondEQ = 0;
				EscreveMDR = 0;			
				IouD = 2'b00;
				EscreveMem = 0;
				EscrevePC = 0;
				EscreveAluOut = 0;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
				
				/*Variaveis Utilizada*/
				OrigAALU = 2'b01;
				OrigBALU = 2'b00;
				OpAlu = 2'b01;
				EscrevePCCondNE = 1;
				OrigPC = 01;
			end
		
			LUI:
			begin
				/*Variaveis NAO Modificadas*/
				IouD = 2'b00;
				EscreveMem = 0;
				OrigAALU = 2'b01;
				EscreveIR = 0;
				OrigBALU = 2'b0;
				EscreveMDR = 0;
				OpAlu = 2'b00;			
				EscrevePC = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				OrigPC = 00;
				EscreveAluOut = 0;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
				
				/*Variaveis Utilizada*/				
				EscreveReg = 1;
				RegDst = 0;
				MemparaReg = 2'b10;		
			end
			
			JUMP:
			begin	
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				IouD = 2'b00;
				EscreveMem = 0;
				EscreveMDR = 0;
				OrigAALU = 2'b01;
				EscreveIR = 0;
				OrigBALU = 2'b0;
				OpAlu = 2'b00;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveAluOut = 0;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;	
				
				/*Variaveis Utilizada*/
				OrigPC = 2'b10;			
				EscrevePC = 1;
			end
			
			JR:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveIR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveMDR = 0;			
				IouD = 2'b00;
				EscreveMem = 0;
				EscrevePC = 0;
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				OpAlu = 2'b00;
				EscreveAluOut = 0;
				OrigPC = 2'b00;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
				
			end
			
			RTE:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveIR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveMDR = 0;			
				IouD = 2'b00;
				EscreveMem = 0;
				EscrevePC = 0;
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				OpAlu = 2'b00;
				EscreveAluOut = 0;
				OrigPC = 2'b00;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
				
			end
			
			INEXISTENTE:
			begin	
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveMem = 0;
				EscreveMDR = 0;
				EscrevePC = 0;
				EscreveIR = 0;
				OrigPC = 2'b00;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveAluOut = 0;
				OrigBALU = 2'b00;	
				
				/*Variaveis Utilizada*/
				IntCause = 0;
				CauseWrite = 1;
				IouD = 2'b10;
				
				OrigAALU = 2'b00;
				OpAlu = 2'b11;	
				EPCWrite = 1;
			end
			
			OVERFLOW:
			begin	
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveMem = 0;
				EscreveMDR = 0;
				EscrevePC = 0;
				EscreveIR = 0;
				OrigPC = 2'b00;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveAluOut = 0;
				OrigBALU = 2'b00;	
				
				/*Variaveis Utilizada*/
				IntCause = 1;
				CauseWrite = 1;
				IouD = 2'b10;
				
				OrigAALU = 2'b00;
				OpAlu = 2'b11;	
				EPCWrite = 1;
			end
			
			INTERRUPCAO_ESPERA:
			begin	
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveMem = 0;
				EscreveMDR = 0;
				EscrevePC = 0;
				EscreveIR = 0;
				OrigPC = 2'b00;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveAluOut = 0;		
				EPCWrite = 0;
				IntCause = 0;
				CauseWrite = 0;
				IouD = 2'b10;
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				OpAlu = 2'b00;	
			end
			
			INTERRUPCAO:
			begin	
				/*Variaveis NAO Modificadas*/
				RegDst = 0;
				EscreveReg = 0;
				MemparaReg = 2'b00;
				EscreveMem = 0;
				EscreveMDR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveAluOut = 0;		
				EPCWrite = 0;
				IntCause = 0;
				CauseWrite = 0;
				OrigBALU = 2'b00;
				IouD = 2'b10;
				
				/*Variaveis Utilizada*/
				EscreveIR = 1;
				OrigAALU = 2'b10;
				OpAlu = 2'b11;
				OrigPC = 2'b00;
				EscrevePC = 1;
			end
			
	endcase
			
end

endmodule: Unidade_Controle
