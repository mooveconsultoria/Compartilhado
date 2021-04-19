#Include "TopConn.Ch"
#Include "FiveWin.ch"
#Include "RwMake.Ch"
#Include "Protheus.Ch"
#Include "TbiConn.Ch"
#Include "ApWizard.Ch"

// Opções do MessageBox
#Define MB_ICONASTERISK       64

/*/{Protheus.doc} EECLondon
Descrição: Integração das Faturas via EDI.
@author Walnir Necho Mandu \ Nastri
@since 24/11/2015 \ 08/11/2017
@version V12
@type function
/*/
User Function EECLondon()
	Local cFile			:= ''
	Local cDir        	:= 'C:\Exp_CSV\"
	Local cMask       	:= 'Planilha Excel CSV (*.CSV) | *.CSV'
	Local cTitle      	:= 'Baixas de Fatura via EDI'
	Local nOpcImp		:= GETF_LOCALHARD+GETF_NETWORKDRIVE
	Local dDtBxs		:= Ctod('  /  /    ')
	Local lServer	    := .F.
	Local lSave			:= .T.
	Local lOk			:= .F.
	Local oFile			:= Nil
	Local oWizard		:= Nil
	Local oGroup		:= Nil

	DEFINE WIZARD oWizard TITLE "Baixas de Fatura via EDI" HEADER "Wizard utilizado para Importação de EDI.";                                                                                                                                                                                                                                                                                                                                                                                                                                                   
	MESSAGE "";
	TEXT "Esta rotina tem por objetivo importar um arquivo CSV para efetuar as baixas das faturas via EDI."; 
	PANEL NEXT {|| .T. } FINISH {|| .T. };

	// Painel da selecao do arquivo
	CREATE PANEL oWizard HEADER "Parametros para Importação";
	MESSAGE "Informe os parametros abaixo.";
	PANEL BACK {|| .T. } NEXT {|| VldPar(cFile,dDtBxs)  } FINISH {|| .T. } EXEC {|| .T. }	

	@ 006,003 Say "Arquivo"	Size 051,008 COLOR CLR_BLUE PIXEL OF oWizard:oMPanel[2]
	@ 005,024 MsGet oFile Var cFile Size 236,009 COLOR CLR_BLACK PIXEL OF oWizard:oMPanel[2] When .F.
	@ 005,260 Button "Selecione" Size 035,011 Action cFile := Upper(Alltrim(cGetFile(cMask,cTitle,,cDir,lSave,nOpcImp,lServer))) PIXEL OF oWizard:oMPanel[2]

	oGroup := TGroup():New(021,002,022,294,"",oWizard:oMPanel[2],,,.T.)

	@ 028,005 Say 'Data para Baixa'  Size 051,008 COLOR CLR_BLUE PIXEL OF oWizard:oMPanel[2]
	@ 038,005 MsGet dDtBxs Size 050,010 COLOR CLR_BLACK PIXEL OF oWizard:oMPanel[2]

	// Painel da importacao do arquivo e finalizacao do processo
	CREATE PANEL oWizard HEADER "Obrigado por utilizar uma ferramenta TOTVS.";
	MESSAGE "";
	PANEL BACK {|| .T. } FINISH {|| lOk := .T. } EXEC {|| .T.}

	@ 005,005 Say "Clique em Finalizar para iniciar o processo de importação." Size 250,008 COLOR CLR_BLUE PIXEL OF oWizard:oMPanel[3]

	ACTIVATE WIZARD oWizard CENTERED

	If lOk	
		Processa( {|| ProcPed(cFile,dDtBxs) }, "Aguarde...", "Processando arquivo : " + cFile,.F.)
	EndIf
Return

/*/{Protheus.doc} VldPar
Descrição: Valida as informações minimas para importação.
@author Nastri
@since 08/11/2017
@version V12
@param cArq, characters, descricao
@param dData, date, descricao
@type function
/*/
Static Function VldPar(cArq,dData)
	Local lRet := .T.

	If Empty(cArq) .Or. Empty(dData)
		MessageBox("Arquivo ou Data não informados!","EECLondon",MB_ICONASTERISK)
		lRet := .F.
	EndIf
