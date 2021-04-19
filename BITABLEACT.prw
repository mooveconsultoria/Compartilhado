#include 'protheus.ch'
#include "json.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} BITABLEACT
Action para resgate de dados para BI Global
@author  ERPSERV
@since   19/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
class BITABLEACT 

	method new () constructor
	method getTable() 
	method getJson()
	method getQtyRegs() 
	method destroy()

	data oModel   as object
	data dDataRef as date
	data cTable   as string
	data oDao     as object
	data oUtil    as object
	data lPageSize as boolean
	data lRefDate  as boolean
endClass



//-------------------------------------------------------------------
/*/{Protheus.doc} new
método construtor
@author  ERPSERV
@since   19/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
method new (oBiUtils, dDataRef, lPageSize) class BITABLEACT

	default dDataRef := NIL
	default lPageSize := .F.

	self:lPageSize := lPageSize
	self:oUtil    := oBiUtils
	self:cTable   := alltrim(self:oUtil:cTable)
	//-------------------------------------
	//Resgata data da última execução de
	//extração de dados da tabela em questão
	//---------------------------------------
	if empty(dDataRef)
		// self:dDataRef := self:oUtil:lastExec()
		self:dDataRef := Date()
		self:lRefDate := .F.
	else
		self:dDataRef := dDataRef
		self:lRefDate := .T.
	endif

	self:oDao     := BITABLEDAO():new(self:dDataRef ,self:oUtil )
return

//-------------------------------------------------------------------
/*/{Protheus.doc} getTable
método responsável por resgatar registros de uma determinada tabela
@author  ERPSERV
@since   19/06/2019
@version 1.0
@param   cTable, character, nome da tabela
@param   nStart, numeric, registro inicial
@param   nFinish, numeric, registro final
@param   nPageSize, numeric, numero máximo de registro na paginação
@param   nPage, numeric, numero da página atual
@return  nil, nil
/*/
//-------------------------------------------------------------------
method getTable(nStart, nFinish, nPageSize, nRecords, nPage,lDummy) class BITABLEACT

	default lDummy := .F.
	
	//-----------------------------------------------------------------------------------
	//Verifica se é uma requisição de pageSize apenas ou se deve retornar registros
	//-----------------------------------------------------------------------------------
	if self:lPageSize

		//-----------------------------
		//Monta retorno de pageSize
		//-----------------------------
		self:oModel := BITABLEMOD():new(nRecords, ,nPage,nPageSize,self:oUtil, .T.,self:dDataRef)

	else
		
		//--------------------------------------------------------------------------------
		//Realiza a extração de dados
		//--------------------------------------------------------------------------------
		self:oModel := self:oDao:getNewRegs(nStart, nFinish, nPageSize, nPage, lDummy)

	endif
	
	//---------------------------------------------------------
	//Realiza a gravação da data de execução da rotina na SX5
	//para ter como referência na próxima extração delta
	//---------------------------------------------------------
	if !lDummy .and. nPage == int(ceiling(nRecords/nPageSize))
		// self:oUtil:setExec(dDataBase) 
	endif
	
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getJson
método responsável por converte o JSON Object do model em string
@author  ERPSERV
@since   19/06/2019
@version 1.0
@return  character, json
/*/
//-------------------------------------------------------------------
method getJson() class BITABLEACT

	local oResult as object
	local oJson   as object

	//--------------------------------
	//Instancia do JsonObject
	//--------------------------------
	oJson:= self:oModel:getJsonObj()

	//Converte json object em texto
	oResult := JSON():New( oJson )
	cJson := oResult:Stringify()

	
	freeObj(oResult)

return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} destroy
método responsável por realizar a limpeza das dependências
@author  ERPSERV
@since   19/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
method destroy() class BITABLEACT

	if !empty(self:oModel)
		freeObj(self:oModel)
	endif
		
	self:oUtil:destroy()		
	freeObj(self:oUtil)
	freeObj(self:oDao )
return

//-------------------------------------------------------------------
/*/{Protheus.doc} getQtyRegs
método responsável por retornar o numero do registros de uma 
determinada tabela.
@author  ERPSERV
@since   19/06/2019
@version 1.0
@param   cTable, character, nome da tabela
@return  numeric, quantidade de registros
/*/
//-------------------------------------------------------------------
method getQtyRegs(lDummy) class BITABLEACT
	local nQtd as numeric
	
	default lDummy := .F.
	
	nQtd := self:oDao:getQtyRegs(lDummy, self:lPageSize, self:lRefDate)


return nQtd