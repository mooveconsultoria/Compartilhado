#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "TbiConn.ch"
#Include "RwMake.ch"
#Include "MSOLE.CH"

#Define CRLF Chr(13)+Chr(10)

/*/{Protheus.doc} EECR0001
Air BP - Geração de INTEGRACAO IMI
@author WALNIR MANDU
@since 28/03/2016
@type function
/*/
User Function IMI_EEC()
	Local aTabelas   := {"EE7","EE8","EEC","EE9","SF2","SD2","SA1","SE1","EEX","EEQ","EY6","SX6","SX3","SX7","SC5","SC6","EEM","EXL","EEQ","SE5","SF2"}
	Local cStart     := GetSrvProfString( 'STARTPATH', '' )
	Local cIniFile   := GetADV97()
	Local cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )
	Local cHora      := Time()

	Local cResName 	:= ""	
	Local cDirIni  	:= "\DATA\IMI"
	Local aHelp 	:= {}
	Local cTargetDir
	Local cLinha 	:= ""	
	Local nHandle             
	Local nPos      := 0

	Private lFirst	:= .T.
	Private cAlias	:= ""
	Private cAlFat	:= ""
	Private cPagEdi	:= "0"
	Private cAerOrig:= ""
	Private aFls      := {}

	Private lSchedule := .T.

	Private cFlagXImi := .T.

	lSchedule := .f.				//	marcelino

	if lSchedule
		RpcSetType(3)
		RpcSetEnv("01","010101")
		cUsuario := SuperGetMv("MV_XUSUBIL",.F.," ")  // Usuário
		cSenha   := SuperGetMv("MV_XSENBIL",.F.," ")  // Senha 
		RpcSetType(3)
		RpcSetEnv("01","010101",cUsuario,cSenha,"EEC",,aTabelas,,,,)
	endif

	cResName 	:= "SBR" + GravaData(dDataBase,.F.,4) + ".TXT"

	AADD(aFls, {"SP1", "011","010101"})
	AADD(aFls, {"MGF", "041","010104"})
	AADD(aFls, {"RAO", "061","010106"})
	AADD(aFls, {"SP2", "081","010108"})
	AADD(aFls, {"SP3", "101","010110"})
	AADD(aFls, {"DJD", "121","010112"})
	AADD(aFls, {"JCR", "141","010114"})
	AADD(aFls, {"CFB", "151","010115"})
	AADD(aFls, {"TU1", "181","010118"})
	AADD(aFls, {"CGB", "191","010119"})
	AADD(aFls, {"IGU", "211","010121"})
	AADD(aFls, {"GIG", "221","010122"})
	AADD(aFls, {"GYN", "241","010124"})
	AADD(aFls, {"BSB", "271","010127"})
	AADD(aFls, {"AR1", "281","010128"})
	AADD(aFls, {"CWB", "291","010129"})
	AADD(aFls, {"REC", "301","010130"})
	AADD(aFls, {"IPO", "311","010131"})
	AADD(aFls, {"VCP", "321","010132"})
	AADD(aFls, {"GRU", "331","010133"})
	AADD(aFls, {"CNF", "341","010134"})
	AADD(aFls, {"VIX", "351","010135"})
	AADD(aFls, {"FC1", "361","010136"})

	//Cria diretório Inicial caso nao exista
	MakeDir(cDirIni)                        

	cTargetDir := cDirIni

	nHandle := MsfCreate(cTargetDir + "\"+cResName,0)

	chkfile("SD1",.F.)
	chkfile("EE7",.F.)

	EE7->(DBSETORDER(1))				
	SD1->(DBSETORDER(1))

	fExecQry(2)

	If (cAlFat)->(!Eof()) 

		(cAlFat)->(DbGoTop())
		Do While (cAlFat)->(!Eof())

			IF alltrim((cAlFat)->E1_TIPO) == "FT"      // WNM 16/12/16
				fExecQry(3)
			ELSEIF (cAlFat)->E1_TIPO == "NCC"                         // WNM 16/12/16
				IF SD1->(DBSEEK((cAlFat)->(E1_FILORIG+E1_NUM+E1_SERIE+E1_CLIENTE+E1_LOJA) ))
					DO WHILE SD1->(!EOF()) .AND. (cAlFat)->(E1_FILORIG+E1_NUM+E1_SERIE+E1_CLIENTE+E1_LOJA) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) // WNM 16/12/16 NOTA DE DEVOLUCAO

						IF ! EMPTY(SD1->D1_NFORI) .AND. ! EMPTY(SD1->D1_SERIORI) .AND. ! EMPTY(SD1->D1_ITEMORI)
							fExecQry(4)                   // WNM 16/12/16
						ELSE
							fCredit(nHandle)
						ENDIF

						SD1->(DBSKIP())  
					ENDDO
				ELSE    // NAO ACHOU SD1 --> nota de credito sem itens
					fCredit(nHandle)
					(cAlFat)->(DBSKIP())		
					LOOP
				ENDIF
			ENDIF                             // WNM 16/12/16

			If select(cAlias) # 0 .and. (cAlias)->(!Eof())

				(cAlias)->(DbGoTop())
				Do While (cAlias)->(!Eof())
					cAerOrig := "XXX"
					IF EE7->(DBSEEK((cAlias)->(SC5_FILIAL+C5_NUM))) //POSICIONA PEDIDO DE EXPORTAÇÃO
						cAerOrig := EE7->EE7_ORIGEM
					ELSE
						nPos     := aScan(aFls, {|x| x[3] == (cAlias)->E1_FILORIG })  
						IF nPos # 0
							cAerOrig := AFls[nPos][1]
						ENDIF
					ENDIF
					//Abastecimento (Itens)
					fAbastec(nHandle)

					IF cFlagXImi
						dbSelectArea("SE1")
						SE1->(dbGoTo((cAlias)->E1RECNO))
						If RecLock("SE1",.F.)
							SE1->E1_XIMI   := "S"
							SE1->E1_XIMIDT := DtoS(Date()) + Time()
							SE1->(MsUnlock())
						EndIf
					EndIf		
					dbSelectArea(cAlias)
					(cAlias)->(DBSKIP())		

				enddo	
				(cAlias)->(dbCloseArea()) 
				If Select(cAlias) == 0
					Ferase(cAlias+GetDBExtension())
				Endif

			endif

			IF cFlagXImi
				dbSelectArea("SE1")
				SE1->(dbGoTo((cAlFat)->E1RECNO))
				If RecLock("SE1",.F.)
					SE1->E1_XIMI   := "S"
					SE1->E1_XIMIDT := DtoS(Date()) + Time()
					SE1->(MsUnlock())
				EndIf
			EndIf		
			dbSelectArea(cAlFat)

			(cAlFat)->(DBSKIP())
		EndDo				

		fClose(nHandle)
		(cAlFat)->(dbCloseArea()) 
		If Select(cAlFat) == 0
			Ferase(cAlFat+GetDBExtension())
		Endif
	EndIf      

	IF lSchedule
		RpcClearEnv()
	ENDIF

