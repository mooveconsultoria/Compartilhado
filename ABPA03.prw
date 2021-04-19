#Include "TOTVS.Ch"
#Include "TBICONN.Ch"

STATIC cDirErro	:= "\erro_msexecauto\"
STATIC cDirFunc	:= "ABPA03\"

//--------------------------------------------------
/*/{Protheus.doc} ABPA03
Função para realizar a devolução da Nota Fiscal de Saída.

@trello ID02.3 - Rotina de devolução de nota

@author Irineu Filho
@since 11/05/2019 - 16:03
@param param, param_type, param_descr
/*/
//--------------------------------------------------
User Function ABPA03()

Local cBody      := PARAMIXB[2]
Local oBody      := JsonObject():New()
Local aDados
Local aFields
Local nlx
Local cField
Local uInfo
Local cNF
Local cSerie
Local aRet
Local cFil := cFilAnt
Local cEmp := cEmpAnt

oBody:fromJson( cBody )
aDados  := oBody:getJsonObject( "DADOS" )

aFields := aDados[1]:getNames()

for nlx := 1 to len( aFields )

	cField := aFields[nlx]
	uInfo  := aDados[1]:getJsonText( aFields[nlx] )

	if ( cField == "NF" )
		cNF := PADR( uInfo, tamSX3("F2_DOC")[1] )
	elseif ( cField == "SERIE" )
		cSerie := PADR( uInfo, tamSX3("F2_SERIE")[1] )	
	else
		conOut( "ABPA03 >> Campo [" + cField + "] nao encontrado")
	endif

next nlx

if ( empty( cNF ) .or. empty( cSerie ) )
	aRet := { .F., "Não foi encontrado o documento ou serie nos parametros do request!" }
else
	aRet := devNF(, cNF , cSerie )
endif

Return aRet

/*
User Function ABPA03()

Local cFilPar := ""
Local cDocPar := ""
Local cSeriePar := ""

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010104"

cFilPar := fwxFilial("SF2")
cDocPar := "000003216"
cSeriePar := "001"

devNF( cFilPar , cDocPar , cSeriePar )

RESET ENVIRONMENT

Return
*/

 /*/{Protheus.doc} ABPA08
Executa a devolução de NF de saída
@type  User Function
@author Irineu Filho
@since 03/05/2019
@version 1.0
/*/
Static Function devNF( cFilPar , cDocPar , cSeriePar )

Local aRetorno     := {}
Local lRetorno     := .F.
Local cMsgRetorno  := ""
Local nTamF2FILIAL := TAMSX3("F2_FILIAL")[1]
Local nTamF2DOC    := TAMSX3("F2_DOC")[1]
Local nTamF2SERIE  := TAMSX3("F2_SERIE")[1]
Local aRetExclui   := {}
Local aReturn      := {}

Default cFilPar := fwxFilial( "SF2" )
Default cDocPar := ""
Default cSeriePar := ""

makedir(cDirErro)
makedir(cDirErro+cDirFunc)

cFilPar 	:= PADR(cFilPar,nTamF2FILIAL)
cDocPar 	:= PADR(cDocPar,nTamF2DOC)
cSeriePar 	:= PADR(cSeriePar,nTamF2SERIE)

SF2->(dbSetOrder(1))
SF2->(dbGoTop())
If SF2->(dbSeek( cFilPar + cDocPar + cSeriePar ))

	aRetExclui := FDevolveNF()

	lRetorno := aRetExclui[1]
	aReturn  := aClone( aRetExclui[3] )

	If lRetorno
		cMsgRetorno := "NOTA FISCAL DEVOLVIDA COM SUCESSO!"
	Else
		cMsgRetorno := aRetExclui[2]
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

Return { lRetorno, cMsgRetorno, aReturn }

//--------------------------------------------------
/*/{Protheus.doc} FDevolveNF
Função para tratamento dos dados e chamada da execauto MATA103.

@author Irineu Filho
@since 11/05/2019 - 16:11
@param param, param_type, param_descr
/*/
//--------------------------------------------------
Static Function FDevolveNF(nRecnoSF2)

Local aCabSF1   := {}
Local aItensSD1 := {}
Local aRetInfo  := {}
Local aRetorno  := array(3)
Local lContinua := .T.
Local alErroAuto := {}
Local clMsgErro := ""

Default nRecnoSF2 := SF2->(Recno())

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T. 

