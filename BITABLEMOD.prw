#include 'protheus.ch'
#include 'json.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} BITABLEMOD
Model de retorno do JSON TableBiBrazil
@author  ERPSERV	
@since   25/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
class BITABLEMOD 

	method new() constructor
	method get() 
	method set()
	method newSet()
	method getJsonObj()
	method getQtyReg()


	data oJson as object
	data nInd as integer
	data cUserLGI as string
	data cUserLGA as string
	data oBiUtils  as object
	data cBlkColumn as string
endClass



//-------------------------------------------------------------------
/*/{Protheus.doc} new
método construtor
@author  ERPSERV
@since   25/06/2019
@version 1.0
@param   nTotalRegs, numeric, numero total de registros na tabela 
@param   nRegs, numeric, numero total de registros da página
@param   nPage, numeric, páginal atual
@param   nPageSize, numeric, numero máximo de registros por pagina
@param   oBiUtils, object, classe utils
@param   lPageSize, logical, indica se é a primeira requisição 
@param   dDataRef, date, data referencia para extração de registros.
@return  object, self.
/*/
//-------------------------------------------------------------------
method new(nTotalRegs, nRegs, nPage, nPageSize, oBiUtils, lPageSize,dDataRef) class BITABLEMOD
	
	default lPageSize := .F.
	default nRegs     := 0

	
	self:cBlkColumn := ""
	DbSelectArea ("SX6")
	SX6->(DbSetOrder (1))
	If (SX6->(DbSeek (xFilial ("SX6")+"ES_BIBLK")))
		Do While !SX6->(Eof ()) .And.  "ES_BIBLK"$SX6->X6_VAR
			If !Empty(SX6->X6_CONTEUD)
				self:cBlkColumn += "/"+AllTrim (SX6->X6_CONTEUD)
			EndIf
			SX6->(DbSkip ())
		EndDo
	EndIf
	self:oBiUtils := oBiUtils
	self:cUserLGI := self:oBiUtils:cUserLGI
	self:cUserLGA := self:oBiUtils:cUserLGA

	self:oJson := JSONERP():new()
	self:oJson[#'table']      := self:oBiUtils:cTable

	if !lPageSize
		self:oJson[#'page']       := nPage
		self:oJson[#'pageSize']   := nRegs
	endif
		
	self:oJson[#'totalPages']   := int(ceiling(nTotalRegs/nPageSize))
	self:oJson[#'totalRecords'] := nTotalRegs
	self:oJson[#'referenceDate'] := dDataRef

	if !lPageSize
		self:oJson[#'records']    := array(nRegs)
	endif

	self:nInd   := 0

return

//-------------------------------------------------------------------
/*/{Protheus.doc} newSet
Adiciona mais um registro da tabela no JSON
@author  ERPSERV
@since   25/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
method newSet() class BITABLEMOD
	self:nInd++
	self:oJson[#'records'][self:nInd] := JSONERP():new()
return

//-------------------------------------------------------------------
/*/{Protheus.doc} set
Adiciona os atributos e valores do registro no JSON.
@author  ERPSERV
@since   25/06/2019
@version 1.0
@param   cColumn, character, nome da coluna
@param   xValue, any, valor
/*/
//-------------------------------------------------------------------
method set(cColumn, xValue) class BITABLEMOD
	Local aFields := StrTokArr(self:cBlkColumn, "\")

	if cColumn == 'DELETED'
		self:oJson[#'records'][self:nInd][#cColumn] := !empty(xValue)
	else
		if aScan( aFields, {|x| replace(x, "/", "") == cColumn} ) > 0 //cColumn $ self:cBlkColumn
			if valType(xValue) == 'C'
				xValue := PADR('',tamSx3(cColumn)[1])
			else
				xValue := 0
			endif
		ENDIf

		self:oJson[#'records'][self:nInd][#cColumn] := self:oBiUtils:normaliza(xValue)
		
	endif
return
//-------------------------------------------------------------------
/*/{Protheus.doc} get
retorna o valor de um atributo
@author  ERPSER
@since   25/06/2019
@version 1.0
@param   cColumn, character, atributo json
@return  any, valor do atributo
/*/
//-------------------------------------------------------------------
method get(cColumn) class BITABLEMOD

return self:oJson[#cColumn]

//-------------------------------------------------------------------
/*/{Protheus.doc} getJsonObj
retorn o json object
@author  ERPSERV
@since   30/08/2019
@version 1.0
@return  object, json object
/*/
//-------------------------------------------------------------------
method getJsonObj() class BITABLEMOD

return self:oJson

//-------------------------------------------------------------------
/*/{Protheus.doc} getQtyReg
quantidade de registros do JSON
@author  ERPSERV
@since   25/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
method getQtyReg() class BITABLEMOD

return self:oJson['total']

