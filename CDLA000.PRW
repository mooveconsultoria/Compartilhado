#include "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CLD000   ³ Autor ³ J.Marcelino            ³ Data ³31.03.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função de Gatilhos										   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Air BP					                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CDLA000()

Local cCodBombeio   := ""
Local cTipoTMD3	    := M->D3_TM
Local cTipoTMPR	    := AllTrim(GetMV("MV_XTMBOM"))
Local nQtdCorrigido := 0


User Function CDLA001()
/*±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para preencher código do bombeio no campo D3_DOC    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±*/

cCodPro	 	:= M->D3_COD
cCodBombeio	:= ""
cTipoTMD3		:= M->D3_TM
cTipoTMPR		:= AllTrim(GetMV("MV_XTMBOM"))

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+M->D3_COD))

Return(cCodBombeio)



User Function CDLA002()
/*±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para cálculo da quantidade corrigida a 20°C         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±*/

cCodPro		:= M->D3_COD
cCodBombeio  	:= ""
cTipoTMD3	   	:= M->D3_TM
cTipoTMPR		:= AllTrim(GetMV("MV_XTMBOM"))
nQtdCorrigido := 0

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+M->D3_COD))

If !Empty(SB1->B1_XGEN) .And. cTipoTMD3 $ cTipoTMPR
	nQtdCorrigido := M->D3_QUANT * (1+((M->D3_XTEMPAB-20)/100))
	M->D3_XVOL20  :=  nQtdCorrigido
EndIF

Return(nQtdCorrigido)




User Function CDLA003()
/*±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para cálculo da quantidade corrigida a 20°C         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±*/

Local lRet := .T.

Return(lRet)


User Function VLDARMAZ(cCodArm)
Local cQuery:= ""	// #9288

DbSelectArea("SBE")
SBE->(DbSetOrder(09))

lRet := .T.

If Empty(cCodArm)
	lRet := .F.
	msgstop("Endereço não informado!")
	Return(lRet)
EndIf

If !Empty(cCodArm) .and. !SBE->(DbSeek(xFilial("SBE")+cCodArm))
	lRet := .F.
	msgstop("Endereço não cadastrado!")
	Return(lRet)
EndIf

If AllTrim(FunName()) == "RDCLA07"										//	processo de medições
	If SBE->BE_XSERVD == "S"
		lRet := .F.
		msgstop("Endereço de Servidor não pode ser utilizado!")
		Return(lRet)
	EndIf
Else
	If AllTrim(FunName()) <> "RDCLA06" .And. AllTrim(FunName()) <> "RDCLA08"
		If SBE->BE_XSERVD == "S"
			lRet := .F.
			msgstop("Endereço de Servidor não pode ser utilizado!")
			Return(lRet)
		EndIf
	EndIf
	
	If AllTrim(FunName()) <> "RDCLA02"
		If AllTrim(FunName()) <> "RDCLA06" 
			If SBE->BE_XPADRAO == "S"		// para bombeio tem que ser padrão e não pode ser servidor.
				lRet := .F.
				msgstop("Endereço Padrão não pode ser utilizado!")
				Return(lRet)
			EndIf
		EndIf
	EndIf
	
	If AllTrim(FunName()) == "RDCLA02"
		If SBE->BE_XPADRAO <> "S"		// para bombeio tem que ser padrão e não pode ser servidor.
			lRet := .F.
			msgstop("Endereço Não é Padrão!   não pode ser utilizado para Bombeio!")
			Return(lRet)
		EndIf
	EndIf
EndIf

cDescArm	:= SBE->BE_DESCRIC
cLocal 		:= SBE->BE_LOCAL
nMeterOri	:= SBE->BE_XMETER
nQtde02		:= 0

SBF->(dbSetOrder(1))
SBF->(dbSeek(xFilial("SBF")+cLocal+cCodArm))

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+SBF->BF_PRODUTO))

If AllTrim(FunName()) == "RDCLA07"
	cCodPro := Iif(!Empty(SB1->B1_XGEN),SB1->B1_XGEN,SB1->B1_COD)	//SBF->BF_PRODUTO
Else
//	cCodPro := SBF->BF_PRODUTO

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+cCodPro))
EndIf

