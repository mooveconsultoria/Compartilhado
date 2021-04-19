#Include "Totvs.Ch"

STATIC cDirErro	:= "\erro_msexecauto\"
STATIC cDirFunc	:= "AIFATP03\"

//--------------------------------------------------
/*/{Protheus.doc} AIFATP03
User Function responsАvel pela ValidaГЦo das InformaГУes,
InclusЦo do Pedido de DevoluГЦo,
LiberaГЦo do Pedido,
Faturamento da NF
e Retorno dos Dados para a API.

@author Irineu Filho
@since 05/04/2019 - 20:23
/*/
//--------------------------------------------------
User Function AIFATP03(cNumDoc, cSerieDoc, cFornece,cLoja)

Local aRetInfo	:= {}
Local aRetPed	:= {}
Local aRetLib	:= {}
Local aRetNF	:= {}
Local aRetorno	:= {"",""}
Local cDataHora := DTOS(MsDate()) + "_" + StrTran(Time(),":","") + "_" + Alltrim(Str(Randomize(1,9999)))

makedir(cDirErro)
makedir(cDirErro+cDirFunc)

//--------------------------------------------------
//Valida as informaГУes (Fornecedor e NF)
//--------------------------------------------------

aRetInfo := FVldInfo(cNumDoc, cSerieDoc, cFornece, cLoja)

If aRetInfo[1]

	//-----------------------------
	//Inclui o Pedido de DevoluГЦo.
	//-----------------------------
	aRetPed := FPedDev(cDataHora,aRetInfo[2])

	If aRetPed[1]

		cPedido := aRetPed[2]

		//------------------------------
		//Realiza a LiberaГЦo do Pedido.
		//------------------------------
		aRetLib := FLibPed(cPedido,cDataHora)

		If aRetLib[1]

			//----------------------------
			//Gera a Nota Fiscal de SaМda.
			//----------------------------
			aRetNF := FGeraNF(cPedido,cDataHora)

			If aRetNF[1]
				aRetorno[1] := .T.
				aRetorno[2] := aRetNF[2]
			Else
				aRetorno[1] := .F.
				aRetorno[2] := aRetNF[2]
			EndIf

		Else
			aRetorno[1] := .F.
			aRetorno[2] := aRetLib[2]
		EndIf

	Else
		aRetorno[1] := .F.
		aRetorno[2] := aRetPed[2]
	EndIf
Else

	aRetorno[1] := .F.
	aRetorno[2] := aRetInfo[2]

EndIf

Return aRetorno

//--------------------------------------------------
/*/{Protheus.doc} FVldInfo
Realiza as validaГУes dos Conteudos.

@author Irineu Filho
@since 05/04/2019 - 23:37
/*/
//--------------------------------------------------
Static Function FVldInfo(cNumDoc, cSerieDoc, cFornece, cLoja)

Local aRetorno	:= {Nil,""}

// O Destanqueio И um beneficiamento, por tanto deve ser verificado se existe em clientes
DbSelectArea( "SA1" )
SA1->(dbSetOrder(1))
If SA1->(dbSeek( xFilial("SA1") + cFornece + cLoja ))

	SF1->(dbSetOrder(1))
	If SF1->(dbSeek( xFilial("SF1") + cNumDoc + cSerieDoc + cFornece + cLoja + "B" ) ) // Busca a NF de beneficiamento

		If FNFTemSaldo(cNumDoc, cSerieDoc, cFornece, cLoja)
			aRetorno[1] := .T.
			aRetorno[2] := SF1->(Recno())
		Else
			aRetorno[1] := .F.
			aRetorno[2] := "Nota Fiscal: " + Alltrim(cNumDoc) + "/" + Alltrim(cSerieDoc)
			aRetorno[2] += " - Cliente: " +  Alltrim(cFornece) + "-" + Alltrim(cLoja) + CRLF
			aRetorno[2] += "Nota Fiscal de Entrada sem Saldo para Devolucao." + CRLF
			aRetorno[2] += "Verifique se a Nota Fiscal possui Saldo ou se ha Pedidos vinculados a Nota Fiscal." + CRLF
		EndIf
	Else
		aRetorno[1] := .F.
		aRetorno[2] := "Nota Fiscal: " + Alltrim(cNumDoc) + "/" + Alltrim(cSerieDoc)
		aRetorno[2] += " - Cliente: " +  Alltrim(cFornece) + "-" + Alltrim(cLoja) + CRLF
		aRetorno[2] += "Nota Fiscal de Entrada nao encontrada!"
	EndIf

Else
	aRetorno[1] := .F.
	aRetorno[2] := "Cliente: " + Alltrim(cFornece) + "-" + Alltrim(cLoja) + CRLF
	aRetorno[2] += "Cliente nao encontrado!"
EndIf

Return aRetorno

//--------------------------------------------------
/*/{Protheus.doc} FPedDev
FunГЦo para gerar o Pedido de Venda de DevoluГЦo, baseado na Nota Fiscal de Entrada.

@author Irineu Filho
@since 05/04/2019 - 22:42
/*/
//--------------------------------------------------
Static Function FPedDev(cDataHora, nRecSF1)

