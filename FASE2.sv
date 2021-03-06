module FASE2(
	input clock , reset,
	
	
	output [4:0] INST_25_21,
	output [4:0] INST_20_16,
	output [4:0] RD,
	output [15:0] INST_15_0,
	
	output [1:0] OrigPC,
	output [5:0] FUNCT,
	output [4:0]shamt,

	
	
	/*DE ACORDO COM A ESPECIFICACAO*/
	output [31:0] MemData, 		// SAIDA DA MEMORIA
	output [31:0] Address, 		// ENDERECO DA MEMORIA
	output [31:0] WriteDataMem,	// Dado a ser escrito no endereco de memoria
	output [4:0] WriteRegister,	// Registrador a ser escrito
	output [31:0] WriteDataReg,	//Dado  a ser escrito no reg
	output [31:0] MDR,			// SAIDA DO MDR
	output [31:0] Alu,			//SAIDA DA ALU
	output [31:0] AluOut,		//SAIDA da AluOut
	output [31:0] PC,			//Saida do PC
	output [31:0] EPC,
	output [5:0] OPCODE,
	output [5:0] Estado
	

);



/*******************************************/
/**************  W I R E S  ****************/
/*******************************************/


/*--------------Sinais de Controle --------------*/
wire EscreveMem;
wire EscreveMDR;
wire EscrevePC;
wire EscrevePCCondEQ;
wire EscrevePCCondNE;
wire EscrevePCCond;
wire RegDst;
wire EscreveReg;
wire [1:0]IouD;
wire EscreveIR;
wire EscreveAluOut;
wire OrigAALU;
wire [1:0] OrigBALU;
wire [2:0] OpAlu;
wire [1:0] MemparaReg;
wire IntCause;
wire EPCWrite;
wire CauseWrite;
wire OutExtensaoBlock;
wire [31:0] Cause;
wire [31:0] IR;
wire OrigRegLet2;



/*------------------ Saidas ------------------*/



wire ov;
//Registradores
wire [31:0] A_in, B_in;
wire [31:0] A_saida;
wire [31:0]B_saida;

//Muxes
wire [31:0] Mux2_saida;
wire [31:0] Mux3_saida;

//
wire [31:0] LuiOut;
wire [31:0] Desloc1Out;
wire [31:0] ExtensaoOut;
wire [31:0] PC_In;
wire SinalPC;
wire [2:0] ControleUlaOut;
wire ZeroAlu;
wire OverflowAlu;
wire [31:0] DeslocPCOut;
wire InCause;
wire [31:0] OutInterruption;
wire [31:0] RDesloc_saida;
wire [31:0] DeslocaN;
wire MaiorAlu;
wire MenorAlu;
wire IgualAlu;

/*----------------- ESPECIAIS ---------------*/
//wire[4:0]shamt;
assign shamt = INST_15_0[10:6];

//wire[4:0]RD;
assign RD = INST_15_0[15:11];

//wire [5:0] FUNCT;
assign FUNCT = INST_15_0[5:0];

//wire [32:0] IR;
assign IR = {OPCODE, INST_25_21, INST_20_16, INST_15_0};


/*************************************************/
/**************** COMPONENTES ********************/
/*************************************************/


//////////////////////MUX///////////////////
////////////////////////////////////////////

//------IouD------/
MUX_TRES_IN Mux1( 

	.prm_entrada(PC),
	.seg_entrada(AluOut),
	.ter_entrada(OutInterruption),
	.controle(IouD),
	.saida(Address)

);

//----OrigAALU-----/
MUX_DOIS_IN Mux2(

	.prm_entrada(PC),
	.seg_entrada(A_saida),
	.controle(OrigAALU),
	.saida(Mux2_saida)

);


