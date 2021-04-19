#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO2     º Autor ³ AP6 IDE            º Data ³  14/10/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CTBCUSDV(ntipo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea := GetArea()
Local cQuery	:= ""
Local cQry		:= ""
Local cQryD1	:= ""

Private cString 	:= ""
Private nPedagio 	:= 0
Private nFrete		:= 0
Private nICMST		:= 0
Private nCusto		:= 0
Private nCTotal		:= 0
Private nValIcms	:= 0
Private nQtdSD1		:= 0
Private nQtd		:= 0

cQuery := " SELECT D1_FILIAL, D1_EMISSAO, D1_DOC, D1_SERIE, D1_COD, D1_LOCAL, D1_LOTECTL, D8_SEQ, D8_TIPONF, D1_QUANT, D1_NUMSEQ, D1_NFORI, D1_ITEMORI  "
cQuery += " FROM " +RetSqlName("SD1")+ " D1 INNER JOIN "
cQuery += " " +RetSqlName("SB8")+" C8 ON B8_FILIAL = D1_FILIAL AND B8_LOTECTL = D1_LOTECTL "
cQuery += " INNER JOIN " +RetSqlName("SD8")+ " D8 ON B8_FILIAL = D8_FILIAL AND B8_DOC = D8_DOC AND B8_SERIE = D8_SERIE  AND B8_PRODUTO = D8_PRODUTO "
cQuery += " WHERE D1_FILIAL = '"+SD1->D1_FILIAL+"' "
cQuery += " AND D1_DOC = '"+SD1->D1_DOC+"' "
cQuery += " AND D1_SERIE = '"+SD1->D1_SERIE+"' "
cQuery += " AND D1_ITEMORI = '"+SD1->D1_ITEMORI+"' "
cQuery += " AND D1.D_E_L_E_T_ = '' "
cQuery += " AND C8.D_E_L_E_T_ = '' "
cQuery += " AND D8.D_E_L_E_T_ = '' "

//MemoWrit("QUERYCUSTO.sql",cQuery)
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYCUSTO",.T.,.T.)
QRYCUSTO->(dbGoTop())

//BUSCA O NUMSEQ
// Busca todas as notas fiscais, através do lote
cQy := " SELECT * FROM "+RetSqlName("SD8")+" SD80 WHERE D8_NUMSEQ = '"+QRYCUSTO->D1_NUMSEQ+"' AND D_E_L_E_T_ = '' ORDER BY D8_SEQCALC"
cQy := ChangeQuery(cQy)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQy),"QRYSEQ",.T.,.T.)
QRYSEQ->(dbGoTop())

// Busca todas as notas fiscais, através do lote
cQry := " SELECT * FROM "+RetSqlName("SD8")+" SD80 WHERE D8_SEQ = '"+QRYSEQ->D8_SEQ+"' AND D_E_L_E_T_ = '' ORDER BY D8_SEQCALC"
cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRYPROD",.T.,.T.)
QRYPROD->(dbGoTop())

