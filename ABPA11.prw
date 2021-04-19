#Include "Totvs.Ch"
#Include "TopConn.Ch"

STATIC cDirErro	:= "\erro_msexecauto\"
STATIC cDirFunc	:= "ABPA11\"

//--------------------------------------------------
/*/{Protheus.doc} ABPA11
Rotina para processamento do Faturamento Aglutinado

@trello ID09 - Api para faturamento aglutinado

@author Irineu Filho
@since 18/05/2019 - 21:55
/*/
//--------------------------------------------------
User Function ABPA11(aPedidos)

Local aValPedidos	:= {}
Local aGeraNota		:= {}
Local lRetorno		:= .F.
Local cMsgRetorno	:= ""
Local cSerie        := ""

Default aPedidos	:= {}

makedir(cDirErro)
makedir(cDirErro+cDirFunc)

If Len(aPedidos) > 0

	// Checa liberacao dos pedidos envolvidos
	chkLib( aPedidos )

	aValPedidos := FValPedidos(aPedidos)

	If aValPedidos[1]

		aGeraNota := FGeraNotaSaida(aValPedidos[2])
		If aGeraNota[1]
			lRetorno := .T.
			cMsgRetorno  := aGeraNota[2]
			cSerie  := aGeraNota[3]
		Else
			lRetorno := .F.
			cMsgRetorno := aGeraNota[2]
		EndIf

	Else
		lRetorno := .F.
		cMsgRetorno := aValPedidos[2]
	EndIf

Else

	lRetorno := .F.
	cMsgRetorno := ""
	cMsgRetorno += "Filial: " + cFilPar + CRLF
	cMsgRetorno += "Documento: " + cDocPar + CRLF
	cMsgRetorno += "Serie: " + cSeriePar + CRLF
	cMsgRetorno += "Chave Pesquisa: " + cFilPar + cDocPar + cSeriePar + CRLF
	cMsgRetorno += "NOTA FISCAL DE SAIDA NÃO ENCONTRADA!"

EndIf

Return {lRetorno, cMsgRetorno, cSerie}

//-------------------------------------------------------------------
/*/{Protheus.doc} chkLib
Funcao para tratar liberacao do pedido de venda
@author  DS2U (SDA)
@since   25/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function chkLib( aPedidos )

Local aArea := getArea()
Local nlx

for nlx := 1 to len( aPedidos )

	// Caso os pedidos nao tenham liberacao
	// relazia a liberação item a
	U_ABPA05( aPedidos[nlx] )

next nlx

restArea( aArea )

Return


//--------------------------------------------------
/*/{Protheus.doc} FValPedidos
Função para validação dos array de pedidos.

