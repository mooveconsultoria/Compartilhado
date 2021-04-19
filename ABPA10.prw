#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} ABPA10
Exclui pedido de venda automático

@trello ID08 - Api de exclusão de pedido de venda

@author DS2U - Everton Diniz
@since 27/05/2019
@version 1.0
@return NIL
@type function
@param  aParam[1] = Número do pedido de venda
/*/
User Function ABPA10()

Local cBody      := PARAMIXB[2]
Local oBody      := JsonObject():New()
Local aDados
Local aFields
Local nlx
Local cField
Local uInfo
Local cNumPed
Local aRet
Local lForce := .F.

oBody:fromJson( cBody )
aDados  := oBody:getJsonObject( "DADOS" )

aFields := aDados[1]:getNames()

for nlx := 1 to len( aFields )

	cField := aFields[nlx]
	uInfo  := aDados[1]:getJsonText( aFields[nlx] )

	if ( cField == "PEDIDO" )
		cNumPed := PADR( uInfo, tamSX3("C5_NUM")[1] )	
	elseif ( cField == "FORCAR_EXCLUSAO" )
		lForce := iif( upper( uInfo ) == "S", .T., .F. )
	else
		conOut( "ABPA10 >> Campo [" + cField + "] nao encontrado")
	endif

next nlx

if ( empty( cNumPed ) )
	aRet := { .F., "Não foi encontrado o numero do pedido nos parametros do request!" }
else
	aRet := execExPv( cNumPed, lForce )
endif

Return aRet

/*
User Function ABPA10()

Local cNumPed := ""
Local lForce := .T.
Local aRet

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101"

cNumPed := "000646"

aRet := execExPv( cNumPed, lForce )

RESET ENVIRONMENT

return
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} function
Executa processamento de exclusao de pedido de venda
@author  Everton Diniz
@since 27/05/2019
@version 1.0
@param cNumPed, caracter,  numero do pedido de venda
@param lForce, logic,  indica se forca a exclusao, alterando o pedido de venda para voltar a ficar com o status em aberto.

Modificação na função para garantir que um pedido de venda será excluído, mesmo que este esteja liberado.
Neste link, é explicado o porque não é possível excluir um pedido de venda com liberações e como fazer para excluir: http://tdn.totvs.com/display/public/PROT/FAT0186_Alert_A410LIBER
@author  DS2U (SDA)
@since 31/05/2019
@version 2.0

/*/
//-------------------------------------------------------------------
Static Function execExPv( cNumPed, lForce )

Local aArea      := GetArea()
Local alErroAuto := {}
Local clMsgErro  := ""
Local cMsg		 := ""
Local lRet		 := .T.
Local aRet

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

Default cNumPed := ""
Default lForce := .F.

dbSelectArea("SC5")
SC5->(dbSetOrder(1))
SC5->(dbSeek(xFilial("SC5") + PadR(cNumPed,TamSx3("C5_NUM")[1])))

If SC5->(FOUND())

	if ( lForce )
	/*
		aRet := altPvAbert( cNumPed ) // Altera o pedido de venda para em aberto
		lRet := aRet[1]
		cMsg := aRet[2]
	*/
		aRet := PedEstor( cNumPed )
		lRet := aRet[1]
		cMsg := aRet[2]
	endif
	
	if ( lRet )

		lMsErroAuto    := .F.
		lMsHelpAuto    := .T.
		AutoErrNoFile  := .T.
		
		Begin Transaction
		MSExecAuto({|x,y,z| MATA410(x,y,z)}, {{"C5_NUM", cNumPed, Nil}} , {} , 5 )
				
		If lMsErroAuto 
			DisarmTransaction()
				
			alErroAuto := GetAutoGRLog()
			aEval( alErroAuto, {|x| clMsgErro += allTrim( x ) + '<br/>'} )
				
			lRet := .F.
			cMsg := "Não foi possível realizar a exclusão de pedido de venda >> " + clMsgErro
				
		Else
				
			cMsg := "Pedido de venda excluido com sucesso. Pedido: " + cNumPed + " <br/>"
			
		Endif
		End Transaction
		
	Endif

Else
		
		cMsg := "Pedido de venda "+cNumPed+" nao encontrado <br/>"
		lRet := .F.

Endif
	
RestArea(aArea)

Return {lRet , cMsg}

/*/{Protheus.doc} altPvAbert
Funcao para realizar a alteracao do pedido de venda de modo que ele fique apenas com o status "Em aberto"
@type  Static Function
@author DS2U (SDA)
@since 31/05/2019
@version 1.0
@param cPedido, caracter, codigo do pedido de venda
@return aRet, array, [1] Se .T., o processamento ocorreu com sucesso, Se .F. houve erro
                     [2] Mensagem de erro, caso o elemento [1] = .F.

/*/
Static Function altPvAbert( cPedido )

