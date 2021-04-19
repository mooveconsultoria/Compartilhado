#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'TopConn.ch'
#Include 'APWEBSRV.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} WebService
Webservice para retornar os dados financeiros das notas fiscais
@author  Victor Andrade
@since   04/02/2018
@version 1
/*/
//-------------------------------------------------------------------
User Function WSAIR003()	
Return

WsStruct NOTAPARAM

WsData DATA_INI As String 
WsData DATA_FIM As String
WsData TIPO     As String

EndWsStruct

WsStruct NFISCAL

    WsData FILIAL   As String
    WsData NUM_TIT  As String
    WsData TIPO     As String
    WsData CLIENTE  As String
    WsData LOJA     As String
    WsData EMISSAO  As String
    WsData VENCTO   As String
    WsData FATURA   As String
    WsData FIL_ORI  As String
    WsData DT_BAIXA As String
    WsData VALOR    As Float
    WsData SALDO    As Float

EndWsStruct

WSSERVICE AIRBPNFS
    
    WSData NOTAS      As Array Of NFISCAL
    WSData PARAMETRO  As NOTAPARAM

    WSMETHOD GETNF DESCRIPTION "Retorna lista de faturas específico para a Central de Negociação"

ENDWSSERVICE

WSMETHOD GETNF WSRECEIVE PARAMETRO WSSEND NOTAS WSSERVICE AIRBPNFS
 
Local cIniParam  := self:PARAMETRO:DATA_INI
Local cFimParam  := self:PARAMETRO:DATA_FIM
Local cTipo      := self:PARAMETRO:TIPO
Local cQuery     := ""
Local cNextAlias := ""
Local lRet       := .T.
Local oNota      := Nil

If Empty( cTipo )
    cTipo := "%'NF','FT'%"
Else
    cTipo := "%'" + cTipo + "'%"
EndIf

If Empty(cIniParam) .Or. Empty(cFimParam)
    lRet := .F.
    SetSoapFault("Atenção", "Parâmetros inválidos")
Else
    RPCClearEnv()
	RPCSetType(3)
	WFPrepENV( "01" , "010101" )

    cNextAlias := GetNextAlias()
EndIf

If lRet

    If Select(cNextAlias) > 0
        (cNextAlias)->( DbCloseArea() )
    EndIf

    BeginSQL Alias cNextAlias
        SELECT  E1_FILIAL, E1_NUM, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_EMISSAO, E1_VENCREA, E1_FATURA, E1_FILORIG, 
                E1_VALOR, E1_BAIXA, E1_SALDO  FROM %table:SE1% SE1
        WHERE E1_EMISSAO BETWEEN %exp:cIniParam% AND %exp:cFimParam%
        AND   E1_TIPO IN ( %exp:cTipo% )
        AND   E1_FILIAL = %xFilial:SE1%
        AND   SE1.%notdel%
    EndSQL

    (cNextAlias)->( DbGoTop() )

    While (cNextAlias)->( !Eof() )

        oNota := WsClassNew( "NFISCAL" )

        oNota:FILIAL    := AllTrim( (cNextAlias)->E1_FILIAL )
        oNota:NUM_TIT   := AllTrim( (cNextAlias)->E1_NUM )
        oNota:TIPO      := AllTrim( (cNextAlias)->E1_TIPO )
        oNota:CLIENTE   := AllTrim( (cNextAlias)->E1_CLIENTE )
        oNota:LOJA      := AllTrim( (cNextAlias)->E1_LOJA )
        oNota:EMISSAO   := ToData( (cNextAlias)->E1_EMISSAO )
        oNota:VENCTO    := ToData( (cNextAlias)->E1_VENCREA )
        oNota:FATURA    := AllTrim( (cNextAlias)->E1_FATURA )
        oNota:FIL_ORI   := AllTrim( (cNextAlias)->E1_FILORIG )
        oNota:DT_BAIXA  := ToData( (cNextAlias)->E1_BAIXA )
        oNota:VALOR     := Round( (cNextAlias)->E1_VALOR, 2 )
        oNota:SALDO     := Round( (cNextAlias)->E1_SALDO, 2 )
        
        Aadd( Self:NOTAS, oNota )

        (cNextAlias)->( DbSkip() )

    EndDo

EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ToData
Converte a data para o formato da central de negociações
@author  Victor Andrade
@since   16/02/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function ToData( cData )
Return( SubStr( cData, 1, 4 ) + "-" + SubStr( cData, 5, 2 ) + "-" + SubStr( cData, 7, 2 ) )