module FASE2(
	input clock , reset,
	
	
	output [4:0] INST_25_21,
	output [4:0] INST_20_16,
	output [4:0] RD,
	output [15:0] INST_15_0,
	
	output [1:0] OrigPC,
	output [5:0] FUNCT,
	
	
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



/*------------------ Saidas ------------------*/


//Registradores
wire [31:0] A_in, B_in;
wire [31:0] A_saida;
//wire [31:0]B_saida;

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
wire [31:0] DeslocPCOut;
wire InCause;
wire [31:0] OutInterruption;



/*----------------- ESPECIAIS ---------------*/
wire[4:0]shamt;
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
MUX_DOIS_IN Mux4 (

	.prm_entrada(INST_20_16), 	//RT
	.seg_entrada(RD), 	//  RD
	.controle(RegDst),
	.saida(WriteRegister)

);

//---MemToReg---//
MUX_QUATRO_IN Mux5(

	.prm_entrada(AluOut),		// AluOut
	.seg_entrada(MDR),		// MDR
	.ter_entrada(LuiOut),
	.qrt_entrada(OutExtensaoBlock),
	.controle(MemparaReg),
	.saida(WriteDataReg)

);

//---OrigPC-----/
MUX_TRES_IN Mux6(

	.prm_entrada(Alu), //saida do ALU
	.seg_entrada(AluOut), // 
	.ter_entrada(DeslocPCOut),	//SIGNEXTEND
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
	.Saida(WriteDataMem)	

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
			.ReadReg2(INST_20_16),// INSTR 20-16
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


///////////////////////////////////////////
//////////////CONTROLE ULA/////////////////
///////////////////////////////////////////
CONTROLE_ULA ControleUla(
		.funct(FUNCT),
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

EXTENSAO_BLOCK ExtensaoBlock(
		.entrada(IR[7:0]),
		.saida(OutExtensaoBlock)
);

///////////////////////////////////////////
///////////////// U L A ///////////////////
///////////////////////////////////////////
ula32 ALU_componente(

		.A(Mux2_saida),		// origA
		.B(Mux3_saida),		//origB
		.Seletor(ControleUlaOut),
		.S(Alu),
		.Overflow(),
		.Negativo(),
		.z(ZeroAlu),
		.Igual(),
		.Maior(),
		.Menor()
		
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
		.EscrevePC(EscrevePC),
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
	
	.EscreveMem(EscreveMem),
	
	.EscreveAluOut(EscreveAluOut),
	
	.EscrevePC(EscrevePC),
	
	.EscreveMDR(EscreveMDR),
	
	.EscrevePCCondEQ(EscrevePCCondEQ),
	
	.EscrevePCCondNE(EscrevePCCondNE),
	
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
	
	.State(Estado)

);

endmodule: FASE2