Return

/*/{Protheus.doc} fAbastec
//Itens do abastecimento com NF
@author WALNR MANDU
@since 28/03/2016
/*/ 
Static Function fAbastec(nHandle) 
	Local cLinha := ""    
	cTexto := ""//SPACE(700)
	/*	cTexto := STUFF(cTexto,001,0,PADR((cAlias)->EE7_XPREFI,30)            )
	cTexto := STUFF(cTexto,031,0,PADR(DTOS((cAlias)->EE7_XDTEMI),8)       )
	// WNM 10/10/16	cTexto := STUFF(cTexto,039,0,PADR(ORI100Numero(((cAlias)->EE9_SLDINI),22,5),23))
	cTexto := STUFF(cTexto,039,0,PADR(STR((cAlias)->EE9_SLDINI,22,5),23)  )
	cTexto := STUFF(cTexto,062,0,PADL("1",7)                              )
	cTexto := STUFF(cTexto,070,0,PADR((cAlias)->EE7_XTIPAE,7)             )
	cTexto := STUFF(cTexto,077,0,PADR(" AIR",9)                            )
	cTexto := STUFF(cTexto,086,0,PADR(SPACE(05),5)                        ) // VAZIO
	cTexto := STUFF(cTexto,091,0,PADL((cAlias)->A1_XGREF,15)              ) // --> GLOBAL REFERENCE NUMER - VERIFICAR
	cTexto := STUFF(cTexto,107,0,PADR(SPACE(15),15)                       ) // VAZIO
	cTexto := STUFF(cTexto,122,0,PADR(SPACE(15),15)                       ) // VAZIO
	cTexto := STUFF(cTexto,137,0,PADR(SPACE(13),13)                       ) // VAZIO
	cTexto := STUFF(cTexto,150,0,PADR("N",1)                              ) // NOTA DE CREDITO OU DEBITO
	cTexto := STUFF(cTexto,151,0,PADR(SPACE(01),1)                        ) //VAZIO
	cTexto := STUFF(cTexto,152,0,PADL("BRL",11)                           )
	cTexto := STUFF(cTexto,163,0,PADL(IIF((cAlias)->EEQ_MOEDA==1,"BRL","USD"),8))   
	cTexto := STUFF(cTexto,171,0,PADL(IIF((cAlias)->EEQ_MOEDA==1,"BRL","USD"),8))
	cTexto := STUFF(cTexto,179,0,PADL("USD",8)                            )
	cTexto := STUFF(cTexto,187,0,PADR((cAlias)->A1_XGREF,14)              ) // --> GLOBAL REFERENCE NUMER - VERIFICAR
	cTexto := STUFF(cTexto,201,0,PADR(" ",30)                             ) // --> CARTAO STERLING
	cTexto := STUFF(cTexto,231,0,PADR((cAlias)->EE7_XNUMCE,15)            )
	cTexto := STUFF(cTexto,246,0,PADR(ORI100Numero(((cAlias)->C5_TXMOEDA),21,5),27))
	cTexto := STUFF(cTexto,273,0,PADR(ORI100Numero(((cAlias)->C5_TXMOEDA),21,5),21))
	cTexto := STUFF(cTexto,294,0,PADR("1",21)                             )
	cTexto := STUFF(cTexto,315,0,PADR((cAlias)->EE7_XNUMVO,7)             )
	cTexto := STUFF(cTexto,322,0,PADR("E",8)                              )
	cTexto := STUFF(cTexto,330,0,PADR((cAlias)->EE7_XCODAE+"01",15)       )
	cTexto := STUFF(cTexto,345,0,PADR(" ",15)                             ) // TIPO DE TRANSACAO - SANDRA FICOU DE VERIFICAR
	cTexto := STUFF(cTexto,356,0,PADR(DTOS((cAlias)->EEQ_EMISSA),8)       )
	cTexto := STUFF(cTexto,364,0,PADR(" ",22)                             ) // VALOR DA COBRANCA EM USD
	cTexto := STUFF(cTexto,386,0,PADR(SPACE(13),13)                       ) //VAZIO
	cTexto := STUFF(cTexto,399,0,PADR(" ",10)                             ) // ID DO ITEM VERIFICAR COM EBILLING
	cTexto := STUFF(cTexto,409,0,PADR(SPACE(10),10)                       ) //VAZIO
	cTexto := STUFF(cTexto,419,0,PADR((cAlias)->EEQ_PREEMB,30)            )
	cTexto := STUFF(cTexto,449,0,PADR(SPACE(15),15)                       ) //VAZIO
	cTexto := STUFF(cTexto,464,0,PADR((cAlias)->EE7_XCODAE,15)            )
	cTexto := STUFF(cTexto,479,0,PADR((cAlias)->EE9_COD_I,17)             )
	cTexto := STUFF(cTexto,496,0,PADR(DTOS(dDataBase),8)                  )
	cTexto := STUFF(cTexto,504,0,PADR(DTOS((cAlias)->EEQ_VCT),8)          ) // verificar condicoes de pagamento
	cTexto := STUFF(cTexto,512,0,PADR(" ",7)                              )
	cTexto := STUFF(cTexto,519,0,PADR(" ",39)                             ) // valor dos impostos
	cTexto := STUFF(cTexto,558,0,PADR(ORI100Numero(((cAlias)->EE9_SLDINI),22,5),23))
	cTexto := STUFF(cTexto,571,0,PADR("28",8)                             )
	cTexto := STUFF(cTexto,579,0,PADR((cAlias)->A1_NOME,71)               )
	cTexto := STUFF(cTexto,650,0,PADR(" ",30)                             ) // SETOR DO CLIENTE - VERIFICAR TOTVS SE FOI CRIADA TABELA
	cTexto := STUFF(cTexto,680,0,PADR(SPACE(20),20)                       ) //VAZIO 
	cTexto := cTexto + CRLF */

	cTexto := cTexto + PADR((cAlias)->EE7_XPREFI,30)            
	cTexto := cTexto + PADR(DTOS((cAlias)->EE7_XDTEMI),8)       
	cTexto := cTexto + PADR(STR((cAlias)->EE9_SLDINI,22,5),23)  
	cTexto := cTexto + PADL("1",7)                              
	cTexto := cTexto + PADR((cAlias)->EE7_XTIPAE,7)             
	cTexto := cTexto + PADR(" AIR",9)                           
	cTexto := cTexto + PADR(SPACE(06),6)                         // VAZIO
	cTexto := cTexto + PADL((cAlias)->A1_XGREF,15)               // --> GLOBAL REFERENCE NUMER - VERIFICAR
	cTexto := cTexto + PADR(SPACE(15),15)                        // VAZIO
	cTexto := cTexto + PADR(SPACE(15),15)                        // VAZIO
	cTexto := cTexto + PADR(SPACE(13),13)                        // VAZIO

	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// NOTA DE CREDITO E DEBITO -- V E R I F I C A R - Falta fechar conceito para nota de credito e debito - JULIO NEGRI em 17/10/16
	cTexto := cTexto + PADR("  N",3)                               // NOTA DE CREDITO OU DEBITO
	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	cTexto := cTexto + PADL("BRL",11)                           
	cTexto := cTexto + PADL(IIF((cAlias)->EEQ_MOEDA==1,"BRL","USD"),8)   
	cTexto := cTexto + PADL(IIF((cAlias)->EEQ_MOEDA==1,"BRL","USD"),8)
	cTexto := cTexto + PADL("USD",8)                            
	cTexto := cTexto + PADR(SPACE(05),5)                         //VAZIO
	cTexto := cTexto + PADR((cAlias)->A1_XGREF,14)               // --> GLOBAL REFERENCE NUMER - VERIFICAR

	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// CARTAO STERLING -- V E R I F I C A R - Questionado a Sandra (AirBP)  em 17/10/16 - [Sandra Helena De Souza] Pode ser deixado em branco. Não registramos esta informação hoje.
	cTexto := cTexto + PADR(" ",31)                              // --> CARTAO STERLING
	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	cTexto := cTexto + PADR((cAlias)->EE7_XNUMCE,15)
	IF (cAlias)->EEQ_MOEDA == 1
		cTexto := cTexto + PADR(STR(1,21,15)+"0000000",21)
		cTexto := cTexto + "    " + ALLTRIM(PADR(STR(1,21,15)+"0000000",21))
		cTexto := cTexto + "    " + ALLTRIM(PADR(STR(1,21,15)+"0000000",21))
	ELSE
		// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		// TAXA DOLAR - FORMATO -- V E R I F I C A R - Questionado a Sandra (AirBP)  em 17/10/16  - [Sandra Helena De Souza] A taxa informada no IMI indica quantos dólares consigo comprar com 1 real. 
		cTexto := cTexto + PADR(STR((1/(cAlias)->C5_TXMOEDA),21,15)+"0000000",21)
		cTexto := cTexto + "    " + ALLTRIM(PADR(STR((1/(cAlias)->C5_TXMOEDA),21,15)+"0000000",21))
		cTexto := cTexto + "    " + ALLTRIM(PADR(STR((1/(cAlias)->C5_TXMOEDA),21,15)+"0000000",21))
		// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	ENDIF
	cTexto := cTexto + SPACE(3)                             
	cTexto := cTexto + PADR((cAlias)->EE7_XNUMVO,7)             
	IF (cAlias)->EEQ_MOEDA == 1
		cTexto := cTexto + PADR("I",8)                              
	ELSE
		cTexto := cTexto + PADR("E",8)                              
	ENDIF       
	cTexto := cTexto + PADR(cAerOrig+"01",15)       // WNM 09/12/16

	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// TIPO DE TRANSACAO - VER ORIGEM -- V E R I F I C A R - Tipo de transacao depende da definicao do nota de credito e/ou debito
	IF  (cAlFat)->E1_TIPO              == "NCC"
		cTexto := cTexto + PADL("21",8)                             // TIPO DE TRANSACAO - SANDRA FICOU DE VERIFICAR
	ELSEIF alltrim((cAlFat)->E1_TIPO)  == "FT"
		cTexto := cTexto + PADL("1",8)                              // TIPO DE TRANSACAO - SANDRA FICOU DE VERIFICAR
	ELSE
		cTexto := cTexto + PADL(" ",8)                              // TIPO DE TRANSACAO - SANDRA FICOU DE VERIFICAR
	ENDIF
	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	cTexto := cTexto + PADR(DTOS((cAlias)->EEQ_EMISSA),8)       
	cTexto := cTexto + PADR(STR((cAlias)->E1_VALOR,22,5),22)                              // VALOR DA COBRANCA EM USD
	cTexto := cTexto + PADR(SPACE(13),13)                        //VAZIO

	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// ID DO ITEM NA COBRANCA  -- V E R I F I C A R - Questionado a Sandra (AirBP)  em 17/10/16 - SD2->D2_ITEM INSERIDO NA QRY
	cTexto := cTexto + PADR("00"+(cAlias)->D2_ITEMPV+" ",10)                              // ID DO ITEM VERIFICAR COM EBILLING
	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	cTexto := cTexto + PADR(SPACE(12),12)                        //VAZIO            
	IF  (cAlFat)->E1_TIPO              == "NCC"
		cTexto := cTexto + PADR(cAerOrig +(cAlFat)->("/"+ E1_NUM+E1_TIPO),30)            // WNM 09/12/16
	ELSEIF alltrim((cAlFat)->E1_TIPO)  == "FT"
		cTexto := cTexto + PADR(cAerOrig +(cAlias)->("/"+ EEQ_PREEMB),30)            // WNM 09/12/16
	ELSE
		cTexto := cTexto + PADR(cAerOrig +(cAlias)->("/"+ EEQ_PREEMB),30)            // WNM 09/12/16
	ENDIF

	cTexto := cTexto + PADR(SPACE(15),15)                        //VAZIO
	cTexto := cTexto + PADR(cAerOrig,15) //WNM 09/12/16

	cProduto := " "
	IF "8601" $ (cAlias)->EE9_COD_I
		cProduto := "8601"
	ELSEIF "8604" $ (cAlias)->EE9_COD_I
		cProduto := "8604"
	ELSEIF "5000" $ (cAlias)->EE9_COD_I
		cProduto := "5000"
	ENDIF
	cTexto := cTexto + PADR(cProduto,15)             

	cTexto := cTexto + PADR(DTOS((cAlias)->EEQ_EMISSA),8)                  
	cTexto := cTexto + PADR(DTOS((cAlias)->EEQ_VCT),8)           // verificar condicoes de pagamento

	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// PERIODO DE CONTABILIZACAO  -- V E R I F I C A R - Questionado a Sandra (AirBP)  em 17/10/16
	cTexto := cTexto + PADR(alltrim(str(YEAR((cAlias)->C6_DATFAT)))+STRZERO(month((cAlias)->C6_DATFAT),3),7)                              
	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// VALOR DOS IMPOSTOS  -- V E R I F I C A R - Para cobrancas nacionais deve-se buscar os valores de impostos na nota  D2_VALICM
	cTexto := cTexto + PADl(str(((cAlias)->D2_VALICM),22,5),30)                              // valor dos impostos
	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	cTexto := cTexto + PADR(str(((cAlias)->EE9_SLDINI),22,5),23)
	cTexto := cTexto + PADR(" ",5)                              
	cTexto := cTexto + PADR("28",2)                             
	cTexto := cTexto + PADR((cAlias)->A1_NOME,71)               
	cTexto := cTexto + PADR(" ",9)                              
	cTexto := cTexto + PADR((cAlias)->A1_XSETOR,30)                             // SETOR DO CLIENTE - VERIFICAR TOTVS SE FOI CRIADA TABELA
	cTexto := cTexto + PADR(SPACE(20),20)                        //VAZIO 
	cTexto := cTexto + CRLF 

	Fwrite(nHandle, cTexto)

