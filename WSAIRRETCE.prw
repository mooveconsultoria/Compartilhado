#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} WSAIRRETCE
Classe de objeto de retorno do WS Rest. Para padronização de retorno de serviços Rest
@project AirField Automation
@author DS2U (SDA)
@since 09/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
class WSAIRRETCE

	data aRet as Array
	
	method new() constructor
	
	method getRetJson()
	method addRet( cStep, cCode, cMsgPar )
	
endClass

/*/{Protheus.doc} new
Metdoso construtor
@author DS2U (SDA)
@since 09/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
method new() class WSAIRRETCE

	SELF:aRet := {}

return

/*/{Protheus.doc} addRet
Metodo para armazenar pilha de erros de processamento
@author DS2U (SDA)
@since 09/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cStep, characters, Codigo/Descricao da etapa do processo
@param cCode, characters, Codigo do erro
@param cMsgPar, characters, Detalhe do erro
@type function
/*/
method addRet( cStep, cCode, cMsgPar ) class WSAIRRETCE

	default cStep   := ""
	default cCode   := ""
	default cMsgPar := ""
	
	AADD( SELF:aRet, { cStep, cCode, encodeUTF8( fwNoAccent( strTran( strTran( cMsgPar, chr(13)," " ), chr(10)," " ) ) ) } )
	
return

/*/{Protheus.doc} getRetJson
Metodo para retornar o objeto Json com as informações de retorno do WS
@author DS2U (SDA)
@since 09/04/2019
@version 1.0
@return oJsonRet, objeto JsonObject de retorno das informações para serviços Rest

@type function
/*/
method getRetJson() class WSAIRRETCE

Local oJsonRet  := nil
Local oJsonBody := nil
Local nlx

Static POS_STEP := 1
Static POS_CODE := 2
Static POS_MSG  := 3

if ( len( SELF:aRet ) > 0 )

	oJsonRet  := JsonObject():New()
	oJsonRet["StatusRequest"] := {}

	for nlx := 1 to len( SELF:aRet )

		oJsonBody := JsonObject():New()
		
		oJsonBody["step"]    := SELF:aRet[nlx][POS_STEP]
		oJsonBody["code"]    := SELF:aRet[nlx][POS_CODE]
		oJsonBody["message"] := SELF:aRet[nlx][POS_MSG]
		AAdd( oJsonRet["StatusRequest"], oJsonBody )
		
	next nlx

endif

return oJsonRet