#Include "Protheus.Ch"

/*/{Protheus.doc} LP520
Descrição: Contabilização da Variação Cambial.
@author Vanessa Vega
@since 22/11/2017
@version V12
@type function
/*/
User Function LP520()
	Local lContab := .F.
	Local nValVar := 0
	Local nTxIni  := 0
	Local nTxFim  := 0
	Local nValTit := 0

	If IsInCallStack("FINA070") .AND. IsInCallStack("u_EECLondon")  // A BAIXA ESTA SENDO FEITA PELA ROTINA DE EDI DE LONDRES
		lContab	:= Iif(mv_par04 == 1,.T.,.F.)
		If lContab // contabilizacao online
			nTxIni  := SE1->E1_TXMOEDA
			nTxFim  := BuscaTaxa("US$", dDataBase,,.F.)
			nValVar := (SE1->E1_VALOR * nTxFim) - (SE1->E1_VALOR * nTxIni)
		EndIf
	Else
		If AllTrim(SE5->E5_TIPO) == "FT" .AND. SE5->E5_MOEDA # "01" .AND. SE5->E5_TXMOEDA # 0
			nTxIni  := POSICIONE("SE1",1,xFilial("SE1")+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),"E1_TXMOEDA")
			nTxFim  := SE5->E5_TXMOEDA
			nValVar := (SE5->E5_VALOR * nTxFim) - (SE5->E5_VALOR * nTxIni)
		EndIf
	EndIf
Return(nValVar)