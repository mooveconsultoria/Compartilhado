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

User Function CTBCUSTO(ntipo)

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

cQuery := " SELECT C9_FILIAL, C9_NFISCAL, C9_SERIENF, C9_PRODUTO, C9_LOCAL, C9_LOTECTL, D8_SEQ, D8_TIPONF "
cQuery += " FROM " +RetSqlName("SC9")+ " C9 INNER JOIN "
cQuery += " " +RetSqlName("SB8")+" C8 ON B8_FILIAL = C9_FILIAL AND B8_LOTECTL = C9_LOTECTL "
cQuery += " INNER JOIN " +RetSqlName("SD8")+ " D8 ON B8_FILIAL = D8_FILIAL AND B8_DOC = D8_DOC AND B8_SERIE = D8_SERIE  AND B8_PRODUTO = D8_PRODUTO "
cQuery += " WHERE C9_FILIAL = '"+SD2->D2_FILIAL+"' "
cQuery += " AND C9_NFISCAL = '"+SD2->D2_DOC+"' "
cQuery += " AND C9_SERIENF = '"+SD2->D2_SERIE+"' "
cQuery += " AND C9.D_E_L_E_T_ = '' " 
cQuery += " AND C8.D_E_L_E_T_ = '' " 
cQuery += " AND D8.D_E_L_E_T_ = '' " 

//MemoWrit("QUERYCUSTO.sql",cQuery)
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYCUSTO",.T.,.T.)
QRYCUSTO->(dbGoTop())   

// Busca todas as notas fiscais, através do lote
cQry := " SELECT * FROM "+RetSqlName("SD8")+" SD80 WHERE D8_SEQ = '"+QRYCUSTO->D8_SEQ+"' AND D_E_L_E_T_ = '' ORDER BY D8_SEQCALC" 

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRYPROD",.T.,.T.)
QRYPROD->(dbGoTop())   

// Busca e calcula os itens do SD8
WHILE QRYPROD->(!EOF()) 

    If QRYPROD->D8_TIPONF == "N" .AND. QRYPROD->D8_TM < '500'
    	nqtd := QRYPROD->D8_QUANT
    	// Busca o ICMS da nota fiscal original
    	
		cQryD1 := " SELECT D1_VALICM FROM "+RetSqlName("SD1")+" SD1 WHERE D1_FILIAL = '"+SD2->D2_FILIAL+"' AND D1_DOC = '"+QRYPROD->D8_DOC+ "'"
		cQryD1 += " AND D1_SERIE = '"+QRYCUSTO->C9_SERIENF+"' AND D1_COD = '"+QRYCUSTO->C9_PRODUTO+"' "
		cQryD1 += " AND D1_LOCAL = '"+QRYCUSTO->C9_LOCAL+"' AND D_E_L_E_T_ = '' " 

		cQryD1 := ChangeQuery(cQryD1)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryD1),"QRYD1",.T.,.T.)
		QRYD1->(dbGoTop())   
    	nValIcms := QRYD1->D1_VALICM                                                                                         
    	
	ElseIf QRYPROD->D8_TIPONF == "C"
		nFrete	:= ( QRYPROD->D8_CUSTO1 / nqtd ) * SD2->D2_QUANT 
	ElseIf QRYPROD->D8_TIPONF == "P"
		nPedagio := (QRYPROD->D8_CUSTO1 / nqtd) * SD2->D2_QUANT
	ElseIf QRYPROD->D8_TIPONF == "N" .AND. QRYPROD->D8_DOC == QRYCUSTO->C9_NFISCAL
		nICMST :=  (nValIcms / nqtd ) * SD2->D2_QUANT
		nCusto	:= QRYPROD->D8_CUSTO1 / SD2->D2_QUANT /////QRYPROD->D8_QUANT

	Endif

	QRYPROD->(dbSkip())
	
EndDo 

RestArea(aArea)

QRYCUSTO->(dbclosearea())
QRYPROD->(dbclosearea())              
QRYD1->(dbclosearea())

If nTipo == "1" // Retorna o Valor do Frete    
	Return(nFrete)                             
ElseIf nTipo == "2" // Retorna o Valor do Pedágio
	Return(nPedagio)                        
ElseIf nTipo == "3" // Retorna o Valor do Custo
	nCTotal := nCusto ////- nFrete - nPedagio - nICMST
	Return(nCTotal)
ElseIf nTipo == "4" // valor do icms   
	Return(nICMST)
Endif



Return