Local aRetorno			:= {Nil,""}
Local cArqErro			:= cDataHora + "_FPedDev.log"
Local cPedido			:= ""
Local lFornece			:= .F. //Quando .F. filtra a NF posicionada no SF1, caso .T. serА necessАrio passar o parametro cDocSF1
Local nRetA410ProcDv	:= 0

//Variaveis para que a funГЦo HELP grave a mensagem em .LOG e que seja possivel extrair pela MostraErro()
Private lMSHelpAuto 	:= .T.
Private lMsErroAuto 	:= .F.

//Variavel utilizada na funГЦo A410ProcDv.
Private INCLUI			:= .T.
Private cCadastro		:= Nil
Private lForn			:= .T.
Private l410Auto		:= .T.

dbSelectArea("SC5")
dbSelectArea("SF1")

//--------------------------------------------------
//FunГЦo do PadrЦo para inclusЦo do Pedido baseado na NOTA Fiscal.
//Por jА estar posicionado na SF1 correta, nЦo hА necessidade de passar todos os parametros,
//pois os Default pega da tabela.
//A410ProcDv() - MATN410A.prx
//--------------------------------------------------
SF1->(dbGoTo(nRecSF1))
nRetA410ProcDv := u_XA410ProcDv( "SC5" , SC5->(Recno()) , 4 , lFornece )

If nRecSF1 <> SF1->(Recno())
	SF1->(dbGoTo(nRecSF1))
EndIf

If lMsErroAuto
	aRetorno[1] := .F.
	aRetorno[2] := "Nota Fiscal: " + Alltrim(SF1->F1_DOC) + "/" + Alltrim(SF1->F1_SERIE)
	aRetorno[2] += " - Fornecedor: " +  Alltrim(SF1->F1_FORNECE) + "-" + Alltrim(SF1->F1_LOJA) + CRLF
	aRetorno[2] += MostraErro(cDirErro+cDirFunc,cArqErro)
ElseIf nRetA410ProcDv == 0
	aRetorno[1] := .F.
	aRetorno[2] := "Nota Fiscal: " + Alltrim(SF1->F1_DOC) + "/" + Alltrim(SF1->F1_SERIE)
	aRetorno[2] += " - Fornecedor: " +  Alltrim(SF1->F1_FORNECE) + "-" + Alltrim(SF1->F1_LOJA) + CRLF
	aRetorno[2] += "Pedido nao gerado! Problema A410ProcDv"
Else
	aRetorno[1] := .T.
	aRetorno[2] := SC5->C5_NUM
EndIf

Return aRetorno

//--------------------------------------------------
/*/{Protheus.doc} FLibPed
FunГЦo que realiza a LiberaГЦo do Pedido.

@author Irineu Filho
@since 05/04/2019 - 21:34
/*/
//--------------------------------------------------

Static Function FLibPed(cPedPar,cDataHora)

Local aRetorno	:= {Nil,""}
Local lTudoLib	:= .F.
Local nQtdLib	:= 0
Local lCredito	:= .T.
Local lEstoque	:= .T.
Local lAvCred	:= .T.
Local lAvEst	:= .T.
Local lLiber	:= .T.
Local lTransf	:= .T.
Local cErro		:= ""
Local cArqErro	:= cDataHora + "_FLibPed_" + cPedPar + ".log"

Private lMSHelpAuto := .T.
Private lMsErroAuto := .F.

SC6->(dbSetOrder(1))
If SC6->(dbSeek( xFilial("SC6") + cPedPar ))

	lTudoLib := .T.
	While SC6->(!EOF()) .AND. SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC6") + cPedPar
		
		//--------------------------------------------------
		//FunГЦo padrЦo para LiberaГЦo do Pedido
		//MaLibDoFat() - FATXFUN.prx
		//--------------------------------------------------
		nQtdLib := MaLibDoFat( SC6->(RecNo()) , SC6->C6_QTDVEN , @lCredito , @lEstoque , lAvCred , lAvEst , lLiber , lTransf , NIL , NIL , NIL , NIL , NIL , NIL)

		If nQtdLib <= 0

			lTudoLib := .F.
			cErro := "Pedido: " + Alltrim(cPedPar) + "-" + Alltrim(SC6->C6_ITEM) + CRLF + "Pedido nao liberado"
			
			If !lCredito
				cErro += CRLF + "Problema de Credito!"
			EndIf

			If !lEstoque
				cErro += CRLF + "Problema de Estoque!"
			EndIf

		EndIf

		If !Empty(cErro)
			If lMsErroAuto
				cErro += CRLF + MostraErro(cDirErro+cDirFunc,cArqErro)
			EndIf
		EndIf

		If !lTudoLib
			Exit
		EndIf

		SC6->(dbSkip())
	EndDo

	If lTudoLib
		aRetorno[1] := .T.
	Else
		aRetorno[1] := .F.
		aRetorno[2] := cErro
	EndIf

Else
	aRetorno[1] := .F.
	aRetorno[2] := "Pedido: " + cPedPar + CRLF
	aRetorno[2] += "Pedido nao encontrado!"