If AllTrim(FunName()) == "RDCLA08"
	If !Eof()
		cCodPro := SBF->BF_PRODUTO
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+cCodPro))
		If !Empty(SB1->B1_XGEN)
			cCodPro := SB1->B1_XGEN
		EndIf
		//cUM 	:= SB1->B1_UM
		//cCodGen := SB1->B1_XGEN
		SBF->(dbSeek(xFilial("SBF")+cLocal+cCodArm+cCodPro))
		While !Eof() .And. SBF->BF_FILIAL == xFilial("SBF") .And. SBF->BF_LOCAL == cLocal .And. SBF->BF_LOCALIZ == cCodArm .And. SBF->BF_PRODUTO == cCodPro
			nQtde02+=(SBF->BF_QUANT-SBF->BF_EMPENHO)	
			SBF->(dbSkip())
		EndDo
	EndIf	
EndIf

//If SBF->BF_QUANT <= 0
//	lRet := .F.
//	msgstop("Endereço sem Saldo")
//	Return(lRet)
//EndIf
//cCodPro	:= SBF->BF_PRODUTO


//SB1->(dbSetOrder(1))
//SB1->(dbSeek(xFilial("SB1")+cCodPro))

cCodProJet 	:= SB1->B1_COD
cCodProGen 	:= SB1->B1_XGEN
cDescPro   	:= SB1->B1_DESC
cUM		   	:= SB1->B1_UM
cCodVl20_1	:= SB1->B1_XTAB1
cCodVl20_2	:= SB1->B1_XTAB2

If FunName() == "RDCLA07"
	//SBF->(dbSetOrder(1))
	//SBF->(dbSeek(xFilial("SBF")+cLocal+cCodArm+cCodPro))

    // #9288
//	cQuery := "SELECT SUM(BF_QUANT) AS QUANT FROM " + RetSqlName("SBF") + " WHERE BF_LOCAL ='" + cLocal + "' AND BF_LOCALIZ = '" + cCodArm + "' AND BF_PRODUTO = '" + cCodPro + "' and D_E_L_E_T_ = ''"
	cQuery := "SELECT SUM(BF_QUANT) AS QUANT FROM " + RetSqlName("SBF") + " WHERE BF_LOCAL ='" + cLocal + "' AND BF_LOCALIZ = '" + cCodArm + "' AND D_E_L_E_T_ = ''"
	cQuery := ChangeQuery(cQuery)
		
	If Select("TRB") > 0
		TRB->(DbCloseArea())
	Endif

	dbUseArea( .t., "TopConn", TCGenQry(,,cQuery),"TRB", .F., .F. )  	

//	If SBF->BF_QUANT == 0
	If TRB->QUANT == 0
		lRet := .F.
		msgstop(" Endereço sem Estoque ")
		Return(lRet)
	EndIf

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	Endif

EndIf

Return(cCodArm,cDescArm,nMeterOri)


User Function VLDTEMP()

lRet := .T.
//If AllTrim(FunName()) == "RDCLA02" 
//	If Empty(nTempAmb)
//		lRet := .F.
//		msgstop("Temperatura deve ser informada!")
	
//		Return(lRet)
//	EndIf
//EndIf
Return(nTempAmb)


User Function VLDDENS()

lRet := .T.
//If AllTrim(FunName()) == "RDCLA02" 
//	If Empty(nDensAmb)
//		lRet := .F.
//		msgstop("Densidade deve ser informada!")
	
//		Return(lRet)
//	EndIf
//EndIf

Return(nDensAmb)



User Function VLDPRO(cCodPro)

lRet := .T.
SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+cCodPro))
cCodProJet := SB1->B1_COD
if !Empty(SB1->B1_XGEN)
	cCodProGen := SB1->B1_XGEN
endif
cDescPro   := SB1->B1_DESC
cUM        := SB1->B1_UM
cCodVl20_1 := SB1->B1_XTAB1
cCodVl20_2 := SB1->B1_XTAB2

If AllTrim(FunName()) == "RDCLA02"				// inclusão de bombeio
	if AllTrim(SB1->B1_GRUPO) <> "01"  // grupo combustível
//	If Empty(SB1->B1_XGEN) 
		lRet := .F.
		msgstop( " Atencao! Este Produto não pertence ao grupo de combustível!!! ")
		Return(lRet)