// Busca e calcula os itens do SD8
WHILE QRYPROD->(!EOF())
	
	If QRYPROD->D8_TIPONF == "N" .AND. QRYPROD->D8_CF < '500'
		nqtd := QRYPROD->D8_QUANT
		// Busca o ICMS da nota fiscal original
		
		cQryD1 := " SELECT D1_ICMSRET FROM "+RetSqlName("SD1")+" SD1 WHERE D1_FILIAL = '"+SD1->D1_FILIAL+"' AND D1_DOC = '"+QRYPROD->D8_DOC+ "'"
		cQryD1 += " AND D1_SERIE = '"+QRYCUSTO->D1_SERIE+"' AND D1_COD = '"+QRYCUSTO->D1_COD+"' "
		cQryD1 += " AND D1_LOCAL = '"+QRYCUSTO->D1_LOCAL+"' AND D_E_L_E_T_ = '' "
		
		cQryD1 := ChangeQuery(cQryD1)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryD1),"QRYD1",.T.,.T.)
		QRYD1->(dbGoTop())
		nValIcms := QRYD1->D1_ICMSRET
		QRYD1->(dbclosearea())
		
		nICMST :=  (nValIcms / nqtd ) * QRYCUSTO->D1_QUANT
		nCusto	:= QRYPROD->D8_CUSTO1 / QRYCUSTO->D1_QUANT /////QRYPROD->D8_QUANT
		
	ElseIf QRYPROD->D8_TIPONF == "D" //QRYPROD->D8_CF == "281"
		If SELECT("QRYD8") > 0
			QRYD8->(dbClosearea())
		Endif
		/// busco a nota fiscal de origem, através da nota fiscal de devolução de entrada
		cQRYD8 := " SELECT * FROM "+RETSQLNAME("SD8")+" SD8 WHERE D_E_L_E_T_ = '' AND D8_DOC = '"+QRYCUSTO->D1_NFORI+"' AND D8_ITEM = '"+QRYCUSTO->D1_ITEMORI+"' "
		cQRYD8 := ChangeQuery(cQryD8)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryD8),"QRYD8",.T.,.T.)
		QRYD8->(dbGoTop())
		
		If SELECT("QYD8") > 0
			QYD8->(dbClosearea())
		Endif
		// busco a nota fiscal de seq de entrada através da nota de devolução
		cQYD8 := " SELECT * FROM "+RETSQLNAME("SD8")+" SD8 WHERE D_E_L_E_T_ = '' AND D8_SEQ = '"+QRYD8->D8_SEQ+"' AND D8_CF = '281' "
		cQYD8 := ChangeQuery(cQyD8)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQyD8),"QYD8",.T.,.T.)
		QYD8->(dbGoTop())
		
		If SELECT("QQD8") > 0
			QQD8->(dbClosearea())
		Endif
		// busco a QUANTIDADE de seq de entrada através da nota de devolução
		cQQD8 := " SELECT * FROM "+RETSQLNAME("SD8")+" SD8 WHERE D_E_L_E_T_ = '' AND D8_SEQ = '"+QRYD8->D8_SEQ+"' AND D8_CF = '103' "
		cQQD8 := ChangeQuery(cQQD8)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQQD8),"QQD8",.T.,.T.)
		QQD8->(dbGoTop())
		
		nFrete	:= ( QYD8->D8_CUSTO1 / QQD8->D8_QUANT ) * QRYCUSTO->D1_QUANT
		
	ElseIf QRYPROD->D8_CF == "400"
		//		nPedagio := (QRYPROD->D8_CUSTO1 / nqtd) * QRYCUSTO->D1_QUANT
		If SELECT("QRYD8") > 0
			QRYD8->(dbClosearea())
		Endif
		/// busco a nota fiscal de origem, através da nota fiscal de devolução de entrada
		cQRYD8 := " SELECT * FROM "+RETSQLNAME("SD8")+" SD8 WHERE D_E_L_E_T_ = '' AND D8_DOC = '"+QRYCUSTO->D1_NFORI+"' AND D8_ITEM = '"+QRYCUSTO->D1_ITEMORI+"' "
		cQRYD8 := ChangeQuery(cQryD8)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryD8),"QRYD8",.T.,.T.)
		QRYD8->(dbGoTop())
		
		If SELECT("QYD8") > 0
			QYD8->(dbClosearea())
		Endif
		// busco a nota fiscal de seq de entrada através da nota de devolução
		cQYD8 := " SELECT * FROM "+RETSQLNAME("SD8")+" SD8 WHERE D_E_L_E_T_ = '' AND D8_SEQ = '"+QRYD8->D8_SEQ+"' AND D8_CF = '281' "
		cQYD8 := ChangeQuery(cQyD8)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQyD8),"QYD8",.T.,.T.)
		QYD8->(dbGoTop())
		
		If SELECT("QQD8") > 0
			QQD8->(dbClosearea())
		Endif
		// busco a QUANTIDADE de seq de entrada através da nota de devolução
		cQQD8 := " SELECT * FROM "+RETSQLNAME("SD8")+" SD8 WHERE D_E_L_E_T_ = '' AND D8_SEQ = '"+QRYD8->D8_SEQ+"' AND D8_CF = '103' "
		cQQD8 := ChangeQuery(cQQD8)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQQD8),"QQD8",.T.,.T.)
		QQD8->(dbGoTop())
		
		nPedagio := ( QYD8->D8_CUSTO1 / QQD8->D8_QUANT ) * QRYCUSTO->D1_QUANT
		
	Endif
	If SELECT("QRYD8") > 0
		QRYD8->(dbClosearea())
	EndIf
	If SELECT("QYD8") > 0
		QYD8->(dbClosearea())
	EndIf
	If SELECT("QQD8") > 0
		QQD8->(dbClosearea())
	EndIf
	QRYPROD->(dbSkip())
EndDo

RestArea(aArea)
If SELECT("QRYCUSTO") > 0
	QRYCUSTO->(dbclosearea())
EndIf
If SELECT("QRYPROD") > 0
	QRYPROD->(dbclosearea())
EndIf
If SELECT("QRYSEQ") > 0
	QRYSEQ->(dbclosearea())
EndIf

If nTipo == "1" // Retorna o Valor do Frete
	Return(nFrete)
ElseIf nTipo == "2" // Retorna o Valor do Pedágio
	Return(nPedagio)
ElseIf nTipo == "3" // Retorna o Valor do Custo
	nCTotal := SD1->D1_CUSFF1 - nFrete - nPedagio
	Return(nCTotal)
ElseIf nTipo == "4" // valor do icms
	Return(nICMST)
ElseIf nTipo == "5"
	Return(SD1->D1_CUSFF1)
Endif

Return
