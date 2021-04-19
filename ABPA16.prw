#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} ABPA16
Programa para transmitir NFe recebidas em parâmetro

@trello
ID01.3.4 - Processamento de dados da tabela muro - Etapa 4 - Transmissão Automática de NF-e
ID06 - Api para retransmitir nota fiscal para Sefaz

@author [DS2U] - E. Diniz
@since 29/05/2019
@version 1.0
@type function
/*/
User Function ABPA16()

Local cIdInteg   := PARAMIXB[1]
Local cBody      := PARAMIXB[2]
Local oBody      := JsonObject():New()
Local aDados
Local aFields
Local nlx
Local cField
Local uInfo
Local cNF
Local cSerie
Local aRet

oBody:fromJson( cBody )
aDados  := oBody:getJsonObject( "DADOS" )

aFields := aDados[1]:getNames()

for nlx := 1 to len( aFields )

	cField := aFields[nlx]
	uInfo  := aDados[1]:getJsonText( aFields[nlx] )

	if ( cField == "NF" )
		cNF := PADR( uInfo, tamSX3("F2_DOC")[1] )	
	elseif ( cField == "SERIE" )
		cSerie := PADR( uInfo, tamSX3("F2_SERIE")[1] )	
	else
		conOut( "ABPA16 >> Campo [" + cField + "] nao encontrado")
	endif

next nlx

if ( empty( cNF ) )
	aRet := { .F., "Não foi encontrado o numero da nota nos parametros do request!" }
elseif ( empty( cSerie ) )
	aRet := { .F., "Não foi encontrado o numero da serie nos parametros do request!" }
else
	aRet := execTransf( { cSerie, cNF, cNF } )
endif

Return aRet

/*/{Protheus.doc} execTransf
// Programa para transmitir NFe recebidas em parâmetro
@author [DS2U] - E. Diniz
@since 29/05/2019
@version 1.0
@type function
@param aParam, array, descricao
	
	aParam[1] -> Serie da NF			(Tipo Char)
	aParam[2] -> Numero NF inicial		(Tipo Char)
	aParam[3] -> Numero NF final		(Tipo Char)
	aParam[4] -> 1=NFe, 2=CTe			(Tipo Numerico)

@return ${return}, ${return_description}
	
	cRetorno -> Mensagem de retorno do SEFAZ (Formato Texto)
/*/
Static Function execTransf( aParam )

Local aArea			:= GetArea()
Local cError        := ""
Local cIdEnt		:= StaticCall(SPEDNFE, GetIdEnt, .F.)
Local cAmbiente		:= getCfgAmbiente(@cError, cIdEnt, "55")
Local cModalidade	:= subs(getCfgModalidade(@cError, cIdEnt, "55", , .T.), 1, 1)
Local cVersao		:= getCfgVersao(@cError, cIdEnt, "55" )
Local cNotaIni		:= aParam[02]
Local cNotaFim		:= aParam[03]
Local cRetorno		:= ""
Local cSerie		:= aParam[01]
Local cTipo			:= iif ( len( aParam ) > 3, aParam[04], "1")
Local lAuto			:= .T.
Local lCte			:= If(cTipo == "2",.T.,.F.)

cRetorno := SpedNFeTrf("SF2",cSerie,cNotaIni,cNotaFim,cIdEnt,cAmbiente,cModalidade,cVersao,.F.,lCte,lAuto, , , )

restArea( aArea )

Return {.T.,cRetorno}