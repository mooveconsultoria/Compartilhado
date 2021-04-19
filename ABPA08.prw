#INCLUDE "PROTHEUS.CH"

 /*/{Protheus.doc} ABPA08
Funcao para processamento de baixa de título a receber

Link TDN: http://tdn.totvs.com/pages/releaseview.action?pageId=6070728

@trello ID03 - Api de Títulos Financeiros

@type  User Function
@author DS2U (SDA)
@since 03/05/2019
@version 1.0
/*/
User Function ABPA08()

Local cBody      := PARAMIXB[2]
Local aDados     := {}
Local nlx
Local oBody      := JsonObject():New()
Local aFields    := {}
Local alErroAuto := {}
Local clMsgErro  := ""
Local lRet       := .T.
Local cMsg       := ""
Local aBaixa     := {}
Local cField     := ""
Local uInfo      := nil
Local cPrefixo
Local cTitulo
Local cParcela
Local cTipo
Local cBanco
Local cAgencia
Local cConta
Local dDtBaixa
Local cHistorico
Local nJuros
Local nValBx
Local cCliente
Local cLoja

private lMsErroAuto    := .F.
private lMsHelpAuto    := .T.
private lAutoErrNoFile := .T. 
	
oBody:fromJson( cBody )

aDados  := oBody:getJsonObject( "DADOS" )

aFields := aDados[1]:getNames()

for nlx := 1 to len( aFields )
	
	cField := aFields[nlx]
	uInfo  := aDados[1]:getJsonText( aFields[nlx] )

	if ( cField == "PREFIXO" )
		cPrefixo := PADR( uInfo, tamSX3("E1_PREFIXO")[1] )
	elseif ( cField == "TITULO" )
		cTitulo := PADR( uInfo, tamSX3("E1_NUM")[1] )
	elseif ( cField == "PARCELA" )
		cParcela := PADR( uInfo, tamSX3("E1_PARCELA")[1] )
	elseif ( cField == "TIPO" )
		cTipo := PADR( uInfo, tamSX3("E1_TIPO")[1] )
	elseif ( cField == "CLIENTE" )
		cCliente := PADR( uInfo, tamSX3("E1_CLIENTE")[1] )
	elseif ( cField == "LOJA" )
		cLoja := PADR( uInfo, tamSX3("E1_LOJA")[1] )
	elseif ( cField == "BANCO" )
		cBanco := PADR( uInfo, tamSX3("A6_COD")[1] )
	elseif ( cField == "AGENCIA" )
		cAgencia := PADR( uInfo, tamSX3("A6_AGENCIA")[1] )
	elseif ( cField == "CONTA" )
		cConta := PADR( uInfo, tamSX3("A6_NUMCON")[1] )
	elseif ( cField == "DTBAIXA" )
		dDtBaixa := sToD( uInfo )
	elseif ( cField == "HISTORICO" )
		cHistorico := allTrim( uInfo )
	elseif ( cField == "JUROS" )
		nJuros := val( uInfo )
	elseif ( cField $ "VALORBX" )
		nValBx := val( uInfo )
	else
		conOut( "ABPA08 >> Campo [" + cField + "] nao encontrado")
	endif

next nlx
 
aBaixa := {{"E1_FILIAL"   ,fwxFilial( "SE1" )   ,nil },;
		   {"E1_PREFIXO"  ,cPrefixo   ,nil },;
           {"E1_NUM"      ,cTitulo    ,nil },;
           {"E1_TIPO"     ,cTipo      ,nil },;
		   {"E1_PARCELA"  ,cParcela   ,nil },;
		   {"E1_CLIENTE"  ,cCliente   ,nil },;
		   {"E1_LOJA   "  ,cLoja      ,nil },;
           {"AUTMOTBX"    ,"NOR"      ,nil },; // Baixa sempre sera normal
           {"AUTBANCO"    ,cBanco     ,nil },;
           {"AUTAGENCIA"  ,cAgencia   ,nil },;
           {"AUTCONTA"    ,cConta     ,nil },;
           {"AUTDTBAIXA"  ,dDtBaixa   ,nil },;
           {"AUTDTCREDITO",dDtBaixa   ,nil },;
           {"AUTHIST"     ,cHistorico ,nil },;
           {"AUTJUROS"    ,nJuros     ,nil, .T. },;
           {"AUTVALREC"   ,nValBx     ,nil }}

dbSelectArea( "SE1" )
SE1->( dbSetOrder( 2 ) ) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

dbSelectArea("SA6")
SA6->( dbSetOrder( 1 ) )

if ( SE1->( dbSeek( fwxFilial( "SE1" ) + cCliente + cLoja + cPrefixo + cTitulo + cParcela + cTipo ) ) )

	if ( SA6->( dbSeek( fwxFilial("SA6") + cBanco + cAgencia + cConta ) ) )

		lMsErroAuto := .F. 
		MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3) 

		if lMsErroAuto
				
			alErroAuto := getAutoGRLog()
			aEval( alErroAuto, {|x| clMsgErro += allTrim( x ) + '<br/>'})
								
			lRet := .F.
			cMsg := "Não foi possível realizar a baixa do titulo " + cTitulo
			cMsg += clMsgErro
									
		else                                                 
				
			cMsg  := "Titulo [" + cTitulo + "] baixado com sucesso!"
			
		endif

	else

		lRet := .F.
		cMsg := "Banco [" + cBanco + "], Agencia [" + cAgencia + "] e Conta [" + cConta + "] nao encontrado!"

	endif

else

	lRet := .F.
	cMsg := "Titulo [" + cTitulo + "] nao encontrado! >> Array da execauto " + varInfo( "aBaixa", aBaixa )

endif

Return { lRet, cMsg }