EndIf

Return aRetorno

//--------------------------------------------------
/*/{Protheus.doc} FGeraNF
FunГЦo para geraГЦo da NF de SaМda

@author Irineu Filho
@since 05/04/2019 - 21:21
/*/
//--------------------------------------------------
Static Function FGeraNF(cPedPar,cDataHora)

Local aRetorno	:= {Nil,Nil}
Local cSerieDev	:= GetMV("AI_SERIEDV",,"1")
Local cEmbExp	:= ""
Local aNotas	:= {}
Local cArqErro	:= cDataHora + "_FGeraNF_" + cPedPar + ".log"

Private lMSHelpAuto := .T.
Private lMsErroAuto := .F.

//---------------------
//Inclui a NF de SaМda.
//IncNota() - FATXFUN.prx
//---------------------
lMSHelpAuto := .F.
lMsErroAuto := .F.
IncNota(cPedPar,cSerieDev,cEmbExp,@aNotas)

If !lMsErroAuto .AND. Len(aNotas) > 0
	aRetorno[1] := .T.
	aRetorno[2] := ACLONE(aNotas)
Else
	If lMsErroAuto
		aRetorno[1] := .F.
		aRetorno[2] := "Pedido: " + cPedPar +", Nota Fiscal nao Gerada!" + CRLF
		aRetorno[2] += MostraErro(cDirErro+cDirFunc,cArqErro)
	Else
		aRetorno[1] := .F.
		aRetorno[2] := "Pedido: " + cPedPar + CRLF
		aRetorno[2] += "Problemas no array [aNotas]"
	EndIf
EndIf

Return aRetorno

//--------------------------------------------------
/*/{Protheus.doc} FNFTemSaldo
Verifica se a NF tem Saldo para DevoluГЦo.

@author Irineu Filho
@since 06/04/2019 - 21:46
/*/
//--------------------------------------------------
Static Function FNFTemSaldo(cNumDoc, cSerieDoc, cFornece, cLoja)

Local cQuery	:= ""
Local lRetorno	:= .F.

cQuery := ""
cQuery += " SELECT (SUM(TOTQUANT) - SUM(TOTQTDEDEV) - SUM(TOTPEDIDO)) AS SLDNOTA FROM ( "

cQuery += " SELECT ISNULL(SUM(D1_QUANT),0) AS TOTQUANT, ISNULL(SUM(D1_QTDEDEV),0) AS TOTQTDEDEV, 0 AS TOTPEDIDO "
cQuery += " FROM " + RetSqlName("SD1") + " SD1 "
cQuery += " WHERE D1_FILIAL = '" + xFilial("SD1") + "' "
cQuery += " AND D1_DOC = '" + cNumDoc + "' "
cQuery += " AND D1_SERIE = '" + cSerieDoc + "' "
cQuery += " AND D1_FORNECE = '" + cFornece + "' "
cQuery += " AND D1_LOJA = '" + cLoja + "' "
cQuery += " AND SD1.D_E_L_E_T_ = ' ' "

cQuery += " UNION ALL "

cQuery += " SELECT 0 AS TOTQUANT, 0 AS TOTQTDEDEV, ISNULL((C6_QTDVEN-C6_QTDENT),0) AS TOTPEDIDO "
cQuery += " FROM " + RetSqlName("SC6") + " SC6 "
cQuery += " WHERE C6_FILIAL = '" + xFilial("SC6") + "'"
cQuery += " AND C6_NFORI = '" + cNumDoc + "' "
cQuery += " AND C6_SERIORI = '" + cSerieDoc + "' "
cQuery += " AND C6_CLI = '" + cFornece + "' "
cQuery += " AND C6_LOJA = '" + cLoja + "' "
cQuery += " AND C6_QTDVEN > C6_QTDENT "
cQuery += " AND SC6.D_E_L_E_T_ = ' ' ) TRB "

If Select('TMPSD1') > 0
   TMPSD1->(dbCloseArea())
EndIf

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., 'TOPCONN', TcGenQry(NIL, NIL, cQuery), 'TMPSD1', .T., .F.)

If TMPSD1->SLDNOTA > 0
	lRetorno := .T.
EndIf

TMPSD1->(dbCloseArea())

Return lRetorno


//--------------------------------------------------
/*/{Protheus.doc} XA410ProcDv
FunГЦo para InclusЦo do Pedido de Vendas DevoluГЦo referenciando a Nota Fiscal de Entrada.

@author Irineu Filho
@since 12/04/2019 - 19:48
/*/
//--------------------------------------------------
User Function XA410ProcDv(cAlias,nReg,nOpc,lFornece,cFornece,cLoja,cDocSF1)

Local aArea     := GetArea()
Local aAreaSX3  := SX3->(GetArea())
Local aAreaSF1  := SF1->(GetArea())
Local aAreaSD1  := SD1->(GetArea())
Local aAreaSB8  := SB8->(GetArea())
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aPosGet   := {}
Local aRegSC6   := {}
Local aRegSCV   := {}
Local aInfo     := {}
Local aHeadSC6  := {}
Local aValor    := {}

