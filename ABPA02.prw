#Include "Totvs.Ch"

STATIC cDirErro	:= "\erro_msexecauto\"
STATIC cDirFunc	:= "ABPA02\"

//--------------------------------------------------
/*/{Protheus.doc} ABPA02
Função para exclusão de Nota Fiscal de Saída de acordo com parametros.

@trello ID02.2 - Rotina de cancelamento de nota

@author Irineu Filho
@since 03/05/2019 - 23:17
/*/
//--------------------------------------------------
User Function ABPA02()

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
		conOut( "ABPA02 >> Campo [" + cField + "] nao encontrado")
	endif

next nlx

if ( empty( cNF ) .or. empty( cSerie ) )
	aRet := { .F., "Não foi encontrado o documento ou serie nos parametros do request!" }
else
	aRet := excNF(, cNF , cSerie )
endif

Return aRet

 /*/{Protheus.doc} ABPA08
Executa a exclusão de NF
@type  User Function
@author Irineu Filho
@since 03/05/2019
@version 1.0
/*/
Static Function excNF( cFilPar , cDocPar , cSeriePar )

Local aRetorno		:= {}
Local nTamF2FILIAL	:= TAMSX3("F2_FILIAL")[1]
Local nTamF2DOC		:= TAMSX3("F2_DOC")[1]
Local nTamF2SERIE	:= TAMSX3("F2_SERIE")[1]
Local lRetorno		:= .T.
Local cMsgRetorno	:= ""
Local aRet          := {}

Default cFilPar		:= xFilial("SF2")
Default cDocPar		:= ""
Default cSeriePar	:= ""

makedir(cDirErro)
makedir(cDirErro+cDirFunc)

cFilPar 	:= PADR(cFilPar,nTamF2FILIAL)
cDocPar 	:= PADR(cDocPar,nTamF2DOC)
cSeriePar 	:= PADR(cSeriePar,nTamF2SERIE)

SF2->(dbSetOrder(1))
If SF2->(dbSeek( cFilPar + cDocPar + cSeriePar ))

	aRetExclui := FExcluiNF(cFilPar + cDocPar + cSeriePar)
	aRet := aClone( aRetExclui[3] )

	If aRetExclui[1]

		SF2->(dbSetOrder(1))
		If !SF2->(dbSeek( cFilPar + cDocPar + cSeriePar ))
			lRetorno := .T.
			cMsgRetorno := ""
			cMsgRetorno += "NOTA FISCAL DE SAIDA EXCLUÍDA COM SUCESSO!"
		Else
			lRetorno := .F.
			cMsgRetorno := ""
			cMsgRetorno += "Filial: " + cFilPar + CRLF
			cMsgRetorno += "Documento: " + cDocPar + CRLF
			cMsgRetorno += "Serie: " + cSeriePar + CRLF
			cMsgRetorno += "Chave Pesquisa: " + cFilPar + cDocPar + cSeriePar + CRLF
			cMsgRetorno += "PROBLEMA NA EXCLUSÃO! EXECAUTO PROCESSOU COM SUCESSO PORÉM A NOTA FISCAL DE SAÍDA NÃO FOI EXCLUIDA."
		EndIf

	Else
		lRetorno := .F.
		cMsgRetorno := ""
		cMsgRetorno += aRetExclui[2]
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

Return { lRetorno, cMsgRetorno, aRet }

//--------------------------------------------------
/*/{Protheus.doc} FExcluiNF
Função para chamada da execauto MATA520 (Exclusão de NF).

@author Irineu Filho
@since 03/05/2019 - 23:46
/*/
//--------------------------------------------------
Static Function FExcluiNF()

Local aRetorno	:= array(2)
Local aRegSD2   := {}
Local aRegSE1   := {}
Local aRegSE2   := {}
Local cHoraRMT
Local aTimeUf 
Local nHoras
Local nSpedExc
Local cMsg      := ""
Local lRet      := .T.
Local aRet      := {}
Local alErroAuto := {}

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T. 

If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2,,.T.)
	
	PcoIniLan("000102")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estorna o documento de saida                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
	SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,.F.,.T.,.F.))
	PcoFinLan("000102")

	If !lMsErroAuto
		lRet := .T.
	Else
		lRet := .F.		
		alErroAuto := GetAutoGRLog()
		aEval( alErroAuto, {|x| cMsg += AllTrim( x ) + '<br/>'})								
	EndIf

else
	
	// Se nao conseguiu validar a exclusao de NF, verifica se o motivo é prazo.
	// Em caso positivo, inclui uma NF de entrada igual ao doc de saida
	nSpedExc := getMv("MV_SPEDEXC",,24)
	cHoraRMT := getMv("MV_HORARMT",,"2")
	
	If ValType(cHoraRMT) == "L"
		If cHoraRMT
			cHoraRMT := "1"
		Else
			cHoraRMT := "2"
		EndIf
	Else
		If cHoraRMT == NIL
			cHoraRMT := "2"
		EndIf
	EndIf

	If cHoraRMT == "3"
		aTimeUf := A103HORA()
		nHoras := SubtHoras(SF2->F2_DAUTNFE, SF2->F2_HAUTNFE,dDataBase, aTimeUf[2] )
	Else
		nHoras := SubtHoras(SF2->F2_DAUTNFE, SF2->F2_HAUTNFE,dDataBase, substr(Time(),1,2)+":"+substr(Time(),4,2) )
	EndIf

	If nHoras > nSpedExc
		lRet := .F.
		cMsg += "Não foi possivel excluir a nota, pois o prazo para o cancelamento da NF-e e de " + allTrim( str( nSpedExc ) ) +" horas"
		AADD( aRet, { "motivo", "prazo" } )
	EndIf

EndIf

Return { lRet, cMsg, aRet }