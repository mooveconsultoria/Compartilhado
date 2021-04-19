#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"

User Function WSAIR015()
Return

/*/{Protheus.doc} Fornecedores
Serviço Rest para manutenção de Fornecedores
@project API de cadastro de Fornecedores
@author DS2U (SDA)
@since 09/09/2019
@version 1.0

@type class
/*/
WsRestFul Fornecedores DESCRIPTION "Serviço de Manutenção de Cadastro de Fornecedor"
	
	WsMethod GET Description "Consulta de Fornecedores" WsSyntax "Fornecedores/{codigo}/{loja}"
	WsMethod POST Description "Inclusão de Fornecedores" WsSyntax "Fornecedores"
	WsMethod PUT Description "Alteração de Fornecedores" WsSyntax "Fornecedores/{codigo}/{loja}"
	WsMethod DELETE Description "Exclusão de Fornecedores" WsSyntax "Fornecedores/{codigo}/{loja}"

End WsRestFul

/*/{Protheus.doc} GET
Metodo GET para consulta de Fornecedores
@author DS2U (SDA)
@since 09/09/2019
@version 1.0
@return ${return}, ${return_description}
@param SA2_NUMCE, caracter, codigo da CE
@type function
/*/
WsMethod GET WsService Fornecedores

Local lRet      := .T.
Local oJsonRet  := nil
Local oJsonBody := nil
Local aStruSA2  := {}
Local nlx
Local cField
Local uContent
Local cCode     := ""
Local cMsg      := ""
Local cTipo
Local cCodForn   := ""
Local cLojaForn  := ""
	
RPCClearEnv()
RPCSetType(3)
WFPrepENV( "01", "010101" )

if !( len( SELF:aURLParms ) == 2 )

	cCode := "#001"
	cMsg  := "URL INVALIDA >> Parametro de codigo e loja obrigatorio na URL >> Fornecedores/{codigo}/{loja}"

else

	cCodForn  := PADR( SELF:aURLParms[1], tamSX3("A2_COD")[1] )
	cLojaForn := PADR( SELF:aURLParms[2], tamSX3("A2_LOJA")[1] )

	dbSelectArea( "SA2" )
	SA2->( dbSetOrder( 1 ) )

	if ( SA2->( dbSeek( fwxFilial( "SA2" ) + cCodForn + cLojaForn ) ) )

		aStruSA2 := SA2->( dbStruct() )

		oJsonRet  := JsonObject():New()
		oJsonRet["SA2"] := {}
		
		oJsonBody := JsonObject():New()
		
		for nlx := 1 to len( aStruSA2 )
		
			cField := allTrim( aStruSA2[nlx][1] )
			cTipo  := tamSX3( cField )[3]
			
			if ( cTipo == "D" )
				uContent := dToS( SA2->&( cField ) )
			elseif ( cTipo == "C" )
				uContent := encodeUTF8( fwNoAccent( SA2->&( cField ) ) )
			else
				uContent := SA2->&( cField )
			endif
		
			oJsonBody[cField] := uContent
			
		next nlx
		
		AAdd( oJsonRet["SA2"], oJsonBody )

	else

		cCode := "#002"
		cMsg  := "Metodo GET - Consulta de Fornecedores >> NAo foi encontrado Fornecedor " + cCodForn + "/" + cLojaForn

	endif

endif

if ( !empty( cCode ) .and. !empty( cMsg ) )

	//-------------------------------
	// Cria objeto de retorno de WS -
	//-------------------------------
	oJsonRet  := JsonObject():New()
	oJsonRet["StatusRequest"] := {}

	oJsonBody := JsonObject():New()
	oJsonBody["code"]          := cCode
	oJsonBody["message"]       := cMsg

	AAdd( oJsonRet["StatusRequest"], oJsonBody )

endif

SELF:setContentType("application/json")
SELF:setResponse( fwJsonSerialize( oJsonRet ) )

Return lRet

/*/{Protheus.doc} POST
Metodo Post para incusão de CE
@author DS2U (SDA)
@since 09/09/2019
@version 1.0

@type function
/*/
WsMethod POST WsService Fornecedores

Local lRet      := .T.
Local oJsonRet  := nil
Local oJsonBody := nil
Local oModel    := nil
Local cCode     := ""
Local cMsg      := ""
Local oBody
Local aRet      := {}

if ( len( SELF:aURLParms ) == 0 )	
   
	// recupera o body da requisição
	oBody  := JsonObject():New()
	oBody:fromJson( allTrim( SELF:getContent() ) )
   
	if ( valType( oBody ) == "J" )

		RPCClearEnv()
		RPCSetType(3)
		WFPrepENV( "01", "010101" )
			
		aRet := customer( 3, oBody )
		cCode := aRet[1]
		cMsg  := aRet[2]
			
	else
		cCode := "#002"
		cMsg  := "Corpo nao esta no formato Json correto."
	endif