Local lLiber 	:= .F.
Local lTransf	:= .F.
Local lContinua := .T.
Local lPoder3   := .T. 
Local lM410PcDv := ExistBlock("M410PCDV")
Local nOpcA		:= 0
Local nUsado    := 0
Local nCntFor   := 0
Local nTotalPed := 0
Local nTotalDes := 0
Local nNumDec   := TamSX3("C6_VALOR")[2]
Local cItem		:= StrZero(0,TamSX3("C6_ITEM")[1])
Local nGetLin   := 0
Local nStack    := GetSX8Len()
Local nPosPrc   := 0
Local nPValDesc := 0
Local nPPrUnit  := 0
Local nPQuant   := 0
Local nSldQtd   := 0
Local nSldQtd2  := 0
Local nSldLiq   := 0
Local nSldBru   := 0
Local nX        := 0
Local nCntSD1   := 0
Local nTamPrcVen:= TamSX3("C6_PRCVEN")[2]

Local cAliasSD1 := "SD1"
Local cAliasSB1 := "SB1"
Local cCodTES   := ""
Local cCadastro := IIF(cCadastro == Nil,"AtualizaГЦo de Pedidos de Venda",cCadastro)
Local cCampo    :=""
Local cTipoPed  :=""
Local cQuery   := ""
Local oDlg
Local oGetd
Local oSAY1
Local oSAY2
Local oSAY3
Local oSAY4
Local aRecnoSE1RA := {} // Array com os titulos selecionados pelo Adiantamento
Local aHeadAGG    := {}
Local aColsAGG    := {}
Local lBenefPodT	:=.F.

//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis utilizadas na LinhaOk                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aCols      := {}
PRIVATE aHeader    := {}
PRIVATE aHeadFor   := {}
PRIVATE aColsFor   := {}
PRIVATE N          := 1
If IsAtNewGrd()
	PRIVATE oGrade	  := MsMatGrade():New('oGrade',,"C6_QTDVEN",,"a410GValid()",{ {VK_F4,{|| A440Saldo(.T.,oGrade:aColsAux[oGrade:nPosLinO][aScan(oGrade:aHeadAux,{|x| AllTrim(x[2])=="C6_LOCAL"})] )}} }) 
Else
	PRIVATE aColsGrade := {}
	PRIVATE aHeadgrade := {}
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta a entrada de dados do arquivo                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aTELA[0][0],aGETS[0]

PRIVATE oGetPV	:= Nil

Default lFornece := .F.
Default cFornece := SF1->F1_FORNECE
Default cLoja    := SF1->F1_LOJA
Default cDocSF1  := ''

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁCarrega perguntas do MATA440 e MATA410                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte("MTA440",.F.)
lLiber := MV_PAR02 == 1
lTransf:= MV_PAR01 == 1

Pergunte("MTA410",.F.)
//Carrega as variaveis com os parametros da execauto
Ma410PerAut()

SB8->(dbSetOrder(3))

