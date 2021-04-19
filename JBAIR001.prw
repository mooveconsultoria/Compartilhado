#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "TBICONN.CH"
#Include "RPTDEF.CH"
#Include "RWMAKE.CH"
#Include "RwMake.ch"
#Include "APWIZARD.CH"
#Include "FILEIO.CH"
#Include "FWPrintSetup.ch"
#Include "TOTVS.CH"
#Include "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JBAIR001
Job para geração da DANFE em XML e PDF
@author  Victor Andrade
@since   06/12/2017
@version 1
/*/
//-------------------------------------------------------------------
User Function JBAIR001(aParam)

Local cNextAlias := ""
Local cDirPai	 := "\danfe_bp\"
Local cDirPDF	 := ""
Local cDirXML	 := ""

If aParam <> Nil
	
	ConOut("Acessando Filial: " + aParam[2])

	RPCClearEnv()
	RPCSetType(3)
	WFPrepENV( aParam[1] , aParam[2] )

EndIf

cNextAlias 	:= GetNextAlias()
cDirPDF	 	:= cDirPai + GetMV("MV_XDIRPDF")
cDirXML	 	:= cDirPai + GetMV("MV_XDIRXML")

If !ExistDir(cDirPai)
	MakeDir(cDirPai)
EndIf

If !ExistDir(cDirPDF)
	MakeDir(cDirPDF)
EndIf

//Criação de pasta para casos que o arquivo corrompe após geração do PDF
If !ExistDir(cDirPDF+"crash\")
	MakeDir(cDirPDF+"crash\")
EndIf        

If !ExistDir("c:\temp\crash\")
	MakeDir("c:\temp\crash\")
EndIf

If !ExistDir(cDirXML)
	MakeDir(cDirXML)
EndIf

// --> Se encontrou registros, então gera a DANFE e XML no diretório informado
If FilterRegs( @cNextAlias )
	ImpDANFE(cNextAlias)
	MsgAlert("Processamento finalizado.")
EndIf

Return(.F.)

//-------------------------------------------------------------------
/*/{Protheus.doc} FilterRegs
Filtra os registros pendentes
@author  Victor Andrade
@since   06/12/2017
@version 1
/*/
//-------------------------------------------------------------------
Static Function FilterRegs( cNextAlias )

Local lRet  := .T.

If Select( cNextAlias ) > 0
	( cNextAlias )->( DbCloseArea() )
EndIf
                 
BeginSQL Alias cNextAlias
	SELECT F2_DOC, F2_SERIE, SF2.R_E_C_N_O_ AS RECNO
	FROM %table:SF2% SF2
	INNER JOIN %table:SF3% SF3
	ON SF2.F2_FILIAL = SF3.F3_FILIAL AND SF2.F2_DOC = SF3.F3_NFISCAL AND SF2.F2_SERIE = SF3.F3_SERIE 
	AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR 
	AND SF2.F2_LOJA = SF3.F3_LOJA 
	AND SF2.F2_EMISSAO = SF3.F3_EMISSAO
	AND SF2.F2_FILIAL = SF3.F3_FILIAL
	WHERE F2_FILIAL  = %xFilial:SF2%
	AND   F2_CHVNFE  <> ''
	AND   F2_XCTRNEG <> 'S'
	AND   SF3.F3_DTCANC = ''
	AND   SF2.%notdel%
	AND   SF3.%notdel%
EndSQL

( cNextAlias )->( DbGoTop() )

If ( cNextAlias )->( Eof() )
	MsgAlert("Sem registros para processar na filial: " + xFilial("SF2") )
	lRet := .F.	
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpDANFE
Encapsula a chamada da rotina para impressão da DANFE
@author  Victor Andrade
@since   06/12/2017
@version 1
/*/
//-------------------------------------------------------------------
Static Function ImpDANFE( cNextAlias )

Local aArea		:= GetArea()
Local i			:= 0
Local cNfPerg	:= Padr( "NFSIGW", 10 )      
Local aFiles	:= {}
Local aSizes	:= {}
Local cDirPDF 	:= "\danfe_bp\" + GetMV("MV_XDIRPDF")
  