/*
	Else
		cQuery := ""
		cQuery := "SELECT B1_COD, B1_XGEN"
		cQuery += "FROM "+RetSqlName("SB1")+" SB1  					"
		cQuery += "WHERE SB1.B1_FILIAL  = '"+XFilial("SB1")+"'		"
		cQuery += "AND SB1.B1_XGEN 	 = '" + SB1->B1_XGEN + "' 			"
		cQuery += "AND SB1.D_E_L_E_T_ <> '*' 						"
		cQuery := ChangeQuery( cQuery )
		
		If Select("TRB") > 0
			TRB->(DbClosearea())
		Endif
		dbUseArea( .t., "TopConn", TCGenQry(,,cQuery),"TRB", .F., .F. )

		If TRB->(Eof())
			lRet := .F.
			msgstop(" este produto não tem produtos relacionados (JET E  ou  JET N)! - Verifique")
			If Select("TRB") > 0
				TRB->(DbClosearea())
			Endif
			Return(lRet)
		EndIf
*/
	EndIf
EndIf
//If Empty(SB1->B1_XGEN) 
//	lRet := .F.
//	msgstop("Não Existe Produto Genérico! - Verifique")

//	Return(lRet)
//EndIf

//If !Empty(SB1->B1_XGEN) 
//	lRet := .F.
//	msgstop("Não Existe Produto Genérico! - Verifique")
//
//	Return(lRet)
//EndIf

//If Empty(SB1->B1_XTAB1) 
//	lRet := .F.
//	msgstop("Não Existe Tabela de Fator Cadastrada! - Verifique")
//
//	Return(lRet)
//EndIf

//If Empty(SB1->B1_XTAB2) 
//	lRet := .F.
//	msgstop("Não Existe Tabela de Fator Cadastrada! - Verifique")
//
//	Return(lRet)
//EndIf

if !Empty(SB1->B1_XGEN)
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+cCodProGen))
	cProGen := AllTrim(SB1->B1_DESC)
endif

Return(cDescPro)


User Function VLDQUANT(nQtde)

Local nFator

lRet := .T.

If AllTrim(FunName()) == "RDCLA06" //.Or. AllTrim(FunName()) == "RDCLA02"
	If Empty(nQtde)
		lRet := .F.
		msgstop("Quantidade deve ser informada!")
		Return(lRet)
	EndIf
	
Else
	If AllTrim(FunName()) <> "RDCLA07" 					// medição pode ser sem quantidade
//		If nTempAmb > 0 .and. nDensAmb > 0
			If nQtde <= 0  //Empty(nQtde)
				lRet := .F.
				msgstop("Quantidade deve ser informada!")
				Return(lRet)
			EndIf
//		Else
//			Return Nil
//		EndIf
	EndIf
	
	//U_VldVl20(cCodPro,nDensAmb,nTempAmb,nQtde,nQtdVol20)						//	função para calcular quantidades a 20ºC
	If nTempAmb > 0 .and. nDensAmb > 0
		If AllTrim(FunName()) == "RDCLA02" 
			If nTempAmb > 0 .or. nDensAmb > 0
				nFator		:= U_CorDen20(nDensAmb,nTempAmb)
				nQtdVol2X 	:= Round((nQtde*nFator),0)
				Return(nQtdVol2X)
			Else
				nQtdVol2X := Round(nQtde,0)
				Return(nQtdVol2X)
			EndIf
		
		Else
			If AllTrim(FunName()) == "RDCLA07" 
				nFator := U_CorDen20(nDensAmb,nTempAmb)
				nQtdVol2X := Round((nQtde*nFator),0)
			
				Return(nQtdVol2X)
			Else
				Return Nil
		
			EndIf
		EndIf
	else
		If AllTrim(FunName()) == "RDCLA02" .and. nTempAmb <= 0 .and. nDensAmb <= 0
			nQtdVol2X := Round(nQtde,0)
			Return(nQtdVol2X)
		endif
	EndIf
EndIf

Return Nil


//User Function VLDVL20(cCodPro,nDensAmb,nTempAmb,nQtde,nQtdVol20)
User Function VLDVL20(nQtdVol20,lGrava)

nVol20 := 0					//	nQtde+nTempAmb+nDensAmb+nFator+nVolAgua
lVol20 := .T.

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+cCodPro))

cCodVl20_1	:= SB1->B1_XTAB1
cCodVl20_2	:= SB1->B1_XTAB2

