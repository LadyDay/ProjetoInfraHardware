module Unidade_Controle(
	input clock, reset ,
	input [4:0] RT,
	input [5:0] OPcode,
	input [5:0] funct,
<<<<<<< HEAD
	input OverflowAlu,
=======
	input overflow,
>>>>>>> 8efc2d08e95b98f94c0780b430c4ae08fd0bc0ae
	
	output logic EscreveMem,
	output logic EscrevePC,
	output logic EscrevePCCondEQ,
	output logic EscrevePCCondNE,
	output logic EscrevePCCond,
	output logic OrigRegLet2,
	output logic [1:0] OrigPC,
	output logic [1:0]RegDst,
	output logic EscreveReg,
	output logic [2:0]MemparaReg,
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
	output logic MuxDeslc,
	output logic LHorLB,
	output logic SHorSB,
	output logic OrigDataMem,

	output [5:0]State //( precisamos ter visão do estado)
);




typedef enum logic [5:0]{ 
	MEM_READ,			//0
	ESPERA,				//1
	IR_WRITE,			//2
	DECOD,				//3
	CLASSE_R,			//4
	WRITE_RD,			//5
	REF_MEM,			//6
	LOAD,				//7
	STORE,				//8
	END_REF_MEM,		//9
	BREAK,				//10
	BEQ,				//11
	BNE,				//12
	LUI,				//13
	JUMP,				//14
	JR,					//15
	RTE,				//16
	LOAD_ESPERA1, 		//17
	LOAD_ESPERA2, 		//18
	INEXISTENTE,  		//19
	CLASSE_Shift, 		//20
	WRITE_Shift,  		//21
	CLASSE_ShiftV, 		//22
	OVERFLOW,     		//23
	INTERRUPCAO_ESPERA, //24
	INTERRUPCAO,		//25
	CLASSE_I,			//26
	WRITE_SLT,			//27
	LBU, 				//28
	LHU,				//29
	SB,					//30
	SH,					//31
	JAL,				//32
	OSB				//33		
	
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
							6'h20: ESTADO = CLASSE_R;	//ADD
							6'h21: ESTADO = CLASSE_R;	//ADDU
							6'h22: ESTADO = CLASSE_R;	//SUB
							6'h23: ESTADO = CLASSE_R;	//SUBU
							6'h24: ESTADO = CLASSE_R;	//AND
							6'h26: ESTADO = CLASSE_R;	//XOR
							6'h2a: ESTADO = CLASSE_R;	//SLT
							
							6'h0: ESTADO = CLASSE_Shift; //sll
							6'h4: ESTADO = CLASSE_ShiftV; //sllv
							6'h3: ESTADO = CLASSE_Shift; //sra
							6'h7: ESTADO = CLASSE_ShiftV; //srav
							6'h2: ESTADO = CLASSE_Shift; //srl
							
							6'h8: ESTADO = JR;
							default: ESTADO = INEXISTENTE;
						endcase
					end
					6'h1:
					begin
						if(RT == 5'h1) ESTADO = OSB;
						else if(RT == 5'h11) ESTADO = OSB;
						else if(RT == 5'h0) ESTADO = OSB;
						else if(RT == 5'h12) ESTADO = OSB;
						else ESTADO = INEXISTENTE;
					end
					6'h6:
					begin
						if(RT == 5'h0) ESTADO = OSB;
						else ESTADO = INEXISTENTE;
					end
					6'h7:
					begin
						if(RT == 5'h0) ESTADO = OSB;
						else ESTADO = INEXISTENTE;
					end
					6'h8: ESTADO = CLASSE_I;//addi
					6'h9: ESTADO = CLASSE_I;//addiu
					6'h10:
					begin
						if(funct == 6'h10) ESTADO = RTE;
						else ESTADO = INEXISTENTE;
					end
					6'hc: ESTADO = CLASSE_I;//andi
					6'he: ESTADO = CLASSE_I;//sxori
					
					
					6'ha: ESTADO = CLASSE_I;//SLTI
					
					6'h24: ESTADO = REF_MEM;//LBU
					6'h25: ESTADO = REF_MEM;//LHU
					
					6'h28: ESTADO = REF_MEM;//SB
					6'h29: ESTADO = REF_MEM;//SH
					
					6'h2: ESTADO = JUMP;
					6'h3: ESTADO = JAL;
					6'h4: ESTADO = BEQ;
					6'h5: ESTADO = BNE;
					6'h23: ESTADO = REF_MEM; //LW
					6'h2b: ESTADO = REF_MEM; //SW
					6'hf: ESTADO = LUI;
					6'h3: ESTADO = JAL;
					default: ESTADO = INEXISTENTE;
				endcase
			end
			
			JAL:
			begin
				ESTADO = MEM_READ;
			end
			BREAK:
			begin
				ESTADO = BREAK;
			end
			
			CLASSE_I:
			begin
				if(OPcode == 6'ha)
				begin
					ESTADO = WRITE_SLT;
				end
				else
				begin
					ESTADO = WRITE_RD;
				end
			end
				
			CLASSE_R:
			begin
				if(funct == 6'h2a)
				begin
					ESTADO = WRITE_SLT;
				end
				else
				begin
					ESTADO = WRITE_RD;
				end
			end
			
			CLASSE_Shift:
			begin
				ESTADO = WRITE_Shift;
			end
			
			CLASSE_ShiftV:
			begin
				ESTADO = WRITE_Shift;
			end
			
			WRITE_RD:
			begin
<<<<<<< HEAD
				case(funct)
					6'h21: ESTADO = MEM_READ;	//ADDU
					6'h23: ESTADO = MEM_READ;	//SUBU
					default:
					begin
						if(OverflowAlu==1)	ESTADO = OVERFLOW;
						else ESTADO = MEM_READ;
					end
				endcase
=======
				if(overflow == 1 && !(funct == 6'h21  || funct == 6'h23 || OPcode == 6'h9))//addiu. addu, subu
					begin
					ESTADO = OVERFLOW;
					end
				else
					begin
					ESTADO = MEM_READ;
					end
			end
			
			WRITE_Shift:
			begin
				ESTADO = MEM_READ;
			end
			
			WRITE_SLT:
			begin
				ESTADO = MEM_READ;
>>>>>>> 8efc2d08e95b98f94c0780b430c4ae08fd0bc0ae
			end
			
			REF_MEM:
			begin
				case(OPcode)
					6'h23: ESTADO = LOAD; //LW
					6'h2b: ESTADO = STORE; //SW
					6'h24: ESTADO = LOAD; //LBU
					6'h25: ESTADO = LOAD; //LHU
					6'h28: ESTADO = LOAD; //SB
					6'h29: ESTADO = LOAD; //SH
					default: ESTADO = LOAD;
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
				case(OPcode)
					6'h23: ESTADO = END_REF_MEM;
					6'h24: ESTADO = LBU;
					6'h25: ESTADO = LHU;
					
					6'h28: ESTADO = SB;
					6'h29: ESTADO = SH;
					
				endcase
			end
			
			LBU:
			begin
				ESTADO = MEM_READ;
			end
			
			LHU:
			begin
				ESTADO = MEM_READ;
			end
			
			SB:
			begin
				ESTADO = MEM_READ;
			end
			
			SH:
			begin
				ESTADO = MEM_READ;
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
			
			OSB:
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
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
				EscreveIR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveAluOut = 0;
				EscreveMDR = 0;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;		
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
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
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				
			end
			
			IR_WRITE:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
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
				RegDst = 2'b00;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				
			end
			
			CLASSE_I:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/
				OrigAALU = 2'b01;
				OrigBALU = 2'b10; //IMEDIATO
				OpAlu = 2'b10;
				EscreveAluOut = 1;
			end
			
			CLASSE_R:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/
				OrigAALU = 2'b01;
				OrigBALU = 2'b00;
				OpAlu = 2'b10;
				EscreveAluOut = 1;
			end
			
			CLASSE_Shift:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				EscreveAluOut = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/
				MuxDeslc = 0;
				OpAlu = 2'b10;
				
			end
			
			CLASSE_ShiftV:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				EscreveAluOut = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/
				MuxDeslc = 1;
				OpAlu = 2'b10;
				
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/
				MemparaReg = 3'b000;
				RegDst = 2'b1;
				EscreveReg = 1;
				EscreveAluOut = 0;
			end
			
			WRITE_Shift:
			begin
				/*Variaveis NAO Modificadas*/	
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
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				EscreveAluOut = 0;
				MuxDeslc = 0;
				OpAlu = 2'b00;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/
				EscreveReg = 1;
				RegDst = 2'b1;
				MemparaReg = 3'b011;
				
			end
			
			WRITE_SLT:
			begin
				/*Variaveis NAO Modificadas*/
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/
				OrigAALU = 2'b01;
				OrigBALU = 2'b00;
				OpAlu = 2'b10;
				EscreveAluOut = 0;
				
				RegDst = 2'b1;
				EscreveReg = 1;
				MemparaReg = 3'b100;
				
			end
			
			BREAK:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
					
			end
			
			REF_MEM:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				
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
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/		
				IouD = 2'b01;
				EscreveMem = 0;
				EscreveMDR = 0;
			end
			
			LOAD_ESPERA1:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/		
				IouD = 2'b01;
				EscreveMem = 0;
				EscreveMDR = 0;
			end
			
			LOAD_ESPERA2:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/		
				IouD = 2'b01;
				EscreveMem = 0;
				EscreveMDR = 1;
			end
			
			STORE:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst =2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/
				MemparaReg = 3'b001;
				RegDst = 2'b0;
				EscreveReg = 1;
						
			end
			
			BEQ:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/
				OrigAALU = 2'b01;
				OrigBALU = 2'b00;
				OpAlu = 2'b01;
				EscrevePCCondEQ = 1;
				OrigPC = 01;
			end
			
			OSB:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
				EscreveIR = 0;
				EscrevePCCondNE = 0;
				EscrevePCCondEQ = 0;
				EscreveMDR = 0;			
				IouD = 2'b00;
				EscreveMem = 0;
				EscrevePC = 0;
				EscreveAluOut = 0;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				
				/*Variaveis Utilizada*/
				OrigAALU = 2'b01;
				OrigBALU = 2'b00;
				OpAlu = 2'b10;
				EscrevePCCond = 1;
				OrigRegLet2 = 1;
				OrigPC = 01;
			end
			
			BNE:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/				
				EscreveReg = 1;
				RegDst = 2'b0;
				MemparaReg = 3'b010;		
			end
			
			JUMP:
			begin	
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;	
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/
				OrigPC = 2'b10;			
				EscrevePC = 1;
			end
			
			JR:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
				EscreveIR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveMDR = 0;			
				IouD = 2'b00;
				EscreveMem = 0;
<<<<<<< HEAD
=======
				OrigAALU = 2'b00;
>>>>>>> 8efc2d08e95b98f94c0780b430c4ae08fd0bc0ae
				OrigBALU = 2'b00;
				EscreveAluOut = 0;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
<<<<<<< HEAD
				/*Variaveis Utilizada*/
				OrigAALU = 2'b01;
				OpAlu = 2'b11;
				OrigPC = 2'b00;
				EscrevePC = 1;
				
=======
				/*Variaveis Utilizadas*/
				EscrevePC = 1;
				OpAlu = 2'b11;
				OrigPC = 2'b00;
>>>>>>> 8efc2d08e95b98f94c0780b430c4ae08fd0bc0ae
			end
			
			RTE:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
				EscreveIR = 0;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveMDR = 0;			
				IouD = 2'b00;
				EscreveMem = 0;
				OrigAALU = 2'b00;
				OrigBALU = 2'b00;
				OpAlu = 2'b00;
				EscreveAluOut = 0;
				IntCause = 0;
				CauseWrite = 0;
				EPCWrite = 0;
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizadas*/
				OrigPC = 2'b11;
				EscrevePC = 1;
				
				/*Variaveis Utilizada*/
				OrigPC = 2'b11;
				EscrevePC = 1;
								
			end
			
			INEXISTENTE:
			begin	
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
				EscreveMem = 0;
				EscreveMDR = 0;
				EscrevePC = 0;
				EscreveIR = 0;
				OrigPC = 2'b00;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveAluOut = 0;
				OrigBALU = 2'b00;
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
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
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
				EscreveMem = 0;
				EscreveMDR = 0;
				EscrevePC = 0;
				EscreveIR = 0;
				OrigPC = 2'b00;
				EscrevePCCondEQ = 0;
				EscrevePCCondNE = 0;
				EscreveAluOut = 0;
				OrigBALU = 2'b00;	
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
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
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
			end
			
			INTERRUPCAO:
			begin	
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizadas*/
				EscreveIR = 1;
				OrigAALU = 2'b10;
				OpAlu = 2'b11;
				OrigPC = 2'b00;
				EscrevePC = 1;
			end
			
			LBU:
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
				MuxDeslc = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/
				LHorLB = 0;
				MemparaReg = 3'b100;
				RegDst = 2'b0;
				EscreveReg = 1;
			end
			
			LHU:
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
				MuxDeslc = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/
				LHorLB = 1;
				MemparaReg = 3'b100;
				RegDst = 2'b0;
				EscreveReg = 1;
			end
			
			SB:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/		
				IouD = 2'b01;
				OrigDataMem = 1;
				EscreveMem = 1;	
				SHorSB = 0;
					
			end
			
			SH:
			begin
				/*Variaveis NAO Modificadas*/
				RegDst = 2'b0;
				EscreveReg = 0;
				MemparaReg = 3'b000;
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
				MuxDeslc = 0;
				LHorLB = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/		
				IouD = 2'b01;
				OrigDataMem = 1;
				EscreveMem = 1;	
				SHorSB = 1;
					
			end
			
			JAL:
			begin
				/*Variaveis NAO Modificadas*/
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
				MuxDeslc = 0;	
				LHorLB = 0;
				SHorSB = 0;
				OrigDataMem = 0;
				EscrevePCCond = 0;
				OrigRegLet2 = 0;
				
				/*Variaveis Utilizada*/
				OrigPC = 2'b10;			
				EscrevePC = 1;
				RegDst = 2'b10;
				EscreveReg = 1;
				MemparaReg = 3'b000;
			end
			
	endcase
			
end

endmodule: Unidade_Controle