DbSelectArea("SF2")

//ProcRegua( (cNextAlias)->( LastRec() ) )

While (cNextAlias)->( !Eof() )

	//IncProc( "Gerando Nota Fiscal: " + AllTrim( (cNextAlias)->F2_DOC ) + " - " + (cNextAlias)->F2_SERIE + "." )

	Pergunte( "NFSIGW", .F. )

	SF2->( DbGoTo( (cNextAlias)->RECNO ) )

	MV_PAR01 := (cNextAlias)->F2_DOC //NF De:
	MV_PAR02 := (cNextAlias)->F2_DOC //NF Ate:
	MV_PAR03 := (cNextAlias)->F2_SERIE //Serie:
	MV_PAR04 := 2          //Tipo de Nota ( Entrada/Saída )
	MV_PAR05 := 1          //Imprime no Verso
	MV_PAR06 := 2          //Imprime no Verso
				
	// Faz a impressão da danfe e geração do XML
	// Se conseguiu gerar os arquivos, então marca como exportado.
	
	If AirBPDanfe()
		SF2->( RecLock("SF2", .F.) )
		SF2->F2_XCTRNEG := "S"
		SF2->( MsUnlock() )
	EndIf
	
	//Trecho para verificar se o arquivo PDF pode ter corrompido, casos com 0k de tamanho
	
	cChave := SF2->F2_DOC + "_" + SF2->F2_FILIAL + "_" + SF2->F2_CLIENTE + "_" + SF2->F2_LOJA 
	
	//Busca arquivo na pasta
	ADir(cDirPDF + cChave + ".pdf", aFiles, aSizes)

	if Len( aFiles ) > 0
		nErro := 0
		
		//Verifica tamanho do arquivo e se já ocorreu erro 3 vezes
		while aSizes[1] == 0 .and. nErro < 3
			alert ("Falha na geracao, tentativa: " + alltrim(str(nErro+1)) + " NF: " + cChave)
			frename(cDirPDF + cChave + ".pdf",cDirPDF + "crash\" + cChave + "_crash"+alltrim(str(nErro+1)))
			frename("c:\temp\" + cChave + ".pdf","c:\temp\crash\" + cChave + "_crash"+alltrim(str(nErro+1)))
			AirBPDanfe()
			aFiles := {}
			aSizes := {}
			ADir(cDirPDF + cChave + ".pdf", aFiles, aSizes)
			nErro++
		enddo
		
		//Caso tenha acontecido a falha 3 vezes, irá informar o cliente e retirar o flag
		if nErro == 3 .and. aSizes[1] == 0
			alert ("A nota fiscal " + cChave + " não foi gerada corretamente, por favor entre em contato com a equipe de TI") 
			SF2->( RecLock("SF2", .F.) )
			SF2->F2_XCTRNEG := ""
			SF2->( MsUnlock() )		
		endif
		
		aFiles := {}
		aSizes := {}
	endif
	
	(cNextAlias)->( DbSkip() )

EndDo

RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AirBPDanfe
Parametriza a chamada da geração da DANFE
@author  Victor Andrade
@since   06/12/2017
@version 1
/*/
//-------------------------------------------------------------------
Static Function AirBPDanfe()

Local cIdEnt 	:= BPIdEnt()
Local aIndArq 	:= {}
Local aDevice 	:= {}
Local nHRes 	:= 0
Local nVRes 	:= 0
Local nRet 		:= 0
Local nDevice
Local cFilePrt  := "DANFE_" + cIdEnt + DtoS(MSDate()) + StrTran(Time(),":","")
Local oSetup 	:= Nil
Local oDanfe	:= Nil
Local cSession 	:= GetPrinterSession()
Local lRet		:= .F.
Local aArea		:= GetArea()

If FindFunction("U_DANFE_V")
	nRet := u_Danfe_v()
EndIf

aAdd(aDevice,"DISCO") // 1
aAdd(aDevice,"SPOOL") // 2
aAdd(aDevice,"EMAIL") // 3
aAdd(aDevice,"EXCEL") // 4
aAdd(aDevice,"HTML" ) // 5
aAdd(aDevice,"PDF"  ) // 6

nLocal       	:= Iif( fwGetProfString( cSession, "LOCAL","SERVER", .T. ) == "SERVER", 1 ,2 )
nOrientation 	:= Iif( fwGetProfString( cSession, "ORIENTATION", "PORTRAIT",.T.) == "PORTRAIT",1,2 )
cDevice     	:= Iif( Empty(fwGetProfString(cSession, "PRINTTYPE", "SPOOL",.T.)), "PDF", fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.) )
nPrintType      := aScan(aDevice,{|x| x == cDevice })

DbSelectArea("SF2")
RetIndex("SF2")
DbClearFilter()

lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
oDanfe 			:= FWMSPrinter():New(cFilePrt, IMP_PDF, lAdjustToLegacy, /*cPathInServer*/, .T.)
nFlags 			:= PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
oDanfe:lInJob 	:= .F.

If !(oDanfe:lInJob)
	oSetup := FWPrintSetup():New(nFlags, "DANFE")
	oSetup:SetPropert(PD_PRINTTYPE   , IMP_PDF)
	oSetup:SetPropert(PD_ORIENTATION , nOrientation)
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
	oSetup:SetPropert(PD_PAPERSIZE   , 2)
	oSetup:SetPropert(PD_DESTINATION , 2) // 1=Servidor 2=Local
EndIf

fwWriteProfString( cSession, "LOCAL"      , Iif(  .F. , "SERVER"   , "CLIENT"    ), .T. )
fwWriteProfString( cSession, "PRINTTYPE"  , Iif(  .F. , "SPOOL"    , "PDF"       ), .T. )
fwWriteProfString( cSession, "ORIENTATION", Iif(  .T. , "PORTRAIT" , "LANDSCAPE" ), .T. )

// Configura o objeto de impressão com o que foi configurado na interface.
oDanfe:setCopies(1)
//@ERPSERV - Projeto Compliance Fiscal - NT 2018/001 - a função PrtNfeSef recebe um parâmetro a mais no final (nTipo)
lRet := u_PrtNfeSef(cIdEnt,,,oDanfe, oSetup, cFilePrt, .T., ,.T.)

Pergunte("NFSIGW", .F.)

oDanfe := Nil
oSetup := Nil

RestArea(aArea)

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} BPIdEnt
Baseado no GetIdEnt do FISA022
@author  Victor Andrade
@since   06/12/2017
@version 1
/*/
//-------------------------------------------------------------------
Static Function BPIdEnt()

Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs
Local lUsaGesEmp := IIF(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)
Local lEnvCodEmp := GetNewPar("MV_ENVCDGE",.F.)
Local lUsaColab := UsaColaboracao("3")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem o codigo da entidade                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !lUsaColab
oWS := WsSPEDAdm():New()
oWS:cUSERTOKEN := "TOTVS"
	
oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
oWS:oWSEMPRESA:cFANTASIA   := IIF(lUsaGesEmp,FWFilialName(),Alltrim(SM0->M0_NOME))
oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
oWS:oWSEMPRESA:cCEP_CP     := Nil
oWS:oWSEMPRESA:cCP         := Nil
oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cINDSITESP  := ""
oWS:oWSEMPRESA:cID_MATRIZ  := ""

If lUsaGesEmp .And. lEnvCodEmp
	oWS:oWSEMPRESA:CIDEMPRESA:= FwGrpCompany()+FwCodFil()
EndIf
oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
If ExecWSRet(oWs,"ADMEMPRESAS")
	cIdEnt  := oWs:cADMEMPRESASRESULT
Else
	Aviso("NFS-e",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
EndIf

Else
	if !( ColCheckUpd() )
		Aviso("SPED","UPDATE do TOTVS Colaboração 3.0 não aplicado. Desativado o uso do TOTVS Colaboração 3.0",{"Ok"},3)	
	else
		cIdEnt := "000000"
	endif	 
EndIF

RestArea(aArea)

Return(cIdEnt)

//-------------------------------------------------------------------
/*/{Protheus.doc} function
Chamada para ser realizada via menu (JOB não está funcionando)
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
User Function JbMenu01()
Return( U_JBAIR001() )