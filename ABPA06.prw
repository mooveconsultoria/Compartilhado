#INCLUDE "PROTHEUS.CH"

 /*/{Protheus.doc} ABPA06
Funcao de Faturamento de Pedido de Venda, conforme ID de Integração

@trello ID01.3.3 - Processamento de dados da tabela muro - Etapa 3 - Faturamento de Pedido

@type  User Function
@author DS2U (SDA)
@since 15/05/2019
@version 1.0
/*/
User Function ABPA06()

Local cIdInteg   := PARAMIXB[1]
Local lRet       := .T.
Local cMsg       := ""
Local cPedido
Local oAutoFat   := AutoFat():new()
Local aRetEsp    := {}

// Identifica pedido de venda a ser liberado atraves do ID de integração
cPedido := oAutoFat:getPedByNr( cIdInteg )

if ( empty( cPedido ) )
    lRet := .F.
    cMsg := "Pedido não encontrado conforme id de integracao [" + cIdInteg + "]"
else

    // Reaproveita rotina de faturamento aglutinado
    aRet := U_ABPA11( { cPedido } )
    lRet := aRet[1]

    if ( lRet )
        cMsg := "Pedido [" + cPedido + "] faturado com sucesso. Nota: " + aRet[2]
    else
        cMsg := aRet[2]
    endif
    
    AADD( aRetEsp, { "pedido", cPedido } )
    AADD( aRetEsp, { "nota", aRet[2] } )
    AADD( aRetEsp, { "serie", aRet[3] } )

endif

Return { lRet, cMsg, aRetEsp }