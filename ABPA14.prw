#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "FWMVCDEF.CH"

 /*/{Protheus.doc} ABPA14
Rotina de inclusao de CE via processo de fatura conta e ordem

@trello ID07 - Api de Fatura Conta e Ordem considerando também CE

@type  User Function
@author DS2U (SDA)
@since 28/05/2019
@version 1.0
/*/
User Function ABPA14()

Local cIdInteg   := PARAMIXB[1]
Local cBody      := PARAMIXB[2]
Local oBody
Local lRet       := .T.
Local cMsg       := ""
Local cPedido
Local cNfRemessa
Local oAutoFat   := AutoFat():new()
Local aDados
Local aCE
Local aFields
Local aVetor     := {}
Local nlx
Local aInfo
Local nTam
Local cTipo
Local cNumCE
Local oModel
Local aErroRet

// Identifica pedido de venda
cPedido := oAutoFat:getPedByNr( cIdInteg )

if ( empty( cPedido ) )
    lRet := .F.
    cMsg := "Pedido não encontrado conforme id de integracao [" + cIdInteg + "]"
else

    // Identifica a NF de Remessa
    dbSelectArea( "SC5" )
    SC5->( dbSetOrder( 1 ) )

    if ( SC5->( dbSeek( fwxFilial( "SC5" ) + cPedido ) ) )
        cNfRemessa := SC5->C5_NOTA
    endif

    if ( empty( cNfRemessa ) )
        lRet := .F.
        cMsg  := "Pedido " + cPedido + " nao foi faturado. Necessario a nota de remessa para a inclusao de CE!"
    else

        oBody := JsonObject():New()
        oBody:fromJson( cBody )

        aDados  := oBody:getJsonObject( "DADOS" )
        //aCE := aDados[2]
        aCE := aDados[2]:GetJSonObject("CE")
		//aFields := aCE:getNames()
        aFields := aCE[1]:GetNames()

        // Adiciona na CE o numero da nota de Remessa
        AADD( aVetor, { "ZB0_OBSERV", cNfRemessa, nil } )

        // Adiciona o ID de Integracao na CE para facilitar a identificacao
        AADD( aVetor, { "ZB0_XINTEG", cIdInteg, nil } )

        for nlx := 1 to len( aFields )
        
            cField:= allTrim( aFields[nlx] )
            aInfo := tamSX3( cField )
            nTam  := aInfo[1]
            cTipo := aInfo[3]
            
            if ( cTipo == "N" )
                AADD( aVetor, { cField, val( aCE[1]:getJsonText( aFields[nlx] ) ), nil } )
            elseif ( cTipo == "D" )
                AADD( aVetor, { cField, sToD( aCE[1]:getJsonText( aFields[nlx] ) ), nil } )
            else
                AADD( aVetor, { cField, PADR( allTrim( aCE[1]:getJsonText( aFields[nlx] ) ), nTam ), nil } )
            endif

            // Captura o numero da CE enviado no Request
            if ( cField == "ZB0_NUMCE" )
                cNumCE := PADR( allTrim( aCE[1]:getJsonText( aFields[nlx] ) ), nTam )
            endif
        
        next nlx

        // Ordena array conforme dicionario de dados
        aVetor := FWVetByDic( aVetor, "ZB0", .F. , )

        dbSelectArea( "ZB0" )
        ZB0->( dbSetOrder( 1 ) )
        
        if ( !ZB0->( dbSeek( fwxFilial( "ZB0" ) + cNumCE ) ) )
            
            oModel := fwLoadModel("RFATA001")
            
            if ( valType( oModel ) == "O" )
            
                oModel:SetOperation( MODEL_OPERATION_INSERT )
                oModel:Activate()
                
                // Adiciona no model os campos enviados para alteracao
                for nlx := 1 to len( aVetor )
                    oModel:setValue("ZB0MASTER", aVetor[nlx][1], aVetor[nlx][2] )
                next nlx
                        
                if ( oModel:vldData() )	
                    
                    lRet := .T.
                    cMsg := "CE " + cNumCE + " incluida com sucesso"
                        
                    oModel:commitData()
                    
                else
                    
                    lRet := .F.
                    aErroRet := aClone( oModel:GetErrorMessage() )
                    cMsg  := "CE " + cNumCE + " NAO pode ser incluida >> " + aErroRet[2] + ": " + aErroRet[6]
                    
                endif        
                
                oModel:DeActivate()
                oModel:Destroy()
				oModel:= Nil
                
            else
                lRet := .F.
                cMsg  := "Nao foi encontrado o model do cadastro de CE"
            endif
            
        else
            lRet := .F.
            cMsg  := "CE " + cNumCE + " ja existe"
        endif

    endif

endif

return { lRet, cMsg }