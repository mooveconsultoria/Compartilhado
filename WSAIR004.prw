#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'TopConn.ch'
#Include 'APWEBSRV.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} WebService
Webservice para retornar as informações das faturas (SOAP)
@author  Victor Andrade
@since   04/02/2018
@version 1
/*/
//-------------------------------------------------------------------
User Function WSAIR004()	
Return

WSStruct NFPARAM
    WSData NUM_FAT As String
EndWSStruct

WSStruct FATURA
    WsData NUM_FATURA As String
    WsData DT_BAIXA   As String
    WsData VALOR      As Float
    WsData SALDO      As Float
EndWSStruct

WSSERVICE AIRBPFATURAS
    
    WSData FATURAS    As FATURA
    WSData PARAMETRO  As NFPARAM

    WSMETHOD GETFATURAS DESCRIPTION "Retorna lista de faturas específico para a Central de Negociação"

ENDWSSERVICE

WSMETHOD GETFATURAS WSRECEIVE PARAMETRO WSSEND FATURAS WSSERVICE AIRBPFATURAS
 
Local cNFParam   := Self:PARAMETRO:NUM_FAT
Local cNextAlias := GetNextAlias()
Local lRet       := .T.

If Empty(cNFParam)
    lRet := .F.
    SetSoapFault("Atenção", "Parâmetros informados inválidos")
Else
    
    //If !Empty(cFilParam)
        RPCClearEnv()
        RPCSetType(3)
        WFPrepENV( "01" , "010101" )
    //Else
    //    SetSoapFault("Atenção", "Filial não informada")
    //EndIf

EndIf

If lRet
    
    If Select(cNextAlias) > 0
        (cNextAlias)->( DbCloseArea() )
    EndIf

    BeginSQL Alias cNextAlias
        SELECT E1_FILIAL, E1_NUM, E1_BAIXA, E1_VALOR, E1_SALDO  FROM %table:SE1% SE1 
        WHERE  E1_NUM       = %exp:cNFParam%
        AND    E1_TIPO      = 'FT'
        AND    E1_FILIAL    = %xFilial:SE1%
        AND    SE1.%notdel%
    EndSQL

    (cNextAlias)->( DbGoTop() )

    If (cNextAlias)->( !Eof() )

        ::FATURAS:NUM_FATURA := AllTrim( (cNextAlias)->E1_NUM  )
        ::FATURAS:DT_BAIXA   := ToData( (cNextAlias)->E1_BAIXA )
        ::FATURAS:VALOR      := (cNextAlias)->E1_VALOR
        ::FATURAS:SALDO      := (cNextAlias)->E1_SALDO

    Else
        SetSoapFault('Atenção',"Não foram encontrados registros com os parâmetros informados.")
        lRet := .F.
    EndIf

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