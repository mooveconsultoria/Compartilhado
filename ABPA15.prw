#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "FWMVCDEF.CH"

 /*/{Protheus.doc} ABPA15
Fatura pedido de venda gerado pela CE do processo de fatura conta e ordem

@trello ID07 - Api de Fatura Conta e Ordem considerando também CE

@type  User Function
@author DS2U (SDA)
@since 28/05/2019
@version 1.0
/*/
User Function ABPA15()

Local cIdInteg   := PARAMIXB[1]
Local lRet       := .T.
Local cMsg       := ""
Local oAutoFat   := AutoFat():new()
Local cPedido
Local cCE
Local aRet

// Identifica a CE pelo ID de Integracao
cCE := oAutoFat:getCeByNr( cIdInteg )

if ( empty( cCE ) )
    lRet := .F.
    cMsg := "CE não encontrado conforme id de integracao [" + cIdInteg + "]"
else

    // Identifica pedido de venda atraves da CE
    cPedido := oAutoFat:getPvByCE( cCE )

    if ( empty( cPedido ) )
        lRet := .F.
        cMsg := "Pedido não encontrado conforme CE [" + cCE + "]"
    else

        // Reaproveita rotina de faturamento aglutinado
        aRet := U_ABPA11( { cPedido } )
        lRet := aRet[1]

        if ( lRet )
            cMsg := "Pedido " + cPedido + " faturado com sucesso. Nota: " + aRet[2]
        else
            cMsg := aRet[2]
        endif

    endif

endif

return { lRet, cMsg }