Return(lRet)

/*/{Protheus.doc} ProcPed
Descrição: Processa o Arquivo.
@author Walnir Necho Mandu \ Nastri
@since 24/11/2015 \ 08/11/2017
@version V12
@param cFile, characters, descricao
@param dDtBxs, date, descricao
@type function
/*/
Static Function ProcPed(cFile,dDtBxs)
	Local cPrefixo		:= ''   
	Local N				:= 0
	Local nReg			:= 0
	Local dDataOri		:= dDataBase      
	Local lErrImped 	:= .F.
	Local aBaixa    	:= {}

	Private cAlias      := ""
	Private nValQry     := 0
	Private aLinha      := {}
	Private aCambios    := {}

	lMsHelpAuto 		:= .F. 
	lMsErroAuto 		:= .F. 

	//Ajusto a Database para as Baixas. Vide data informada pelo user.
	dDataBase := dDtBxs

	DbSelectArea("SE1")
	SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

	DbSelectArea("EEQ")
	EEQ->(DbSetOrder(1)) //EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE

	//Inicia o processamento do Arquivo.
	FT_FUse(cFile)
	FT_FGOTOP()

	ProcRegua(FT_FLASTREC())

	While!FT_FEOF()
		nReg ++
		IncProc("Lendo Arquivo " + CValToChar(nReg))

		FT_FSkip()
		If FT_FEOF()
			Exit
		Endif                                                                          	

		aLinha := Separa(Alltrim(FT_FREADLN()),";")

		Aadd(aCambios,{ "01"                                                   ,; // Prefixo
						StrZero(Val(AllTrim(aLinha[5])),9)                     ,; // Numero da Fatura 
						aLinha[11]                                             ,; // Identificador da Moeda (Ex: USD)
						Abs(Val(StrTran(StrTran(aLinha[10],".", ),",",".")))   ,; // Valor
						"STATUS"                                               ,; // Fixo STATUS
						Val(StrTran(StrTran(aLinha[10],".", ),",","."))        }) // Valor
	EndDo
	FT_FUse()

	ProcRegua(Len(aCambios))

	//Inicia a Baixa dos Itens Lidos do Arquivo.
	For N := 1 To Len(aCambios)
		IncProc("Importando Liquidacao : " + AllTrim(aLinha[5]))

		lErrImped :=  .F.

		cPrefixo := Space(03)
		cPrefixo := BusPrefixo(aCambios[N][2])

		If !SE1->(DbSeek(xFilial("SE1")+cPrefixo+AvKey(aCambios[N][2],"E1_NUM") ))
			AutoGrLog( "Titulo inexistente, linha " + str(n+1,2,0) + " Titulo " + aCambios[N][2]+ " " + aCambios[N][2] + " Favor verificar" )
			lErrImped :=  .T. 
		Else
			If SE1->E1_SALDO # aCambios[N][4]
				AutoGrLog( "Titulo incompativel, linha " + str(n+1,2,0) + " Titulo " + aCambios[N][2]+ " " +;
				aCambios[N][2] + " valor no sistema " + STR(SE1->E1_VALOR) + " valor no ARQ " + str(aCambios[N][4],12,2) +" Favor verificar" )
				lErrImped :=  .T.
			EndIf
			If SE1->E1_FATURA # "NOTFAT" .AND. SE1->E1_TIPO # "NCC"
				AutoGrLog( "Titulo não é fatura, linha " + str(n+1,2,0) + " Titulo " + aCambios[N][2]+ " " + aCambios[N][2] + " Favor verificar" )
				lErrImped :=  .T. 
			EndIf			
		EndIf

		If !lErrImped
			aBaixa :=  {{"E1_FILIAL"   ,xFilial("SE1")                      ,Nil},;
						{"E1_PREFIXO"  ,cPrefixo           					,Nil},;
						{"E1_NUM"      ,aCambios[N,2]					    ,Nil},;
						{"E1_TIPO"     ,SE1->E1_TIPO                        ,Nil},;
						{"E1_PARCELA"  ,SE1->E1_PARCELA                     ,Nil},;
						{"E1_CLIENTE"  ,SE1->E1_CLIENTE                     ,Nil},;
						{"E1_LOJA"     ,SE1->E1_LOJA                        ,Nil},;
						{"AUTVALREC"   ,aCambios[N,4]	                    ,Nil},;
						{"AUTTXMOEDA"  ,BuscaTaxa("US$", dDataBase,,.F.)    ,Nil},;
						{"AUTMOTBX"    ,"NOR"                               ,Nil},;
						{"AUTDTBAIXA"  ,dDataBase                           ,Nil},;
						{"AUTBANCO"    ,"SNA"                               ,Nil},;
						{"AUTAGENCIA"  ,"00000"                             ,Nil},;
						{"AUTCONTA"    ,"7679485860"                        ,Nil},;
						{"AUTDTCREDITO",dDataBase                           ,Nil},;
						{"AUTHIST"     ,"BAIXA EDI LONDRES"                 ,Nil},;
						{"AUTJUROS"    ,0                                   ,Nil}}
		EndIf

		MsExecAuto({|x,y| Fina070(x,y)},aBaixa,3)

		If !lMsErroAuto                    
			QryBusca(aCambios[N,2],aCambios[N,4])

			(cAlias)->(DbGoTop())            

			While !(cAlias)->(EOF())
				If EEQ->(DbSeek(Padr((cAlias)->E1_FILORIG,TamSx3("EEQ_FILIAL")[1]) + Padr((cAlias)->E1_NUM,TamSx3("EEQ_PREEMB")[1])  ))
					RecLock("EEQ",.F.)
					EEQ->EEQ_DTCE   := dDataBase
					EEQ->EEQ_BCOEXT := "SNA"
					EEQ->EEQ_AGCEXT := "00000"
					EEQ->EEQ_CNTEXT := "7679485860"
					EEQ->EEQ_MODAL  := "2"
					EEQ->EEQ_TX     := BuscaTaxa("US$", dDataBase,,.F.)
					EEQ->(MsUnLock())
				EndIf
				(cAlias)->(DbSkip())
			EndDo

			(cAlias)->(DbCloseArea())

			If Select(cAlias) == 0
				Ferase(cAlias+GetDBExtension())
			Endif
		Else
			MostraErro()
		EndIf 
	Next N

	If Select(cAlias) == 0  .Or. Empty(cAlias)
		Ferase(cAlias+GetDBExtension())
	Else
		(cAlias)->(dbCloseArea()) 
		Ferase(cAlias+GetDBExtension())
	Endif

	//Retorna a Database Original.
	dDataBase := dDataOri
