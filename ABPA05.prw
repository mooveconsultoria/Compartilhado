#INCLUDE "PROTHEUS.CH"

 /*/{Protheus.doc} ABPA05
Funcao de liberacao de pedido de venda

@trello ID01.3.2 - Processamento de dados da tabela muro - Etapa 2 - Liberação de Crédito e Estoque

@type  User Function
@author DS2U (SDA)
@since 15/05/2019
@version 1.0
/*/
User Function ABPA05( cPedido )

Local cIdInteg   := PARAMIXB[1]
Local lRet       := .F.
Local cMsg       := ""
Local cPedido
Local nQtdLib
Local oAutoFat   := nil
Local lFoundSC9  := .F.

Default cPedido := ""

if ( empty( cPedido ) .and. !( type( "PARAMIXB" ) == "U" ) )

    cIdInteg   := PARAMIXB[1]
    oAutoFat   := AutoFat():new()

    // Identifica pedido de venda a ser liberado atraves do ID de integração
    cPedido := oAutoFat:getPedByNr( cIdInteg ) 

endif

if ( empty( cPedido ) )
    lRet := .F.
    cMsg := "Pedido não encontrado conforme id de integracao [" + cIdInteg + "]"
else

    dbSelectArea("SF4")
    SF4->( dbSetOrder( 1 ) )

    dbSelectArea("SC6")
    SC6->( dbSetOrder( 1 ) )

    dbSelectArea("SC9")
    SC9->( dbSetOrder( 1 ) )
    
    if ( SC6->( dbSeek( fwxFilial("SC6") + cPedido ) ) )

        lRet := .T.

        while ( SC6->( !eof() ) .and. SC6->C6_NUM == cPedido .and. SC6->C6_FILIAL == fwxFilial("SC6") )

            lFoundSC9 := SC9->( dbSeek( fwxFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM ) )

            if ( !lFoundSC9 )
        
                if ( SF4->( dbSeek( fwxFilial("SF4") + SC6->C6_TES ) ) )

                    // Utiliza o campo C6_QTDLIB para permitir faturamento parcial
                    nQtdLib := SC6->C6_QTDLIB

                    if ( nQtdLib == 0 )
                        nQtdLib := SC6->C6_QTDVEN
                    endif

                    begin transaction

                        //------------------------------------------------------------------------
                        // Funcao |MaLibDoFat | Autor |Eduardo Riera         | Data | 09.03.99   -
                        //------------------------------------------------------------------------
                        // Descricao |Liberacao dos Itens de Pedido de Venda                     -
                        //------------------------------------------------------------------------
                        // Retorno   |ExpN1: Quantidade Liberada                                 -
                        //------------------------------------------------------------------------
                        // Transacao |Nao possui controle de Transacao a rotina chamadora deve   -
                        //           |controlar a Transacao e os Locks                           -
                        //------------------------------------------------------------------------
                        // Parametros|ExpN1: Registro do SC6                                     -
                        //           |ExpN2: Quantidade a Liberar                                -
                        //           |ExpL3: Bloqueio de Credito                                 -
                        //           |ExpL4: Bloqueio de Estoque                                 -
                        //           |ExpL5: Avaliacao de Credito                                -
                        //           |ExpL6: Avaliacao de Estoque                                -
                        //           |ExpL7: Permite Liberacao Parcial                           -
                        //           |ExpL8: Tranfere Locais automaticamente                     -
                        //           |ExpA9: Empenhos ( Caso seja informado nao efetua a gravacao-
                        //           |       apenas avalia ).                                    -
                        //           |ExpbA: CodBlock a ser avaliado na gravacao do SC9          -
                        //           |ExpAB: Array com Empenhos previamente escolhidos           -
                        //           |       (impede selecao dos empenhos pelas rotinas)         -
                        //           |ExpLC: Indica se apenas esta trocando lotes do SC9         -
                        //           |ExpND: Valor a ser adicionado ao limite de credito         -
                        //           |ExpNE: Quantidade a Liberar - segunda UM                   -
                        //------------------------------------------------------------------------
                        MaLibDoFat( SC6->( recno() ),@nQtdLib,.F.,.F.,.T.,.T.)
                        
                    end transaction

                    lFoundSC9 := SC9->( dbSeek( fwxFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM ) )

                endif

            endif

            if ( lFoundSC9 )

                while ( SC9->( !eof() ) .and. SC9->C9_FILIAL == fwxFilial( "SC9" ) .and. SC9->C9_PEDIDO == SC6->C6_NUM .and. SC9->C9_ITEM == SC6->C6_ITEM )

                    if ( !empty( SC9->C9_BLEST ) .or. !empty( SC9->C9_BLCRED ) )
                        lRet := .F.
                        cMsg += ">> Pedido: " + SC6->C6_NUM
                        cMsg += " / Item: " + SC6->C6_ITEM
                        cMsg += " / Motivo: "
                    endif

                    if ( !empty( SC9->C9_BLEST ) )                        
                        cMsg += getMotBlq( "EST", SC9->C9_BLEST )
                        cMsg += "/"
                    endif

                    if ( !empty( SC9->C9_BLCRED ) )                                 
                        cMsg += getMotBlq( "CRED", SC9->C9_BLCRED )
                        cMsg += "/"
                    endif

                    SC9->( dbSkip() )
                endDo

            else
                lRet := .F.
                cMsg := "Pedido [" + cPedido + "] NAO pode ser liberado!"
            endif

            SC6->( dbSkip() )
        endDo

        if ( lRet )
            // Atualiza o flag do pedido de venda
            MaLiberOk( { cPedido }, .F. )
            cMsg := "Pedido [" + cPedido + "] liberado com sucesso!"
        endif

    endif

