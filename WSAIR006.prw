#Include 'protheus.ch'
#Include 'parmtype.ch'
#INCLUDE "APWEBSRV.CH"
#Include 'TopConn.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} WebService
Webservice para retornar informações dos comprovantes de entrega
@author  Victor Andrade
@since   06/02/2018
@version 1
/*/
//-------------------------------------------------------------------
User Function WSAIR006()	
Return

WSStruct COMPROV_ENTREGA

    WsData ZB0_FILIAL   As String
    WsData ZB0_NUMCE    As String
    WsData ZB0_DTEMIS   As String
    WsData ZB0_CODCLI   As String
    WsData ZB0_LOJCLI   As String
    WsData ZB0_PREFIX   As String
    WsData ZB0_CTA      As String
    WsData ZB0_HORINI   As String
    WsData ZB0_HORFIM   As String
    WsData ZB0_NUMVOO   As String
    WsData ZB0_TIPAER   As String
    WsData ZB0_TSTVIS   As String
    WsData ZB0_MATRIC   As String
    WsData ZB0_CODAER   As String
    WsData ZB0_OBSERV   As String
    WsData ZB0_PRODUT   As String
    WsData ZB0_QTDE     As Float
    WsData ZB0_PRCNEG   As String
    WsData ZB0_PRCVEN   As Float
    WsData ZB0_REGIST   As String
    WsData ZB0_STATUS   As String
    WsData ZB0_USUARI   As String
    WsData ZB0_DTINCL   As String
    WsData ZB0_HRINCL   As String
    WsData ZB0_NOMCLI   As String
    WsData ZB0_NOMAER   As String
    WsData ZB0_DESPRO   As String
    WsData ZB0_DESEND   As String
    WsData ZB0_CONTRA   As String
    WsData ZB0_CODTAB   As String
    WsData ZB0_REVTAB   As String
    WsData ZB0_HORINT   As String
    WsData ZB0_REGFIM   As String
    WsData ZB0_DENSAB   As Float
    WsData ZB0_TEMPAB   As Float
    WsData ZB0_LOCAL    As String
    WsData ZB0_PGTVIS   As String
    WsData ZB0_NUMSEQ   As String
    WsData ZB0_HRDIGI   As String
    WsData ZB0_DTDIGI   As String
    WsData ZB0_DEVOLU   As String

EndWsStruct

WSStruct PARAMCE

    WsData DATA_INICIO As String
    WsData DATA_FIM    As String

EndWsStruct

WSSERVICE AIRBPCE
    
    WSData CE   As Array Of COMPROV_ENTREGA
    WSDATA PARAMETRO  As PARAMCE

    WSMETHOD GETCE DESCRIPTION "Retorna lista dos comprovantes de Entrega"

ENDWSSERVICE

WSMETHOD GETCE WSRECEIVE PARAMETRO WSSEND CE WSSERVICE AIRBPCE
 
Local cIniParam  := self:PARAMETRO:DATA_INICIO
Local cFimParam  := self:PARAMETRO:DATA_FIM
Local lRet       := .T.
Local cNextAlias := ""
Local cQuery     := ""
Local oItemCE    := Nil

// Sempre entra na filial 010101
WFPrepENV( "01" , "010101" )

cNextAlias := GetNextAlias()

If Select( cNextAlias ) > 0
    (cNextAlias)->( DbCloseArea() )
EndIf

BeginSQL Alias cNextAlias
    SELECT ZB0_FILIAL, ZB0_NUMCE, ZB0_DTEMIS, ZB0_CODCLI, ZB0_LOJCLI, ZB0_PREFIX, ZB0_CTA, ZB0_HORINI, ZB0_HORFIM, ZB0_NUMVOO, 
    ZB0_TIPAER, ZB0_TSTVIS, ZB0_MATRIC, ZB0_CODAER, ZB0_OBSERV, ZB0_PRODUT, ZB0_QTDE, ZB0_PRCNEG, ZB0_PRCVEN, ZB0_REGIST,
    ZB0_STATUS, ZB0_USUARI, ZB0_DTINCL, ZB0_HRINCL, ZB0_NOMCLI, ZB0_NOMAER, ZB0_DESPRO, ZB0_DESEND, ZB0_CONTRA,
    ZB0_CODTAB, ZB0_REVTAB, ZB0_HORINT, ZB0_REGFIM, ZB0_DENSAB, ZB0_TEMPAB, ZB0_LOCAL, ZB0_PGTVIS, ZB0_NUMSEQ, ZB0_HRDIGI,
    ZB0_DTDIGI, ZB0_DEVOLU FROM %table:ZB0% ZB0
    WHERE ZB0.ZB0_FILIAL <> ''
    AND   ZB0.ZB0_DTEMIS BETWEEN %exp:cIniParam% AND %exp:cFimParam%
    AND   ZB0.%notdel%
EndSQL

If (cNextAlias)->( Eof() )
    SetSoapFault( "Atenção", "Não foram encontrados registros." )
    lRet := .F.
Else

    While (cNextAlias)->( !Eof() )
    
        oItemCE := WSClassNew( "COMPROV_ENTREGA" )
        oItemCE:ZB0_FILIAL  := AllTrim( (cNextAlias)->ZB0_FILIAL )
        oItemCE:ZB0_NUMCE   := AllTrim( (cNextAlias)->ZB0_NUMCE ) 
        oItemCE:ZB0_DTEMIS  := ToData( (cNextAlias)->ZB0_DTEMIS )
        oItemCE:ZB0_CODCLI  := AllTrim( (cNextAlias)->ZB0_CODCLI )
        oItemCE:ZB0_LOJCLI  := AllTrim( (cNextAlias)->ZB0_LOJCLI )
        oItemCE:ZB0_PREFIX  := AllTrim( (cNextAlias)->ZB0_PREFIX )
        oItemCE:ZB0_CTA     := AllTrim( (cNextAlias)->ZB0_CTA )   
        oItemCE:ZB0_HORINI  := AllTrim( (cNextAlias)->ZB0_HORINI )
        oItemCE:ZB0_HORFIM  := AllTrim( (cNextAlias)->ZB0_HORFIM )
        oItemCE:ZB0_NUMVOO  := AllTrim( (cNextAlias)->ZB0_NUMVOO )
        oItemCE:ZB0_TIPAER  := AllTrim( (cNextAlias)->ZB0_TIPAER )
        oItemCE:ZB0_TSTVIS  := AllTrim( (cNextAlias)->ZB0_TSTVIS )
        oItemCE:ZB0_MATRIC  := AllTrim( (cNextAlias)->ZB0_MATRIC )
        oItemCE:ZB0_CODAER  := AllTrim( (cNextAlias)->ZB0_CODAER )
        oItemCE:ZB0_OBSERV  := AllTrim( (cNextAlias)->ZB0_OBSERV )
        oItemCE:ZB0_PRODUT  := AllTrim( (cNextAlias)->ZB0_PRODUT )
        oItemCE:ZB0_QTDE    := (cNextAlias)->ZB0_QTDE  
        oItemCE:ZB0_PRCNEG  := AllTrim( (cNextAlias)->ZB0_PRCNEG )
        oItemCE:ZB0_PRCVEN  := (cNextAlias)->ZB0_PRCVEN
        oItemCE:ZB0_REGIST  := AllTrim( (cNextAlias)->ZB0_REGIST )
        oItemCE:ZB0_STATUS  := AllTrim( (cNextAlias)->ZB0_STATUS )
        oItemCE:ZB0_USUARI  := AllTrim( (cNextAlias)->ZB0_USUARI )
        oItemCE:ZB0_DTINCL  := ToData( (cNextAlias)->ZB0_DTINCL )
        oItemCE:ZB0_HRINCL  := AllTrim( (cNextAlias)->ZB0_HRINCL )
        oItemCE:ZB0_NOMCLI  := AllTrim( (cNextAlias)->ZB0_NOMCLI )
        oItemCE:ZB0_NOMAER  := AllTrim( (cNextAlias)->ZB0_NOMAER )
        oItemCE:ZB0_DESPRO  := AllTrim( (cNextAlias)->ZB0_DESPRO )
        oItemCE:ZB0_DESEND  := AllTrim( (cNextAlias)->ZB0_DESEND )
        oItemCE:ZB0_CONTRA  := AllTrim( (cNextAlias)->ZB0_CONTRA )
        oItemCE:ZB0_CODTAB  := AllTrim( (cNextAlias)->ZB0_CODTAB )
        oItemCE:ZB0_REVTAB  := AllTrim( (cNextAlias)->ZB0_REVTAB )
        oItemCE:ZB0_HORINT  := AllTrim( (cNextAlias)->ZB0_HORINT )
        oItemCE:ZB0_REGFIM  := AllTrim( (cNextAlias)->ZB0_REGFIM )
        oItemCE:ZB0_DENSAB  := (cNextAlias)->ZB0_DENSAB
        oItemCE:ZB0_TEMPAB  := (cNextAlias)->ZB0_TEMPAB
        oItemCE:ZB0_LOCAL   := AllTrim( (cNextAlias)->ZB0_LOCAL  )
        oItemCE:ZB0_PGTVIS  := AllTrim( (cNextAlias)->ZB0_PGTVIS )
        oItemCE:ZB0_NUMSEQ  := AllTrim( (cNextAlias)->ZB0_NUMSEQ )
        oItemCE:ZB0_HRDIGI  := AllTrim( (cNextAlias)->ZB0_HRDIGI )
        oItemCE:ZB0_DTDIGI  := ToData( (cNextAlias)->ZB0_DTDIGI )
        oItemCE:ZB0_DEVOLU  := AllTrim( (cNextAlias)->ZB0_DEVOLU )

        aAdd( self:CE, oItemCE )
        
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