else
	cCode := "#001"
	cMsg  := "URL Invalida >> Nao deve ter parametros na URL"
endif

if ( !empty( cCode ) .and. !empty( cMsg ) )

	//-------------------------------
	// Cria objeto de retorno de WS -
	//-------------------------------
	oJsonRet  := JsonObject():New()
	oJsonRet["StatusRequest"] := {}

	oJsonBody := JsonObject():New()
	oJsonBody["code"]          := cCode
	oJsonBody["message"]       := cMsg

	AAdd( oJsonRet["StatusRequest"], oJsonBody )

endif	

SELF:setContentType("application/json")
SELF:setResponse( fwJsonSerialize( oJsonRet ) )

Return lRet

/*/{Protheus.doc} PUT
metodo PUT para alteração de CE
@author DS2U (SDA)
@since 09/09/2019
@version 1.0

@type function
/*/
WsMethod PUT WsService Fornecedores

Local lRet      := .T.
Local oJsonRet  := nil
Local oJsonBody := nil
Local oModel    := nil
Local cCode     := ""
Local cMsg      := ""
Local oBody
Local aRet      := {}

if ( len( SELF:aURLParms ) == 0 )	
   
	// recupera o body da requisição
	oBody  := JsonObject():New()
	oBody:fromJson( allTrim( SELF:getContent() ) )
   
	if ( valType( oBody ) == "J" )

		RPCClearEnv()
		RPCSetType(3)
		WFPrepENV( "01", "010101" )
			
		aRet := customer( 4, oBody )
		cCode := aRet[1]
		cMsg  := aRet[2]
			
	else
		cCode := "#002"
		cMsg  := "Corpo nao esta no formato Json correto."
	endif

else
	cCode := "#001"
	cMsg  := "URL Invalida >> Nao deve ter parametros na URL"
endif

if ( !empty( cCode ) .and. !empty( cMsg ) )

	//-------------------------------
	// Cria objeto de retorno de WS -
	//-------------------------------
	oJsonRet  := JsonObject():New()
	oJsonRet["StatusRequest"] := {}

	oJsonBody := JsonObject():New()
	oJsonBody["code"]          := cCode
	oJsonBody["message"]       := cMsg

	AAdd( oJsonRet["StatusRequest"], oJsonBody )

endif	

SELF:setContentType("application/json")
SELF:setResponse( fwJsonSerialize( oJsonRet ) )

Return lRet
  
/*/{Protheus.doc} DELETE
Metodo DELETE para exclusão de CE
@author DS2U (SDA)
@since 09/09/2019
@version 1.0

@type function
/*/
WsMethod DELETE WsService Fornecedores

Local lRet      := .T.
Local oJsonRet  := nil
Local oJsonBody := nil
Local oModel    := nil
Local cCode     := ""
Local cMsg      := ""
Local oBody
Local aRet      := {}
Local cCodForn   := ""
Local cLojaForn  := ""

if ( len( SELF:aURLParms ) == 2 )	
   
	// recupera o body da requisição
	oBody  := JsonObject():New()
	oBody:fromJson( allTrim( SELF:getContent() ) )
   
	if ( valType( oBody ) == "J" )

		RPCClearEnv()
		RPCSetType(3)
		WFPrepENV( "01", "010101" )

		cCodForn  := PADR( SELF:aURLParms[1], tamSX3("A2_COD")[1] )
		cLojaForn := PADR( SELF:aURLParms[2], tamSX3("A2_LOJA")[1] )
			
		aRet := customer( 5, oBody, cCodForn, cLojaForn )
		cCode := aRet[1]
		cMsg  := aRet[2]
			
	else
		cCode := "#002"
		cMsg  := "Corpo nao esta no formato Json correto."
	endif

else
	cCode := "#001"
	cMsg  := "URL INVALIDA >> Parametro de codigo e loja obrigatorio na URL >> Fornecedores/{codigo}/{loja}"	
endif

if ( !empty( cCode ) .and. !empty( cMsg ) )

	//-------------------------------
	// Cria objeto de retorno de WS -
	//-------------------------------
	oJsonRet  := JsonObject():New()
	oJsonRet["StatusRequest"] := {}

	oJsonBody := JsonObject():New()
	oJsonBody["code"]          := cCode
	oJsonBody["message"]       := cMsg

	AAdd( oJsonRet["StatusRequest"], oJsonBody )

endif	

SELF:setContentType("application/json")
SELF:setResponse( fwJsonSerialize( oJsonRet ) )

Return lRet