//--------------------------
//Posiciona no Recno da SF2.
//--------------------------
lContinua := .T.
If nRecnoSF2 <> SF2->(Recno())
	SF2->(dbGoto(nRecnoSF2))
	lContinua := SF2->(!EOF())
EndIf

If lContinua
	aRetInfo := ACLONE(FRetSF1( SF2->F2_CLIENTE, SF2->F2_LOJA ))

	If aRetInfo[1]

		aCabSF1 := ACLONE(aRetInfo[2])

		If Len(aCabSF1) > 0

			aRetInfo := ACLONE(FRetSD1( SF2->F2_FILIAL , SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA ))

			If aRetInfo[1]
			
				aItensSD1 := ACLONE(aRetInfo[2])
				
				If Len(aCabSF1) > 0 .AND. Len(aItensSD1) > 0
					
					MSExecAuto({|x,y,z| MATA103(x,y,z) },aCabSF1,aItensSD1,3)
					
					If !lMsErroAuto
						aRetorno[1] := .T.
						aRetorno[3] := { {"nfDevolucao", SF1->F1_DOC } }
					Else
						aRetorno[1] := .F.
						aRetorno[3] := {}

						alErroAuto := GetAutoGRLog()
						aEval( alErroAuto, {|x| clMsgErro += AllTrim( x ) + '<br/>'})					
						
						if ( empty( clMsgErro ) )
							clMsgErro := "FALHA NA EXECAUTO DE DEVOLUÇÃO (MATA103). NAO FOI RETORNADO MENSAGEM PARA TRATAMENTO DE ERROS."
						endif

						aRetorno[2] := clMsgErro
					EndIf
				Else
					aRetorno[1] := .F.
					aRetorno[2] := "PROBLEMAS AO CARREGAR AS INFORMAÇÕES DE CABEÇALHO E/OU ITENS"
				EndIf

			Else
				aRetorno[1] := .F.
				aRetorno[2] := aRetInfo[2]
			EndIf
		Else
			aRetorno[1] := .F.
			aRetorno[2] := "PROBLEMAS AO CARREGAR AS INFORMAÇÕES DE CABEÇALHO"
		EndIf
	Else
		aRetorno[1] := .F.
		aRetorno[2] := aRetInfo[2]
	EndIf
Else
	aRetorno[1] := .F.
	aRetorno[2] := ""
	aRetorno[2] += "Recno SF2: " + Alltrim(Str(nRecnoSF2)) + CRLF
	aRetorno[2] += "RECNO SF2 NÃO ENCONTRADO!"
EndIf

Return aRetorno

//--------------------------------------------------
/*/{Protheus.doc} FRetSF1
Função para retorno das informações de Cabeçalho da NF de Entrada (Devolução)

@author Irineu Filho
@since 11/05/2019 - 16:18
/*/
//--------------------------------------------------
Static Function FRetSF1( cCliPar , cLojaPar )

Local aRetorno		:= { Nil , Nil }
Local aInfoSF1		:= {}
Local cF1ESPECIE	:= GetMV("BP_ESPECIE",,"NF")
Local cF1SERIE		:= GetMV("BP_SERIEDE",,"001")
Local cTipoNf  := SuperGetMv("MV_TPNRNFS")
Local lContinua 	:= .T.

//--------------------
//Validação do Cliente
//--------------------
SA1->(dbSetOrder(1))
If SA1->(!dbSeek( xFilial("SA1") + cCliPar + cLojaPar ))
	aRetorno[2] := ""
	aRetorno[2] += "Filial: " + xFilial("SA1") + CRLF
	aRetorno[2] += "Codigo: " + cCliPar + CRLF
	aRetorno[2] += "Loja: " + cLojaPar + CRLF
	aRetorno[2] += "Chave Pesquisa: " + xFilial("SA1") + cCliPar + cLojaPar + CRLF
	aRetorno[2] += "CLIENTE NÃO ENCONTRADO!"
	lContinua := .F.
EndIf

If lContinua
	//---------------------
	//Busca o número da NF.
	//---------------------
	cNumDoc := NxtSX5Nota(cF1SERIE, NIL, cTipoNf)
	Aadd(aInfoSF1,{"F1_DOC"		,cNumDoc	,NIL})
	Aadd(aInfoSF1,{"F1_SERIE"	,cF1SERIE	,NIL})
	Aadd(aInfoSF1,{"F1_FORNECE"	,cCliPar	,Nil})
	Aadd(aInfoSF1,{"F1_LOJA"	,cLojaPar	,Nil})
	Aadd(aInfoSF1,{"F1_EMISSAO"	,MsDate()	,Nil})
	Aadd(aInfoSF1,{"F1_TIPO"	,"D"		,Nil})
	Aadd(aInfoSF1,{"F1_ESPECIE"	,cF1ESPECIE	,Nil})
	Aadd(aInfoSF1,{"F1_FORMUL"	,"S"		,Nil})
	aRetorno[2] := ACLONE(aInfoSF1)
