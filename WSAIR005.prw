#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'TopConn.ch'
#Include 'APWEBSRV.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} WebService
Webservice para retornar os cancelamentos de notas fiscais (SOAP)
@author  Victor Andrade
@since   10/02/2018
@version 1
/*/
//-------------------------------------------------------------------
User Function WSAIR005()	
Return

WSStruct NFCANCPARAM
    WsData DATA_INI    As String
    WsData DATA_FIM    As String
EndWSStruct

WSStruct CANCELADAS
    WsData NUM_NOTA As String
    WsData PREFIXO  As String
    WsData FILIAL   As String
    WsData CODCLI   As String
    WsData LOJACLI  As String
    WsData OBS      As String
    WsData TIPO     As String
EndWSStruct

WSSERVICE AIRBPCANCELAMENTOS
    
    WSData NFCANCEL   As Array Of CANCELADAS
    WSData PARAMETRO  As NFCANCPARAM

    WSMETHOD GETCANCELAMENTOS DESCRIPTION "Retorna lista de notas fiscais canceladas específico para a Central de Negociação"

ENDWSSERVICE

WSMETHOD GETCANCELAMENTOS WSRECEIVE PARAMETRO WSSEND NFCANCEL WSSERVICE AIRBPCANCELAMENTOS

Local aCanc    := {}
Local aDevs    := {}
Local lRet     := .T.
Local nX       := 0
Local oNFCanc  := Nil

// Entra em qualquer empresa, pois deve filtrar todas as filiais
RPCClearEnv()
RPCSetType(3)
WFPrepENV( "01" , "010101" )

aCanc := GetCancel( self:PARAMETRO:DATA_INI, self:PARAMETRO:DATA_FIM )

aDevs := GetDevols( self:PARAMETRO:DATA_INI, self:PARAMETRO:DATA_FIM )

If Len( aCanc ) > 0 .Or. Len( aDevs ) > 0

    For nX := 1 To Len( aCanc )
        
        oNFCanc := WsClassNew( "CANCELADAS" )
    
        oNFCanc:NUM_NOTA := aCanc[nX][1]
        oNFCanc:PREFIXO  := aCanc[nX][2]
        oNFCanc:FILIAL   := aCanc[nX][3]
        oNFCanc:CODCLI   := aCanc[nX][4]
        oNFCanc:LOJACLI  := aCanc[nX][5]
        oNFCanc:OBS      := aCanc[nX][6]
        oNFCanc:TIPO     := aCanc[nX][7]

        aAdd( self:NFCANCEL, oNFCanc )

    Next nX

    For nX := 1 To Len( aDevs )
        
        oNFCanc := WsClassNew( "CANCELADAS" )
    
        oNFCanc:NUM_NOTA := aDevs[nX][1]
        oNFCanc:PREFIXO  := aDevs[nX][2]
        oNFCanc:FILIAL   := aDevs[nX][3]
        oNFCanc:CODCLI   := aDevs[nX][4]
        oNFCanc:LOJACLI  := aDevs[nX][5]
        oNFCanc:OBS      := aDevs[nX][6]
        oNFCanc:TIPO     := aDevs[nX][7]

        aAdd( self:NFCANCEL, oNFCanc )

    Next nX

Else
    SetSoapFault( "Atenção", "Não foram encontrados registros com os parâmetros informados." )
    lRet := .F.
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCancel
Retorna notas fiscais canceladas de acordo com parâmetros
@author  Victor Andrade
@since   12/02/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function GetCancel( cPeriodoIni, cPeriodoFim )

Local aArea      := GetArea()
Local cAliasCanc := "TMPCANC"
Local aRet       := {}

If Select( cAliasCanc ) > 0; ( cAliasCanc )->( DbCloseArea() ); EndIf

BeginSQL Alias cAliasCanc 
    SELECT F3_FILIAL, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, F3_OBSERV FROM %table:SF3% SF3
    WHERE SF3.F3_FILIAL <> ''
    AND   SF3.F3_DTCANC BETWEEN %exp:cPeriodoIni% AND %exp:cPeriodoFim%
    AND   SF3.%notdel%
EndSQL

(cAliasCanc)->( DbGoTop() )

While (cAliasCanc)->( !Eof() )

    aAdd( aRet, { ;
                  (cAliasCanc)->F3_NFISCAL,;
                  (cAliasCanc)->F3_SERIE,;
                  (cAliasCanc)->F3_FILIAL,;
                  (cAliasCanc)->F3_CLIEFOR,;
                  (cAliasCanc)->F3_LOJA,;
                  (cAliasCanc)->F3_OBSERV,;
                  "C";
                };
        )

    (cAliasCanc)->( DbSkip() )

EndDo

RestArea( aArea )

Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDevols
Retorna notas fiscais canceladas de acordo com parâmetros
@author  Victor Andrade
@since   12/02/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function GetDevols( cPeriodoIni, cPeriodoFim )

Local aArea     := GetArea()
Local cAliasDev := "TMPDEV"
Local aRet      := {}

If Select( cAliasDev ) > 0; (cAliasDev)->( DbCloseArea() ); EndIf

BeginSQL Alias cAliasDev 
    SELECT D1_FILIAL, D1_NFORI, D1_SERIORI, D1_FORNECE, D1_LOJA FROM %table:SD1% SD1
    WHERE SD1.D1_FILIAL <> ''
    AND   SD1.D1_TIPO = 'D'
    AND   SD1.D1_EMISSAO BETWEEN %exp:cPeriodoIni% AND %exp:cPeriodoFim%
    AND   SD1.%notdel%
    GROUP BY D1_FILIAL, D1_NFORI, D1_SERIORI, D1_FORNECE, D1_LOJA
EndSQL

(cAliasDev)->( DbGoTop() )

While (cAliasDev)->( !Eof() )

    aAdd( aRet, { ;
                  (cAliasDev)->D1_NFORI,;
                  (cAliasDev)->D1_SERIORI,;
                  (cAliasDev)->D1_FILIAL,;
                  (cAliasDev)->D1_FORNECE,;
                  (cAliasDev)->D1_LOJA,;
                  "",;
                  "D";
                }; 
        )

    (cAliasDev)->( DbSkip() )

EndDo

RestArea( aArea )

Return( aRet )