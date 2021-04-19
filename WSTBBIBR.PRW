#INCLUDE "protheus.ch"
#INCLUDE "restful.ch"


/*/{Protheus.doc} tablesBIBrazil
//Webservice que retorna registros de qualquer 
//tabela do Protheus que possui USERLGI e USERLGA
@author ERPSERV
@since 03/06/2019
@version 1.0
/*/
WSRESTFUL tablesBIBrazil Description "Webservice to return records from Protheus Tables"
	WSDATA table      AS STRING
	WSDATA referenceDate   AS DATE OPTIONAL
	WSDATA page            AS INTEGER OPTIONAL
 
	WSMETHOD GET    DESCRIPTION "Return records"   WSSYNTAX "/tablesBIBrazil?table= , page= 

	
END WSRESTFUL


WSMETHOD GET  WSRECEIVE table, referenceDate, page WSSERVICE tablesBIBrazil
	local lGet     as logical
	local cJson    as character
	local nStart   as numeric            
	local nFinish  as numeric 
	local oBiUtils as object
	local nPageSize as numeric
	local dDataRef  as date
	

	default self:page := 0
	default self:referenceDate := stod("")
	//-----------------------------
	//Prepara o ambiente
	//-----------------------------
	//RpcClearEnv()
	RpcSetType( 3 )
	RpcSetEnv( '01', '010101',,,"FAT") 

	lGet      := .T.   
	cJson     := ""    
	nStart    := 1             
	nFinish   := 1   
	oBiUtils  := BITABLEUTL():new(alltrim(self:table))

	dDataRef := self:referenceDate
	//------------------------------------
	// define o tipo de retorno do método
	//------------------------------------
	::SetContentType("application/json; charset=UTF-8")

	if oBiUtils:validTable() 
		//-----------------------------------
		//Instância do objeto de action
		//------------------------------------
		oBiAct := BITABLEACT():new(oBiUtils,dDataRef, self:page == 0)


		//----------------------------------------
		//Resgata a quantidade total de registros
		//----------------------------------------
		nRecords := oBiAct:getQtyRegs()

		//------------------------------------------------
		//Limitar a quantidade de pagesize a 100 registros, ou
		//de acordo com o parâmetro ES_WSPSIZE
		//------------------------------------------------
		nPageSize := superGetMv("ES_WSPSIZE", .F., 100)
		

		
		if nRecords > 0
			//-------------------------------------------------------------------
			//Trata paginação
 			//-------------------------------------------------------------------
 			// nStart -> primeiro registro da pagina
 			// nReg -> numero de registros do inicio da pagina ao fim do arquivo
 			//-------------------------------------------------------------------
 			if self:page > 1
				nStart := ( ( self:page - 1 ) * nPageSize ) + 1
			endif

			nReg := nRecords - nStart	
			//---------------------------------------------
			//Definindo o registro final
			//---------------------------------------------
			if nStart <=  nRecords 
				if nPageSize <= nReg
					nFinish := nStart + (nPageSize-1)
				else
					nFinish := nStart + nReg
				endif
			endif	
			
				
		endif	
		//------------------------------------------------------
		//Realizando o resgate de registros de acordo com os
		//parâmetros recebidos de paginação
		//------------------------------------------------------
		oBiAct:getTable(nStart, nFinish, nPageSize, nRecords, self:page, .F.)
		
		//------------------------------------
		//Convertendo em UTF8 o JSON
		//------------------------------------
		cJson := encodeUtf8(oBiAct:getJson(), "cp1251" )
		
		//--------------------------------------
		//Retorna como resposta o JSON do Model
		//--------------------------------------
		if !empty(cJson)
			self:setResponse(cJson)
		endif	
			
		oBiAct:destroy()
		freeObj(oBiAct)
	else		
		SetRestFault(400, "INVALID TABLE", .t.)
		lGet := .F.
		freeObj(oBiUtils)
	endif

Return lGet


user function wsTableBr()
	
return