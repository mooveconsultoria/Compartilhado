#Include 'Protheus.ch'

/*
Programa.: m265vest
Autor....: Fabiano Migoto Pinto
Data.....: 25/09/2017 
Descricao: valida o saldo do produto genérico (JET G) no estorno do endereçamento.
Uso......: AIR BP BRASIL LTDA
*/
User Function m265vest()

	Local cQry 		:= ""
	Local nSaldo 	:= 0
	Local nQtd		:= 0
	Local cProduto 	:= ""
	Local cLocal 	:= ""
	Local cLocaliz 	:= ""
	Local cNumseq	:= ""
	Local cAliSDB := GetNextAlias()

	// VERIFICA SE EXISTE SALDO NO PRODUTO FILHO
	cProduto 	:= Posicione( "SB1", 1, xFilial( "SB1" ) + SDA->DA_PRODUTO, "B1_XGEN" )
	cNumseq		:= SDA->DA_NUMSEQ

	cQry := "SELECT SDB.DB_LOCALIZ, SDB.DB_QUANT, SDB.DB_LOCAL, SDB.DB_PRODUTO"
	cQry += "  FROM " + RetSqlName( "SDB" ) + " SDB "
	cQry += " WHERE SDB.D_E_L_E_T_ <> '*' "
	cQry += "   AND SDB.DB_FILIAL   = '" + xFilial( "SDB" ) + "' "
	cQry += "   AND SDB.DB_PRODUTO  = '" + Trim( SDA->DA_PRODUTO ) + "' "
	cQry += "   AND SDB.DB_NUMSEQ   = '" + cNumSeq + "'"
	cQry += "   AND SDB.DB_ESTORNO  = ''"

	cQry := ChangeQuery(cQry) 

	DbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliSDB, .F., .T. )

	(cAliSDB)->( DbGoTop() )
	While( (cAliSDB)->( !Eof() ) )
		cLocal		:= (cAliSDB)->DB_LOCAL  
		cLocaliz	:= (cAliSDB)->DB_LOCALIZ
		nQtd		:= (cAliSDB)->DB_QUANT  

		(cAliSDB)->( DbSkip() )
	EndDo

	/// 08/12/2017 - RAFAEL FALCO - AJUSTADO CALCULO DO SALDO PARA FUNÇÃO SALDOSBF, PARA RETORNAR O SALDO NO ENDEREÇO
	//nSaldo := CalcEst(cProduto,SDB->DB_LOCAL, dDataBase+1)
	nSaldo := SaldoSBF( cLocal, cLocaliz, cProduto, "", "", "", .F., "", .F., "" )                 
	                
//	DbSelectArea("SB2")
//	DbSeek(xFilial("SB2")+Posicione("SB1",1,xFilial("SB1")+SDB->DB_PRODUTO+SDB->DB_LOCAL,"B1_XGEN"))
	    
	If !Empty(cProduto)
		If nQtd > nSaldo //SaldoSb2() //
			MsgStop( " Saldo insuficiente, Produto: " + cProduto )
			Return( 2 )
		Endif     
    EndIf
    
Return