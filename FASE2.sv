module FASE2(
	input clock , reset,
	
	
	output [4:0]  INST_25_21,
	output [4:0]  INST_20_16,
	output [15:0] INST_15_0,
		
	
	
	/*DE ACORDO COM A ESPECIFICACAO*/
	output [31:0]MemData, 		// SAIDA DA MEMORIA
	output [31:0]Address, 		// ENDERECO DA MEMORIA
	output [31:0]WriteDataMem,	// Dado a ser escrito no endereco de memoria
	output [4:0]WriteRegister,	// Registrador a ser escrito
	output [31:0]WriteDataReg,	//Dado  a ser escrito no reg
	output [31:0]MDR,			// SAIDA DO MDR
	output [31:0]Alu,			//SAIDA DA ALU
	output [31:0]AluOut,		//SAIDA da AluOut
	output [31:0]PC,			//Saida do PC
	
	output [5:0]OPCODE,
	output [5:0]Estado
	

);



/*******************************************/
/**************  W I R E S  ****************/
/*******************************************/


/*--------------Sinais de Controle --------------*/
wire EscreveMem;
wire EscrevePC;
wire RegDst;
wire EscreveReg;
wire IouD;
wire EscreveIR;
wire OrigAALU;
wire [1:0]OrigBALU;
wire [2:0]OpALU;
wire [1:0]MemparaReg;



/*------------------ Saidas ------------------*/


//Registradores
wire [31:0] A_in, B_in;
wire [31:0]A_saida;
//wire [31:0]B_saida;


//Muxes
wire [31:0]Mux2_saida;
wire [31:0]Mux3_saida;


/*----------------- ESPECIAIS ---------------*/
wire[4:0]shamt;
assign shamt = INST_15_0[10:6];

wire[4:0]RD;
assign RD = INST_15_0[15:11];

wire [5:0] FUNCT;
assign FUNCT = INST_15_0[5:0];




/*************************************************/
/**************** COMPONENTES ********************/
/*************************************************/


//////////////////////MUX///////////////////
////////////////////////////////////////////

//------IouD------/
MUX_DOIS_IN Mux1( 

	.prm_entrada(PC),
	.seg_entrada(AluOut),
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
MUX_DOIS_IN Mux5(

	.prm_entrada(AluOut),		// AluOut
	.seg_entrada(MDR),		// MDR
	.controle(MemparaReg),
	.saida(WriteDataReg)

);

//---OrigPC-----/
MUX_QUATRO_IN Mux6(

	.prm_entrada(Alu), //saida do B
	.seg_entrada(AluOut), // CONSTANTE QUATRO
	.ter_entrada(),	//SIGNEXTEND
	.controle(OrigPC),
	.saida(PC_In)

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
	.Entrada(ALU), 
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
///////DESLOCAMENTO DE 2 À ESQUERDA////////
///////////////////////////////////////////
RegDesloc Desloc1(
			.Clk(clock),
		 	.Reset(reset),
			.Shift(3'b010), //CONSTANTE
			.N(3'b010),		//CONSTANTE
			.Entrada(ExtensaoOut),
			.Saida(Desloc1Out)
);
/*
RegDesloc Desloc2(
			.Clk(clock),
		 	.Reset(reset),
			.Shift(3'b010), //CONSTANTE
			.N(3'b010),		//CONSTANTE
			.Entrada(INST_25_0),
			.Saida(Desloc2Out)
);
*/

///////////////////////////////////////////
////////////EXTENSÃO DE SINAL//////////////
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
		.EscrevePCCond(EscrevePCCond),
		.EscrevePC(EscrevePC),
		.saida(SinalPC)
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
	
	.EscrevePC(EscrevePC),
	
	.EscrevePCCond(EscrevePCCond),
	
	.OrigPC(OrigPC),
	
	.RegDst(RegDst),
	
	.EscreveReg(EscreveReg),
	
	.MemparaReg(MemparaReg),
	
	.IouD(IouD),
	
	.EscreveIR(EscreveIR),
	
	.OrigAALU(OrigAALU),
	
	.OrigBALU(OrigBALU),
	
	.OpALU(OpALU),
	
	.State(Estado)

);

endmodule: FASE2