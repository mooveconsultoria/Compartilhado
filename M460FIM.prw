#Include 'Protheus.ch'

/*
Programa.: SF2460I
Autor....: Danilo José Grodzicki
Data.....: 22/07/2016 
Descricao: Este P.E. e' chamado apos a Gravacao da NF de Saida, e fora da transação.
Uso......: AIR BP BRASIL LTDA
*/
User Function M460FIM()

Local nI
Local cQuery
Local dDtAux
Local cSd2Key
Local dDtVencto

Local aSd2      := {}
Local aDadosSE1 := {}
Local cAliasTmp := GetNextAlias()
Local aAreaSA1  := SA1->(GetArea())
Local aAreaSE1  := SE1->(GetArea())
Local aAreaSE4  := SE4->(GetArea())
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSD2  := SD2->(GetArea())

DbSelectArea("SA1")
SA1->(DbSetOrder(01))

DbSelectArea("SE1")
SE1->(DbSetOrder(02))

DbSelectArea("SE4")
SE4->(DbSetOrder(01))

DbSelectArea("SC5")
SC5->(DbSetOrder(01))

DbSelectArea("SD2")
SD2->(DbSetOrder(03))

if SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))  // Grava o D3_NUMSEQ no SD2
	if SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
		if !(SC5->C5_TIPO == "C" .or. SC5->C5_TIPO == "I" .or. SC5->C5_TIPO == "P")
			while SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA .and. SD2->(!Eof())
				cSd2Key   := SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_ITEM
				cQuery    := ""
				cAliasTmp := GetNextAlias()
				cQuery    := "SELECT SUBSTR(SD3.D3_XSD2KEY,1,9) AS DOC, "
				cQuery    += "             SUBSTR(SD3.D3_XSD2KEY,10,3) AS SERIE, "
				cQuery    += "             SUBSTR(SD3.D3_XSD2KEY,13,6) AS CLIENTE, "
				cQuery    += "             SUBSTR(SD3.D3_XSD2KEY,19,2) AS LOJA, "
				cQuery    += "             SUBSTR(SD3.D3_XSD2KEY,21,2) AS ITEM, "
				cQuery    += "             SD3.D3_NUMSEQ AS NUMSEQ "
				cQuery    += "FROM "+RetSqlName("SD3")+" SD3 "
				cQuery    += "WHERE SD3.D_E_L_E_T_ <> '*' "
				cQuery    += "     AND SD3.D3_FILIAL = '"+xFilial("SD3")+"' "
				cQuery    += "     AND SD3.D3_XSD2KEY = '"+cSd2Key+"'"
				cQuery    := ChangeQuery(cQuery) 
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
				(cAliasTmp)->(DbGoTop())
				while (cAliasTmp)->(!Eof())
					aadd(aSd2,{AllTrim((cAliasTmp)->DOC),AllTrim((cAliasTmp)->SERIE),AllTrim((cAliasTmp)->CLIENTE),AllTrim((cAliasTmp)->LOJA),;
						        SD2->D2_COD,AllTrim((cAliasTmp)->ITEM),AllTrim((cAliasTmp)->NUMSEQ)})
					(cAliasTmp)->(DbSkip())
				enddo
				(cAliasTmp)->( dbCloseArea() )
				If Select(cAliasTmp) == 0
					Ferase(cAliasTmp+GetDBExtension())
				Endif
				if Len(aSd2) > 0
					for nI = 1 to Len(aSd2)
						if SD2->(DbSeek(xFilial("SD2")+aSd2[nI][01]+aSd2[nI][02]+aSd2[nI][03]+aSd2[nI][04]+aSd2[nI][05]+aSd2[nI][06]))
							If RecLock("SD2",.F.)
								SD2->D2_XSD3SEQ := aSd2[nI][07]  // Grava o D3_NUMSEQ no SD2
								SD2->(MsUnlock())
							endif
						endif
					next
				endif
				SD2->(DbSkip())
			enddo
		endif
	endif
endif