@author Irineu Filho
@since 18/05/2019 - 22:04
/*/
//--------------------------------------------------
Static Function FValPedidos(aPedidosPar)

Local cQuery		:= ""
Local aRetorno 		:= { Nil , Nil }
Local nTotPedidos	:= Len(aPedidosPar)
Local aVolume		:= { {} , {} , {} , {} }
Local aCFOP			:= {}
Local aRetOper		:= {}
Local aLiberacao	:= {}
Local aMoeda		:= {}
Local aSugEntrega	:= {}
Local aEntrega		:= {}
Local aRecISS		:= {}
Local aIncISS		:= {}
Local aTransp		:= {}
Local aTipoCond		:= {}
Local aCondPagto	:= {}
Local aVendedores	:= {}
Local aEntCli		:= {}
Local aTipoPed		:= {}
Local aFatCli		:= {}
Local aAux			:= {}
Local aItensFat		:= {}
Local aPedControle		:= {}
Local cMsgRetOper	:= ""
Local cMsgLib		:= ""
Local cPedidoIN		:= ""
Local nX			:= 0

Default aPedidosPar := {}

cPedidoIN := ""
For nX := 1 To Len(aPedidosPar)

	cPedidoIN += aPedidosPar[nX]

	If nX <> Len(aPedidosPar)
		cPedidoIN += ";"
	EndIf

Next nX
cPedidoIN := FormatIn(cPedidoIN,";")

cQuery := ""
cQuery += " SELECT	C5_NUM, "
cQuery += " 		C5_TIPO, "
cQuery += " 		C5_CLIENTE, C5_LOJACLI, "
cQuery += " 		C5_CLIENT, C5_LOJAENT, "
cQuery += " 		C5_VEND1, C5_VEND2, C5_VEND3, C5_VEND4, C5_VEND5, "
cQuery += " 		C5_CONDPAG, "
cQuery += " 		C5_TRANSP, C5_TPFRETE, C5_VOLUME1, C5_VOLUME2, C5_VOLUME3, C5_VOLUME4, "
cQuery += " 		C5_INCISS, "
cQuery += " 		C5_RECISS, "
cQuery += " 		C6_ENTREG, "
cQuery += " 		C6_SUGENTR, "
cQuery += " 		C6_ITEM, "
cQuery += " 		C5_MOEDA, "
cQuery += " 		C9_BLEST, C9_BLCRED, "
cQuery += " 		E4_TIPO, "
cQuery += " 		B1_RETOPER, C9_RETOPER, "
cQuery += " 		C6_CF, "
cQuery += " 		C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_QTDLIB, C9_PRCVEN, C9_PRODUTO, "
cQuery += " 		SC9.R_E_C_N_O_ AS RECSC9, SC5.R_E_C_N_O_ RECSC5, SC6.R_E_C_N_O_ AS RECSC6, "
cQuery += " 		SE4.R_E_C_N_O_ AS RECSE4 , SB1.R_E_C_N_O_ AS RECSB1, SB2.R_E_C_N_O_ AS RECSB2, SF4.R_E_C_N_O_ AS RECSF4 "

cQuery += " FROM " + RetSqlName("SC5") + " SC5 "

cQuery += " LEFT JOIN " + RetSqlName("SC6") + " SC6 "
cQuery += " ON C6_FILIAL = C5_FILIAL "
cQuery += " AND C6_NUM = C5_NUM "
cQuery += " AND SC6.D_E_L_E_T_ = ' ' "

cQuery += " LEFT JOIN " + RetSqlName("SC9") + " SC9 "
cQuery += " ON C9_FILIAL = C6_FILIAL
cQuery += " AND C9_PEDIDO = C6_NUM "
cQuery += " AND C9_ITEM = C6_ITEM "
cQuery += " AND SC9.D_E_L_E_T_ = ' ' "

cQuery += " LEFT JOIN " + RetSqlName("SB2") + " SB2 "
cQuery += " ON B2_FILIAL = '" + xFilial("SB2") + "'"
cQuery += " AND B2_COD = C6_PRODUTO "
cQuery += " AND B2_LOCAL = C6_LOCAL "
cQuery += " AND SB2.D_E_L_E_T_ = ' ' "

cQuery += " LEFT JOIN " + RetSqlName("SF4") + " SF4 "
cQuery += " ON F4_FILIAL = '" + xFilial("SF4") + "'"
cQuery += " AND F4_CODIGO = C6_TES "
cQuery += " AND SF4.D_E_L_E_T_ = ' ' "

cQuery += " LEFT JOIN " + RetSqlName("SE4") + " SE4 "
cQuery += " ON E4_FILIAL = '" + xFilial("SE4") + "' "
cQuery += " AND E4_CODIGO = C5_CONDPAG "
cQuery += " AND SE4.D_E_L_E_T_ = ' ' "

cQuery += " LEFT JOIN " + RetSqlName("SB1") + " SB1 "
cQuery += " ON B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += " AND B1_COD = C6_PRODUTO "
cQuery += " AND SB1.D_E_L_E_T_ = ' ' "

cQuery += " WHERE C5_FILIAL = '" + xFilial("SC5") + "' "

cQuery += " AND C5_NUM IN " + cPedidoIN
cQuery += " AND C6_QTDVEN > C6_QTDENT "
cQuery += " AND E4_TIPO <> '9' "
cQuery += " AND SC5.D_E_L_E_T_ = ' ' "

cQuery += " ORDER BY C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_CLIENT "

If Select('TMPPED') > 0
	TMPPED->(dbCloseArea())
EndIf

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., 'TOPCONN', TcGenQry(NIL, NIL, cQuery), 'TMPPED', .T., .F.)

If TMPPED->(!EOF())

	While TMPPED->(!EOF())

		If	TMPPED->RECSC9 > 0 .AND. TMPPED->RECSC5 > 0 .AND. TMPPED->RECSC6 > 0 .AND.;
		TMPPED->RECSE4 > 0 .AND. TMPPED->RECSB1 > 0 .AND. TMPPED->RECSB2 > 0 .AND. TMPPED->RECSF4 > 0

			//----------------------------
			//Validação do Tipo do Pedido.
			//----------------------------
			nPosAux := aScan(aTipoPed,{|x| x[1] == TMPPED->C5_TIPO })
			If nPosAux == 0
				Aadd(aTipoPed,{ TMPPED->C5_TIPO , TMPPED->C5_NUM})
			EndIf

			//------------------------------------
			//Validação do Cliente de Faturamento.
			//------------------------------------
			nPosAux := aScan(aFatCli,{|x| x[1] == TMPPED->C5_CLIENTE+"-"+TMPPED->C5_LOJACLI })
			If nPosAux == 0
				Aadd(aFatCli,{ TMPPED->C5_CLIENTE+"-"+TMPPED->C5_LOJACLI , TMPPED->C5_NUM})
			EndIf

			//--------------------------------
			//Validação do Cliente de Entrega.
			//--------------------------------
			nPosAux := aScan(aEntCli,{|x| x[1] == TMPPED->C5_CLIENT+"-"+TMPPED->C5_LOJAENT })
			If nPosAux == 0
				Aadd(aEntCli,{ TMPPED->C5_CLIENT+"-"+TMPPED->C5_LOJAENT ,TMPPED->C5_NUM})
			EndIf

			//-------------------------
			//Validação dos Vendedores.
			//-------------------------
			nPosAux := aScan(aVendedores,{|x| x[1] == TMPPED->C5_VEND1+"/"+TMPPED->C5_VEND2+"/"+TMPPED->C5_VEND3+"/"+TMPPED->C5_VEND4+"/"+TMPPED->C5_VEND5 })
			If nPosAux == 0
				Aadd(aVendedores, { TMPPED->C5_VEND1+"/"+TMPPED->C5_VEND2+"/"+TMPPED->C5_VEND3+"/"+TMPPED->C5_VEND4+"/"+TMPPED->C5_VEND5 ,TMPPED->C5_NUM})
			EndIf

			//-----------------------------------
			//Validação da Condição de Pagamento.
			//-----------------------------------
			nPosAux := aScan(aCondPagto,{|x| x[1] == TMPPED->C5_CONDPAG })
			If nPosAux == 0
				Aadd(aCondPagto, { TMPPED->C5_CONDPAG ,TMPPED->C5_NUM})
			EndIf

			//----------------------------------------
			//Validação da Tipo Condição de Pagamento.
			//----------------------------------------
			nPosAux := aScan(aTipoCond,{|x| x[1] == TMPPED->E4_TIPO })
			If nPosAux == 0
				Aadd(aTipoCond, { TMPPED->E4_TIPO ,TMPPED->C5_NUM})
			EndIf

			//-----------------------------------
			//Validação da Transportadora.
			//-----------------------------------
			nPosAux := aScan(aTransp,{|x| x[1] == TMPPED->C5_TRANSP + "-" + TMPPED->C5_TPFRETE })
			If nPosAux == 0
				Aadd(aTransp, { TMPPED->C5_TRANSP + "-" + TMPPED->C5_TPFRETE ,TMPPED->C5_NUM})
			EndIf

			//--------------------
			//Validação do Volume.
			//--------------------
			For nX := 1 To 4

				cCpoAtu := "TMPPED->C5_VOLUME" + Alltrim(cValToChar(nX))
				nVolume := &(cCpoAtu)

				nPosAux := aScan(aVolume[nX],{|x| x[1] == nVolume })
				If nPosAux == 0
					Aadd(aVolume[nX], { nVolume ,TMPPED->C5_NUM})
				EndIf

			Next nX

			//-------------------------
			//Validação da Iss incluso.
			//-------------------------
			nPosAux := aScan(aIncISS,{|x| x[1] == TMPPED->C5_INCISS })
			If nPosAux == 0
				Aadd(aIncISS, { TMPPED->C5_INCISS ,TMPPED->C5_NUM})
			EndIf

			//-------------------------
			//Validação da Iss incluso.
			//-------------------------
			nPosAux := aScan(aRecISS,{|x| x[1] == TMPPED->C5_RECISS })
			If nPosAux == 0
				Aadd(aRecISS, { TMPPED->C5_RECISS ,TMPPED->C5_NUM})
			EndIf

			//-------------------------
			//Validação da Entrega.
			//-------------------------
			nPosAux := aScan(aEntrega,{|x| x[1] == STOD(TMPPED->C6_ENTREG) })
			If nPosAux == 0
				Aadd(aEntrega, { STOD(TMPPED->C6_ENTREG) ,TMPPED->C5_NUM + "-" + TMPPED->C6_ITEM })
			EndIf

			/*
			//------------------------------
			//Validação da Entrega Sugerida.
			//------------------------------
			nPosAux := aScan(aSugEntrega,{|x| x[1] == STOD(TMPPED->C6_SUGENTR) })
			If nPosAux == 0
			Aadd(aSugEntrega, { STOD(TMPPED->C6_SUGENTR) ,TMPPED->C5_NUM + "-" + TMPPED->C6_ITEM })
			EndIf
			*/

			//------------------------------
			//Validação da Moeda.
			//------------------------------
			nPosAux := aScan(aMoeda,{|x| x[1] == TMPPED->C5_MOEDA })
			If nPosAux == 0
				Aadd(aMoeda, { TMPPED->C5_MOEDA ,TMPPED->C5_NUM })
			EndIf

			//---------------------------
			//Validação da Liberação SC9.
			//---------------------------
			If !(Empty(TMPPED->C9_BLEST) .AND. Empty(TMPPED->C9_BLCRED))
				cMsgLib := "ITEM NAO LIBERADO"
			EndIf

			If !Empty(cMsgLib)
				nPosAux := aScan(aLiberacao,{|x| x[1] == cMsgLib })
				If nPosAux == 0
					Aadd(aLiberacao, { cMsgLib ,TMPPED->C5_NUM + "-" + TMPPED->C6_ITEM })
				EndIf
			EndIf

			/*
			//-----------------------
			//Validação da Ret. Oper.
			//-----------------------
			If !(TMPPED->B1_RETOPER == "2" .AND. TMPPED->C9_RETOPER == "2")
			cMsgRetOper := "RETOPER NAO OK"
			EndIf

			If !Empty(cMsgRetOper)
			nPosAux := aScan(aRetOper,{|x| x[1] == cMsgRetOper })
			If nPosAux == 0
			Aadd(aRetOper, { cMsgRetOper ,TMPPED->C5_NUM + "-" + TMPPED->C6_ITEM })
			EndIf
			EndIf
			*/

			/*
			//---------------
			//Validação CFOP.
			//---------------
			nPosAux := aScan(aCFOP,{|x| x[1] == TMPPED->C6_CF })
			If nPosAux == 0
			Aadd(aCFOP, { TMPPED->C6_CF ,TMPPED->C5_NUM + "-" + TMPPED->C6_ITEM })
			EndIf
			*/

			//-------------------------------
			//Informações para Geração da NF.
			//-------------------------------
			aAux := {}
			Aadd(aAux,TMPPED->C9_PEDIDO)
			Aadd(aAux,TMPPED->C9_ITEM)
			Aadd(aAux,TMPPED->C9_SEQUEN)
			Aadd(aAux,TMPPED->C9_QTDLIB)

			nPrcVen := TMPPED->C9_PRCVEN
			If ( TMPPED->C5_MOEDA <> 1 )
				nPrcVen := xMoeda(nPrcVen,TMPPED->C5_MOEDA,1,MsDate())
			EndIf
			Aadd(aAux,nPrcVen)
			Aadd(aAux,TMPPED->C9_PRODUTO)
			Aadd(aAux,.F.)
			Aadd(aAux,TMPPED->RECSC9)
			Aadd(aAux,TMPPED->RECSC5)
			Aadd(aAux,TMPPED->RECSC6)
			Aadd(aAux,TMPPED->RECSE4)
			Aadd(aAux,TMPPED->RECSB1)
			Aadd(aAux,TMPPED->RECSB2)
			Aadd(aAux,TMPPED->RECSF4)

			Aadd( aItensFat , ACLONE(aAux) )

			If	Len(aTipoPed) == 1		.AND. Len(aFatCli) == 1		.AND. Len(aEntCli) == 1		.AND. Len(aVendedores) == 1	.AND.;
			Len(aCondPagto) == 1	.AND. Len(aTipoCond) == 1	.AND. Len(aTransp) == 1		.AND. Len(aVolume[1]) == 1	.AND.;
			Len(aVolume[2]) == 1	.AND. Len(aVolume[3]) == 1	.AND. Len(aVolume[4]) == 1	.AND. Len(aIncISS) == 1		.AND.;
			Len(aRecISS) == 1		.AND. Len(aEntrega) == 1	.AND. Len(aSugEntrega) == 0	.AND. Len(aMoeda) == 1		.AND.;
			Len(aLiberacao) == 0	.AND. Len(aRetOper) == 0	.AND. Len(aCFOP) == 0

				//------------------
				//Controle dos Pedidos
				//------------------
				nPosAux := aScan(aPedControle, TMPPED->C5_NUM )
				If nPosAux == 0
					Aadd(aPedControle, TMPPED->C5_NUM)
				EndIf

			EndIf

		Else

			aRetorno[1] := .F.
			aRetorno[2] := "INFORMAÇÕES VINCULADAS AO PEDIDO NÃO ENCONTRADA: " + CRLF

			If TMPPED->RECSC9 == 0
				aRetorno[2] += "LIBERAÇÃO DE PEDIDO (SC9) NÃO ENCONTRADO" + CRLF
			EndIf

			If TMPPED->RECSC5 == 0
				aRetorno[2] += "PEDIDO DE VENDAS (SC5) NÃO ENCONTRADO" + CRLF
			Endif

			If TMPPED->RECSC6 == 0
				aRetorno[2] += "ITENS DO PEDIDO DE VENDAS (SC6) NÃO ENCONTRADO" + CRLF
			EndIf

			If TMPPED->RECSE4 == 0
				aRetorno[2] += "CONDIÇÃO DE PAGAMENTO (SE4) NÃO ENCONTRADO" + CRLF
			EndIf

			If TMPPED->RECSB1 == 0
				aRetorno[2] += "PRODUTO (SB1) NÃO ENCONTRADO" + CRLF
			EndIf

			If TMPPED->RECSB2 == 0
				aRetorno[2] += "SALDO EM ESTOQUE (SB2) NÃO ENCONTRADO" + CRLF
			EndIf

			If TMPPED->RECSF4 == 0
				aRetorno[2] += "TES (SF4) NÃO ENCONTRADO" + CRLF
			EndIf

			aRetorno[2] += "Query: " + cQuery + CRLF

			aPedControle := {}

			Exit

		EndIf

		TMPPED->(dbSkip())

	EndDo

	If Len(aPedControle) == nTotPedidos
		aRetorno[1] := .T.
		aRetorno[2] := ACLONE(aItensFat)
	ElseIf aRetorno[1] == Nil
		aRetorno[1] := .F.
		aRetorno[2] := "PROBLEMAS FORAM ENCONTRADOS AO VALIDAR OS PEDIDOS ENVIADOS (" + cPedidoIN + "):" + CRLF

		If Len(aTipoPed) > 1
			For nX := 1 To Len(aTipoPed)
				aRetorno[2] += "PEDIDO: " + aTipoPed[nX][2] + " - C5_TIPO: " + aTipoPed[nX][1] + CRLF
			Next nX
			aRetorno[2] += Replicate("-",10) + CRLF
		EndIf

		If Len(aFatCli) > 1
			For nX := 1 To Len(aFatCli)
				aRetorno[2] += "PEDIDO: " + aFatCli[nX][2] + " - C5_CLIENTE+C5_LOJACLI: " + aFatCli[nX][1] + CRLF
			Next nX
			aRetorno[2] += Replicate("-",10) + CRLF
		EndIf

		If Len(aEntCli) > 1
			For nX := 1 To Len(aEntCli)
				aRetorno[2] += "PEDIDO: " + aEntCli[nX][2] + " - C5_CLIENT+C5_LOJAENT: " + aEntCli[nX][1] + CRLF
			Next nX
			aRetorno[2] += Replicate("-",10) + CRLF
		EndIf

		If Len(aVendedores) > 1
			For nX := 1 To Len(aVendedores)
				aRetorno[2] += "PEDIDO: " + aVendedores[nX][2] + " - C5_VEND1+C5_VEND2+C5_VEND3+C5_VEND4+C5_VEND5: " + aVendedores[nX][1] + CRLF
			Next nX
			aRetorno[2] += Replicate("-",10) + CRLF
		EndIf

		If Len(aCondPagto) > 1
			For nX := 1 To Len(aCondPagto)
				aRetorno[2] += "PEDIDO: " + aCondPagto[nX][2] + " - C5_CONDPAG: " + aCondPagto[nX][1] + CRLF
			Next nX
			aRetorno[2] += Replicate("-",10) + CRLF
		EndIf

		If Len(aTipoCond) > 1
			For nX := 1 To Len(aTipoCond)
				aRetorno[2] += "PEDIDO: " + aTipoCond[nX][2] + " - E4_TIPO: " + aTipoCond[nX][1] + CRLF
			Next nX
			aRetorno[2] += Replicate("-",10) + CRLF
		EndIf

		If Len(aTransp) > 1
			For nX := 1 To Len(aTransp)
				aRetorno[2] += "PEDIDO: " + aTransp[nX][2] + " - C5_TRANSP+C5_TPFRETE: " + aTransp[nX][1] + CRLF
			Next nX
			aRetorno[2] += Replicate("-",10) + CRLF
		EndIf

		If Len(aVolume[1]) > 1
			For nX := 1 To Len(aVolume[1])
				aRetorno[2] += "PEDIDO: " + aVolume[1][nX][2] + " - C5_VOLUME1: " + cValToChar(aVolume[1][nX][1]) + CRLF
			Next nX
			aRetorno[2] += Replicate("-",10) + CRLF
		EndIf

		If Len(aVolume[2]) > 1
			For nX := 1 To Len(aVolume[2])
				aRetorno[2] += "PEDIDO: " + aVolume[2][nX][2] + " - C5_VOLUME2: " + cValToChar(aVolume[2][nX][1]) + CRLF
			Next nX
			aRetorno[2] += Replicate("-",10) + CRLF
		EndIf

		If Len(aVolume[3]) > 1
			For nX := 1 To Len(aVolume[3])
				aRetorno[2] += "PEDIDO: " + aVolume[3][nX][2] + " - C5_VOLUME3: " + cValToChar(aVolume[3][nX][1]) + CRLF
			Next nX
			aRetorno[2] += Replicate("-",10) + CRLF
		EndIf

		If Len(aVolume[4]) > 1
			For nX := 1 To Len(aVolume[4])
				aRetorno[2] += "PEDIDO: " + aVolume[4][nX][2] + " - C5_VOLUME4: " + cValToChar(aVolume[4][nX][1]) + CRLF
			Next nX
			aRetorno[2] += Replicate("-",10) + CRLF
		EndIf

		If Len(aIncISS) > 1
			For nX := 1 To Len(aIncISS)
				aRetorno[2] += "PEDIDO: " + aIncISS[nX][2] + " - C5_INCISS: " + aIncISS[nX][1] + CRLF
			Next nX
			aRetorno[2] += Replicate("-",10) + CRLF
		EndIf

		If Len(aRecISS) > 1
			For nX := 1 To Len(aRecISS)
				aRetorno[2] += "PEDIDO: " + aRecISS[nX][2] + " - C5_RECISS: " + aRecISS[nX][1] + CRLF
			Next nX
			aRetorno[2] += Replicate("-",10) + CRLF
		EndIf

		If Len(aEntrega) > 1
			For nX := 1 To Len(aEntrega)
				aRetorno[2] += "PEDIDO: " + aEntrega[nX][2] + " - C6_ENTREG: " + cValToChar(aEntrega[nX][1]) + CRLF
			Next nX
			aRetorno[2] += Replicate("-",10) + CRLF
		EndIf

		/*
		If Len(aSugEntrega) > 1
		For nX := 1 To Len(aSugEntrega)
		aRetorno[2] += "PEDIDO: " + aSugEntrega[nX][2] + " - C6_SUGENTR: " + cValToChar(aSugEntrega[nX][1]) + CRLF
		Next nX
		aRetorno[2] += Replicate("-",10) + CRLF
		EndIf
		*/

		If Len(aMoeda) > 1
			For nX := 1 To Len(aMoeda)
				aRetorno[2] += "PEDIDO: " + aMoeda[nX][2] + " - C5_MOEDA: " + cValToChar(aMoeda[nX][1]) + CRLF
			Next nX
			aRetorno[2] += Replicate("-",10) + CRLF
		EndIf

		If Len(aLiberacao) > 0
			For nX := 1 To Len(aLiberacao)
				aRetorno[2] += "PEDIDO: " + aLiberacao[nX][2] + " - C9_BLEST+C9_BLCRED: " + cValToChar(aLiberacao[nX][1]) + CRLF
			Next nX
			aRetorno[2] += Replicate("-",10) + CRLF
		EndIf

		/*
		If Len(aRetOper) > 0
		For nX := 1 To Len(aRetOper)
		aRetorno[2] += "PEDIDO: " + aRetOper[nX][2] + " - B1_RETOPER+C9_RETOPER: " + aRetOper[nX][1] + CRLF
		Next nX
		aRetorno[2] += Replicate("-",10) + CRLF
		EndIf
		*/

		/*
		If Len(aCFOP) > 1
		For nX := 1 To Len(aCFOP)
		aRetorno[2] += "PEDIDO: " + aCFOP[nX][2] + " - C6_CF: " + aCFOP[nX][1] + CRLF
		Next nX
		aRetorno[2] += Replicate("-",10) + CRLF
		EndIf
		*/

	EndIf