Local aArea := getArea()
Local lRet  := .T.
Local cMsg  := ""
Local aCabec:= {}
Local aItem := {}
Local aItens:= {}
Local nTo
Local nlx
Local cOpcLibBkp
Local alErroAuto
Local clMsgErro := ""
Local cField
Local cContent
Local cMvAltPed
Local cNotFields := "C6_CF/C6_LOCALIZ"

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

cPedido := PADR( cPedido, tamSX3("C5_NUM")[1] )

dbSelectArea( "SC5" )
SC5->( dbSetOrder( 1 ) )

if ( SC5->( dbSeek( fwxFilial( "SC5" ) + cPedido ) ) )

	// Captura informações do cabeçalho	
	nTo := SC5->( fCount() )

	for nlx := 1 to nTo

		cField   := allTrim( SC5->( fieldName( nlx ) ) )
		cContent := SC5->&( fieldName( nlx ) )

		if ( !empty( cContent ) .and. X3OBRIGAT( cField ) )
			AADD( aCabec, { cField, cContent, .F. } )
		endif

	next nlx

	// Ordena array conforme dicionario de dados
	aCabec := FWVetByDic( aCabec, "SC5", .F. , )

	// Captura informações do iten
	dbSelectArea( "SC6" )
	SC6->( dbSetOrder( 1 ) )

	if ( SC6->( dbSeek( fwxFilial( "SC6" ) + cPedido ) ) )

		nTo := SC6->( fCount() )
		while ( !SC6->( eof() ) .and. SC6->C6_FILIAL == fwxFilial( "SC6") .and. SC6->C6_NUM == cPedido )
		
			for nlx := 1 to nTo

				cField   := allTrim( SC6->( fieldName( nlx ) ) )
				cContent := SC6->&( fieldName( nlx ) )

				if !( cField $ cNotFields )

					if ( X3USO(GetSx3Cache(cField,"X3_USADO")) .AND. !empty( cContent ) )
						AADD( aItem, { cField, cContent, nil } )
					endif

				endif
			
			next nlx

			// Ordena array conforme dicionario de dados
			aItem := FWVetByDic( aItem, "SC6", .F. , )

			AADD( aItens, aItem )

			SC6->( dbSkip() )
		endDo

		// Carrega variaveis do F12 do pedido de venda
		pergunte( "MTA440", .F. )

		// Guarda opcao "Sugere Qtde Liber. ?"  do usuario
		cOpcLibBkp := MV_PAR03

		// Guarda parametrizacao de permissao de alteracao de pedido
		cMvAltPed := allTrim( getMv( "MV_ALTPED" ) )

		// Seta "Sugere Qtde Liber. ?" como Nao
		MV_PAR03 := "2"

		// Seta para permitir alteração de pedido de venda
		putMv( "MV_ALTPED", "S" )

		// Faz a alteração do pedido de venda para que seu status fique como "Em aberto"
		lMsErroAuto := .F.		
		MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, 4, .F.)

		if lMsErroAuto
				
			alErroAuto := getAutoGRLog()
			aEval( alErroAuto, {|x| clMsgErro += allTrim( x ) + '<br/>'})
								
			lRet  := .F.
			cMsg  := "Não foi possível realizar a alteracao de pedido de venda >> " + clMsgErro
									
		else                                                 
						
			cMsg  := "Pedido de venda Alterado com sucesso."
			
		endif

		// Retorna a opcao "Sugere Qtde Liber. ?"  do usuario
		MV_PAR03 := cOpcLibBkp

		//Retorna permissao de alteração de pedido de venda
		putMv( "MV_ALTPED", cMvAltPed )

	endif

endif

restArea( aArea )

Return { lRet, cMsg }


// Estorna a liberação do pedido de venda
Static Function PedEstor(cPedido)
Local aArea := GetArea()
Local aRet := Array(2)
	
	dbSelectArea("SC9")
	SC9->(dbGoTop())
	SC9->(dbSetOrder(1))
	If SC9->(dbSeek( FWxFilial( "SC9" ) + cPedido ))
		
		Begin Transaction
		
		If a460Estorna()
			aRet[1] := .T.
			aRet[2] := "A liberação do pedido foi estornada! <br/>"
		Else
			aRet[1] := .F.
			aRet[2] := "A liberação do pedido nao foi estornada! <br/>"
		Endif
		
		End Transaction
	
	Else
		
		aRet[1] := .F.
		aRet[2] := "Pedido nao encontrado! <br/>"
			
	Endif
	
	RestArea(aArea)
	
Return aRet