If SoftLock("SF1")

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Montagem do aHeader                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("SC6")
	While ( !EOF() .And. (SX3->X3_ARQUIVO == "SC6") )
		If (	X3USO(SX3->X3_USADO) .And.;
				!( Trim(SX3->X3_CAMPO) == "C6_NUM" );
				.And. Trim(x3_campo) <> "C6_QTDEMP";
				.And. Trim(x3_campo) <> "C6_QTDENT";
				.And. cNivel >= SX3->X3_NIVEL )
			nUsado++
			aAdd(aHeader,{ TRIM(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT } )
		EndIf
		dbSelectArea("SX3")
		dbSkip()
	EndDo
	If ( lContinua )
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Montagem dos itens da Nota Fiscal de Devolucao/Retorno          Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea("SD1")
		dbSetOrder(1)

		cAliasSD1 := "QRYSD1"
		cAliasSB1 := "QRYSD1"
		aStruSD1  := SD1->(dbStruct())
		cQuery    := "SELECT SD1.*,B1_DESC,B1_UM,B1_SEGUM "
		cQuery    += "FROM "+RetSqlName("SD1")+" SD1, "
		cQuery    += RetSqlName("SB1")+" SB1 "
		cQuery    += "WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
		If !lFornece
			cQuery    += "SD1.D1_DOC = '"+SF1->F1_DOC+"' AND "
			cQuery    += "SD1.D1_SERIE = '"+SF1->F1_SERIE+"' AND "
		Else
			If !Empty(cDocSF1)
				cQuery += " ( "
				cQuery += cDocSF1 + " AND "
			EndIf
		EndIf
		cQuery    += "SD1.D1_FORNECE = '"+cFornece+"' AND "
		cQuery    += "SD1.D1_LOJA = '"+cLoja+"' AND "
		cQuery    += "SD1.D_E_L_E_T_=' ' AND "

		cQuery    += "SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
		cquery    += "SB1.B1_COD = SD1.D1_COD AND "
		cQuery    += "SB1.D_E_L_E_T_=' ' "

		cQuery    += "ORDER BY "+SqlOrder(SD1->(IndexKey()))

		cQuery    := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)

		For nX := 1 To Len(aStruSD1)
			If aStruSD1[nX][2]<>"C"
				TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
			EndIf
		Next nX
			While !Eof() .And. (cAliasSD1)->D1_FILIAL == xFilial("SD1") .And.;
			(cAliasSD1)->D1_FORNECE == cFornece .And.;
			(cAliasSD1)->D1_LOJA == cLoja .And.;
			If(!lFornece,(cAliasSD1)->D1_DOC == SF1->F1_DOC .And.;
							 (cAliasSD1)->D1_SERIE == SF1->F1_SERIE,.T.)

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Se existe quantidade a ser devolvida                            Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If (cAliasSD1)->D1_QUANT > (cAliasSD1)->D1_QTDEDEV

				cItem := Soma1(cItem)

				SF1->(dbSetOrder(1))
				SF1->(MsSeek(xFilial("SF1")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_TIPO))

				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica se existe um tes de devolucao correspondente           Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

				dbSelectArea("SF4")
				DbSetOrder(1)
				If MsSeek(xFilial("SF4")+(cAliasSD1)->D1_TES)
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Verifica o poder de terceiros                                   Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If lPoder3 
						lPoder3 := ( SF4->F4_PODER3=="R" ) 
					EndIf

					If Empty(SF4->F4_TESDV) .Or. !(SF4->(MsSeek(xFilial("SF4")+SF4->F4_TESDV)))
						Help(" ",1,"DSNOTESDEV")
						lContinua := .F.
						Exit 
					Else
						cCodTES := SF4->F4_CODIGO
					EndIf
					
					If !(lPoder3 .Or. SF1->F1_TIPO=="N")
						Help(" ",1,"A410PODER3")
						lContinua := .F.
						Exit 						
					EndIf
				
				EndIf

				aValor := A410SNfOri((cAliasSD1)->D1_FORNECE,;
											(cAliasSD1)->D1_LOJA,;
											(cAliasSD1)->D1_DOC,;
											(cAliasSD1)->D1_SERIE,;
											If(lPoder3,"",(cAliasSD1)->D1_ITEM),;
											(cAliasSD1)->D1_COD,;
											If(lPoder3,(cAliasSD1)->D1_IDENTB6,),;
											If(lPoder3,(cAliasSD1)->D1_LOCAL,),;
											cAliasSD1,,IIf(lForn,.F.,.T.) )

				nSldQtd:= aValor[1]
				nSldQtd2:=ConvUm((cAliasSD1)->D1_COD,nSldQtd,0,2)
				nSldLiq:= aValor[2] - (cAliasSD1)->D1_VALDESC
				nSldBru:= nSldLiq+A410Arred(nSldLiq*(cAliasSD1)->D1_VALDESC/((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC),"C6_VALOR")

				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica se existe saldo                                        Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If nSldQtd <> 0

					nCntSD1++
					If nCntSD1 > 900  // No. maximo de Itens 
						Exit
					EndIf

					aAdd(aCols,Array(Len(aHeader)+1))
					For nCntFor := 1 To Len(aHeader)
						cCampo := Alltrim(aHeader[nCntFor,2])

						If ( aHeader[nCntFor,10] # "V" .And. !cCampo$"C6_QTDLIB#C6_RESERVA" )

							Do Case

							Case Alltrim(aHeader[nCntFor][2]) == "C6_ITEM"
								aCols[Len(aCols)][nCntFor] := cItem
							Case Alltrim(aHeader[nCntFor][2]) == "C6_PRODUTO"
								aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_COD								
								SB1->(dbSetOrder(1))
								SB1->(MsSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))
								aCols[Len(aCols)][Ascan(aHeader,{|x| Alltrim(x[2])=="C6_CLASFIS"})] :=  IIf( !Empty(SB1->B1_TS), SB1->B1_TS, SF4->F4_CODIGO ) 
				 				//If ExistTrigger("C6_PRODUTO")
				   			        //		RunTrigger(2,Len(aCols))
							        //	EndIf
							Case Alltrim(aHeader[nCntFor][2]) == "C6_CC"
								aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_CC
							Case Alltrim(aHeader[nCntFor][2]) == "C6_CONTA"
								aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_CONTA
							Case Alltrim(aHeader[nCntFor][2]) == "C6_ITEMCTA"
								aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_ITEMCTA
							Case Alltrim(aHeader[nCntFor][2]) == "C6_CLVL"
								aCols[Len(aCols)][nCntFor] :=(cAliasSD1)->D1_CLVL			
							Case Alltrim(aHeader[nCntFor][2]) == "C6_DESCRI"
								aCols[Len(aCols)][nCntFor] := (cAliasSB1)->B1_DESC
							Case Alltrim(aHeader[nCntFor][2]) == "C6_SEGUM"
								aCols[Len(aCols)][nCntFor] := (cAliasSB1)->B1_SEGUM
							Case Alltrim(aHeader[nCntFor][2]) == "C6_UM"
								aCols[Len(aCols)][nCntFor] := (cAliasSB1)->B1_UM
							Case Alltrim(aHeader[nCntFor][2]) == "C6_UNSVEN"
								aCols[Len(aCols)][nCntFor] := a410Arred(nSldQtd2,"C6_UNSVEN")
							Case Alltrim(aHeader[nCntFor][2]) == "C6_QTDVEN"
								aCols[Len(aCols)][nCntFor] := a410Arred(nSldQtd,"C6_QTDVEN")
							Case Alltrim(aHeader[nCntFor][2]) == "C6_PRCVEN"
								If nTamPrcVen > 2
									aCols[Len(aCols)][nCntFor] := a410Arred(((cAliasSD1)->D1_VUNIT-((cAliasSD1)->D1_VALDESC/(cAliasSD1)->D1_QUANT)),"C6_PRCVEN")
								Else
									aCols[Len(aCols)][nCntFor] := a410Arred(nSldLiq/IIf(nSldQtd==0,1,nSldQtd),"C6_PRCVEN")
								EndIf
							Case Alltrim(aHeader[nCntFor][2]) == "C6_PRUNIT"
								aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_VUNIT
							Case Alltrim(aHeader[nCntFor][2]) == "C6_VALOR"
								If nSldQtd <> (cAliasSD1)->D1_QUANT
									If nTamPrcVen > 2
										aCols[Len(aCols)][nCntFor] := a410Arred(nSldQtd*a410Arred(((cAliasSD1)->D1_VUNIT-((cAliasSD1)->D1_VALDESC/(cAliasSD1)->D1_QUANT)),"C6_PRCVEN"),"C6_VALOR")
									Else
										aCols[Len(aCols)][nCntFor] := a410Arred(nSldQtd*a410Arred(nSldLiq/IIf(nSldQtd==0,1,nSldQtd),"C6_PRCVEN"),"C6_VALOR")
									EndIf
								Else
									aCols[Len(aCols)][nCntFor] := nSldLiq
								EndIf
							Case Alltrim(aHeader[nCntFor][2]) == "C6_VALDESC"
								If (cAliasSD1)->D1_VALDESC>0
									aCols[Len(aCols)][nCntFor] := a410Arred(((cAliasSD1)->D1_VUNIT-a410Arred(nSldLiq/IIf(nSldQtd==0,1,nSldQtd),"C6_PRCVEN"))*a410Arred(nSldQtd,"C6_QTDVEN"),"C6_VALDESC")
								Else
									aCols[Len(aCols)][nCntFor] := 0
								EndIf
							Case Alltrim(aHeader[nCntFor][2]) == "C6_DESCONT"
								If (cAliasSD1)->D1_DESC>0
									aCols[Len(aCols)][nCntFor] :=(cAliasSD1)->D1_DESC
								Else
									aCols[Len(aCols)][nCntFor] := 0
								EndIf
							Case Alltrim(aHeader[nCntFor][2]) == "C6_TES"
								aCols[Len(aCols)][nCntFor] := cCodTES
								SF4->(dbSetOrder(1))
								SF4->(MsSeek(xFilial("SF4")+cCodTES))
								If !Empty(Subs(aCols[Len(aCols)][Ascan(aHeader,{|x| Alltrim(x[2])=="C6_CLASFIS"})],1,1)) .And. !Empty(SF4->F4_SITTRIB) 
									aCols[Len(aCols)][Ascan(aHeader,{|x| Alltrim(x[2])=="C6_CLASFIS"})] :=Subs(aCols[Len(aCols)][Ascan(aHeader,{|x| Alltrim(x[2])=="C6_CLASFIS"})],1,1)+SF4->F4_SITTRIB 								
				 				EndIf
				 				//If ExistTrigger("C6_TES    ")
				   				//	RunTrigger(2,Len(aCols))
								//EndIf
							Case Alltrim(aHeader[nCntFor][2]) == "C6_CF"
								aCols[Len(aCols)][nCntFor] := SF4->F4_CF
							Case Alltrim(aHeader[nCntFor][2]) == "C6_NFORI"
								aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_DOC
							Case Alltrim(aHeader[nCntFor][2]) == "C6_SERIORI"
								aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_SERIE // Deve amarrar pelo ID de controle D1_SERIE sera costrado apenas a serie por causa da picture !!! Manter Projeto Chave Unica.
							Case Alltrim(aHeader[nCntFor][2]) == "C6_ITEMORI" 
								aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_ITEM
							Case Alltrim(aHeader[nCntFor][2]) == "C6_NUMLOTE"
								aCols[Len(aCols)][nCntFor] := IIF(SF4->F4_ESTOQUE == "S",(cAliasSD1)->D1_NUMLOTE ,"")
							Case Alltrim(aHeader[nCntFor][2]) == "C6_LOTECTL"
								aCols[Len(aCols)][nCntFor] := IIF(SF4->F4_ESTOQUE == "S",(cAliasSD1)->D1_LOTECTL ,"")
							Case Alltrim(aHeader[nCntFor][2]) == "C6_LOCAL"
								aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_LOCAL
							Case Alltrim(aHeader[nCntFor][2]) == "C6_IDENTB6"
								aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_IDENTB6
							Case Alltrim(aHeader[nCntFor][2]) == "C6_DTVALID"			
								If SF4->F4_ESTOQUE == "S"
									aCols[Len(aCols)][nCntFor] := (cAliasSD1)->D1_DTVALID
									If SB8->(MsSeek(xFilial("SB8")+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_LOCAL+(cAliasSD1)->D1_LOTECTL+IIf(Rastro((cAliasSD1)->D1_COD,"S"),(cAliasSD1)->D1_NUMLOTE,"")))
										aCols[Len(aCols)][nCntFor] := SB8->B8_DTVALID
									Endif   
								Else
									aCols[Len(aCols)][nCntFor] := CTOD("  /  /  ")
								EndIf
							Case Alltrim(aHeader[nCntFor][2]) == "C6_CLASFIS"
								aCols[Len(aCols)][nCntFor] := SB1->B1_ORIGEM+SF4->F4_SITTRIB
							OtherWise
								aCols[Len(aCols)][nCntFor] := CriaVar(cCampo)
							EndCase
						Else
							aCols[Len(aCols)][nCntFor] := CriaVar(cCampo)
						EndIf
					Next nCntFor

					aCols[Len(aCols)][Len(aHeader)+1] := .F.

					If lM410PCDV
						ExecBlock("M410PCDV",.F.,.F.,{cAliasSD1})
					Endif

				Endif

			Endif

			dbSelectArea(cAliasSD1)
			dbSkip()
		EndDo
		dbSelectArea(cAliasSD1)
		dbCloseArea()
		ChkFile("SC6",.F.)
		dbSelectArea("SC6")
		
		If (lContinua)

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Inicializa as variaveis de busca do acols                                 Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

			nPosPrc   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
			nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
			nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
			nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})


			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Inici aliza desta forma para criar uma nova instancia de variaveis privateЁ
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Cria Variaveis de Memoria da Enchoice                                 Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			DbSelectArea("SX3")
			DbSetOrder(1)
			DbSeek("SC5")
			While ( !Eof() .And. (SX3->X3_ARQUIVO == "SC5") )
				cCampo := SX3->X3_CAMPO

				If	( SX3->X3_CONTEXT <> "V" )
					Do Case

					Case Alltrim(cCampo) == "C5_TIPO"

						cTipoPed := "" 

						//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Verifica o tipo da nota para o retorno do pedido     Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
						Do Case
						Case SF1->F1_TIPO == "N" .And. lPoder3
							cTipoPed := "B" 
						Case SF1->F1_TIPO == "B" .And. lPoder3
							cTipoPed := "N" 
							lBenefPodT := .T.
						EndCase

						If Empty(cTipoPed)
							cTipoPed := "D" 
						Endif

						_SetOwnerPrvt(Trim(SX3->X3_CAMPO),cTipoPed )

					Case Alltrim(cCampo) == "C5_CLIENTE"
						_SetOwnerPrvt(Trim(SX3->X3_CAMPO),cFornece)
					Case Alltrim(cCampo) == "C5_LOJACLI"
						_SetOwnerPrvt(Trim(SX3->X3_CAMPO),cLoja)
					Case Alltrim(cCampo) == "C5_EMISSAO"
						_SetOwnerPrvt(Trim(SX3->X3_CAMPO),dDataBase)
					Case Alltrim(cCampo) == "C5_CONDPAG"
						_SetOwnerPrvt(Trim(SX3->X3_CAMPO),SF1->F1_COND)
					Case Alltrim(cCampo) == "C5_CLIENT"
						_SetOwnerPrvt(Trim(SX3->X3_CAMPO),cFornece)						
					Case Alltrim(cCampo) == "C5_LOJAENT"
						_SetOwnerPrvt(Trim(SX3->X3_CAMPO),cLoja)
					OtherWise
						_SetOwnerPrvt(Trim(SX3->X3_CAMPO),CriaVar(SX3->X3_CAMPO))
					EndCase
				Else
					_SetOwnerPrvt(Trim(SX3->X3_CAMPO),CriaVar(SX3->X3_CAMPO))
				Endif

				DbSelectArea("SX3")
				DbSkip()
			EndDo

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Busca o tipo do cliente/fornecedor                   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If M->C5_TIPO$"DB"
				SA2->(dbSetOrder(1))
				If SA2->(MsSeek(xFilial("SA2")+M->C5_CLIENTE+M->C5_LOJACLI))
					_SetOwnerPrvt("C5_TIPOCLI",If(SA2->A2_TIPO=="J","R",SA2->A2_TIPO))
				EndIf
			Else
				SA1->(dbSetOrder(1))
				If SA1->(MsSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
					_SetOwnerPrvt("C5_TIPOCLI",SA1->A1_TIPO)
				Endif 
			EndIf

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Marca o cliente utilizado para verificar posterior mudanca Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			a410ChgCli(M->C5_CLIENTE+M->C5_LOJACLI)
		Endif

	EndIf
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Caso nao ache nenhum item , abandona rotina.         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ( lContinua )
	If ( Len(aCols) == 0 )
		lContinua := .F.
	EndIf
EndIf

aRegSC6 := {}
aRegSCV := {}

If ( lContinua )
	//зддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁMonta o array com as formas de pagamento do SX5Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддды
	Ma410MtFor(@aHeadFor,@aColsFor)
	A410ReCalc(.F.,lBenefPodT)	

	If ( Type("l410Auto") == "U" .OR. !l410Auto )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Faz o calculo automatico de dimensoes de objetos     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aSize := MsAdvSize()
		aObjects := {}
		aAdd( aObjects, { 100, 100, .t., .t. } )
		aAdd( aObjects, { 100, 100, .t., .t. } )
		aAdd( aObjects, { 100, 015, .t., .f. } )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )
		aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,263}} )
		nGetLin := aPosObj[3,1]

		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL 
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Armazenar dados do Pedido anterior.                  Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддды
		IF M->C5_TIPO $ "DB"
			aTrocaF3 := {{"C5_CLIENTE","SA2"}}
		Else
			aTrocaF3 := {}
		EndIf
		oGetPV:=MSMGet():New( "SC5", nReg, 3, , , , , aPosObj[1],,3,,,"A415VldTOk",,,.T.)
		A410Limpa(.F.,M->C5_TIPO)
		@ nGetLin,aPosGet[1,2]  SAY oSAY1 VAR Space(40)						SIZE 120,09 PICTURE "@!"	OF oDlg PIXEL
		@ nGetLin,aPosGet[1,3]  SAY OemToAnsi("Total :")						SIZE 020,09 OF oDlg PIXEL
		@ nGetLin,aPosGet[1,4]  SAY oSAY2 VAR 0 PICTURE TM(0,16,Iif(cPaisloc=="CHI",NIL,nNumDec))	SIZE 050,09 OF oDlg PIXEL		
		@ nGetLin,aPosGet[1,5]  SAY OemToAnsi("Desc. :")						SIZE 030,09 OF oDlg PIXEL
		@ nGetLin,aPosGet[1,6]  SAY oSAY3 VAR 0 PICTURE TM(0,16,Iif(cPaisloc=="CHI",NIL,nNumDec))		SIZE 050,09 OF oDlg PIXEL RIGHT
		@ nGetLin+10,aPosGet[1,5]  SAY OemToAnsi("=")							SIZE 020,09 OF oDlg PIXEL
		If cPaisLoc == "BRA"				
			@ nGetLin+10,aPosGet[1,6]  SAY oSAY4 VAR 0								SIZE 050,09 PICTURE TM(0,16,2) OF oDlg PIXEL RIGHT
		Else
			@ nGetLin+10,aPosGet[1,6]  SAY oSAY4 VAR 0								SIZE 050,09 PICTURE TM(0,16,Iif(cPaisloc=="CHI",NIL,nNumDec)) OF oDlg PIXEL RIGHT
		EndIf
		oDlg:Cargo	:= {|c1,n2,n3,n4| oSay1:SetText(c1),;
			oSay2:SetText(n2),;
			oSay3:SetText(n3),;
			oSay4:SetText(n4) }
		Set Key VK_F4 to A440Stok(NIL,"A410")
		oGetd:=MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],3,"A410LinOk","A410TudOk","+C6_ITEM/C6_Local/C6_TES/C6_CF/C6_PEDCLI",.T.,,1,,ITENSSC6*IIF(MaGrade(),1,3.33),"A410Blq()")
		Private oGetDad:=oGetd
		A410Bonus(2)
		Ma410Rodap(oGetD,nTotalPed,nTotalDes)
		ACTIVATE MSDIALOG oDlg ON INIT Ma410Bar(oDlg,{||nOpcA:=1,if(A410VldTOk(nOpc).And.oGetd:TudoOk(),If(!obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA := 0)},{||oDlg:End()},nOpc,oGetD,nTotalPed,@aRecnoSE1RA,@aHeadAGG,@aColsAGG)
		SetKey(VK_F4,)
	Else
		nOpcA := 1
	EndIf
	If ( nOpcA == 1 )
		A410Bonus(1)
		If a410Trava()
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Inicializa a gravacao dos lancamentos do SIGAPCO          Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			PcoIniLan("000100")
			If !A410Grava(lLiber,lTransf,2,aHeadFor,aColsFor,aRegSC6,aRegSCV,,,aRecnoSE1RA,aHeadAGG,aColsAGG)
				Help(" ",1,"A410NAOREG")
			EndIf
			If ( (ExistBlock("M410STTS") ) )
				ExecBlock("M410STTS",.f.,.f.)
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Finaliza a gravacao dos lancamentos do SIGAPCO            Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			PcoFinLan("000100")
		EndIf
	Else
		While GetSX8Len() > nStack
			RollBackSX8()
		EndDo
		If ( (ExistBlock("M410ABN")) )
			ExecBlock("M410ABN",.f.,.f.)
		EndIf
	EndIf
Else
	While GetSX8Len() > nStack
		RollBackSX8()
	EndDo
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁLimpa cliente anterior para proximo pedido                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
a410ChgCli("")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁDestrava Todos os Registros                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
MsUnLockAll()

RestArea(aAreaSX3)
RestArea(aAreaSF1)
RestArea(aAreaSD1)
RestArea(aAreaSB8)
RestArea(aArea)

Return( nOpcA )