Return

/*/{Protheus.doc} fExecQry
//Query do IMI
@author WALNIR MANDU
@since 28/03/2016
/*/  
Static Function fExecQry(nQuery)

	IF nQuery == 1

		cAlias := GetNextAlias()

		cQuery := " SELECT DISTINCT EEQ.EEQ_IMPORT, EEQ.EEQ_IMLOJA, EEQ.EEQ_VCT   , SA1.A1_XGREF  , EEQ.EEQ_FFC   , EEQ.EEQ_PREEMB, EEQ.EEQ_MOEDA, "
		cQuery += "                 EEQ.EEQ_VL    , EE9.EE9_PEDIDO, EE9.EE9_NF    , EE7.EE7_XNUMCE, EE7.EE7_PEDIDO, EE7.EE7_DIASPA, EE7.EE7_XPREFI,"
		cQuery += "                 EE7_XDTEMI    , EE9.EE9_SLDINI, EE7.EE7_XTIPAE, EE7.EE7_XNUMVO, EEQ.EEQ_EMISSA, EE9.EE9_COD_I , SA1.A1_NOME    " 
		cQuery += " FROM "+ RetSqlName("EEQ") + " EEQ, "+ RetSqlName("EE9") + " EE9, "+ RetSqlName("EE7") + " EE7, " + RetSqlName("SA1") + " SA1 "
		cQuery += " WHERE EEQ.EEQ_FFC <> '       '  AND EE9.EE9_PREEMB = EEQ.EEQ_PREEMB AND EE7.EE7_PEDIDO = EE9.EE9_PEDIDO AND " 
		cQuery += "       SA1.A1_COD     = EEQ.EEQ_IMPORT           AND "
		cQuery += "       SA1.A1_LOJA    = EEQ.EEQ_IMLOJA           AND "
		cQuery += "       EEQ.EEQ_FILIAL = '" + xFilial("EEQ") + "' AND " 
		cQuery += "       SA1.A1_FILIAL  = '" + xFilial("SA1") + "' AND "
		cQuery += "       EE7.EE7_FILIAL = '" + xFilial("EE7") + "' AND " 
		cQuery += "       EE9.EE9_FILIAL = '" + xFilial("EE9") + "' AND " 
		cQuery += "       EEQ.D_E_L_E_T_  <> '*' "             + "  AND "
		cQuery += "       SA1.D_E_L_E_T_  <> '*' "             + "  AND "
		cQuery += "       EE7.D_E_L_E_T_  <> '*' "             + "  AND "
		cQuery += "       EE9.D_E_L_E_T_  <> '*' "             + "      "
		cQuery += " ORDER BY EEQ.EEQ_FFC                                "
		cQuery := ChangeQuery(cQuery) 
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)
		TcSetField(cAlias, "EEQ_VCT"   ,"D")    
		TcSetField(cAlias, "EE7_XDTEMI","D")    
		TcSetField(cAlias, "EEQ_EMISSA","D")    
		TcSetField(cAlias, "EEQ_VL"	    ,"N",TamSx3("EEQ_VL"	)[1],TamSx3("EEQ_VL"	)[2])   
		TcSetField(cAlias, "EE9_SLDINI" ,"N",TamSx3("EE9_SLDINI")[1],TamSx3("EE9_SLDINI")[2])    

		cFlagXImi := .F.

	ELSEIF nQuery == 2   

		cAlFat := GetNextAlias()

		cQuery := " SELECT DISTINCT SE1.E1_CLIENTE, SE1.E1_LOJA    , SE1.E1_VENCREA, SA1.A1_XGREF  , SE1.E1_FATURA, SE1.E1_NUM, 	SE1.E1_MOEDA, "
		cQuery += "                 SE1.E1_VALOR  , SA1.A1_DIASPAG , SE1.E1_TIPO   , SE1.E1_FATURA , SE1.E1_SALDO , SE1.E1_FILORIG, SA1.A1_NOME,  "
		cQuery += "                 SE1.E1_SERIE  , SE1.E1_EMISSAO , SA1.A1_XGREF  , SE1.E1_TXMOEDA, SA1.A1_XSETOR, SE1.E1_XIMI, 	SE1.E1_XIMIDT,"
		cQuery += "SE1.R_E_C_N_O_ AS E1RECNO  "
		cQuery += " FROM "+ RetSqlName("SE1") + " SE1, "+ RetSqlName("SA1") + " SA1 "
		cQuery += " WHERE ((SE1.E1_FATURA  = 'NOTFAT' AND SE1.E1_TIPO = 'FT') OR (SE1.E1_TIPO = 'NCC')) AND "
		cQuery += "       SE1.E1_SALDO  <> 0                        AND "
		cQuery += "       SE1.E1_XIMI	<> 'S'                      AND "