Return                                       

/*/{Protheus.doc} QryBusca
Descrição: Verifica se o Valor dos Titulos da Fatura no sistema bate com o Importado.
@author TOTVS
@since 08/11/2017
@version V12
@param cFatura, characters, descricao
@param nValCamb, numeric, descricao
@type function
/*/
Static Function QryBusca(cFatura, nValCamb)
	Local cQuery  := ""

	cAlias  := GetNextAlias()
	nValQry := 0             

	cQuery := " SELECT DISTINCT SE1.E1_CLIENTE, SE1.E1_LOJA , SE1.E1_VENCREA, SE1.E1_FATURA, SE1.E1_NUM,  SE1.E1_FILORIG, "
	cQuery += "                 SE1.E1_VALOR  , SE1.E1_TIPO , SE1.E1_FATURA , SE1.E1_SALDO , SE1.E1_MOEDA  "
	cQuery += " FROM "+ RetSqlName("SE1") + " SE1  "
	cQuery += " WHERE SE1.E1_FATURA  = '" + cFatura +         "'  AND " 
	cQuery += "       SE1.E1_SALDO   = 0                          AND " 
	cQuery += "       SE1.E1_FILIAL  = '" + xFilial("SE1") + "'   AND " 
	cQuery += "       SE1.D_E_L_E_T_  <> '*' "             + "        "
	cQuery += " ORDER BY SE1.E1_FATURA                                "
	cQuery := ChangeQuery(cQuery) 
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)
	TcSetField(cAlias, "E1_VENCREA" ,"D")    
	TcSetField(cAlias, "E1_VALOR"	,"N",TamSx3("E1_VALOR"	)[1],TamSx3("E1_VALOR"	)[2])   
	TcSetField(cAlias, "E1_SALDO"	,"N",TamSx3("E1_SALDO"	)[1],TamSx3("E1_SALDO"	)[2])   

	(cAlias)->(DbGoTop())

	If (cAlias)->(!EOF())
		While (cAlias)->(!EOF())
			nValQry := nValQry + (cAlias)->E1_VALOR
			(cAlias)->(DbSkip())
		EndDo
		If nValQry # nValCamb
			AutoGrLog( "Titulos da fatura "+ cFatura +" valor no sistema " + str(nValCamb,12,2) + " valor nos titulos " + str(nValQry,12,2) +" Favor verificar" )
		EndIf
	Else
		AutoGrLog( "Não existem titulos para a fatura "+ cFatura + " Favor verificar" )
	EndIf
