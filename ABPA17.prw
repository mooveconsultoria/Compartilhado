#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} ABPA17
Rotina para tratar REQUEST do faturamento aglutinado

@trello ID09 - Api para faturamento aglutinado

@author DS2U (SDA)
@since 21/06/2019
@version 1.0
@type function
/*/
User Function ABPA17()

Local cBody      := PARAMIXB[2]
Local oBody      := JsonObject():New()
Local aDados
Local nlx
Local uInfo
Local aRet     := {}
Local aRetNF   := {}
Local aPedidos := {}

oBody:fromJson( cBody )
aDados  := oBody:getJsonObject( "DADOS" )

for nlx := 1 to len( aDados )

	uInfo  := aDados[nlx]:getJsonText( "PEDIDO" )
	cNumPed := PADR( uInfo, tamSX3("C5_NUM")[1] )	
	AADD( aPedidos, cNumPed )

next nlx

if ( empty( aPedidos ) )
	aRet := { .F., "Não foi encontrado o numero de pedidos nos parametros do request!" }
else
	aRetNF := U_ABPA11( aPedidos )
	AADD( aRet, aRetNF[1] )
	if ( aRetNF[1] )
		AADD( aRet, "Faturamento aglutinado realizado com sucesso!" )
		AADD( aRet, { { "nota", aRetNF[2] },{ "serie", aRetNF[3] } } )
	else
		AADD( aRet, aRetNF[2] )
	endif	
endif

Return aRet