Else

	aRetorno[1] := .F.
	aRetorno[2] := "PEDIDOS NÃO ENCONTRADOS" + CRLF
	aRetorno[2] += "Query: " + cQuery

EndIf

Return aRetorno

//--------------------------------------------------
/*/{Protheus.doc} FGeraNotaSaida
Função para a preparar o documento de Saída.

@author Irineu Filho
@since 25/05/2019 - 00:01
/*/
//--------------------------------------------------
Static Function FGeraNotaSaida(aItensFat)

Local aRetorno := { Nil, Nil, Nil }
Local cSerieFat := GetMV("BP_SERIEFT",,"001")
Local cDataHora := DTOS(MsDate()) + "_" + StrTran(Time(),":","") + "_" + Alltrim(Str(Randomize(1,9999)))
Local cArqErro	:= cDataHora + "FGeraNotaSaida.log"

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

cNota := MaPvlNfs(aItensFat,cSerieFat , .F.    , .F.    , .F.     , .T.    , .F.    , 0      , 0          , .T.  ,.F.,"")

If Empty(cNota) .OR. lMsErroAuto
	aRetorno[1] := .F.
	aRetorno[2] := MostraErro(cDirErro+cDirFunc,cArqErro)
	aRetorno[3] := ""
Else
	aRetorno[1] := .T.
	aRetorno[2] := cNota
	aRetorno[3] := cSerieFat
EndIf

Return aRetorno