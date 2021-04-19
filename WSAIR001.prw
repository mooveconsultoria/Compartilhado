#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'TopConn.ch'
#Include 'APWEBSRV.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} WebService
Webservice para retornar informações de clientes (SOAP)
@author  Victor Andrade
@since   04/02/2018
@version 1
/*/
//-------------------------------------------------------------------
User Function WSAIR001()	
Return

WSSTRUCT CLIENTE
    WsData A1_COD       As String
    WsData A1_LOJA      As String
    WsData A1_NOME      As String
    WsData A1_PESSOA    As String
    WsData A1_NREDUZ    As String
    WsData A1_END       As String
    WsData A1_BAIRRO	As String
    WsData A1_TIPO      As String
    WsData A1_EST       As String
    WsData A1_ESTADO    As String
    WsData A1_CEP       As String
    WsData A1_CODMUN    As String
    WsData A1_MUN       As String
    WsData A1_NATUREZ   As String
    WsData A1_DDI       As String
    WsData A1_ENDCOB    As String
    WsData A1_DDD       As String
    WsData A1_ENDREC    As String
    WsData A1_TEL       As String
    WsData A1_CONTATO   As String
    WsData A1_CGC       As String
    WsData A1_FAX       As String
    WsData A1_INSCR     As String
    WsData A1_PAIS      As String
    WsData A1_CONTA     As String
    WsData A1_TRANSP    As String
    WsData A1_TPFRET    As String
    WsData A1_COND      As String
    WsData A1_RISCO     As String
    WsData A1_LC        As Float
    WsData A1_MSALDO    As Float
    WsData A1_MCOMPRA   As Float
    WsData A1_METR      As Float
    WsData A1_PRICOM    As String
    WsData A1_ULTCOM    As String
    WsData A1_NROCOM    As Float
    WsData A1_SALDUP    As Float
    WsData A1_ATR       As Float
    WsData A1_MAIDUPL   As Float
    WsData A1_BAIRROC   As String
    WsData A1_CEPC      As String
    WsData A1_MUNC      As String
    WsData A1_ESTC      As String
    WsData A1_CODPAIS   As String
    WsData A1_EMAIL     As String
    WsData A1_CNAE      As String
    WsData A1_CONDPAG   As String
    WsData A1_MSBLQL    As String
    WsData A1_BLEMAIL   As String
    WsData A1_COMPLEM   As String
    WsData A1_T_MUNSI   As String
    WsData A1_T_ATVSI   As String
    WsData A1_T_PAISI   As String
    WsData A1_T_CODSI   As String
    WsData A1_T_INST    As String
    WsData A1_X_CT      As String
    WsData A1_X_CT2     As String
    WsData A1_XSETOR    As String
    WsData A1_XCOBINT   As String
    WsData A1_XMCOB     As String
    WsData A1_XEMAIL2   As String
    WsData A1_XSEGM     As String
    WsData A1_XCLISCC   As String
    WsData A1_XACFINA   As Float
    WsData A1_XDESVOL   As Integer
    WsData A1_XPRAZO    As Integer
    WsData A1_XGREF     As String
    WsData A1_XPEICMS   As String
ENDWSSTRUCT

WSSTRUCT RETGETCLI
    WsData A1_COD       As String
    WsData A1_LOJA      As String
    WsData A1_NOME      As String
    WsData A1_PESSOA    As String
    WsData A1_XGREF     As String
    WsData A1_NREDUZ    As String
    WsData A1_XSEGM     As String
    WsData A1_END       As String
    WsData A1_COMPLEM   As String
    WsData A1_BAIRRO    As String
    WsData A1_TIPO      As String
    WsData A1_EST       As String
    WsData A1_CEP       As String
    WsData A1_MUN       As String
    WsData A1_NATUREZ   As String
    WsData A1_DDD       As String
    WsData A1_TRIBFAV   As String
    WsData A1_DDI       As String
    WsData A1_ENDCOB    As String
    WsData A1_ENDREC    As String
    WsData A1_ENDENT    As String
    WsData A1_TEL       As String
    WsData A1_CONTATO   As String
    WsData A1_CGC       As String
    WsData A1_FAX       As String
    WsData A1_PFISICA   As String
    WsData A1_PAIS      As String
    WsData A1_INSCR     As String
    WsData A1_INSCRM    As String
    WsData A1_CONTA     As String
    WsData A1_XSETOR    As String
    WsData A1_XCOBINT   As String
    WsData A1_XMCOB     As String
    WsData A1_TRANSP    As String
    WsData A1_COND      As String
	WsData A1_MSBLQL    As String
    WsData A1_RISCO     As String
    WsData A1_LC        As Float
    WsData A1_RECISS    As String
    WsData A1_INCISS    As String
    WsData A1_DTNASC    As String
    WsData A1_GRPTRIB   As String
    WsData A1_BAIRROC   As String
    WsData A1_CEPC      As String
    WsData A1_MUNC      As String
    WsData A1_ESTC      As String
    WsData A1_BAIRROE   As String
    WsData A1_ESTE      As String
    WsData A1_CODPAIS   As String
    WsData A1_EMAIL     As String
    WsData A1_XEMAIL2   As String
    WsData A1_CNAE      As String
    WsData A1_RECINSS   As String
    WsData A1_RECCOFI   As String
    WsData A1_RECCSLL   As String
    WsData A1_RECPIS    As String
    WsData A1_BLEMAIL   As String
    WsData A1_CONTRIB   As String
    WsData A1_RECIRRF   As String
    WsData A1_T_MUNSI   As String
    WsData A1_T_ATVSI   As String
    WsData A1_T_PAISI   As String
    WsData A1_T_CODSI   As String
    WsData A1_T_INST    As String
    WsData A1_X_CT      As String
    WsData A1_XCLISCC   As String
    WsData A1_XACFINA   As Float
    WsData A1_XPRAZO    As Integer
    WsData A1_SATIV1   As String
ENDWSSTRUCT

WSSTRUCT CLIENTEMANAGER
    WsData A1_COD       As String
    WsData A1_LOJA      As String
    WsData A1_NOME      As String
    WsData A1_PESSOA    As String
    WsData A1_XGREF     As String
    WsData A1_NREDUZ    As String
    WsData A1_XSEGM     As String
    WsData A1_END       As String
    WsData A1_COMPLEM   As String
    WsData A1_BAIRRO    As String
    WsData A1_TIPO      As String
    WsData A1_EST       As String
    WsData A1_CEP       As String
    WsData A1_MUN       As String
    WsData A1_NATUREZ   As String
    WsData A1_DDD       As String
    WsData A1_TRIBFAV   As String
    WsData A1_DDI       As String
    WsData A1_ENDCOB    As String
    WsData A1_ENDREC    As String
    WsData A1_ENDENT    As String
    WsData A1_TEL       As String
    WsData A1_CONTATO   As String
    WsData A1_CGC       As String
    WsData A1_FAX       As String
    WsData A1_PFISICA   As String
    WsData A1_PAIS      As String
    WsData A1_INSCR     As String
    WsData A1_INSCRM    As String
    WsData A1_CONTA     As String
    WsData A1_XSETOR    As String
    WsData A1_XCOBINT   As String
    WsData A1_XMCOB     As String
    WsData A1_TRANSP    As String
    WsData A1_COND      As String
	WsData A1_MSBLQL    As String
    WsData A1_RISCO     As String
    WsData A1_LC        As Float
    WsData A1_RECISS    As String
    WsData A1_INCISS    As String
    WsData A1_DTNASC    As String
    WsData A1_GRPTRIB   As String
    WsData A1_BAIRROC   As String
    WsData A1_CEPC      As String
    WsData A1_MUNC      As String
    WsData A1_ESTC      As String
    WsData A1_BAIRROE   As String
    WsData A1_ESTE      As String
    WsData A1_CODPAIS   As String
    WsData A1_EMAIL     As String
    WsData A1_XEMAIL2   As String
    WsData A1_CNAE      As String
    WsData A1_RECINSS   As String
    WsData A1_RECCOFI   As String
    WsData A1_RECCSLL   As String
    WsData A1_RECPIS    As String
    WsData A1_BLEMAIL   As String
    WsData A1_CONTRIB   As String
    WsData A1_RECIRRF   As String
    WsData A1_T_MUNSI   As String
    WsData A1_T_ATVSI   As String
    WsData A1_T_PAISI   As String
    WsData A1_T_CODSI   As String
    WsData A1_T_INST    As String
    WsData A1_X_CT      As String
    WsData A1_XCLISCC   As String
    WsData A1_XACFINA   As Float
    WsData A1_XPRAZO    As Integer
    WsData A1_SATIV1   As String
ENDWSSTRUCT

WSSTRUCT STPARAM
	WsData A1_XDTHRBI	As String
    WsData A1_EST		As String
    WsData A1_CGC		As String
    WsData A1_COD		As String
    WsData A1_LOJA		As String
    WsData CLIINI		As String
    WsData CLIFIM		As String
ENDWSSTRUCT

WSSTRUCT DADOSCLIENTE
    WsData CODIGO   As String
    WsData LOJA     As String
    WsData MENSAGEM As String
ENDWSSTRUCT

WSSERVICE AIRBPCLIENTES
   WsData CLIENTES    As ARRAY OF RETGETCLI//CLIENTE 
   WsData PARAMETROS  As STPARAM
   WsData STCLIENTE   As CLIENTEMANAGER
   WsData RETCLIENTE  As DADOSCLIENTE  

   WSMETHOD GETCLIENTES Description "Retorna os clientes para a Central de Negociacoes"
   WSMETHOD MANAGERCLI  Description "Inclusao/Atualizacao de clientes para a Central de Negociacoes"
ENDWSSERVICE


WSMETHOD GETCLIENTES WSRECEIVE PARAMETROS WSSEND CLIENTES WSSERVICE AIRBPCLIENTES
 
Local cDataParam 	:= ""
Local cUFParam   	:= ""
Local cCGCParam  	:= ""
Local cCodCliParam 	:= ""
Local cLojCliParam 	:= ""
Local cRecIni		:= ""
Local cRecFim		:= ""
Local oCliente   	:= Nil
Local lRet       	:= .T.

// Private por conta da macroexecução.
Private cNextAlias := ""

RPCClearEnv()
RPCSetType(3)
WFPrepENV( "01" , "010101" )

cNextAlias := GetNextAlias()

// Persistência dos parâmetros recebidos
If !Empty( Upper(Alltrim(Self:PARAMETROS:A1_XDTHRBI)) )
    cDataParam := Upper(Alltrim(Self:PARAMETROS:A1_XDTHRBI))
EndIf

If !Empty( Upper(Alltrim(Self:PARAMETROS:A1_EST)) )
    cUFParam := Upper(Alltrim(Self:PARAMETROS:A1_EST))
EndIf

If !Empty( Upper(Alltrim(Self:PARAMETROS:A1_CGC)) )
    cCGCParam := Upper(Alltrim(Self:PARAMETROS:A1_CGC))
EndIf

If !Empty( Upper(Alltrim(Self:PARAMETROS:A1_COD)) )
    cCodCliParam := Upper(Alltrim(Self:PARAMETROS:A1_COD))
EndIf

If !Empty( Upper(Alltrim(Self:PARAMETROS:A1_LOJA)) )
    cLojCliParam := Upper(Alltrim(Self:PARAMETROS:A1_LOJA))
EndIf

If !Empty( Upper(Alltrim(Self:PARAMETROS:CLIINI)) )
    cRecIni := Upper(Alltrim(Self:PARAMETROS:CLIINI))
EndIf

If !Empty( Upper(Alltrim(Self:PARAMETROS:CLIFIM)) )
    cRecFim := Upper(Alltrim(Self:PARAMETROS:CLIFIM))
EndIf


cQuery := "SELECT TMP.* FROM "
cQuery += "( SELECT ROW_NUMBER() OVER (ORDER BY SA1.R_E_C_N_O_)  AS NRLIN, SA1.* FROM SA1010 SA1 WHERE SA1.D_E_L_E_T_ = ' ' "
If !Empty( cDataParam )
    cQuery += "AND SA1.A1_XDTHRBI = '" + cDataParam + "' "
EndIf
If !Empty( cUFParam )
    cQuery += "AND SA1.A1_EST = '" + cUFParam + "' "
EndIf
If !Empty( cCodCliParam )
    cQuery += "AND SA1.A1_COD = '" + cCodCliParam + "' "
	If !Empty( cLojCliParam )
	    cQuery += "AND SA1.A1_LOJA = '" + cLojCliParam + "' "
	EndIf
EndIf
If !Empty( cCGCParam )
    cQuery += "AND SA1.A1_CGC = '" + cCGCParam + "' "
EndIf
cQuery += "AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' ) TMP "
If ( !Empty(cRecIni) .And. !Empty(cRecFim) )
	cQuery += "WHERE TMP.NRLIN BETWEEN "+cRecIni+" AND "+cRecFim
EndIf

If Select(cNextAlias) > 0
    (cNextAlias)->( DbCloseArea() )
EndIf
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cNextAlias,.T.,.T.)
(cNextAlias)->(dbGoTop())


If (cNextAlias)->( !Eof() )

    While (cNextAlias)->( !Eof () )

        oCliente := WsClassNew("RETGETCLI")
	    oCliente:A1_COD      := NoAcento((cNextAlias)->A1_COD)
	    oCliente:A1_LOJA     := NoAcento((cNextAlias)->A1_LOJA)     
	    oCliente:A1_NOME     := NoAcento((cNextAlias)->A1_NOME)     
	    oCliente:A1_PESSOA   := NoAcento((cNextAlias)->A1_PESSOA)   
	    oCliente:A1_XGREF    := NoAcento((cNextAlias)->A1_XGREF)    
	    oCliente:A1_NREDUZ   := NoAcento((cNextAlias)->A1_NREDUZ)   
	    oCliente:A1_XSEGM    := NoAcento((cNextAlias)->A1_XSEGM)    
	    oCliente:A1_END      := NoAcento((cNextAlias)->A1_END)      
	    oCliente:A1_COMPLEM  := NoAcento((cNextAlias)->A1_COMPLEM)  
	    oCliente:A1_BAIRRO   := NoAcento((cNextAlias)->A1_BAIRRO)   
	    oCliente:A1_TIPO     := NoAcento((cNextAlias)->A1_TIPO)     
	    oCliente:A1_EST      := NoAcento((cNextAlias)->A1_EST)      
	    oCliente:A1_CEP      := NoAcento((cNextAlias)->A1_CEP)      
	    oCliente:A1_MUN      := NoAcento((cNextAlias)->A1_MUN)      
	    oCliente:A1_NATUREZ  := NoAcento((cNextAlias)->A1_NATUREZ)  
	    oCliente:A1_DDD      := NoAcento((cNextAlias)->A1_DDD)      
	    oCliente:A1_TRIBFAV  := NoAcento((cNextAlias)->A1_TRIBFAV)  
	    oCliente:A1_DDI      := NoAcento((cNextAlias)->A1_DDI)      
	    oCliente:A1_ENDCOB   := NoAcento((cNextAlias)->A1_ENDCOB)   
	    oCliente:A1_ENDREC   := NoAcento((cNextAlias)->A1_ENDREC)   
	    oCliente:A1_ENDENT   := NoAcento((cNextAlias)->A1_ENDENT)   
	    oCliente:A1_TEL      := NoAcento((cNextAlias)->A1_TEL)      
	    oCliente:A1_CONTATO  := NoAcento((cNextAlias)->A1_CONTATO)  
	    oCliente:A1_CGC      := NoAcento((cNextAlias)->A1_CGC)      
	    oCliente:A1_FAX      := ((cNextAlias)->A1_FAX)      
	    oCliente:A1_PFISICA  := NoAcento((cNextAlias)->A1_PFISICA)  
	    oCliente:A1_PAIS     := NoAcento((cNextAlias)->A1_PAIS)     
	    oCliente:A1_INSCR    := NoAcento((cNextAlias)->A1_INSCR)    
	    oCliente:A1_INSCRM   := NoAcento((cNextAlias)->A1_INSCRM)   
	    oCliente:A1_CONTA    := NoAcento((cNextAlias)->A1_CONTA)    
	    oCliente:A1_XSETOR   := ((cNextAlias)->A1_XSETOR)   
	    oCliente:A1_XCOBINT  := ((cNextAlias)->A1_XCOBINT)  
	    oCliente:A1_XMCOB    := ((cNextAlias)->A1_XMCOB)    
	    oCliente:A1_TRANSP   := NoAcento((cNextAlias)->A1_TRANSP)   
	    oCliente:A1_COND     := NoAcento((cNextAlias)->A1_COND)
		oCliente:A1_MSBLQL   := NoAcento((cNextAlias)->A1_MSBLQL)
	    oCliente:A1_RISCO    := ((cNextAlias)->A1_RISCO)    
	    oCliente:A1_LC       := ((cNextAlias)->A1_LC)       
	    oCliente:A1_RECISS   := ((cNextAlias)->A1_RECISS)   
	    oCliente:A1_INCISS   := ((cNextAlias)->A1_INCISS)   
	    oCliente:A1_DTNASC   := ((cNextAlias)->A1_DTNASC)   
	    oCliente:A1_GRPTRIB  := ((cNextAlias)->A1_GRPTRIB)  
	    oCliente:A1_BAIRROC  := NoAcento((cNextAlias)->A1_BAIRROC)  
	    oCliente:A1_CEPC     := NoAcento((cNextAlias)->A1_CEPC)     
	    oCliente:A1_MUNC     := NoAcento((cNextAlias)->A1_MUNC)     
	    oCliente:A1_ESTC     := NoAcento((cNextAlias)->A1_ESTC)     
	    oCliente:A1_BAIRROE  := NoAcento((cNextAlias)->A1_BAIRROE)  
	    oCliente:A1_ESTE     := NoAcento((cNextAlias)->A1_ESTE)     
	    oCliente:A1_CODPAIS  := NoAcento((cNextAlias)->A1_CODPAIS)  
	    oCliente:A1_EMAIL    := NoAcento((cNextAlias)->A1_EMAIL)    
	    oCliente:A1_XEMAIL2  := NoAcento((cNextAlias)->A1_XEMAIL2)  
	    oCliente:A1_CNAE     := ((cNextAlias)->A1_CNAE)     
	    oCliente:A1_RECINSS  := ((cNextAlias)->A1_RECINSS)  
	    oCliente:A1_RECCOFI  := ((cNextAlias)->A1_RECCOFI)  
	    oCliente:A1_RECCSLL  := ((cNextAlias)->A1_RECCSLL)  
	    oCliente:A1_RECPIS   := ((cNextAlias)->A1_RECPIS)  
	    oCliente:A1_BLEMAIL  := ((cNextAlias)->A1_BLEMAIL)  
	    oCliente:A1_CONTRIB  := ((cNextAlias)->A1_CONTRIB)  
	    oCliente:A1_RECIRRF  := ((cNextAlias)->A1_RECIRRF)  
	    oCliente:A1_T_MUNSI  := ((cNextAlias)->A1_T_MUNSI)  
	    oCliente:A1_T_ATVSI  := ((cNextAlias)->A1_T_ATVSI)  
	    oCliente:A1_T_PAISI  := ((cNextAlias)->A1_T_PAISI)  
	    oCliente:A1_T_CODSI  := ((cNextAlias)->A1_T_CODSI)  
	    oCliente:A1_T_INST   := ((cNextAlias)->A1_T_INST)  
	    oCliente:A1_X_CT     := ((cNextAlias)->A1_X_CT)     
	    oCliente:A1_XCLISCC  := ((cNextAlias)->A1_XCLISCC)  
	    oCliente:A1_XACFINA  := ((cNextAlias)->A1_XACFINA)  
	    oCliente:A1_XPRAZO   := ((cNextAlias)->A1_XPRAZO)   
	    oCliente:A1_SATIV1   := ((cNextAlias)->A1_SATIV1)   

        Aadd( ::CLIENTES, oCliente )

        (cNextAlias)->( DbSkip() )

    EndDo

Else

    SetSoapFault('Atenção',"Não foram encontrados registros com os parâmetros informados.")
    lRet := .F.

EndIf

Return( lRet )



WsMethod MANAGERCLI WsReceive STCLIENTE WsSend RETCLIENTE WSSERVICE AIRBPCLIENTES
Local lRet      := .T.
Local lNewLJN	:= .F.
Local nOpc      := 3
Local aDadosCli := {}
Local cCodCli   := ""
Local cLojCli   := ""
Local cMsgLog   := ""
Local cDirErro  := "\logCliente\"
Local cErro     := ""
Local cCodMun   := ""
Local cQry		:= ""
Local cTAAlias  := ""
Local cTBAlias  := ""
Local cMdGrv	:= ""
Local lGrv		:= .F.
Local lGo		:= .T.
Local nNx		:= 0
Local cBLEmail  := ""
Local cCEP		:= ""
Local cCEPC		:= ""
Local cSegM		:= ""

//Valida Dados Obrigatorios
If Empty(Upper(Alltrim(self:STCLIENTE:A1_CGC)))
	lGo := .F.
	cMsgLog += "CPF/CNPJ, "
EndIf
If Empty(Upper(Alltrim(self:STCLIENTE:A1_NOME)))
	lGo := .F.
 	cMsgLog += "Nome, "
EndIf
If Empty(Upper(Alltrim(self:STCLIENTE:A1_END)))
	lGo := .F.
	cMsgLog += "Endereco, "
EndIf
If Empty(Upper(Alltrim(self:STCLIENTE:A1_BAIRRO)))
	lGo := .F.
	cMsgLog += "Bairro, "
EndIf
If Empty(Upper(Alltrim(self:STCLIENTE:A1_MUN)))
	lGo := .F.
	cMsgLog += "Municipio, "
EndIf
If Empty(Upper(Alltrim(self:STCLIENTE:A1_EST)))
	lGo := .F.
	cMsgLog += "Estado, "
EndIf
If !lGo
	cMsgLog := "Faltam Dados Obrigatorios: " + cMsgLog
EndIf


//Prepara ambiente
//(Necessario para execucao de queries)
If lGo
	RPCClearEnv()
	RPCSetType(3)
	WFPrepENV( "01" , "010101" )
EndIf


//Valida Segmento do Cliente
If lGo
	If !Empty(Upper(Alltrim(self:STCLIENTE:A1_XSEGM)))
 		cSegM := SuperGetMV("MV_XWSSEG",,"|CA|GA|MIL|GOV|FOR|DOD|PRM|")
		If !( Upper(Alltrim(self:STCLIENTE:A1_XSEGM)) $ cSegM )
			lGo := .F.
			cMsgLog := "Segmento Invalido: "+Upper(Alltrim(self:STCLIENTE:A1_XSEGM))
		EndIf
	EndIf
EndIf


//Valida DODO
If lGo

	If Upper(Alltrim(self:STCLIENTE:A1_XSEGM)) == "DOD"
		If !Empty(Upper(Alltrim(self:STCLIENTE:A1_SATIV1)))

			cQry := "SELECT X5_DESCRI AS X5DESCRI "
			cQry += "FROM "+RetSqlName("SX5")+" WHERE D_E_L_E_T_ <> '*' "
			cQry += "AND X5_FILIAL = '"+xFilial("SX5")+"' "
			cQry += "AND X5_TABELA = 'T3' "
			cQry += "AND X5_CHAVE = '"+Upper(Alltrim(self:STCLIENTE:A1_SATIV1))+"' "

			cTBAlias := GetNextAlias()
			Iif(Select(cTBAlias)>0,(cTBAlias)->(DbCloseArea()),Nil)
			TCQuery cQry New Alias (cTBAlias)
			(cTBAlias)->( DbGoTop() )
			
			If (cTBAlias)->(!EoF())
				If Empty((cTBAlias)->X5DESCRI)
					lGo := .F.
					cMsgLog := "Codigo DODO invalido"
				EndIf
			Else
				lGo := .F.
				cMsgLog := "Codigo DODO invalido"
			EndIf
		Else
			lGo := .F.
			cMsgLog := "Codigo DODO nao informado"
		EndIf
	
	EndIf

EndIf


// Prepara o ambiente para gravacao
If lGo

	If !ExistDir( cDirErro )
	    MakeDir( cDirErro )
	EndIf
	
	cBLEmail := Alltrim(self:STCLIENTE:A1_BLEMAIL)
	If !( cBLEmail $ "|1|2|" )
		If cBLEmail == "S"
			cBLEMail := "1"
		ElseIf cBLEmail == "2"
			cBLEMail := "N"
		Else
			cBLEMail := ""
		EndIf
	EndIf
	
	cCEP := StrTran(Upper(Alltrim(self:STCLIENTE:A1_CEP)),"-","")
	cCEPC := StrTran(Upper(Alltrim(self:STCLIENTE:A1_CEPC)),"-","")
	
	If !Empty(Upper(Alltrim(self:STCLIENTE:A1_MUN)))
		cCodMun := GetCodMun( Upper(Alltrim(self:STCLIENTE:A1_MUN)) )
	EndIf
	
	DbSelectArea( "SA1" )
	SA1->( DbSetOrder( 1 ) )
	
	If SA1->( DbSeek( xFilial( "SA1" ) + SubStr(Alltrim(self:STCLIENTE:A1_COD),1,6) + SubStr(Alltrim(self:STCLIENTE:A1_LOJA),1,2) ) )
	    nOpc    := 4
	    cCodCli := SA1->A1_COD
	    cLojCli := SA1->A1_LOJA
	Else
	    cCodCli := SubStr(Upper(Alltrim(self:STCLIENTE:A1_COD)),1,6)
	    cLojCli := SubStr(Upper(Alltrim(self:STCLIENTE:A1_LOJA)),1,2)
	EndIf

	//Procura Cod. Instalacao Simp (Tabela LJN)
	If !Empty(Alltrim(self:STCLIENTE:A1_T_INST))
	
		cQry := "SELECT LJN.R_E_C_N_O_ AS LJNRECNO "
		cQry += "FROM "+RetSqlName("LJN")+" LJN "
		cQry += "WHERE LJN.D_E_L_E_T_ <> '*' "
		cQry += "AND LJN.LJN_FILIAL = '"+xFilial("SLJ")+"' "
		cQry += "AND LJN.LJN_CDINST = '"+Alltrim(self:STCLIENTE:A1_T_INST)+"' "
	    
		cTAAlias := GetNextAlias()
		Iif(Select(cTAAlias)>0,(cTAAlias)->(DbCloseArea()),Nil)
		TCQuery cQry New Alias (cTAAlias)
		TcSetField(cTAAlias,"LJNRECNO","N",14,0)
		(cTAAlias)->( DbGoTop() )
		
		If (cTAAlias)->(!Eof())
			If (cTAAlias)->LJNRECNO <> 0
				lNewLJN := .F.
			Else
				lNewLJN := .T.
			EndIF
		Else
			lNewLJN := .T.
		EndIf		
		(cTAAlias)->(DbCloseArea())		

		If RecLock("LJN",lNewLJN)
			If lNewLJN
				LJN->LJN_FILIAL	:=	xFilial("LJN")
				LJN->LJN_CDINST :=  Upper(Alltrim(self:STCLIENTE:A1_T_INST))
			EndIf
			LJN->LJN_CNPJ 	:=  Upper(Alltrim(self:STCLIENTE:A1_CGC))
			LJN->LJN_RAZSOC :=  Upper(Alltrim(self:STCLIENTE:A1_NOME))
			LJN->LJN_CEP	:=  Upper(Alltrim(self:STCLIENTE:A1_CEP))
			LJN->LJN_ENDER	:=  Upper(Alltrim(self:STCLIENTE:A1_END))
			LJN->LJN_COMPL	:=  Upper(Alltrim(self:STCLIENTE:A1_COMPLEM))
			LJN->LJN_BAIRRO	:=  Upper(Alltrim(self:STCLIENTE:A1_BAIRRO))
			LJN->LJN_MUNIC	:=  Upper(Alltrim(self:STCLIENTE:A1_MUN))
			LJN->LJN_UF		:=  Upper(Alltrim(self:STCLIENTE:A1_EST))
			LJN->LJN_AUTOR	:=  ""
			LJN->LJN_STATUS	:=  "ABERTO"
			LJN->LJN_TPINST	:=  "POSTO REVENDEDOR - LIQUIDOS"
			LJN->(MsUnLock())
		EndIf

	EndIf

	//Gravacao (inicio)
	If lGo

		aAdd( aDadosCli, { "A1_FILIAL"  , xFilial( "SA1" )                  				, Nil } )
		aAdd( aDadosCli, { "A1_COD"     , cCodCli                           				, Nil } )     
		aAdd( aDadosCli, { "A1_LOJA"    , cLojCli                           				, Nil } )     
		aAdd( aDadosCli, { "A1_NOME"    , Upper(Alltrim(self:STCLIENTE:A1_NOME))            , Nil } )     
		aAdd( aDadosCli, { "A1_PESSOA"  , Upper(Alltrim(self:STCLIENTE:A1_PESSOA))          , Nil } )     
		aAdd( aDadosCli, { "A1_XGREF"   , Upper(Alltrim(self:STCLIENTE:A1_XGREF))           , Nil } )     
		aAdd( aDadosCli, { "A1_NREDUZ"  , Upper(Alltrim(self:STCLIENTE:A1_NREDUZ))          , Nil } )     
		aAdd( aDadosCli, { "A1_XSEGM"   , Upper(Alltrim(self:STCLIENTE:A1_XSEGM))           , Nil } )     
		aAdd( aDadosCli, { "A1_END"     , Upper(Alltrim(self:STCLIENTE:A1_END))             , Nil } )     
		aAdd( aDadosCli, { "A1_COMPLEM" , Upper(Alltrim(self:STCLIENTE:A1_COMPLEM))         , Nil } )     
		aAdd( aDadosCli, { "A1_BAIRRO"  , Upper(Alltrim(self:STCLIENTE:A1_BAIRRO))          , Nil } )     
		aAdd( aDadosCli, { "A1_TIPO"    , Upper(Alltrim(self:STCLIENTE:A1_TIPO))            , Nil } )     
		aAdd( aDadosCli, { "A1_EST"     , Upper(Alltrim(self:STCLIENTE:A1_EST))             , Nil } )     
		aAdd( aDadosCli, { "A1_CEP"     , cCEP   								          	, Nil } )     
		aAdd( aDadosCli, { "A1_MUN"     , Upper(Alltrim(self:STCLIENTE:A1_MUN))             , Nil } )     
		aAdd( aDadosCli, { "A1_NATUREZ" , Upper(Alltrim(self:STCLIENTE:A1_NATUREZ))         , Nil } )     
		aAdd( aDadosCli, { "A1_DDD"     , Upper(Alltrim(self:STCLIENTE:A1_DDD))             , Nil } )     
		aAdd( aDadosCli, { "A1_TRIBFAV" , self:STCLIENTE:A1_TRIBFAV         				, Nil } )     
		aAdd( aDadosCli, { "A1_DDI"     , self:STCLIENTE:A1_DDI             				, Nil } )     
		aAdd( aDadosCli, { "A1_ENDCOB"  , Upper(Alltrim(self:STCLIENTE:A1_ENDCOB))          , Nil } )     
		aAdd( aDadosCli, { "A1_ENDREC"  , Upper(Alltrim(self:STCLIENTE:A1_ENDREC))          , Nil } )     
		aAdd( aDadosCli, { "A1_ENDENT"  , Upper(Alltrim(self:STCLIENTE:A1_ENDENT))          , Nil } )     
		aAdd( aDadosCli, { "A1_TEL"     , self:STCLIENTE:A1_TEL             				, Nil } )     
		aAdd( aDadosCli, { "A1_CONTATO" , Upper(Alltrim(self:STCLIENTE:A1_CONTATO))         , Nil } )     
		aAdd( aDadosCli, { "A1_CGC"     , Upper(Alltrim(self:STCLIENTE:A1_CGC))             , Nil } )     
		aAdd( aDadosCli, { "A1_FAX"     , self:STCLIENTE:A1_FAX             				, Nil } )     
		aAdd( aDadosCli, { "A1_PFISICA" , Upper(Alltrim(self:STCLIENTE:A1_PFISICA))         , Nil } )     
		aAdd( aDadosCli, { "A1_PAIS"    , Upper(Alltrim(self:STCLIENTE:A1_PAIS))            , Nil } )     
		aAdd( aDadosCli, { "A1_INSCR"   , Upper(Alltrim(self:STCLIENTE:A1_INSCR))           , Nil } )     
		aAdd( aDadosCli, { "A1_INSCRM"  , Upper(Alltrim(self:STCLIENTE:A1_INSCRM))          , Nil } )     
		aAdd( aDadosCli, { "A1_CONTA"   , Upper(Alltrim(self:STCLIENTE:A1_CONTA))           , Nil } )     
		aAdd( aDadosCli, { "A1_XSETOR"  , Upper(Alltrim(self:STCLIENTE:A1_XSETOR))          , Nil } )     
		aAdd( aDadosCli, { "A1_XCOBINT" , Upper(Alltrim(self:STCLIENTE:A1_XCOBINT))         , Nil } )     
		aAdd( aDadosCli, { "A1_XMCOB"   , Upper(Alltrim(self:STCLIENTE:A1_XMCOB))           , Nil } )     
		aAdd( aDadosCli, { "A1_TRANSP"  , Upper(Alltrim(self:STCLIENTE:A1_TRANSP))          , Nil } )     
		aAdd( aDadosCli, { "A1_COND"    , Upper(Alltrim(self:STCLIENTE:A1_COND))            , Nil } )
		aAdd( aDadosCli, { "A1_MSBLQL"  , Upper(Alltrim(self:STCLIENTE:A1_MSBLQL))          , Nil } )     
		aAdd( aDadosCli, { "A1_RISCO"   , Upper(Alltrim(self:STCLIENTE:A1_RISCO))           , Nil } )     
		aAdd( aDadosCli, { "A1_LC"      , self:STCLIENTE:A1_LC								, Nil } )     
		aAdd( aDadosCli, { "A1_RECISS"  , Upper(Alltrim(self:STCLIENTE:A1_RECISS))          , Nil } )     
		aAdd( aDadosCli, { "A1_INCISS"  , Upper(Alltrim(self:STCLIENTE:A1_INCISS))          , Nil } )     
		aAdd( aDadosCli, { "A1_DTNASC"  , CTOD(self:STCLIENTE:A1_DTNASC)    				, Nil } )     
		aAdd( aDadosCli, { "A1_GRPTRIB" , Upper(Alltrim(self:STCLIENTE:A1_GRPTRIB))         , Nil } )     
		aAdd( aDadosCli, { "A1_BAIRROE" , Upper(Alltrim(self:STCLIENTE:A1_BAIRROE))         , Nil } )     
		aAdd( aDadosCli, { "A1_CEPC"    , cCEPC            									, Nil } )     
		aAdd( aDadosCli, { "A1_MUNC"    , Upper(Alltrim(self:STCLIENTE:A1_MUNC))            , Nil } )     
		aAdd( aDadosCli, { "A1_ESTE"    , Upper(Alltrim(self:STCLIENTE:A1_ESTE))            , Nil } )     
		aAdd( aDadosCli, { "A1_BAIRROC" , Upper(Alltrim(self:STCLIENTE:A1_BAIRROC))         , Nil } )     
		aAdd( aDadosCli, { "A1_ESTC"    , Upper(Alltrim(self:STCLIENTE:A1_ESTC))            , Nil } )     
		aAdd( aDadosCli, { "A1_CODPAIS" , Upper(Alltrim(self:STCLIENTE:A1_CODPAIS))         , Nil } )     
		aAdd( aDadosCli, { "A1_EMAIL"   , Alltrim(self:STCLIENTE:A1_EMAIL)           		, Nil } )     
		aAdd( aDadosCli, { "A1_XEMAIL2" , Alltrim(self:STCLIENTE:A1_XEMAIL2)         		, Nil } )     
		aAdd( aDadosCli, { "A1_CNAE"    , Upper(Alltrim(self:STCLIENTE:A1_CNAE))            , Nil } )     
		aAdd( aDadosCli, { "A1_RECINSS" , Upper(Alltrim(self:STCLIENTE:A1_RECINSS))         , Nil } )     
		aAdd( aDadosCli, { "A1_RECCOFI" , Upper(Alltrim(self:STCLIENTE:A1_RECCOFI))         , Nil } )     
		aAdd( aDadosCli, { "A1_RECCSLL" , Upper(Alltrim(self:STCLIENTE:A1_RECCSLL))         , Nil } )     
		aAdd( aDadosCli, { "A1_RECPIS"  , Upper(Alltrim(self:STCLIENTE:A1_RECPIS))          , Nil } )     
		aAdd( aDadosCli, { "A1_BLEMAIL" , cBLEmail         		, Nil } )     
		aAdd( aDadosCli, { "A1_CONTRIB" , Upper(Alltrim(self:STCLIENTE:A1_CONTRIB))         , Nil } )     
		aAdd( aDadosCli, { "A1_RECIRRF" , Upper(Alltrim(self:STCLIENTE:A1_RECIRRF))         , Nil } )     
		aAdd( aDadosCli, { "A1_T_MUNSI" , Upper(Alltrim(self:STCLIENTE:A1_T_MUNSI))         , Nil } )     
		aAdd( aDadosCli, { "A1_T_ATVSI" , Upper(Alltrim(self:STCLIENTE:A1_T_ATVSI))         , Nil } )     
		aAdd( aDadosCli, { "A1_T_PAISI" , Upper(Alltrim(self:STCLIENTE:A1_T_PAISI))         , Nil } )     
		aAdd( aDadosCli, { "A1_T_CODSI" , Upper(Alltrim(self:STCLIENTE:A1_T_CODSI))         , Nil } )     
		aAdd( aDadosCli, { "A1_T_INST"  , Upper(Alltrim(self:STCLIENTE:A1_T_INST))          , Nil } )     
		aAdd( aDadosCli, { "A1_X_CT"    , Upper(Alltrim(self:STCLIENTE:A1_X_CT))            , Nil } )     
		aAdd( aDadosCli, { "A1_XCLISCC" , self:STCLIENTE:A1_XCLISCC         				, Nil } )     
		aAdd( aDadosCli, { "A1_XACFINA" , self:STCLIENTE:A1_XACFINA         				, Nil } )     
		aAdd( aDadosCli, { "A1_XPRAZO"  , self:STCLIENTE:A1_XPRAZO          				, Nil } )     
		aAdd( aDadosCli, { "A1_SATIV1"  , Upper(Alltrim(self:STCLIENTE:A1_SATIV1))			, Nil } )     
		
		// --> Ordena array de acordo com dicionário SX3
		aDadosCli := FWVetByDic( aDadosCli, "SA1", .F., )  
	
		cMdGrv	:= SuperGetMV("BP_MNGCLIA",,"1") // Metodo de Gravado do Cliente: 1=ExecAuto, 2=RecLock	
		
		BeginTran()
	
		If cMdGrv == "1"
	
			lMsErroAuto := .F.
			
		    MSExecAuto( { |x,y| MATA030( x, y ) }, aDadosCli, nOpc )
		
		    If !lMsErroAuto
		        ConfirmSX8()
		
		        // Força a gravação do Cód. Munícipio pois o execauto está com bug em validação padrão.
		        SA1->( DbSetOrder(1) )
		        
		        If SA1->( DbSeek( xFilial("SA1") + cCodCli + cLojCli ) )
		            RecLock("SA1", .F.)
		            SA1->A1_COD_MUN := cCodMun
		            SA1->( MsUnlock() )
		        EndIf
		
		        cMsgLog := AllTrim( self:STCLIENTE:A1_NOME ) + Iif(nOpc == 3, " incluido", " alterado") + " com sucesso." 
	
		    Else
	
				lGo := .F.
		        RollBackSX8()
		        cErro   := MostraErro( cDirErro, AllTrim( self:STCLIENTE:A1_CGC ) + DTOS( dDataBase ) + StrTran(Time(), ":", "") )
		        cMsgLog := VerErro( cErro )
	
		    EndIf
	
		Else

			lGrv := ( nOpc == 3 )
	
			aAdd( aDadosCli, { "A1_COD_MUN"	, cCodMun				, Nil } )
			//aAdd( aDadosCli, { "A1_MSBLQL"	, "2"				, Nil } )
			aAdd( aDadosCli, { "A1_B2B"		, "2"					, Nil } )
			aAdd( aDadosCli, { "A1_ABATIMP"	, "1"					, Nil } )
			aAdd( aDadosCli, { "A1_MINIRF"	, "2"					, Nil } )
	        If lGrv
				aAdd( aDadosCli, { "A1_HRCAD"	, SubStr(Time(),1,5)	, Nil } )     
				aAdd( aDadosCli, { "A1_DTCAD"	, dDataBase				, Nil } )
			EndIf     
	
			dbSelectArea("SA1")
			lGrv := ( nOpc == 3 )
	
			If RecLock( "SA1" , lGrv )
				lGo :=.T.
				For nNx := 1 to Len(aDadosCli)
					lGo := .T.
					If !lGrv
						If Alltrim(aDadosCli[nNx,1]) $ "|A1_FILIAL|A1_COD|A1_LOJA|"
							lGo := .F.
						EndIf
					EndIf
					If lGo
						SA1->&(aDadosCli[nNx,1]) := aDadosCli[nNx,2]
					EndIf
				Next nNx
				SA1->(MsUnLock())
				lGo := .T.
		        cMsgLog := AllTrim( self:STCLIENTE:A1_NOME ) + Iif(nOpc == 3, " incluido", " alterado") + " com sucesso." 
	
			Else

	            lGo := .F.
		        cMsgLog := "Erro de gravacao. Tente novamente"

			EndIf
	
	    EndIf
	
		EndTran()

	EndIf

EndIf

If !lGo
	cCodCli := ""
	cLojCli := ""
	If Empty(cMsgLog)
		cMsgLog := "Erro"
	EndIf
EndIf

self:RETCLIENTE:CODIGO    := cCodCli
self:RETCLIENTE:LOJA      := cLojCli
self:RETCLIENTE:MENSAGEM  := cMsgLog

Return( lRet )



/*/{Protheus.doc} VerErro
Pega o erro resumido do ExecAuto.
@author  Victor Andrade
@since   13/02/2018
@version 1
/*/
Static Function VerErro( cErroAuto )

Local nLines  := MLCount( cErroAuto )
Local nErr	  := 0
Local cErrRet := ""

For nErr := 1 To nLines
	If "INVALIDO" $ Upper( MemoLine( cErroAuto, , nErr ) )
		cErrRet := MemoLine( cErroAuto, , nErr )
		Exit
	EndIf
Next nErr

If Empty( cErrRet )
    For nErr := 1 To nLines
		cErrRet += AllTrim( MemoLine( cErroAuto, , nErr ) ) + " "
    Next nErr
EndIf

Return( AllTrim( cErrRet ) )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCodMun
Retorna o código do munícipio.
@author  Victor Andrade
@since   05/03/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function GetCodMun( cMunicipio )

Local aArea     := GetArea()
Local cCodMun   := ""

CC2->( DbSetOrder(2) )
If CC2->( DbSeek( xFilial("CC2") + AllTrim(cMunicipio) ) )
    cCodMun := CC2->CC2_CODMUN
EndIf

RestArea( aArea )

Return( cCodMun )



Static FUNCTION NoAcento(cAux)
Local cString := ""
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóúÁÉÍÓÚ"
Local cCircu := "âêîôûÂÊÎÔÛ"
Local cTrema := ""
Local cCrase := "" 
Local cTio   := "ãõ"
Local cCecid := "çÇ"
Local cMaior := "&lt;"
Local cMenor := "&gt;"

cString := Alltrim(cAux)

If !Empty(cString)

	For nX:= 1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
			nY:= At(cChar,cAgudo)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCircu)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTrema)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCrase)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf		
			nY:= At(cChar,cTio)
			If nY > 0          
				cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
			EndIf		
			nY:= At(cChar,cCecid)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("cC",nY,1))
			EndIf
		Endif
	Next
	
	If cMaior$ cString 
		cString := strTran( cString, cMaior, "" ) 
	EndIf
	If cMenor$ cString 
		cString := strTran( cString, cMenor, "" )
	EndIf
	
	cString := StrTran( cString, CRLF, " " )
	cString := StrTran( cString, Chr(13), " " )
	cString := StrTran( cString, Chr(10), " " )
	cString := StrTran( cString, ">", " " )
	cString := StrTran( cString, "<", " " )
	cString := StrTran( cString, '"', " " )
	cString := StrTran( cString, "'", " " )
	
	For nX:= 1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		If !(cChar $ "abcdefghijklmnopqrstuvxywzABCDEFGHIJKLMNOPQRSTUVXYWZ0123456789@_-/., ")
			cString := StrTran( cString, cChar,"")
		EndIf
	Next nX

Else

	cString := ""

EndIf

Return cString