cQuery := ""
cQuery := "SELECT ZC3_XCOD, ZC3_XDENSA, ZC3_XTEMP, ZC3_XFATOR, ZC3_MSBLQL"
cQuery += "FROM "+RetSqlName("ZC3")+" ZC3  					"
cQuery += "WHERE ZC3.ZC3_FILIAL  = '"+XFilial("ZC3")+"'		"
cQuery += "AND ZC3.ZC3_XCOD 	 = '" + cCodVl20_1 + "' 	"
cQuery += "AND ZC3.ZC3_XDENSA	 = "+Str(nDensAmb,12,2)+"	"
cQuery += "AND ZC3.ZC3_XTEMP	 = "+Str(nTempAmb,12,2)+"	"
cQuery += "AND ZC3.ZC3_MSBLQL	<> '2' 						"
cQuery += "AND ZC3.D_E_L_E_T_ <> '*' 						"

cQuery := ChangeQuery( cQuery )

If Select("TRB") > 0
	TRB->(DbClosearea())
Endif
dbUseArea( .t., "TopConn", TCGenQry(,,cQuery),"TRB", .F., .F. )

If TRB->(Eof())					
	msgstop("Atencao!  Fator inexistente para esta temperatura/densidade!!!")
	//lVol20 := .F.
	//Return(.f.)
	if lGrava  // Botão confirma
		lVol20 := .F.
		Return(.f.)
	else
		lVol20 := .T.
		Return(.T.)
	endif
Else
	nFator01 := TRB->ZC3_XFATOR
	TRB->(DbClosearea())

	cQuery := "SELECT ZC3_XCOD, ZC3_XDENSA, ZC3_XTEMP, ZC3_XFATOR"
	cQuery += "FROM "+RetSqlName("ZC3")+" ZC3  					"
	cQuery += "WHERE ZC3.ZC3_FILIAL  = '"+XFilial("ZC3")+"'		"
	cQuery += "AND ZC3.ZC3_XCOD 	= '" + cCodVl20_2 + "' 		"
	cQuery += "AND ZC3.ZC3_XTEMP	= "+Str(nTempAmb,12,2) + "	"
	cQuery += "AND ZC3.ZC3_XDENSA	= "+Str(nFator01,12,2) + "	"
	cQuery += "AND ZC3.ZC3_MSBLQL	<> '2' 						"
	cQuery += "AND ZC3.D_E_L_E_T_ <> '*' 		"
	cQuery := ChangeQuery( cQuery )
	
	If Select("TRB") > 0
		TRB->(DbClosearea())
	Endif
	dbUseArea( .t., "TopConn", TCGenQry(,,cQuery),"TRB", .F., .F. )
	
	If TRB->(Eof())									//	nota fiscal sem rateio
		msgstop("Atencao!  Fator inexistente para esta temperatura/densidade!!!")
		//lVol20 := .F.
		//Return(.f.)
		if lGrava  // Botão confirma
			lVol20 := .F.
			Return(.f.)
		else
			lVol20 := .T.
			Return(.T.)
		endif
	Else
		nFatorFinal := TRB->ZC3_XFATOR
		TRB->(DbClosearea())

		nVol20 := nFatorFinal
	EndIf
EndIf

nQtdVol20 := nVol20*nQtde
nQtdVol2X := nQtdVol20
//Return(nQtdVol20)
//Return(cCodPro,nDensAmb,nTempAmb,nQtde,nQtdVol20)
Return(nQtdVol2X)


User Function VaQtdCir(nQtde02)

lRet := .T.

If nQtde02 <= 0
	lRet := .F.
	MsgStop("Quantidade informada deve ser maio que zero.","ATENÇÃO")
	Return(lRet)
EndIf

Return(lRet)


User Function CALCMETER(nQtde02,cAtuMeter)

//nMeter := nMeterOri+(nQtde02-nQtde)
if cAtuMeter == "S"
	nMeter := nMeterOri+nQtde02
else
	nMeter := nMeterOri
endif

Return(nMeter)


User Function VLDENDERNF()

lRet := .T.
//	validação:	pode ser qualquer armazem menos com status de servidor
//	campo DB_LOCALIZ  -  X3_VLDUSER:		no processo de endereçamento
If SBE->BE_XSERVD == "S"
	lRet := .F.
	msgstop(" Armazem cadastrado como Servidor!  este endereço não pode ser utilizado!")
	Return(lRet)
EndIf

Return(lRet)

/*
Programa.: RETVOL20
Autor....: Danilo José Grodzicki
Data.....: 23/08/2016 
Descricao: Retorna Fator Calculo 20º.
Uso......: AIR BP BRASIL LTDA
*/
User Function RETVOL20(cLocal,cArmaz,dData,cHora)