EndIf

aRetorno[1] := lContinua

Return aRetorno

//--------------------------------------------------
/*/{Protheus.doc} FRetSD1
Função para retorno das informações do SD1.

@author Irineu Filho
@since 11/05/2019 - 16:47
/*/
//--------------------------------------------------
Static Function FRetSD1( cFilPar , cDocPar , cSeriePar , cCliPar , cLojaPar )

Local aAuxSD1 := {}
Local aInfoSD1	:= {}
Local aRetorno := { Nil , Nil }
Local cChaveSeek := ""
Local cMsgRetorno := ""

Default cFilPar := ""
Default cDocPar := ""
Default cSeriePar := ""
Default cCliPar := ""
Default cLojaPar := ""

cChaveSeek := cFilPar + cDocPar + cSeriePar + cCliPar + cLojaPar

SD2->(dbSetOrder(3))
If SD2->(dbSeek( cChaveSeek ))

	cMsgRetorno := ""
	lContinua := .T.

	While SD2->(!EOF()) .AND. ( SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA == cChaveSeek )

		cMsgRetorno += "D2_ITEM: " + SD2->D2_ITEM + CRLF

		SF4->(dbSetOrder(1))
		If !SF4->(dbSeek( xFilial("SF4") + SD2->D2_TES ))
			cMsgRetorno += "Filial: " + xFilial("SF4") + CRLF
			cMsgRetorno += "TES: " + SD2->D2_TES + CRLF
			cMsgRetorno += "Chave Pesquisa: " + xFilial("SF4") + SD2->D2_TES + CRLF
			cMsgRetorno += "TES [D2_TES] NÃO ENCONTRADA!" + CRLF
			lContinua := .F.
		EndIf

		If lContinua
			aAuxSD1 := {}
			Aadd(aAuxSD1,{"D1_COD"		,SD2->D2_COD					,NIL})
			Aadd(aAuxSD1,{"D1_QUANT"	,SD2->D2_QUANT					,NIL})
			Aadd(aAuxSD1,{"D1_VUNIT"	,SD2->D2_PRCVEN					,NIL})
			Aadd(aAuxSD1,{"D1_TOTAL"	,(SD2->D2_QUANT*SD2->D2_PRCVEN)	,NIL})
			Aadd(aAuxSD1,{"D1_FORMUL"	,"S"							,NIL})
			Aadd(aAuxSD1,{"D1_TES"		,If(!Empty(SF4->F4_TESDV), SF4->F4_TESDV, "130")					,NIL})
			Aadd(aAuxSD1,{"D1_LOCAL"	,SD2->D2_LOCAL					,NIL})
			Aadd(aAuxSD1,{"D1_NFORI"	,SD2->D2_DOC					,NIL})
			Aadd(aAuxSD1,{"D1_SERIORI"	,SD2->D2_SERIE					,NIL})
			Aadd(aAuxSD1,{"D1_ITEMORI"	,SD2->D2_ITEM					,NIL})
			Aadd(aInfoSD1, aAuxSD1)
		EndIf

		cMsgRetorno += "------------------" + CRLF

		SD2->(dbSkip())
	EndDo

	If lContinua
		aRetorno[1] := .T.
		aRetorno[2] := ACLONE(aInfoSD1)
	Else
		aRetorno[1] := .F.
		aRetorno[2] := cMsgRetorno
	EndIf

Else
	aRetorno[1] := .F.
	aRetorno[2] := ""
	aRetorno[2] += "Filial: " + cFilPar + CRLF
	aRetorno[2] += "Documento: " + cDocPar + CRLF
	aRetorno[2] += "Serie: " + cSeriePar + CRLF
	aRetorno[2] += "Codigo: " + cCliPar + CRLF
	aRetorno[2] += "Loja: " + cLojaPar + CRLF
	aRetorno[2] += "Chave Pesquisa: " + cChaveSeek + CRLF
	aRetorno[2] += "INFORMAÇÕES NÃO ENCONTRADAS NA TABELA DE ITENS [SD2]!"
EndIf

Return aRetorno