Return(.T.)

/*/{Protheus.doc} BusPrefixo
Descrição: Busca o Prefixo do Titulo - SE1.
@author Danilo José Grodzicki
@since 21/08/2017
@version V12
@param cNumero, characters, descricao
@type function
/*/
Static Function BusPrefixo(cNumero)
	Local lAchou    := .F.
	Local cQuery    := ""
	Local cPrefixo  := space(03)
	Local cAliasTmp := GetNextAlias()

	cQuery := "SELECT E1_PREFIXO AS PREFIXO "
	cQuery += "FROM "+RetSqlName("SE1")+" SE1 "
	cQuery += "WHERE SE1.D_E_L_E_T_ <> '*' "
	cQuery += "  AND SE1.E1_FILIAL = '"+xFilial("SE1")+"' "
	cQuery += "  AND SE1.E1_TIPO = 'FT' "
	cQuery += "  AND SE1.E1_NUM = '"+cNumero+"'"
	cQuery := ChangeQuery(cQuery) 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)

	(cAliasTmp)->(DbGoTop())

	If (cAliasTmp)->(!Eof())
		lAchou   := .T.
		cPrefixo := (cAliasTmp)->PREFIXO
	EndIf

	(cAliasTmp)->( dbCloseArea() )

	If Select(cAliasTmp) == 0
		Ferase(cAliasTmp+GetDBExtension())
	Endif

	If !lAchou
		cQuery := "SELECT E1_PREFIXO AS PREFIXO "
		cQuery += "FROM "+RetSqlName("SE1")+" SE1 "
		cQuery += "WHERE SE1.D_E_L_E_T_ <> '*' "
		cQuery += "  AND SE1.E1_FILIAL = '"+xFilial("SE1")+"' "
		cQuery += "  AND SE1.E1_TIPO = 'NCC' "
		cQuery += "  AND SE1.E1_NUM = '"+cNumero+"'"
		cQuery := ChangeQuery(cQuery) 
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
		(cAliasTmp)->(DbGoTop())
		If (cAliasTmp)->(!Eof())
			cPrefixo := (cAliasTmp)->PREFIXO
		EndIf

		(cAliasTmp)->( dbCloseArea() )

		If Select(cAliasTmp) == 0
			Ferase(cAliasTmp+GetDBExtension())
		Endif
	EndIf
Return(cPrefixo)