/*/{Protheus.doc} customer
Funcao para tratamento de inclusao, alteracao e exclusao de registros
@author DS2U (SDA)
@since 09/09/2019
@version 1.0

@type function
/*/
Static Function customer( nOpc, oBody, cCodForn, cLojaForn )

Local nlx
Local aInfo     := {}
Local aVetor    := {}
Local cTipo
Local nTam
//Local lModMVC   :=.F.
Local aErroAuto
Local cCode     := ""
Local cMsg      := ""
Local aFields   := {}
Local cMsgOper  := ""
Local lExistCli := .F.

Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.

Default cCodForn   := ""
Default cLojaForn  := ""

if ( nOpc == 5 )
	AADD( aVetor, { "A2_COD", PADR( allTrim( cCodForn ), tamSX3( "A2_COD" )[1] ), nil } )
	AADD( aVetor, { "A2_LOJA", PADR( allTrim( cLojaForn ), tamSX3( "A2_LOJA" )[1] ), nil } )
else

	// Captura todas as propriedades do objeto
	aFields := oBody:getNames()

	// Adiciona em um vetor do tipo execauto para ser ordenado posteriormente
	for nlx := 1 to len( aFields )

		aInfo := tamSX3( allTrim( aFields[nlx] ) )
		nTam  := aInfo[1]
		cTipo := aInfo[3]

		if ( empty( cCodForn ) .and. allTrim( aFields[nlx] ) == "A2_COD" )
			cCodForn := PADR( allTrim( oBody:getJsonText( aFields[nlx] ) ), nTam )
		endif

		if ( empty( cLojaForn ) .and. allTrim( aFields[nlx] ) == "A2_LOJA" )
			cLojaForn := PADR( allTrim( oBody:getJsonText( aFields[nlx] ) ), nTam )
		endif
		
		if ( cTipo == "N" )
			AADD( aVetor, { allTrim( aFields[nlx] ), val( oBody:getJsonText( aFields[nlx] ) ), nil } )
		elseif ( cTipo == "D" )
			AADD( aVetor, { allTrim( aFields[nlx] ), sToD( oBody:getJsonText( aFields[nlx] ) ), nil } )
		else
			AADD( aVetor, { allTrim( aFields[nlx] ), PADR( allTrim( oBody:getJsonText( aFields[nlx] ) ), nTam ), nil } )
		endif

	next nlx

	// Ordena array conforme dicionario de dados
	aVetor := FWVetByDic( aVetor, "SA2", .F. , )

endif

dbSelectArea( "SA2" )
SA2->( dbSetOrder( 1 ) )

lExistCli := ( SA2->( dbSeek( fwxFilial( "SA2" ) + cCodForn + cLojaForn ) ) )

if ( empty( cCodForn ) .or. empty( cLojaForn ) )

	cCode := "#006"
	cMsg  := "Campos A2_COD e A2_LOJA sao obrigatorios no corpo do request"

elseif ( nOpc == 3 .and. lExistCli )

	cCode := "#003"
	cMsg  := "Fornecedor " + cCodForn + "/" + cLojaForn + " ja existe"

elseif ( ( nOpc == 4 .or. nOpc == 5 ) .and. !lExistCli )

	cCode := "#005"
	cMsg  := "Fornecedor " + cCodForn + "/" + cLojaForn + " NAO existe"

else

	/*lModMVC := getMv( "MV_MVCSA2",,.F. ) //AQUI PAM

	if ( lModMVC )
	
		lMsErroAuto := .F.
		MSExecAuto( {|a,b,c| CRMA980(a,b,c) }, aVetor, nOpc, {} )

	else*/

		lMsErroAuto := .F. 
		MsExecAuto( {|x,y| MATA020(x,y) }, aVetor, nOpc )

//	endif

	if ( lMsErroAuto )
		
		cCode := "#004"
		aErroAuto := GetAutoGRLog()
		aEval( aErroAuto, {|x| cMsg += x } )
	
	else
	
		cMsgOper := iif( nOpc == 3, "incluido", iif( nOpc == 4, "alterado", iif( nOpc == 5, "excluido", "" ) ) )
		cCode := "#000"
		cMsg  := "Fornecedor " + cCodForn + "/" + cLojaForn + " " + cMsgOper + " com sucesso!"
		
	endif

endif

Return { cCode, trataStr( cMsg ) }

/*/{Protheus.doc} customer
Funcao para tratamento de string para retorno do WS
@author DS2U (SDA)
@since 09/09/2019
@version 1.0

@type function
/*/
Static Function trataStr( cMsg )
Return encodeUTF8( fwNoAccent( strTran( strTran( cMsg, chr(13)," " ), chr(10)," " ) ) )