Local aDados     := {}
Local aAreaZC1   := ZC1->(GetArea())
Local nFatorCalc := 0
Local cQuery     := ""
Local cAliasTmp  := GetNextAlias()
Local cZc1Recno  := 0
Local lAchouZc1  := .F.

DbSelectArea("ZC1")
DbSetOrder(03)

If IsInCallStack("SF2520E") .or. IsInCallStack("SF2460I")
	if !ZC1->(DbSeek(xFilial("ZC1")+cLocal+cArmaz+DtoS(dData)+cHora))
		cQuery := "SELECT ZC1.R_E_C_N_O_ AS ZC1RECNO "
		cQuery += "FROM "+RetSqlName("ZC1")+" ZC1 "
		cQuery += "WHERE ZC1.D_E_L_E_T_ <> '*' "
		cQuery += "  AND ZC1.ZC1_FILIAL = '"+xFilial("ZC1")+"' "
		cQuery += "  AND ZC1.ZC1_LOCAL = '"+cLocal+"' "
		cQuery += "  AND ZC1.ZC1_DATA = '"+DtoS(dData)+"' "
		cQuery += "ORDER BY ZC1RECNO DESC"
		cQuery    := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
		(cAliasTmp)->(DbGoTop())
		if (cAliasTmp)->(!Eof())
			cZc1Recno := (cAliasTmp)->ZC1RECNO
			lAchouZc1 := .T.
		endif
		(cAliasTmp)->( dbCloseArea() )
		If Select(cAliasTmp) == 0
			Ferase(cAliasTmp+GetDBExtension())
		Endif
	endif
elseIf IsInCallStack("U_RESTR001")  // Kardex 20º
	cQuery := "SELECT ZC1.R_E_C_N_O_ AS ZC1RECNO "
	cQuery += "FROM "+RetSqlName("ZC1")+" ZC1 "
	cQuery += "WHERE ZC1.D_E_L_E_T_ <> '*' "
	cQuery += "  AND ZC1.ZC1_FILIAL = '"+xFilial("ZC1")+"' "
	cQuery += "  AND ZC1.ZC1_LOCAL = '"+cLocal+"' "
	cQuery += "  AND ZC1.ZC1_DATA = '"+DtoS(dData)+"' "
	cQuery += "ORDER BY ZC1RECNO DESC"
	cQuery    := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
	(cAliasTmp)->(DbGoTop())
	if (cAliasTmp)->(!Eof())
		cZc1Recno := (cAliasTmp)->ZC1RECNO
		lAchouZc1 := .T.
	endif
	(cAliasTmp)->( dbCloseArea() )
	If Select(cAliasTmp) == 0
		Ferase(cAliasTmp+GetDBExtension())
	Endif
else
	if !ZC1->(DbSeek(xFilial("ZC1")+cLocal+cArmaz+DtoS(dData)))
		cQuery := "SELECT ZC1.R_E_C_N_O_ AS ZC1RECNO "
		cQuery += "FROM "+RetSqlName("ZC1")+" ZC1 "
		cQuery += "WHERE ZC1.D_E_L_E_T_ <> '*' "
		cQuery += "  AND ZC1.ZC1_FILIAL = '"+xFilial("ZC1")+"' "
		cQuery += "  AND ZC1.ZC1_LOCAL = '"+cLocal+"' "
		cQuery += "  AND ZC1.ZC1_DATA = '"+DtoS(dData)+"' "
		cQuery += "ORDER BY ZC1RECNO DESC"
		cQuery    := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
		(cAliasTmp)->(DbGoTop())
		if (cAliasTmp)->(!Eof())
			cZc1Recno := (cAliasTmp)->ZC1RECNO
			lAchouZc1 := .T.
		endif
		(cAliasTmp)->( dbCloseArea() )
		If Select(cAliasTmp) == 0
			Ferase(cAliasTmp+GetDBExtension())
		Endif
	endif
endif

if ZC1->(!Eof()) .or. lAchouZc1
	if lAchouZc1
		ZC1->(DbGoTo(cZc1Recno))
	endif
	nFatorCalc := U_CorDen20(ZC1->ZC1_DENSAB,ZC1->ZC1_TEMPAB)
	aadd(aDados,nFatorCalc     )
	aadd(aDados,ZC1->ZC1_DENSAB)
	aadd(aDados,ZC1->ZC1_TEMPAB)
else
	aadd(aDados,0)
	aadd(aDados,0)
	aadd(aDados,0)
endif

RestArea(aAreaZC1)

Return(aDados)