endif

Return { lRet, cMsg }

/*/{Protheus.doc} getMotBlq
(long_description)
@type  Static Function
@author user
@since date
@version version
@param cTipoBlq, caracter, Tipo do bloqueio (Credito/Estoque/WMS)
@param cCodeBlq, caracter, Codigo do bloqueio
@return cMsg, caracter, Retorno da mensagem do bloqueio
@example
(examples)
@see (links_or_references)
/*/
Static Function getMotBlq( cTipoBlq, cCodeBlq )

Local cMsg    := "MOTIVO NAO IDENTIFICADO"
Local aCodes  := {}
Local nPos

cTipoBlq := upper( allTrim( cTipoBlq ) )
cCodeBlq := upper( allTrim( cCodeBlq ) )

//Codigos de bloqueio para estoque
if ( cTipoBlq == "EST" )

    AADD( aCodes, { "02", "Bloqueio de Estoque" } )
    AADD( aCodes, { "03", "Bloqueio Manual de Estoque" } )
    AADD( aCodes, { "10", "FATURADO" } )

elseif ( cTipoBlq == "CRED" )

    //Codigos de bloqueio para credito
    AADD( aCodes, { "01", "Bloqueio de Crédito por Valor" } )
    AADD( aCodes, { "04", "Vencimento do Limite de Crédito - Data de Crédito Vencida" } )
    AADD( aCodes, { "05", "Bloqueio Manual/Estorno" } )
    AADD( aCodes, { "10", "FATURADO" } )

elseif ( cTipoBlq == "WMS" )

    //Codigos de bloqueio para WMS
    AADD( aCodes, { "01", "Bloqueio de Endereçamento do WMS/Somente SB2" } )
    AADD( aCodes, { "02", "Bloqueio de Endereçamento do WMS" } )
    AADD( aCodes, { "03", "Bloqueio de WMS - Externo" } )
    AADD( aCodes, { "05", "Liberação para Bloqueio 01" } )             
    AADD( aCodes, { "06", "Liberação para Bloqueio 02" } )
    AADD( aCodes, { "07", "Liberação para Bloqueio 03" } )

endif

if ( ( nPos := aScan( aCodes, {|x| x[1] == cCodeBlq } ) ) > 0 )
    cMsg := aCodes[nPos][2]
endif

Return cMsg