//---OrigBALU-----/
MUX_QUATRO_IN Mux3(

	.prm_entrada(WriteDataMem), //saida do B
	.seg_entrada(32'd4), // CONSTANTE QUATRO
	.ter_entrada(ExtensaoOut),	//SIGNEXTEND
	.qrt_entrada(Desloc1Out),	//SIGNEXSHIFTADO
	.controle(OrigBALU),
	.saida(Mux3_saida)

);

//---RegDest-//
MUX_TRES_IN Mux4 (

	.prm_entrada(INST_20_16), 	//RT
	.seg_entrada(RD), 	//  RD
	.ter_entrada(32'd31),
	.controle(RegDst),
	.saida(WriteRegister)

);

//---MemToReg---//
MUX_CINCO_IN Mux5(

	.prm_entrada(AluOut),		// AluOut
	.seg_entrada(MDR),		// MDR
	.ter_entrada(LuiOut),
	.qrt_entrada(RDesloc_saida),
	.qui_entrada(MenorUla),
	.controle(MemparaReg),
	.saida(WriteDataReg)

);

//---OrigPC-----/
MUX_QUATRO_IN Mux6(

	.prm_entrada(Alu), //saida do ALU
	.seg_entrada(AluOut), // 
	.ter_entrada(DeslocPCOut),	//SIGNEXTEND
	.qrt_entrada(EPC),
	.controle(OrigPC),
	.saida(PC_In)

);

//---RegCause--//
MUX_DOIS_IN Mux7 (

	.prm_entrada(1'b0),
	.seg_entrada(1'b1),
	.controle(IntCause),
	.saida(InCause)
	
);

//--OrigDeslc--//
MUX_DOIS_IN Mux8 (

	.prm_entrada(shamt),
	.seg_entrada(A_saida),
	.controle(OrigDeslc),
	.saida(DeslocaN)
	
);

//----OrigDataMem-----/
MUX_DOIS_IN Mux9(

	.prm_entrada(B_saida), // bOUT
	.seg_entrada(SHorSB),
	.controle(OrigDataMem),
	.saida(WriteDataMem)

);

//----OrigRegLet2-----/
MUX_DOIS_IN Mux10(

	.prm_entrada(IR[20:16]), // bOUT
	.seg_entrada(5'd0),
	.controle(OrigRegLet2),
	.saida(OutMux10)

);

/*******************************************************/
/*************R E G I S T R A D O R E S*****************/
/*******************************************************/

//   PC   //
Registrador PC_reg(

	.Clk(clock),		
	.Reset(reset),	
	.Load(SinalPC),	
	.Entrada(PC_In), 
	.Saida(PC)	

);

//   EPC   //
Registrador EPC_reg(

	.Clk(clock),		
	.Reset(reset),	
	.Load(EPCWrite),	
	.Entrada(Alu), 
	.Saida(EPC)	

);

//   Cause   //
Registrador Cause_Reg(

	.Clk(clock),		
	.Reset(reset),	
	.Load(CauseWrite),	
	.Entrada(InCause), 
	.Saida(Cause)	

);

//   A   //
Registrador A(

	.Clk(clock),		
	.Reset(reset),	
	.Load(1'b1),	//CONSTANTE
	.Entrada(A_in), 
	.Saida(A_saida)	

);

//   B   //
Registrador B(

	.Clk(clock),		
	.Reset(reset),	
	.Load(1'b1),	//CONSTANTE
	.Entrada(B_in), 
	.Saida(B_saida)	

);

//   MDR   //
Registrador MDR_reg(

	.Clk(clock),		
	.Reset(reset),	
	.Load(EscreveMDR),	
	.Entrada(MemData), 
	.Saida(MDR)	

);

//   AluOut   //
Registrador AluOut_reg(

	.Clk(clock),		
	.Reset(reset),	
	.Load(EscreveAluOut),	 /// COLOCA NA UC esse wire
	.Entrada(Alu), 
	.Saida(AluOut)	

);

/*****************************************************/
/**************INSTRUCAO REGISTRADOR******************/
/****************************************************/

Instr_Reg InsReg(
	.Clk(clock),
	.Reset(reset),
	.Load_ir(EscreveIR),
	.Entrada(MemData),
	.Instr31_26(OPCODE),/// OPCODE SAI DAQUI
	.Instr25_21(INST_25_21), /// REG RS
	.Instr20_16(INST_20_16), /// REG RT
	.Instr15_0(INST_15_0)	
);


///////////////////////////////////////////
/////////Banco de Registradores////////////
///////////////////////////////////////////

Banco_reg BankReg(
			.Clk(clock),		
			.Reset(reset),	
			.RegWrite(EscreveReg),
			.ReadReg1(INST_25_21),// INSTR 25-21
			.ReadReg2(OutMux10),// INSTR 20-16
			.WriteReg(WriteRegister),// REGDEST
			.WriteData(WriteDataReg),//MEMTORG
			.ReadData1(A_in),//A rs
			.ReadData2(B_in)//B rt
);

///////////////////////////////////////////
/////////////////MEMORIA///////////////////
///////////////////////////////////////////
Memoria MEM(
		.Address(Address),
		.Clock	(clock),
		.Wr		(EscreveMem),
		.Datain	(WriteDataMem),//SAIDA do regB
		.Dataout(MemData)
	

);

///////////////////////////////////////////////
////////////////LHU LB E SH SB/////////////////
///////////////////////////////////////////////


LH_LB lhlb_componente(
	.B(B_saida),
	.MDR(MDR),
	.saida(lh_lb_saida),
	.controle(LHorLB)
);
SH_SB shsb_componente (
	.B(B_saida),
	.MDR(MDR),
	.saida(sh_sb_saida),
	.controle(SHorSB)
);


///////////////////////////////////////////
//////////////CONTROLE ULA/////////////////
///////////////////////////////////////////
CONTROLE_ULA ControleUla(
		.funct(FUNCT),
		.opcode(OPCODE),
		.controle(OpAlu),
		.saida(ControleUlaOut)
);

///////////////////////////////////////////
//////////////INTERRUPTION/////////////////
///////////////////////////////////////////
INTERRUPTION Interruption(
		.entrada(InCause),
		.saida(OutInterruption)
);

///////////////////////////////////////////
///////////////// U L A ///////////////////
///////////////////////////////////////////
ula32 ALU_componente(

		.A(Mux2_saida),		// origA
		.B(Mux3_saida),		//origB
		.Seletor(ControleUlaOut),
		.S(Alu),
<<<<<<< HEAD
		.Overflow(OverflowAlu),
=======
		.Overflow(ov),
>>>>>>> 8efc2d08e95b98f94c0780b430c4ae08fd0bc0ae
		.Negativo(),
		.z(ZeroAlu),
		.Igual(IgualAlu),
		.Maior(MaiorAlu),
		.Menor(MenorAlu)
		
);
///////////////////////////////////////////
////////////////REG DESLOC/////////////////
///////////////////////////////////////////

RegDesloc RgDesloca(
		
			.Clk(clock),
		 	.Reset(reset),
		 	
			.Shift(ControleUlaOut),
			.N(DeslocaN[4:0]),
			.Entrada(B_saida),
			
			.Saida(RDesloc_saida)
		
);



///////////////////////////////////////////
///////DESLOCAMENTO DE 2 � ESQUERDA////////
///////////////////////////////////////////
RegDesloc Desloc1(
		.Clk(clock),
		.Reset(reset),
		.Shift(3'b010), //CONSTANTE
		.N(3'b010),		//CONSTANTE
		.Entrada(ExtensaoOut),
		.Saida(Desloc1Out)
);

MODULO_DESLOC_PC DeslocPC(
		.IR(IR),
		.PC(PC),
		.saida(DeslocPCOut)
);

///////////////////////////////////////////
////////////EXTENS�O DE SINAL//////////////
///////////////////////////////////////////
EXTENSAO_SINAL ExtensaoSinal(
		.entrada(INST_15_0),
		.saida(ExtensaoOut)
);

///////////////////////////////////////////
////////////CIRCUITOS EXTRAS///////////////
///////////////////////////////////////////
CIRCUITO_PC circuito1(
		.zero(ZeroAlu),
		.EscrevePCCondEQ(EscrevePCCondEQ),
		.EscrevePCCondNE(EscrevePCCondNE),
		.MenorAlu(MenorAlu),
		.IgualAlu(IgualAlu),
		.MaiorAlu(MaiorAlu),
		.EscrevePC(EscrevePC),
		.opcode(OPCODE),
		.RT(IR[20:16]),
		.saida(SinalPC)
);

LUI lui(
		.Imediato(INST_15_0),
		.ImediatoLuizado(LuiOut)
);


/**********************************************************/
/*************** UNIDADE DE CONTROLE **********************/
/**********************************************************/



Unidade_Controle UC(

	.clock(clock),
	
	.reset(reset),
	
	.OPcode(OPCODE),
	
	.funct(FUNCT),
	
	.overflow(ov),
	
	.EscreveMem(EscreveMem),
	
	.EscreveAluOut(EscreveAluOut),
	
	.EscrevePC(EscrevePC),
	
	.EscreveMDR(EscreveMDR),
	
	.EscrevePCCondEQ(EscrevePCCondEQ),
	
	.EscrevePCCondNE(EscrevePCCondNE),
	
	.EscrevePCCond(EscrevePCCond),
	
	.OrigRegLet2(OrigRegLet2),
	
	.OrigPC(OrigPC),
	
	.RegDst(RegDst),
	
	.EscreveReg(EscreveReg),
	
	.MemparaReg(MemparaReg),
	
	.IouD(IouD),
	
	.EscreveIR(EscreveIR),
	
	.OrigAALU(OrigAALU),
	
	.OrigBALU(OrigBALU),
	
	.OpAlu(OpAlu),
	
	.CauseWrite(CauseWrite),
	
	.EPCWrite(EPCWrite),
	
	.IntCause(IntCause),
	
	.MuxDeslc(OrigDeslc),
	
	.LHorLB(LHorLB),
	
	.SHorSB(SHorSB),
	
	.OrigDataMem(OrigDataMem),
	
	.State(Estado)

);

endmodule: FASE2