cQuery    := ""
cAliasTmp := GetNextAlias()
cQuery    := "SELECT SE1.E1_CLIENTE AS CLIENTE, "
cQuery    += "       SE1.E1_LOJA AS LOJA, "
cQuery    += "       SE1.E1_EMISSAO AS EMISSAO, "
cQuery    += "       SE1.R_E_C_N_O_ AS RECNO "
cQuery    += "FROM "+RetSqlName("SE1")+" SE1 "
cQuery    += "WHERE SE1.D_E_L_E_T_ <> '*' "
cQuery    += "  AND SE1.E1_FILIAL = '"+xFilial("SE1")+"' "
cQuery    += "  AND SE1.E1_FILORIG = '"+xFilial("SF2")+"' "
cQuery    += "  AND SE1.E1_NUM = '"+SF2->F2_DOC+"' "
cQuery    += "  AND SE1.E1_CLIENTE = '"+SF2->F2_CLIENTE+"' "
cQuery    += "  AND SE1.E1_LOJA = '"+SF2->F2_LOJA+"'"
cQuery    += "  AND RTRIM(SUBSTR(SE1.E1_PREFIXO,1,2)) = '"+SUBSTR(SF2->F2_FILIAL,5,2)+"'"
cQuery    := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
(cAliasTmp)->(DbGoTop())
while (cAliasTmp)->(!Eof())
	aadd(aDadosSE1,{(cAliasTmp)->CLIENTE, (cAliasTmp)->LOJA, CtoD(Right((cAliasTmp)->EMISSAO,2)+"/"+Subs((cAliasTmp)->EMISSAO,5,2)+"/"+Left((cAliasTmp)->EMISSAO,4)),;
	             (cAliasTmp)->RECNO})
	(cAliasTmp)->(DbSkip())
enddo
(cAliasTmp)->( dbCloseArea() )
If Select(cAliasTmp) == 0
	Ferase(cAliasTmp+GetDBExtension())
Endif

if Len(aDadosSE1) > 0
	for nI = 1 to Len(aDadosSE1)
		if SA1->(DbSeek(xFilial("SA1")+aDadosSE1[nI][01]+aDadosSE1[nI][02]))
			if SE4->(DbSeek(xFilial("SE4")+SA1->A1_COND))
				dDtVencto := CtoD("")
				dDtAux    := CtoD("")
				if SE4->E4_DDD == "S"  // Semanal
					if Day(aDadosSE1[nI][03]) >= 1 .and. Day(aDadosSE1[nI][03]) <= 7        // Semana de 01 a 07
						dDtVencto := CtoD("08/"+Subs(DtoS(aDadosSE1[nI][03]),5,2)+"/"+Left(DtoS(aDadosSE1[nI][03]),4)) + (Val(SE4->E4_COND)-1)
					elseif Day(aDadosSE1[nI][03]) >= 8 .and. Day(aDadosSE1[nI][03]) <= 14   // Semana de 08 a 14
						dDtVencto := CtoD("15/"+Subs(DtoS(aDadosSE1[nI][03]),5,2)+"/"+Left(DtoS(aDadosSE1[nI][03]),4)) + (Val(SE4->E4_COND)-1)
					elseif Day(aDadosSE1[nI][03]) >= 14 .and. Day(aDadosSE1[nI][03]) <= 21  // Semana de 15 a 21
						dDtVencto := CtoD("22/"+Subs(DtoS(aDadosSE1[nI][03]),5,2)+"/"+Left(DtoS(aDadosSE1[nI][03]),4)) + (Val(SE4->E4_COND)-1)
					elseif Day(aDadosSE1[nI][03]) > 21                                    // Semana de 21 até o último dia do mês
						dDtAux    := aDadosSE1[nI][03] + 30
						dDtVencto := CtoD("01/"+Subs(DtoS(dDtAux),5,2)+"/"+Left(DtoS(dDtAux),4)) + (Val(SE4->E4_COND)-1)
					endif					
				endif
			endif
		endif
		SE1->(DbGoTo(aDadosSE1[nI][04]))
		If RecLock("SE1",.F.)
			if !Empty(dDtVencto)
				SE1->E1_VENCTO  := dDtVencto
				SE1->E1_VENCREA := dDtVencto
				SE1->E1_VENCORI := dDtVencto
			else
				SE1->E1_VENCREA := SE1->E1_VENCTO
			endif
			SE1->E1_XPREORI := SF2->F2_SERIE
			SE1->(MsUnlock())
		endif
	next
endif

/*  se o trecho acima for comentado, descomentar o abaixo Julio Négri - 09/08/17
If RecLock("SE1",.F.)
	SE1->E1_XPREORI := SF2->F2_SERIE
	SE1->(MsUnlock())
endif
*/

RestArea(aAreaSA1)
RestArea(aAreaSE1)
RestArea(aAreaSE4)
RestArea(aAreaSC5)
RestArea(aAreaSD2)

Return Nil