//		cQuery += " 	  SA1.A1_XCOBINT = 'S'                      AND "	/// 08/12/2017 - RAFAEL FALCO - FILTRO DE COBRANÇA INTERNACIONAL COMENTADO PARA CONSIDERAR TODOS TIPOS DE COBRANÇA
		cQuery += "       SA1.A1_COD     = SE1.E1_CLIENTE           AND "
		cQuery += "       SA1.A1_LOJA    = SE1.E1_LOJA              AND "
		cQuery += "       SE1.D_E_L_E_T_  <> '*' "             + "  AND "
		cQuery += "       SA1.D_E_L_E_T_  <> '*' "             + "      "
		cQuery += " ORDER BY SE1.E1_FATURA                              "
		cQuery := ChangeQuery(cQuery) 
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlFat,.F.,.T.)
		TcSetField(cAlFat, "E1_VENCREA" ,"D")    
		TcSetField(cAlFat, "E1_EMISSAO" ,"D")    
		TcSetField(cAlFat, "E1_VALOR"	,"N",TamSx3("E1_VALOR"	)[1],TamSx3("E1_VALOR"	)[2])   
		TcSetField(cAlFat, "E1_SALDO"	,"N",TamSx3("E1_SALDO"	)[1],TamSx3("E1_SALDO"	)[2])   
		TcSetField(cAlFat, "E1_TXMOEDA"	,"N",TamSx3("E1_TXMOEDA")[1],TamSx3("E1_TXMOEDA")[2])

	ELSEIF nQuery == 3

		cAlias := GetNextAlias()

		cQuery := " SELECT DISTINCT SE1.E1_CLIENTE, SE1.E1_LOJA    , SE1.E1_VENCREA , SA1.A1_XGREF  , SE1.E1_FATURA, SE1.E1_NUM   , SE1.E1_MOEDA  , "
		cQuery += "                 SE1.E1_VALOR  , SA1.A1_DIASPAG , SE1.E1_TIPO    , SE1.E1_FATURA , SE1.E1_SALDO , SE1.E1_PEDIDO, SE1.E1_FILORIG, "
		cQuery += "                 SA1.A1_NOME   , SC6.C6_PRODUTO , SC5.C5_TXMOEDA , SA1.A1_XSETOR , SC6.C6_ITEM  , SD2.D2_ITEMPV, SC6.C6_DATFAT , "
		cQuery += "                 SD2.D2_VALICM , SC5.C5_NUM     , SE1.E1_SERIE   , "
		cQuery += "                 SE1.E1_CLIENTE AS EEQ_IMPORT ,"
		cQuery += "                 SE1.E1_LOJA    AS EEQ_IMLOJA ,"
		cQuery += "                 SE1.E1_VENCREA AS EEQ_VCT    ,"
		cQuery += "                 SE1.E1_FATURA  AS EEQ_FFC    ,"
		cQuery += "                 SE1.E1_FATURA  AS EEQ_PREEMB ,"
		cQuery += "                 SE1.E1_MOEDA   AS EEQ_MOEDA  ,"
		cQuery += "                 SC5.C5_XNUMCE  AS EE7_XNUMCE ,"
		cQuery += "                 SC5.C5_XPREFIX AS EE7_XPREFI ,"
		cQuery += "                 SC5.C5_XDTEMIS AS EE7_XDTEMI ,"
		cQuery += "                 SC5.C5_FILIAL  AS SC5_FILIAL ,"
		cQuery += "                 SC6.C6_QTDVEN  AS EE9_SLDINI ,"
		cQuery += "                 SC6.C6_PRODUTO AS EE9_COD_I  ,"
		cQuery += "                 SC5.C5_XTIPAER AS EE7_XTIPAE ,"
		cQuery += "                 SC5.C5_XNUMVOO AS EE7_XNUMVO ,"
		cQuery += "                 SC5.C5_XCODAER AS EE7_XCODAE ,"   
		cQuery += "                 SE1.E1_EMISSAO AS EEQ_EMISSA, "
		cQuery += "                 SE1.E1_XIMI    AS E1_XIMI ,	  "   
		cQuery += "                 SE1.E1_XIMIDT  AS E1_XIMIDT,  "
		cQuery += "					SE1.R_E_C_N_O_ AS E1RECNO  	  "
		cQuery += " FROM "+ RetSqlName("SE1") + " SE1, "+ RetSqlName("SA1") + " SA1, "+ RetSqlName("SC6") + " SC6, "+ RetSqlName("SC5") + " SC5, "+ RetSqlName("SD2") + " SD2 
		cQuery += " WHERE SE1.E1_FATURA = '"+(cAlFat)->E1_NUM+"'      AND "     
		cQuery += "       SE1.E1_XIMI	 <> 'S'                       AND "
		cQuery += "       SA1.A1_COD     = SE1.E1_CLIENTE             AND "
		cQuery += "       SA1.A1_LOJA    = SE1.E1_LOJA                AND "
		cQuery += "       SC5.C5_NUM     = SE1.E1_PEDIDO              AND "
		cQuery += "       SC6.C6_NUM     = SE1.E1_PEDIDO              AND "
		cQuery += "       SD2.D2_PEDIDO  = SE1.E1_PEDIDO              AND "
		cQuery += "       SD2.D2_ITEMPV  = SC6.C6_ITEM                AND "
		cQuery += "       SC5.C5_XNUMCE  <> ''                        AND "   // Julio Négri 22/08/17 trazer só vendas que tenham CE 
		cQuery += "       SC5.C5_FILIAL  = SE1.E1_FILORIG             AND " 
		cQuery += "       SC6.C6_FILIAL  = SE1.E1_FILORIG             AND " 
		cQuery += "       SD2.D2_FILIAL  = SE1.E1_FILORIG             AND " 
		cQuery += "       SC5.D_E_L_E_T_  <> '*' "               + "  AND "
		cQuery += "       SC6.D_E_L_E_T_  <> '*' "               + "  AND "
		cQuery += "       SE1.D_E_L_E_T_  <> '*' "               + "  AND "
		cQuery += "       SD2.D_E_L_E_T_  <> '*' "               + "  AND "
		cQuery += "       SA1.D_E_L_E_T_  <> '*' "               + "      "
		cQuery += " ORDER BY SE1.E1_NUM                                   "
		cQuery := ChangeQuery(cQuery) 
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)
		TcSetField(cAlias, "E1_VENCREA" ,"D")     
		TcSetField(cAlias, "EE7_XDTEMI" ,"D")     
		TcSetField(cAlias, "EEQ_EMISSA" ,"D")            
		TcSetField(cAlias, "EEQ_VCT"    ,"D")            
		TcSetField(cAlias, "C6_DATFAT"  ,"D")            
		TcSetField(cAlias, "D2_VALICM"	,"N",TamSx3("D2_VALICM"	)[1],TamSx3("D2_VALICM"	)[2])   
		TcSetField(cAlias, "E1_VALOR"	,"N",TamSx3("E1_VALOR"	)[1],TamSx3("E1_VALOR"	)[2])   
		TcSetField(cAlias, "E1_SALDO"	,"N",TamSx3("E1_SALDO"	)[1],TamSx3("E1_SALDO"	)[2])   
		TcSetField(cAlias, "C5_TXMOEDA"	,"N",TamSx3("C5_TXMOEDA")[1],TamSx3("C5_TXMOEDA")[2])   
		TcSetField(cAlias, "EE9_SLDINI" ,"N",TamSx3("EE9_SLDINI")[1],TamSx3("EE9_SLDINI")[2])

	ELSEIF nQuery == 4   

		cAlias := GetNextAlias()

		cQuery := " SELECT DISTINCT SE1.E1_CLIENTE, SE1.E1_LOJA    , SE1.E1_VENCREA , SA1.A1_XGREF  , SE1.E1_FATURA, SE1.E1_NUM   , SE1.E1_MOEDA  , "
		cQuery += "                 SE1.E1_VALOR  , SA1.A1_DIASPAG , SE1.E1_TIPO    , SE1.E1_FATURA , SE1.E1_SALDO , SE1.E1_PEDIDO, SE1.E1_FILORIG, "
		cQuery += "                 SA1.A1_NOME   , SC6.C6_PRODUTO , SC5.C5_TXMOEDA , SA1.A1_XSETOR , SC6.C6_ITEM  , SD2.D2_ITEMPV, SC6.C6_DATFAT , "
		cQuery += "                 SD2.D2_VALICM , SC5.C5_NUM     , SE1.E1_SERIE   , "
		cQuery += "                 SE1.E1_CLIENTE AS EEQ_IMPORT ,"
		cQuery += "                 SE1.E1_LOJA    AS EEQ_IMLOJA ,"
		cQuery += "                 SE1.E1_VENCREA AS EEQ_VCT    ,"
		cQuery += "                 SE1.E1_FATURA  AS EEQ_FFC    ,"
		cQuery += "                 SE1.E1_FATURA  AS EEQ_PREEMB ,"
		cQuery += "                 SE1.E1_MOEDA   AS EEQ_MOEDA  ,"
		cQuery += "                 SC5.C5_XNUMCE  AS EE7_XNUMCE ,"
		cQuery += "                 SC5.C5_XPREFIX AS EE7_XPREFI ,"
		cQuery += "                 SC5.C5_XDTEMIS AS EE7_XDTEMI ,"
		cQuery += "                 SC5.C5_FILIAL  AS SC5_FILIAL ,"
		cQuery += "                 SC6.C6_QTDVEN  AS EE9_SLDINI ,"
		cQuery += "                 SC6.C6_PRODUTO AS EE9_COD_I  ,"
		cQuery += "                 SC5.C5_XTIPAER AS EE7_XTIPAE ,"
		cQuery += "                 SC5.C5_XNUMVOO AS EE7_XNUMVO ,"
		cQuery += "                 SC5.C5_XCODAER AS EE7_XCODAE ,"
		cQuery += "                 SE1.E1_EMISSAO AS EEQ_EMISSA ,"
		cQuery += "                 SE1.E1_XIMI AS E1_XIMI ,	  "
		cQuery += "                 SE1.E1_XIMIDT AS E1_XIMIDT,   "
		cQuery += "					SE1.R_E_C_N_O_ AS E1RECNO  	  "
		cQuery += " FROM "+ RetSqlName("SE1") + " SE1, "+ RetSqlName("SA1") + " SA1, "+ RetSqlName("SC6") + " SC6, "+ RetSqlName("SC5") + " SC5, "+ RetSqlName("SD2") + " SD2 "     
		cQuery += "WHERE  SE1.E1_NUM     = '"+SD1->D1_NFORI+"'        AND "
		cQuery += "       SE1.E1_XIMI	 <> 'S'                       AND "
		cQuery += "       SC5.C5_XNUMCE  <> ''                        AND "   // Julio Négri 16/08/17 trazer só vendas que tenham CE
		cQuery += "       SA1.A1_COD     = SE1.E1_CLIENTE             AND "
		cQuery += "       SA1.A1_LOJA    = SE1.E1_LOJA                AND "
		cQuery += "       SD2.D2_DOC     = '"+SD1->D1_NFORI+"'        AND "
		cQuery += "       SD2.D2_SERIE   = '"+SD1->D1_SERIORI+"'      AND "
		cQuery += "       SD2.D2_ITEMPV  = '"+SD1->D1_ITEMORI+"'      AND "
		cQuery += "       SC5.C5_NUM     = SE1.E1_PEDIDO              AND "
		cQuery += "       SC6.C6_NUM     = SE1.E1_PEDIDO              AND "
		cQuery += "       SD2.D2_PEDIDO  = SE1.E1_PEDIDO              AND "
		cQuery += "       SD2.D2_ITEMPV  = SC6.C6_ITEM                AND " 
		cQuery += "       SC5.C5_FILIAL  = SE1.E1_FILORIG             AND " 
		cQuery += "       SC6.C6_FILIAL  = SE1.E1_FILORIG             AND " 
		cQuery += "       SD2.D2_FILIAL  = SE1.E1_FILORIG             AND " 
		cQuery += "       SC5.D_E_L_E_T_  <> '*' "               + "  AND "
		cQuery += "       SC6.D_E_L_E_T_  <> '*' "               + "  AND "
		cQuery += "       SE1.D_E_L_E_T_  <> '*' "               + "  AND "
		cQuery += "       SD2.D_E_L_E_T_  <> '*' "               + "  AND "
		cQuery += "       SA1.D_E_L_E_T_  <> '*' "               + "      "
		cQuery += " ORDER BY SE1.E1_NUM                                   "
		cQuery := ChangeQuery(cQuery) 
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)
		TcSetField(cAlias, "E1_VENCREA" ,"D")
		TcSetField(cAlias, "EE7_XDTEMI" ,"D")
		TcSetField(cAlias, "EEQ_EMISSA" ,"D")
		TcSetField(cAlias, "EEQ_VCT"    ,"D")
		TcSetField(cAlias, "C6_DATFAT"  ,"D")
		TcSetField(cAlias, "D2_VALICM"	,"N",TamSx3("D2_VALICM"	)[1],TamSx3("D2_VALICM"	)[2])
		TcSetField(cAlias, "E1_VALOR"	,"N",TamSx3("E1_VALOR"	)[1],TamSx3("E1_VALOR"	)[2])
		TcSetField(cAlias, "E1_SALDO"	,"N",TamSx3("E1_SALDO"	)[1],TamSx3("E1_SALDO"	)[2])
		TcSetField(cAlias, "C5_TXMOEDA"	,"N",TamSx3("C5_TXMOEDA")[1],TamSx3("C5_TXMOEDA")[2])
		TcSetField(cAlias, "EE9_SLDINI" ,"N",TamSx3("EE9_SLDINI")[1],TamSx3("EE9_SLDINI")[2])
	ENDIF	
