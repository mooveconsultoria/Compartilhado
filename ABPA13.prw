#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} ABPA13
// Monitor do SEFAZ - Retornar o status das NF's no Sefaz informadas nos parametros
@author (DS2U) - Everton Diniz
@since 20/05/2019
@version 1.0
@return ${return}, ${return_description}
@param 
        * Parametros de recebimento das informações *
        aParam[1] - Série das Notas Fiscais
	    aParam[2] - Nota Fiscal Inicial
        aParam[3] - Nota Fiscal Final

        * Parametros de retorno das informações *
        aRet[1] - Parâmetro Lógico. Se encontrou informações dos parâmetros, retornar .T. Se não retorna .F.  
        aRet[2] - Parâmetro Texto. Retorno das mensagens obtidas do SEFAZ

@type function
/*/
User Function ABPA13(aParam)

Local aNF       := {}
Local aRet      := Array(2)
Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cIdEnt	:= StaticCall(SPEDNFE, GetIdEnt, .F.)
Local nPos      := 0

Private cRecomendacaooLote := ""

aNF := procMonitorDoc(cIdEnt, cURL, aParam, 1)

If Len(aNF) == 0
	aRet[1] := .F.
	aRet[2] := "Notas Fiscais nao encontradas / nao transmitidas </br>"
Else

	aRet[1] := .T.
	aRet[2] := {}

	For nPos := 1 To Len(aNF)

		AADD( aRet[2], { aNF[nPos,1], If(aNF[nPos,7] == 1,"Producao","Homologacao"), If(aNF[nPos,8] == 1,"Normal","Contingencia"), Alltrim(aNF[nPos,4]), Alltrim(aNF[nPos,9]) } )		
		
	Next nPos

EndIf
	
Return aRet