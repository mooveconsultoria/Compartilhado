#Include 'protheus.ch'
#Include 'parmtype.ch'
#INCLUDE "APWEBSRV.CH"
#Include 'TopConn.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} WebService
Webservice para retornar informações de notas fiscais analíticas
@author  Victor Andrade
@since   06/02/2018
@version 1
/*/
//-------------------------------------------------------------------
User Function WSAIR002()	
Return

WSStruct ITEMNF

    WsData FILIAL           As String
    WsData NUM_NOTA         As String
    WsData CLIENTE          As String
    WsData LOJA             As String
    WsData UF               As String
    WsData DATA_EMISSAO_NF  As String
    WsData COD_FISCAL       As String
    WsData CE               As String Optional
    WsData PRODUTO          As String
    WsData ITEM             As String
    WsData QUANTIDADE       As Float
    WsData VALOR_UNITARIO   As Float
    WsData VALOR_TOTAL      As Float
    WsData VALOR_ICMS       As Float Optional
    WsData PIS              As Float Optional
    WsData COFINS           As Float Optional
    WsData REC_LIQUIDA      As Float
    WsData SEGMENTO         As String
    WsData TIPO         	As String
 
EndWsStruct

WSStruct PARAMPV

    WsData CLIENTE  As String 
    WsData LOJA     As String
    WsData INICIO   As String
    WsData FIM      As String

EndWsStruct

WSSERVICE AIRBPNFANALITICO
    
    WSData ITENSNF   As Array Of ITEMNF
    WSDATA PARAMETRO  As PARAMPV

    WSMETHOD GETPEDIDOS DESCRIPTION "Retorna lista de itens das notas fiscais específico para a Central de Negociação"

ENDWSSERVICE

WSMETHOD GETPEDIDOS WSRECEIVE PARAMETRO WSSEND ITENSNF WSSERVICE AIRBPNFANALITICO
 
Local cCliParam  := self:PARAMETRO:CLIENTE
Local cLojParam  := self:PARAMETRO:LOJA
Local cIniParam  := self:PARAMETRO:INICIO
Local cFimParam  := self:PARAMETRO:FIM
Local lRet       := .T.
Local cNextAlias := ""
Local cQuery     := ""
Local oItemNF    := Nil
Local cSdTipo    := ""
Local cEnTipo    := ""

If Empty( cIniParam ) .Or. Empty( cFimParam ) 
    lRet := .F.
    SetSoapFault("Atenção", "Data inicial e final obrigatória")
Else
    RPCClearEnv()
    RPCSetType(3)
    
	WFPrepENV( "01" , "010101" )

    cNextAlias := GetNextAlias()
EndIf


If lRet


	cSdTipo := SuperGetMV("MV_XWSTNS",,"'N'")
	cEnTipo := SuperGetMV("MV_XWSTNE",,"'D'")

	//NFs de Venda
    cQuery := "SELECT D2_FILIAL AS FILIAL, "
    cQuery += "D2_TIPO AS TIPO, "
    cQuery += "D2_DOC AS DOC, "
    cQuery += "D2_CLIENTE AS CLIENTE, "
    cQuery += "D2_LOJA AS LOJA, "
    cQuery += "D2_EST AS EST, "
    cQuery += "D2_EMISSAO AS EMISSAO, "
    cQuery += "D2_CF AS CF, "
    cQuery += "D2_COD AS COD, "
    cQuery += "D2_ITEM AS ITEM, "
    cQuery += "D2_QUANT AS QUANT, "
    cQuery += "D2_PRCVEN AS PRCVEN, "
    cQuery += "D2_TOTAL AS TOTAL, "
    cQuery += "D2_VALICM AS VALICM, "
    cQuery += "D2_VALIMP5 AS VALIMP5, "
    cQuery += "D2_VALIMP6 AS VALIMP6, "
    cQuery += "C5_XNUMCE AS XNUMCE, "
    cQuery += "A1_XSEGM AS XSEGM "
    cQuery += "FROM " + RetSQLName( "SD2" ) + " SD2 "
    cQuery += "INNER JOIN " + RetSQLName( "SC5" ) + " SC5 "
    cQuery += "ON SC5.C5_FILIAL = SD2.D2_FILIAL "
    cQuery += "AND SC5.C5_NUM = SD2.D2_PEDIDO "
    cQuery += "INNER JOIN " + RetSQLName( "SA1" ) + " SA1 "
    cQuery += "ON A1_FILIAL = '" + xFilial( "SA1" ) + "' "
    cQuery += "AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA "
    cQuery += "WHERE D2_FILIAL <> '' "
    If !Empty(cCliParam) .And. !Empty(cLojParam)
        cQuery += "AND D2_CLIENTE = '" + cCliParam + "' AND D2_LOJA = '" + cLojParam + "' "
    EndIf
    If !Empty(cIniParam) .And. !Empty(cFimParam)
        cQuery += "AND D2_EMISSAO BETWEEN '" + cIniParam + "' AND '" + cFimParam + "' "
    EndIf
    cQuery += "AND SD2.D2_TIPO IN ("+cSdTipo+") "
    cQuery += "AND SD2.D_E_L_E_T_ = '' "
    cQuery += "AND SC5.D_E_L_E_T_ = '' "
    cQuery += "AND SA1.D_E_L_E_T_ = '' "
    cQuery += "UNION ALL "

	//Pedidos de Venda Em Aberto
    cQuery += "SELECT C6_FILIAL AS FILIAL, "
    cQuery += "' ' AS TIPO, "
    cQuery += "C5_NUM AS DOC, "
    cQuery += "C5_CLIENTE AS CLIENTE, "
    cQuery += "C5_LOJACLI AS LOJA, "
    cQuery += "A1_EST AS EST, "
    cQuery += "C5_EMISSAO AS EMISSAO, "
    cQuery += "' ' AS CF, "
    cQuery += "C6_PRODUTO AS COD, "
    cQuery += "C6_ITEM AS ITEM, "
    cQuery += "C6_QTDVEN AS QUANT, "
    cQuery += "C6_PRCVEN AS PRCVEN, "
    cQuery += "C6_VALOR AS TOTAL, "
    cQuery += "0 AS VALICM, "
    cQuery += "0 AS VALIMP5, "
    cQuery += "0 AS VALIMP6, "
    cQuery += "C5_XNUMCE AS XNUMCE, "
    cQuery += "A1_XSEGM AS XSEGM "
    cQuery += "FROM " + RetSQLName( "SC6" ) + " SC6 "
    cQuery += "INNER JOIN " + RetSQLName( "SC5" ) + " SC5 "
    cQuery += "ON SC5.C5_FILIAL = SC6.C6_FILIAL "
    cQuery += "AND SC5.C5_NUM = SC6.C6_NUM "
    cQuery += "INNER JOIN " + RetSQLName( "SA1" ) + " SA1 "
    cQuery += "ON A1_FILIAL = '" + xFilial( "SA1" ) + "' "
    cQuery += "AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI "
    cQuery += "WHERE C6_FILIAL <> '' "
    If !Empty(cCliParam) .And. !Empty(cLojParam)
        cQuery += "AND C5_CLIENTE = '" + cCliParam + "' AND C5_LOJACLI = '" + cLojParam + "' "
    EndIf
    If !Empty(cIniParam) .And. !Empty(cFimParam)
        cQuery += "AND C5_EMISSAO BETWEEN '" + cIniParam + "' AND '" + cFimParam + "' "
    EndIf
    cQuery += "AND SC6.D_E_L_E_T_ = '' "
    cQuery += "AND SC6.C6_NOTA = '         ' "
    cQuery += "AND SC5.D_E_L_E_T_ = '' "
    cQuery += "AND SA1.D_E_L_E_T_ = '' "
    cQuery += "UNION ALL "

	//Devolucoes
    cQuery += "SELECT D1_FILIAL AS FILIAL, "
    cQuery += "D1_TIPO AS TIPO, "
    cQuery += "D1_DOC AS DOC, "
    cQuery += "D1_FORNECE AS CLIENTE, "
    cQuery += "D1_LOJA AS LOJA, "
    cQuery += "A1_EST AS EST, "
    cQuery += "D1_EMISSAO AS EMISSAO, "
    cQuery += "D1_CF AS CF, "
    cQuery += "D1_COD AS COD, "
    cQuery += "D1_ITEM AS ITEM, "
    cQuery += "D1_QUANT AS QUANT, "
    cQuery += "D1_VUNIT AS PRCVEN, "
    cQuery += "D1_TOTAL AS TOTAL, "
    cQuery += "D1_VALICM AS VALICM, "
    cQuery += "D1_VALIMP5 AS VALIMP5, "
    cQuery += "D1_VALIMP6 AS VALIMP6, "
    cQuery += "'' AS XNUMCE, "
    cQuery += "A1_XSEGM AS XSEGM "
    cQuery += "FROM " + RetSQLName( "SD1" ) + " SD1 "
    cQuery += "INNER JOIN " + RetSQLName( "SA1" ) + " SA1 "
    cQuery += "ON A1_FILIAL = '" + xFilial( "SA1" ) + "' "
    cQuery += "AND A1_COD = D1_FORNECE AND A1_LOJA = D1_LOJA "
    cQuery += "WHERE D1_FILIAL <> '' "
    If !Empty(cCliParam) .And. !Empty(cLojParam)
        cQuery += "AND D1_FORNECE = '" + cCliParam + "' AND D1_LOJA = '" + cLojParam + "' "
    EndIf
    If !Empty(cIniParam) .And. !Empty(cFimParam)
        cQuery += "AND D1_EMISSAO BETWEEN '" + cIniParam + "' AND '" + cFimParam + "' "
    EndIf
    cQuery += "AND SD1.D1_TIPO IN ("+cEnTipo+") "
    cQuery += "AND SD1.D_E_L_E_T_ = '' "
    cQuery += "AND SA1.D_E_L_E_T_ = '' "

    cQuery := ChangeQuery( cQuery )
    
    If Select(cNextAlias) > 0
        (cNextAlias)->( DbCloseArea() )
    EndIf

    TCQuery cQuery New Alias (cNextAlias)

    (cNextAlias)->( DbGoTop() )

    If (cNextAlias)->( Eof() )
        SetSoapFault( "Atenção", "Não foram encontrados registros." )
        lRet := .F.
    Else
        While (cNextAlias)->( !Eof() )
        
        	//Incluir o Devoluções (SD1) e Pedidos de Venda não Faturados (SC5/SC6)
        	//O D2_CLIENTE + D2_LOJA e' igual a D1_CLIENTE + D1_LOJA
            oItemNF := WSClassNew( "ITEMNF" )

            oItemNF:FILIAL           := (cNextAlias)->FILIAL
            oItemNF:TIPO             := (cNextAlias)->TIPO
            oItemNF:NUM_NOTA         := (cNextAlias)->DOC
            oItemNF:CLIENTE          := (cNextAlias)->CLIENTE
            oItemNF:LOJA             := (cNextAlias)->LOJA
            oItemNF:UF               := (cNextAlias)->EST
            oItemNF:DATA_EMISSAO_NF  := (cNextAlias)->EMISSAO
            oItemNF:COD_FISCAL       := (cNextAlias)->CF
            oItemNF:CE               := (cNextAlias)->XNUMCE
            oItemNF:PRODUTO          := (cNextAlias)->COD
            oItemNF:REC_LIQUIDA      := 0
            oItemNF:SEGMENTO         := (cNextAlias)->XSEGM
            oItemNF:ITEM             := (cNextAlias)->ITEM
            oItemNF:QUANTIDADE       := (cNextAlias)->QUANT
			If ( !Empty((cNextAlias)->CF) .And. SubStr(Alltrim((cNextAlias)->CF),1,1) $ "|1|2|3|" .And. Upper(Alltrim((cNextAlias)->TIPO)) == "D" )
	            oItemNF:VALOR_UNITARIO   := (cNextAlias)->PRCVEN * -1
	            oItemNF:VALOR_TOTAL      := (cNextAlias)->TOTAL * -1
	            oItemNF:VALOR_ICMS       := (cNextAlias)->VALICM * -1
	            oItemNF:PIS              := (cNextAlias)->VALIMP5 * -1
	            oItemNF:COFINS           := (cNextAlias)->VALIMP6 * -1
   			Else
	            oItemNF:VALOR_UNITARIO   := (cNextAlias)->PRCVEN
	            oItemNF:VALOR_TOTAL      := (cNextAlias)->TOTAL
	            oItemNF:VALOR_ICMS       := (cNextAlias)->VALICM
	            oItemNF:PIS              := (cNextAlias)->VALIMP5
	            oItemNF:COFINS           := (cNextAlias)->VALIMP6
			EndIf

            aAdd( self:ITENSNF, oItemNF )
        
            (cNextAlias)->( DbSkip() )
            
        EndDo
    EndIf
EndIf

Return(lRet)