Return  

/*/{Protheus.doc} fAbastec
//Itens do abastecimento com NF
@author WALNR MANDU
@since 28/03/2016
/*/ 
Static Function fCredit(nHandle) 
	Local cLinha := ""    
	Local cFilCrd   := ""                             
	Local nPos      := 0

	nPos    := aScan(aFls, {|x| x[3] == (cAlFat)->E1_FILORIG })
	cFilCrd := AFls[nPos][1]

	cTexto := ""

	cTexto := cTexto + PADR(" ",30)            
	cTexto := cTexto + PADR(DTOS((cAlFat)->E1_EMISSAO),8)       
	cTexto := cTexto + PADR(" ",23)  
	cTexto := cTexto + PADL("1",7)                              
	cTexto := cTexto + PADR(" ",7)             
	cTexto := cTexto + PADR(" AIR",9)                           
	cTexto := cTexto + PADR(SPACE(06),6)                         // VAZIO
	cTexto := cTexto + PADL((cAlFat)->A1_XGREF,15)               // --> GLOBAL REFERENCE NUMER - VERIFICAR
	cTexto := cTexto + PADR(SPACE(15),15)                        // VAZIO
	cTexto := cTexto + PADR(SPACE(15),15)                        // VAZIO
	cTexto := cTexto + PADR(SPACE(13),13)                        // VAZIO

	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// NOTA DE CREDITO E DEBITO -- V E R I F I C A R - Falta fechar conceito para nota de credito e debito - JULIO NEGRI em 17/10/16
	cTexto := cTexto + PADR("  N",3)                               // NOTA DE CREDITO OU DEBITO
	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	cTexto := cTexto + PADL("BRL",11)                           
	cTexto := cTexto + PADL(IIF((cAlFat)->E1_MOEDA==1,"BRL","USD"),8)   
	cTexto := cTexto + PADL(IIF((cAlFat)->E1_MOEDA==1,"BRL","USD"),8)
	cTexto := cTexto + PADL("USD",8)                            
	cTexto := cTexto + PADR(SPACE(05),5)                         //VAZIO
	cTexto := cTexto + PADR((cAlFat)->A1_XGREF,14)               // --> GLOBAL REFERENCE NUMER - VERIFICAR

	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// CARTAO STERLING -- V E R I F I C A R - Questionado a Sandra (AirBP)  em 17/10/16 - [Sandra Helena De Souza] Pode ser deixado em branco. Não registramos esta informação hoje.
	cTexto := cTexto + PADR(" ",31)                              // --> CARTAO STERLING
	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	cTexto := cTexto + PADR(" ",15)
	IF (cAlFat)->E1_MOEDA == 1
		cTexto := cTexto + PADR(STR(1,21,15)+"0000000",21)
		cTexto := cTexto + "    " + ALLTRIM(PADR(STR(1,21,15)+"0000000",21))
		cTexto := cTexto + "    " + ALLTRIM(PADR(STR(1,21,15)+"0000000",21))
	ELSE
		// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		// TAXA DOLAR - FORMATO -- V E R I F I C A R - Questionado a Sandra (AirBP)  em 17/10/16  - [Sandra Helena De Souza] A taxa informada no IMI indica quantos dólares consigo comprar com 1 real. 
		cTexto := cTexto + PADR(STR((1/(cAlFat)->E1_TXMOEDA),21,15)+"0000000",21)
		cTexto := cTexto + "    " + ALLTRIM(PADR(STR((1/(cAlFat)->E1_TXMOEDA),21,15)+"0000000",21))
		cTexto := cTexto + "    " + ALLTRIM(PADR(STR((1/(cAlFat)->E1_TXMOEDA),21,15)+"0000000",21))
		// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	ENDIF
	cTexto := cTexto + SPACE(3)                             
	cTexto := cTexto + PADR(" ",7)             
	IF (cAlFat)->E1_MOEDA == 1
		cTexto := cTexto + PADR("I",8)                              
	ELSE
		cTexto := cTexto + PADR("E",8)                              
	ENDIF

	cTexto := cTexto + PADR(cFilCrd+"01",15)       // WNM 09/12/16

	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// TIPO DE TRANSACAO - VER ORIGEM -- V E R I F I C A R - Tipo de transacao depende da definicao do nota de credito e/ou debito
	IF  (cAlFat)->E1_TIPO              == "NCC"
		cTexto := cTexto + PADL("21",8)                             // TIPO DE TRANSACAO - SANDRA FICOU DE VERIFICAR
	ELSEIF alltrim((cAlFat)->E1_TIPO)  == "FT"
		cTexto := cTexto + PADL("1",8)                              // TIPO DE TRANSACAO - SANDRA FICOU DE VERIFICAR
	ELSE
		cTexto := cTexto + PADL(" ",8)                              // TIPO DE TRANSACAO - SANDRA FICOU DE VERIFICAR
	ENDIF
	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	cTexto := cTexto + PADR(DTOS((cAlFat)->E1_EMISSAO),8)
	cTexto := cTexto + PADR(STR((cAlFat)->E1_VALOR,22,5),22)                              // VALOR DA COBRANCA EM USD
	cTexto := cTexto + PADR(SPACE(13),13)                        //VAZIO

	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// ID DO ITEM NA COBRANCA  -- V E R I F I C A R - Questionado a Sandra (AirBP)  em 17/10/16 - SD2->D2_ITEM INSERIDO NA QRY
	cTexto := cTexto + PADR(" ",10)                              // ID DO ITEM VERIFICAR COM EBILLING
	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	cTexto := cTexto + PADR(SPACE(12),12)                        //VAZIO
	cTexto := cTexto + PADR(cFilCrd+"/"+(cAlFat)->(E1_NUM+E1_TIPO),30)               // WNM 09/12/16
	cTexto := cTexto + PADR(SPACE(15),15)                        //VAZIO
	cTexto := cTexto + PADR(cFilCrd,15) //WNM 09/12/16

	cProduto := " "

	cTexto := cTexto + PADR(" ",15)             
	cTexto := cTexto + PADR(DTOS((cAlFat)->E1_EMISSAO),8)                  
	cTexto := cTexto + PADR(DTOS((cAlFat)->E1_VENCREA),8)           // verificar condicoes de pagamento

	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// PERIODO DE CONTABILIZACAO  -- V E R I F I C A R - Questionado a Sandra (AirBP)  em 17/10/16
	cTexto := cTexto + PADR(alltrim(str(YEAR((cAlFat)->E1_EMISSAO)))+STRZERO(month((cAlFat)->E1_EMISSAO),3),7)                              
	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// VALOR DOS IMPOSTOS  -- V E R I F I C A R - Para cobrancas nacionais deve-se buscar os valores de impostos na nota  D2_VALICM
	cTexto := cTexto + PADl(" ",30)                              // valor dos impostos
	// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	cTexto := cTexto + PADR(" ",23)
	cTexto := cTexto + PADR(" ",5)                              
	cTexto := cTexto + PADR("28",2)                             
	cTexto := cTexto + PADR((cAlFat)->A1_NOME,71)               
	cTexto := cTexto + PADR(" ",9)                              
	cTexto := cTexto + PADR((cAlFat)->A1_XSETOR,30)                             // SETOR DO CLIENTE - VERIFICAR TOTVS SE FOI CRIADA TABELA
	cTexto := cTexto + PADR(SPACE(20),20)                        //VAZIO 
	cTexto := cTexto + CRLF 

	Fwrite(nHandle, cTexto)

Return