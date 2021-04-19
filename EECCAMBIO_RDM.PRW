#Include "Protheus.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EECCAMBIO ºAutor  ³WNM WALNIR NECHO MANDU º Data ³25/05/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RE´s com saldo - baixadas no exterior e liberadas para     º±±
±±º          ³                  nacionalizacao - cambio                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Air BP                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function EECCAMBIO()
	Local aCores := {{"TRB->EEQ_NROP #  SPACE(LEN(EEQ->EEQ_NROP)) ","BR_VERMELHO"},;
					 {"TRB->EEQ_NROP == SPACE(LEN(EEQ->EEQ_NROP)) ","BR_VERDE"   }}
	Local oMark

	Private cFileTRB
	Private cMarca     := GetMark()
	Private lInverte   := .F.
	Private _carq             
	Private cPerg      := "EECCAMBIO"
	Private cPerg2     := "EECRES"
	Private cCadastro  := "Controle de Cambio X REs"
	Private bOpc01     := {|| fSelImpress()}  // impressao verificar
	Private bOpc02     := {|| fLegenda()}     // legenda
	Private	nValRE     := 0

	aRotina   := {  { "Marcar Todos"    ,"U_MarTodos"  , 0, 4},;
					{ "Marcar Valor"    ,"U_MARCAR"    , 0, 4},;
					{ "Desmarcar Todos" ,"U_DESMAR"    , 0, 4},;
					{ "Util. RE Cambio" ,"U_MARKALL"   , 0, 4},;   
					{ "Imprimir Selec." ,"U_IMPRSEL"   , 0, 4},;   
					{ "Legenda"         ,"Eval(bOpc02)", 0,02}}

	IF !Pergunte(cPerg,.T.)  // Pergunta no SX1
		Return
	Endif

	aTela:={}
	AADD(aTela,{"OK"         ,""," "                  ,                     })
	AADD(aTela,{"EEQ_PREEMB" ,"",AVSX3("EEQ_PREEMB",5),                     })
	AADD(aTela,{"EEQ_FILIAL" ,"",AVSX3("EEQ_FILIAL",5),                     })

	AADD(aTela,{"EEQ_IMPORT" ,"",AVSX3("EEQ_IMPORT",5),                     })
	AADD(aTela,{"EEQ_IMLOJA" ,"",AVSX3("EEQ_IMLOJA",5),                     })
	AADD(aTela,{"EEQ_DESIMP" ,"",AVSX3("EEQ_DESIMP",5),                     })

	AADD(aTela,{"EEQ_MOEDA"  ,"",AVSX3("EEQ_MOEDA" ,5),                     })
	AADD(aTela,{"EEQ_VL"     ,"",AVSX3("EEQ_VL"    ,5),AVSX3("EEQ_VL"    ,6)})

	AADD(aTela,{"EEC_NRODUE" ,"",AVSX3("EEC_NRODUE",5),AVSX3("EEC_NRODUE",6)})  // WNM 30/08/18
	AADD(aTela,{"EEC_DTDUE"  ,"",AVSX3("EEC_DTDUE" ,5),                     })  // WNM 30/08/18
	AADD(aTela,{"EEC_CHVDUE" ,"",AVSX3("EEC_CHVDUE",5),                     })  // WNM 01/04/19
	AADD(aTela,{"EEC_DUEAVR" ,"",AVSX3("EEC_DUEAVR",5),                     })  // WNM 01/04/19

	AADD(aTela,{"EE9_RE"     ,"",AVSX3("EE9_RE"    ,5),AVSX3("EE9_RE"    ,6)})
	AADD(aTela,{"EE9_DTRE"   ,"",AVSX3("EE9_DTRE"  ,5),                     })
	AADD(aTela,{"EE9_NRSD"   ,"",AVSX3("EE9_NRSD"  ,5),AVSX3("EE9_NRSD"  ,6)})
	AADD(aTela,{"EE9_DTAVRB" ,"",AVSX3("EE9_DTAVRB",5),                     })
	AADD(aTela,{"EE9_NF"     ,"",AVSX3("EE9_NF"    ,5),                     })


	AADD(aTela,{"EEQ_NRINVO" ,"",AVSX3("EEQ_NRINVO",5),                     })

	AADD(aTela,{"EEQ_VCT"    ,"",AVSX3("EEQ_VCT"   ,5),                     })
	AADD(aTela,{"EEQ_DTCE"   ,"",AVSX3("EEQ_DTCE"  ,5),                     })
	AADD(aTela,{"EEQ_NROP"   ,"",AVSX3("EEQ_NROP"  ,5),                     })
	AADD(aTela,{"EEQ_FORN"   ,"",AVSX3("EEQ_FORN"  ,5),                     })
	AADD(aTela,{"EEQ_FOLOJA" ,"",AVSX3("EEQ_FOLOJA",5),                     })
	AADD(aTela,{"EEQ_BCOEXT" ,"",AVSX3("EEQ_BCOEXT",5),                     })
	AADD(aTela,{"EEQ_AGCEXT" ,"",AVSX3("EEQ_AGCEXT",5),                     })
	AADD(aTela,{"EEQ_CNTEXT" ,"",AVSX3("EEQ_CNTEXT",5),                     })

	CriaTRB() // Cria o Arquivo Temporario.

	Processa ({|| AtualizaTRB() })

	DBSelectArea('TRB')

	TRB->(Markbrow("TRB","OK"     ,,aTela   ,, cMarca,'u_MarkAll()',,,,'u_Mark()',,,,aCores,,,,.F.))

	TRB->(DBCloseArea())
	MsErase(_carq+GetDBExtension(),,"DBFCDX") 
Return

User Function AvalImp()
	Local lReturn := .F.
	IF TRB->IMPRESS == "N"
		lReturn := .T.
	Endif
Return(lReturn)

Static Function CriaTRB()
	Local aCampos := {}

	AADD(aCampos,{"OK"          ,"C"                  ,02                   ,0                    })
	AADD(aCampos,{"RECEEQ"      ,"N"                  ,09                   ,0                    })

	AADD(aCampos,{"EEQ_PREEMB"  ,AVSX3("EEQ_PREEMB",2),AVSX3("EEQ_PREEMB",3),AVSX3("EEQ_PREEMB",4)})
	AADD(aCampos,{"EEQ_FILIAL"  ,AVSX3("EEQ_FILIAL",2),AVSX3("EEQ_FILIAL",3),AVSX3("EEQ_FILIAL",4)})
	AADD(aCampos,{"EEQ_NRINVO"  ,AVSX3("EEQ_NRINVO",2),AVSX3("EEQ_NRINVO",3),AVSX3("EEQ_NRINVO",4)})


	AADD(aCampos,{"EEC_NRODUE"  ,AVSX3("EEC_NRODUE",2),AVSX3("EEC_NRODUE",3),AVSX3("EEC_NRODUE",4)}) // WNM 30/08/18
	AADD(aCampos,{"EEC_CHVDUE"  ,AVSX3("EEC_CHVDUE",2),AVSX3("EEC_CHVDUE",3),AVSX3("EEC_CHVDUE",4)}) // WNM 01/04/19
	AADD(aCampos,{"EEC_DTDUE"   ,AVSX3("EEC_DTDUE",2) ,AVSX3("EEC_DTDUE",3) ,AVSX3("EEC_DTDUE" ,4)}) // WNM 30/08/18
	AADD(aCampos,{"EEC_DUEAVR"  ,AVSX3("EEC_DUEAVR",2),AVSX3("EEC_DUEAVR",3),AVSX3("EEC_DUEAVR",4)}) // WNM 01/04/19

	AADD(aCampos,{"EE9_RE"      ,AVSX3("EE9_RE",2)    ,AVSX3("EE9_RE",3)    ,AVSX3("EE9_RE",4)    })
	AADD(aCampos,{"EE9_DTRE"    ,AVSX3("EE9_DTRE",2)  ,AVSX3("EE9_DTRE",3)  ,AVSX3("EE9_DTRE",4)  })
	AADD(aCampos,{"EE9_NRSD"    ,AVSX3("EE9_NRSD",2)  ,AVSX3("EE9_NRSD",3)  ,AVSX3("EE9_NRSD",4)  })
	AADD(aCampos,{"EE9_DTAVRB"  ,AVSX3("EE9_DTAVRB",2),AVSX3("EE9_DTAVRB",3),AVSX3("EE9_DTAVRB",4)})
	AADD(aCampos,{"EE9_NF"      ,AVSX3("EE9_NF",2)    ,AVSX3("EE9_NF",3)    ,AVSX3("EE9_NF",4)    })
	AADD(aCampos,{"EEQ_VCT"     ,AVSX3("EEQ_VCT",2)   ,AVSX3("EEQ_VCT",3)   ,AVSX3("EEQ_VCT",4)   })
	AADD(aCampos,{"EEQ_MOEDA"   ,AVSX3("EEQ_MOEDA",2) ,AVSX3("EEQ_MOEDA",3) ,AVSX3("EEQ_MOEDA",4) })
	AADD(aCampos,{"EEQ_VL"      ,AVSX3("EEQ_VL",2)    ,AVSX3("EEQ_VL",3)    ,AVSX3("EEQ_VL",4)    })
	AADD(aCampos,{"EEQ_DTCE"    ,AVSX3("EEQ_DTCE",2)  ,AVSX3("EEQ_DTCE",3)  ,AVSX3("EEQ_DTCE",4)  })
	AADD(aCampos,{"EEQ_NROP"    ,AVSX3("EEQ_NROP",2)  ,AVSX3("EEQ_NROP",3)  ,AVSX3("EEQ_NROP",4)  })
	AADD(aCampos,{"EEQ_FORN"    ,AVSX3("EEQ_FORN",2)  ,AVSX3("EEQ_FORN",3)  ,AVSX3("EEQ_FORN",4)  })
	AADD(aCampos,{"EEQ_FOLOJA"  ,AVSX3("EEQ_FOLOJA",2),AVSX3("EEQ_FOLOJA",3),AVSX3("EEQ_FOLOJA",4)})
	AADD(aCampos,{"EEQ_IMPORT"  ,AVSX3("EEQ_IMPORT",2),AVSX3("EEQ_IMPORT",3),AVSX3("EEQ_IMPORT",4)})
	AADD(aCampos,{"EEQ_IMLOJA"  ,AVSX3("EEQ_IMLOJA",2),AVSX3("EEQ_IMLOJA",3),AVSX3("EEQ_IMLOJA",4)})
	AADD(aCampos,{"EEQ_DESIMP"  ,AVSX3("EEQ_DESIMP",2),AVSX3("EEQ_DESIMP",3),AVSX3("EEQ_DESIMP",4)})
	AADD(aCampos,{"EEQ_BCOEXT"  ,AVSX3("EEQ_BCOEXT",2),AVSX3("EEQ_BCOEXT",3),AVSX3("EEQ_BCOEXT",4)})
	AADD(aCampos,{"EEQ_AGCEXT"  ,AVSX3("EEQ_AGCEXT",2),AVSX3("EEQ_AGCEXT",3),AVSX3("EEQ_AGCEXT",4)})
	AADD(aCampos,{"EEQ_CNTEXT"  ,AVSX3("EEQ_CNTEXT",2),AVSX3("EEQ_CNTEXT",3),AVSX3("EEQ_CNTEXT",4)})

	_carq:="T_"+Criatrab(,.F.)
	MsCreate(_carq,aCampos,"DBFCDX")
	Sleep(1000)// atribui a tabela temporária ao alias TRB
	dbUseArea(.T.,"DBFCDX",_cARq,"TRB",.T.,.F.)

	//Cria o Indice
	IndRegua("TRB",_cARq,"EEQ_PREEMB+EEQ_FILIAL+EEC_NRODUE+EE9_RE",,) // WNM 30/08/18

Return

Static Function AtualizaTRB()
	Local cQry        := ""
	Local cSelect     := ""
	Local cWhere2     := "" 
	Local cOrder      := ""
	Local cWhere      := ""    
	Local cFil        := "", i
	Local cUnion      := ""                     
	Private lMultiFil := VerSenha(115) .and. Posicione("SX2",1,"EEC","X2_MODO") == "E" //.and. Posicione("SX2",1,"EF1","X2_MODO") == "C"

	aSelFil:=AvgSelectFil(.T.,"EEC")             

	If lMulTiFil 
		For i:= 1 to len(aSelFil)
			cFil+="'"+aSelFil[i]+"'"
			If i < len(aSelFil)
				cFil+=","
			EndIf 
		Next
	EndIF       

	If EEQ->(FieldPos("EEQ_EVENT")) > 0
		lEvento := .T.
	Else
		lEvento := .F.
	EndIf  

	Begin Sequence

		IF Empty(cQry)
			cQry := "SELECT DISTINCT "+if(lMultiFil," EEC.EEC_FILIAL, ","")+" ' ' AS OK     , EEC.EEC_PREEMB, EEC.EEC_DTPROC, EEQ.EEQ_IMPORT          , EEQ.EEQ_IMLOJA, EEQ.EEQ_FORN   , EEQ.EEQ_FOLOJA                  ,"
			cQry +=                                                         " EEQ.EEQ_MOEDA , EEC.EEC_DTEMBA, EEC.EEC_ETD   , EEQ.EEQ_EVENT           , EEQ.EEQ_VCT   , EEQ.EEQ_PGT    , EEQ.EEQ_CNTEXT                  ,"
			cQry +=                                                         " EEQ.EEQ_VL    , EEQ.EEQ_TX    , EEQ.EEQ_BANC  , EEQ.EEQ_DTCE            , EEQ.EEQ_TP_CON, EEQ.EEQ_PREEMB , EE9.EE9_RE as RE                ,"
			cQry +=                                                         " EEQ.EEQ_NRINVO, EEQ.EEQ_NROP  , EEQ.EEQ_IMPORT, EEQ.EEQ_IMLOJA          , EEQ.EEQ_BCOEXT, EEQ.EEQ_AGCEXT , EE9.EE9_DTRE                    ,"
			cQry +=                                                         " EEQ.EEQ_MODAL , EE9.EE9_NF    , 'S' AS IMPRESS, EEQ.R_E_C_N_O_ AS RECEEQ, EEQ.EEQ_FILIAL, EE9.EE9_NRSD   , EE9.EE9_DTAVRB                  ," // WNM 30/08/18
			cQry +=                                                         " EEC.EEC_NRODUE, EEC.EEC_DTDUE , EEC.EEC_DUEAVR, EEC.EEC_CHVDUE                                                                                                              " // WNM 30/08/18
		Endif 
		cQry += " FROM "+RetSqlName("EEC")+" EEC, "+RetSqlName("EEQ")+" EEQ,"+RetSqlName("EE9")+" EE9 "

		cWhere := " WHERE EEC.D_E_L_E_T_ <> '*' AND " 
		cWhere += " EEC_DTEMBA BETWEEN '" + dtos(MV_PAR02) + "' AND '" + dtos(MV_PAR03) + "' AND "
		
		If !lMultiFil
			cWhere += " EEC_FILIAL = '" +xFilial("EEC")+ "' AND "
			cWhere += " EEC_DTEMBA <> '        ' AND EEQ_PREEMB = EEC_PREEMB AND EEQ.D_E_L_E_T_ <> '*' AND EEQ_FILIAL = '"+xFilial("EEQ")+"' AND"
// WNM 30/08/18			cWhere += " EEQ_PREEMB = EE9_PREEMB AND EE9.D_E_L_E_T_ <> '*' AND EE9_FILIAL = '"+xFilial("EE9")+"' AND EE9_RE <> '"+SPACE(LEN(EE9->EE9_RE))+"'"
			cWhere += " EEQ_PREEMB = EE9_PREEMB AND EE9.D_E_L_E_T_ <> '*' AND EE9_FILIAL = '"+xFilial("EE9")+"' AND (EE9_RE <> '"+SPACE(LEN(EE9->EE9_RE))+"' OR EEC_NRODUE <> '" + SPACE(LEN(EEC->EEC_NRODUE))+"')" //WNM 30/08/18
		Else
			cWhere += " EEC_FILIAL IN (" +cFil+ ")          AND "
			cWhere += " EEC_DTEMBA <> '        ' AND EEQ_PREEMB = EEC_PREEMB AND EEQ.D_E_L_E_T_ <> '*' AND EEQ_FILIAL IN (" +cFil+ ") " +"   AND" 
// WNM 30/08/18			cWhere += " EEQ_PREEMB = EE9_PREEMB AND EE9.D_E_L_E_T_ <> '*' AND EE9_RE <> '"+SPACE(LEN(EE9->EE9_RE))+"'"  // WNM 14/12/16
			cWhere += " EEQ_PREEMB = EE9_PREEMB AND EE9.D_E_L_E_T_ <> '*' AND (EE9_RE <> '"+SPACE(LEN(EE9->EE9_RE))+"' OR EEC_NRODUE <> '" + SPACE(LEN(EEC->EEC_NRODUE))+"')" //WNM 30/08/18
		EndIf                                                                

		cWhere := cWhere + " AND EEQ_TIPO = 'R' AND EE9_FILIAL = EEC_FILIAL AND EEQ_FILIAL = EEC_FILIAL "   // WNM 14/12/16

		If  MV_PAR01 == 1   // ja recebido no exterior // WNM 01/04/19                                                              // WNM 31/05/17
			cWhere2 := " AND EEQ_MODAL = '2' AND EEQ_DTCE <> '" + Space(len(DtoS(MV_PAR02)))+"'"
        Endif

		If  MV_PAR04 == 1                                                                  // WNM 31/05/17
// WNM 01/04/19			cWhere := cWhere + " AND EE9.EE9_NRSD <> '"+SPACE(LEN(EE9->EE9_NRSD))+"' "     // WNM 31/05/17
			cWhere := cWhere + " AND ( EE9.EE9_NRSD <> '"+SPACE(LEN(EE9->EE9_NRSD))+"' OR EEC.EEC_DUEAVR <> '"+SPACE(LEN(DTOS(EEC->EEC_DUEAVR)))+"'  ) "     // WNM 31/05/17
			
		ElseIf  MV_PAR04 == 2                                                              // WNM 31/05/17
// WNM 0104/19			cWhere := cWhere + " AND EE9.EE9_NRSD =  '"+SPACE(LEN(EE9->EE9_NRSD))+"' "     // WNM 31/05/17
			cWhere := cWhere + " AND ( EE9.EE9_NRSD = '"+SPACE(LEN(EE9->EE9_NRSD))+"' OR EEC.EEC_DUEAVR = '"+SPACE(LEN(DTOS(EEC->EEC_DUEAVR)))+"'  ) "     // WNM 31/05/17
		EndIf                                                                              // WNM 31/05/17

		If  MV_PAR05     == 1 // COM SALDO A NACIONALIZAR                                                             // WNM 31/05/17
			cWhere := cWhere + " AND EEQ.EEQ_NROP =  '"+SPACE(LEN(EEQ->EEQ_NROP))+"' "    // WNM 31/05/17
		ElseIf  MV_PAR05 == 2 // sem saldo a nacionalizar
			cWhere := cWhere + " AND EEQ.EEQ_NROP <> '"+SPACE(LEN(EEQ->EEQ_NROP))+"' "    // WNM 31/05/17
		EndIf                                                                             // WNM 31/05/17

		EEQ_NROP #  SPACE(LEN(EEQ->EEQ_NROP))

// INCLUSO NOVAMENTE 01/04/19 /* // WNM 09/10/18 RETIRADO A PEDIDO DE MICHELE  PARA QUE NÃO TENHA DE CONSIDERAR OS RECEBIMENTOS NO EXTERIOR
		If !Empty(MV_PAR02) .and. MV_PAR01 == 1
// WNM 01/04/19			cWhere2 := " AND EEQ_MODAL = '2' AND EEQ_DTCE >= '" + DtoS(MV_PAR02)+"'"
			cWhere2 := " AND EEQ_DTCE >= '" + DtoS(MV_PAR02)+"'"
		EndIf
		If !Empty(MV_PAR03) .and. MV_PAR01 == 1
// WNM 01/04/19			cWhere2 := cWhere2 + " AND EEQ_MODAL = '2' AND EEQ_DTCE <= '" + DtoS(MV_PAR03)+"'"         
			cWhere2 := cWhere2 + " AND EEQ_DTCE <= '" + DtoS(MV_PAR03)+"'"         
		EndIf                           

		If Empty(cWhere2)
			cWhere := cWhere //WNM 01/04/19 + " AND EEQ_MODAL = '2' AND EEQ_DTCE > '     ' "         
		Else
			cWhere := cWhere + cWhere2 
		Endif
		
// INCLUSO NOVAMENTE 01/04/19 */ // WNM 09/10/18 RETIRADO A PEDIDO DE MICHELE  PARA QUE NÃO TENHA DE CONSIDERAR OS RECEBIMENTOS NO EXTERIOR

		if !("COUNT"$upper(cQry) .or. "SUM"$upper(cQry)) //No caso de funçoes de agregações o Order by acusa erro
			cOrder := " ORDER BY "+if(lMultiFil," EEC_FILIAL , ","")+"EEC_PREEMB" 
		endif            

		cUnion := ""
	End Sequence
	// WNM FINAL HOJE QRY
	ProcRegua(50)

	cQuery := ChangeQuery(cQry + cWhere + cUnion + cOrder)

	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySZ2",.F.,.T.)

	TcSetField("QrySZ2","EE9_DTRE"  ,"D")
	TcSetField("QrySZ2","EE9_DTAVRB","D")
	TcSetField("QrySZ2","EEQ_VCT"   ,"D")
	TcSetField("QrySZ2","EEQ_DTCE"  ,"D")
	TcSetField("QrySZ2","EEC_DTDUE" ,"D") // WNM 30/08/18
	TcSetField("QrySZ2","EEC_DUEAVR","D") // WNM 30/08/18

	While QrySZ2->(!Eof())

		RecLock("TRB",.T.)
		TRB->OK          := ""                           
		TRB->RECEEQ      := QrySZ2->RECEEQ
		TRB->EEQ_PREEMB  := QrySZ2->EEQ_PREEMB
		TRB->EEQ_FILIAL  := QrySZ2->EEQ_FILIAL
		TRB->EEQ_NRINVO  := QrySZ2->EEQ_NRINVO 


		TRB->EEC_NRODUE  := QrySZ2->EEC_NRODUE  // WNM 30/08/18 
		TRB->EEC_DTDUE   := QrySZ2->EEC_DTDUE   // WNM 30/08/18
		TRB->EEC_CHVDUE  := QrySZ2->EEC_CHVDUE  // WNM 01/04/19
		TRB->EEC_DUEAVR  := QrySZ2->EEC_DUEAVR  // WNM 01/04/19


		TRB->EE9_RE      := QrySZ2->RE  
		TRB->EE9_DTRE    := QrySZ2->EE9_DTRE 
		TRB->EE9_NRSD    := QrySZ2->EE9_NRSD  
		TRB->EE9_DTAVRB  := QrySZ2->EE9_DTAVRB
		TRB->EE9_NF      := QrySZ2->EE9_NF
		TRB->EEQ_VCT     := QrySZ2->EEQ_VCT 
		TRB->EEQ_MOEDA   := QrySZ2->EEQ_MOEDA
		TRB->EEQ_VL      := QrySZ2->EEQ_VL
		TRB->EEQ_DTCE    := QrySZ2->EEQ_DTCE
		TRB->EEQ_NROP    := QrySZ2->EEQ_NROP
		TRB->EEQ_FORN    := QrySZ2->EEQ_FORN
		TRB->EEQ_FOLOJA  := QrySZ2->EEQ_FOLOJA
		TRB->EEQ_IMPORT  := QrySZ2->EEQ_IMPORT
		TRB->EEQ_IMLOJA  := QrySZ2->EEQ_IMLOJA
		TRB->EEQ_DESIMP  := POSICIONE("SA1",1,XFILIAL("SA1")+ QrySZ2->(EEQ_IMPORT+EEQ_IMLOJA), "A1_NREDUZ")
		TRB->EEQ_BCOEXT  := QrySZ2->EEQ_BCOEXT
		TRB->EEQ_AGCEXT  := QrySZ2->EEQ_AGCEXT
		TRB->EEQ_CNTEXT  := QrySZ2->EEQ_CNTEXT
		MsUnlock()

		QrySZ2->(DBskip())
	Enddo

	DBSelectArea("QrySZ2")
	DBCloseArea()
	TRB->(DBGotop())
Return

Static Function fSelImpress()
	Local aArea      := GetArea()
	Local cMarca     := ThisMark()
	Local lInverte   := ThisInv()
	Local aImpress   := {}
	DBSelectArea("TRB")
	DBSetOrder(1)
	DBGotop()
	ProcRegua(RecCount())
	While !Eof()
		IncProc("Atualizando... "+TRB->PRODUTO)
		IF ((TRB->OK <> cMarca .And. lInverte) .Or. (TRB->OK == cMarca .And. !lInverte))
			AADD(aImpress,{TRB->NRROLO,TRB->QTPRIUM,TRB->PEDCOMP,TRB->PRODUTO})
		Endif
		DBSelectArea("TRB")
		DBskip()
	Enddo

	aImpress := aSort(aImpress,,,{|x,y| x[3]+x[4]+Str(x[2],10,5) < y[3]+y[4]+Str( y[2],10,5)})

	U_ACDE001E(aImpress,MV_PAR07)

	RestArea(aArea)
Return

Static Function fLegenda()
	Local aCores := {}
	aAdd(aCores,{"BR_VERMELHO","DUE / RE Sem Saldo"})
	aAdd(aCores,{"BR_VERDE"   ,"DUE / RE Com Saldo"})
	BrwLegenda(cCadastro,"Legenda",aCores)
Return NIL

Static Function AjustaSX1(cPerg)
	Local aHelpPor01 := {'Data Inicial'               , '  ', ''}
	Local aHelpPor02 := {'Data Final'                 , '  ', ''}
	Local aHelpPor03 := {'Com Saldo a Nacionalizar ?' , '  ', ''}

	PutSx1(cPerg, '01', 'Data De         ?'     ,'','','mv_ch1','D',8,0,2,'G','','   ','','','MV_PAR01','','','','','','','','','','','','','','','','', aHelpPor01, aHelpPor01, aHelpPor01)
	PutSx1(cPerg, '02', 'Data Ate        ?'     ,'','','mv_ch2','D',8,0,2,'G','','   ','','','MV_PAR02','','','','','','','','','','','','','','','','', aHelpPor02, aHelpPor02, aHelpPor02)
	PutSx1(cPerg, '03', 'Saldo a Nacionalizar ?','','','mv_ch3','C',1,0,2,'G','','   ','','','MV_PAR03','','','','','','','','','','','','','','','','', aHelpPor03, aHelpPor03, aHelpPor03)

Static Function AjSX12(cPerg)
	Local aHelpPor01 := {'Valor Fechamento'           , '  ', ''}

	PutSx1(cPerg, '01', 'Valor a Buscar ?'     ,'','','mv_ch1','N',14,2,2,'G','','   ','','','MV_PAR01','','','','','','','','','','','','','','','','', aHelpPor01, aHelpPor01, aHelpPor01)
Return NIL


//+-----------------------------------------------------------------------------------------------
//| Funcao......: RMark()
//+-----------------------------------------------------------------------------------------------
//| Auto........: Walnir
//+-----------------------------------------------------------------------------------------------
//| Descricao...: Efetua a marca no registro quando duplo click
//+-----------------------------------------------------------------------------------------------
User Function Mark()
	If IsMark( 'OK', cMarca )        
		RecLock( 'TRB', .F. )                
		Replace TRB->OK With Space(2)        
		MsUnLock()
	Else        
		RecLock( 'TRB', .F. )                
		Replace TRB->OK With cMarca        
		MsUnLock()
	EndIf
Return 

// Grava marca em todos os registros validos
User Function MarkAll()
	Local oMark    := GetMarkBrow()
	Local nValMark := 0
	Local lSair    := .F.
	Local lRet     := .f.,;
	nOpc     := 0  ,;
	bOk, bCancel   

	Local dDtSol  := AVCTOD("  /  /  ")
	Local dDtNego := AVCTOD("  /  /  ")
	Local dDtPgt  := AVCTOD("  /  /  ")
	Local cNrOp   := space(len(EEQ->EEQ_NROP))
	Local cBanc   := space(len(EEQ->EEQ_BANC))
	Local cAgen   := space(len(EEQ->EEQ_AGEN))
	Local cNcon   := space(len(EEQ->EEQ_NCON))
	Local cRfBc   := space(len(EEQ->EEQ_RFBC))
	Local nTx     := 0

	// EEQ_SOL    --> DT SOLICITACAO DE CAMBIO
	// EEQ_DTNEGO --> DT NEGOCIACAO DE CAMBIO
	// EEQ_PGT    --> DT PAGAMENTO
	// EEQ_NROP   --> NUMERO DO CONTRATO DE CAMBIO
	// EEQ_TX     --> TAXA DE CAMBIO
	// EEQ_BANC   --> BANCO FECHAMENTO DE CAMBIO
	// EEQ_AGEN   --> AGENCIA FECHAMENTO DE CAMBIO
	// EEQ_NCON   --> NUMERO CONTA FECHAMENTO DE CAMBIO
	// EEQ_RFBC   --> REFERENCIA BANCARIA FECH CAMBIO

	dbSelectArea('TRB')
	TRB->(dbGotop())
	While TRB->(!Eof())
		IF ! empty(TRB->OK) 
			nValMark := nValMark + TRB->EEQ_VL        //achou 
		ENDIF
		TRB->(dbSkip())
	End

	IF nValMark == 0 
		MSGINFO("Não foi marcado nenhum RE")
		lSair := .T.
	ELSE
		lSair := ! MsgNoYes("Valor marcado de US$ "+AllTrim(TransForm(nValMark,AvSx3("EEQ_VL",6)))   ,"Deseja Continuar ?")	
	ENDIF
	TRB->(dbGotop())

	MarkBRefresh( )// força o posicionamento do browse no primeiro registro
	oMark:oBrowse:Gotop()

	IF lSair
		return .F.
	ENDIF

	// INFORMAR DADOS DO CAMBIO
	Begin Sequence
		Define MsDialog oDlg Title "Dados da Baixa - DUE / RE - Movimentação Manual" From 9,0 To 39.5,45 Of oMainWnd

		@ 40 ,15 Say "Dt Solic. Cambio"  Pixel 
		@ 40 ,70 MsGet dDtSol  Size 50,8 Pixel
		@ 60 ,15 Say "Dt Negoc. Cambio"  Pixel 
		@ 60 ,70 MsGet dDtNego Size 50,8 Pixel
		@ 80 ,15 Say "Dt Pagam. Cambio"  Pixel 
		@ 80 ,70 MsGet dDtPgt  Size 50,8 valid !empty(dDtPgt) Pixel
		@ 100,15 Say "Contrato"          Pixel 
		@ 100,70 MsGet cNrOp   Size 50,8 valid !empty(cNrOp) Pixel
		@ 120,15 Say "Taxa Cambio"       Pixel 
		@ 120,70 MsGet nTx     Size 50,8 PICTURE "@E 99.999999" Pixel
		@ 140,15 Say "Banco Fecham."     Pixel 
		@ 140,70 MsGet cBanc   Size 50,8 F3 "SA6" Pixel
		@ 160,15 Say "Agencia"           Pixel 
		@ 160,70 MsGet cAgen   Size 50,8 Pixel
		@ 180,15 Say "Conta"             Pixel 
		@ 180,70 MsGet cNcon   Size 50,8 Pixel
		@ 200,15 Say "Referencia"        Pixel 
		@ 200,70 MsGet cRfBc   Size 50,8 Pixel

		bOk     := {|| (nOpc:=1, oDlg:End())}
		bCancel := {|| (nOpc:=0, oDlg:End())}
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED
		lRET := IF(nOpc=1,.t.,.f.)

		IF nOpc == 1 //ok
			TRB->(DBGOTOP())		
			DO WHILE TRB->(!EOF())
				IF ! empty(TRB->OK)
					EEQ->(DBGOTO(TRB->RECEEQ))

					EEQ->(RecLock( 'EEQ', .F. ))
					EEQ->EEQ_SOL    := dDtSol  // --> DT SOLICITACAO DE CAMBIO
					EEQ->EEQ_DTNEGO := dDtNego // --> DT NEGOCIACAO DE CAMBIO
					EEQ->EEQ_PGT    := dDtPgt  // --> DT PAGAMENTO
					EEQ->EEQ_NROP   := cNrOp   // --> NUMERO DO CONTRATO DE CAMBIO
					EEQ->EEQ_TX     := nTx     // --> TAXA DE CAMBIO
					EEQ->EEQ_BANC   := cBanc   // --> BANCO FECHAMENTO DE CAMBIO
					EEQ->EEQ_AGEN   := cAgen   // --> AGENCIA FECHAMENTO DE CAMBIO
					EEQ->EEQ_NCON   := cNcon   // --> NUMERO CONTA FECHAMENTO DE CAMBIO
					EEQ->EEQ_RFBC   := cRfBc   // --> REFERENCIA BANCARIA FECH CAMBIO
					EEQ->(MSUNLOCK())

					TRB->(RecLock( 'TRB', .F. ))  // SO PARA MUDAR O FLAG
					TRB->EEQ_NROP   := cNrOp   // --> NUMERO DO CONTRATO DE CAMBIO
					TRB->OK         := "  "    // --> LIMPA MARCACAO 
					TRB->(MSUNLOCK())
				ENDIF
				TRB->(DBSKIP())
			ENDDO
		ENDIF
	End Sequence

	MarkBRefresh( )      // força o posicionamento do browse no primeiro registro
Return(lRet)

/*/{Protheus.doc} DesMar
Descrição: Função para Desmarcar tudo.
@author WALNIR
@since 25/06/2016
@version undefined
@type function
/*/
User Function DesMar()
	Local oMark := GetMarkBrow()
	DbSelectArea("TRB")
	DbGotop()
	While !Eof()        
		IF RecLock( 'TRB', .F. )                
			TRB->OK := SPACE(2)                
			MsUnLock()        
		EndIf        
		dbSkip()
	Enddo

	MarkBRefresh( )// força o posicionamento do browse no primeiro registro
	oMark:oBrowse:Gotop()
Return

/*/{Protheus.doc} MarTodos
Descrição: Função utilizada para Marcar tudo.
@author WALNIR
@since 25/06/2016
@version V12
@type function
/*/
User Function MarTodos()
	Local oMark := GetMarkBrow()
	DbSelectArea("TRB")
	DbGotop()
	While !Eof()        
		IF RecLock( 'TRB', .F. )                
			TRB->OK := cMarca
			MsUnLock()        
		EndIf        
		dbSkip()
	Enddo

	MarkBRefresh( )// força o posicionamento do browse no primeiro registro
	oMark:oBrowse:Gotop()
Return

/*/{Protheus.doc} Marcar
Descrição: Função utilizada para a Marcar e Desmarcar.
@author WALNIR
@since 25/06/2016
@version V12
@type function
/*/
User Function Marcar()                              
	Local oMark    := GetMarkBrow()       
	Local nValMark := 0

	AjSX12(cPerg2)
	IF !Pergunte(cPerg2,.T.)  // Pergunta no SX1
		Return
	Endif
	U_DesMar()                      

	DBSelectArea('TRB')
	TRB->(DbGotop())
	While TRB->(!Eof()) .AND. (nValMark == MV_PAR01 .OR. nValMark < MV_PAR01)
		IF EMPTY(TRB->EEQ_NROP)
			IF TRB->(RecLock( 'TRB', .F. ))
				TRB->OK := cMarca          
				nValMark := nValMark + TRB->EEQ_VL      
				TRB->(MsUnLock())
			EndIf        
		ENDIF
		TRB->(dbSkip())
	Enddo
	MarkBRefresh( )      // força o posicionamento do browse no primeiro registro
	oMark:oBrowse:Gotop()
Return

/*/{Protheus.doc} IMPRSEL
Descrição: Relatorio para impressão das RE´s Selecionadas.
@author WALNIR
@since 25/06/2016
@version V12
@type function
/*/
User Function IMPRSEL()
	Local oReport

	#IFDEF TOP
	If FindFunction("TRepInUse") .And. TRepInUse()
		oReport := ReportDef()
		oReport:PrintDialog()
	Else
		Aviso("Nao disponivel","Esta funcionalidade so esta disponivel para os relatorios personalizaveis",{"Fechar"})
	Endif
	#ELSE
	Aviso("Nao disponivel","Esta funcionalidade so esta disponivel para uso com bancos de dados relacionais",{"Fechar"})
	#ENDIF
Return(.F.)

Static Function ReportDef()
	Local oReport  
	Local oSection1, oSection2, oBreak1

	oReport := TReport():New("EEC_RES","Relacao de DUE/REs",,; 
	{|oReport| ReportPrint(oReport,"TRB")},"Este programa ira emitir a Relacao das DUE/REs, pagas no exterior e que não foram nacionalizadas ") 

	oReport:SetPortrait(.T.)

	Pergunte(oReport:uParam,.T.)

	oSection1 := TRSection():New(oReport, ,{"EEC","EEQ","EE9"}, )  
//                 oParent ,cName        ,cAlias,cTitle,cPicture,nSize,lPixel,bBlock
	TRCell():New(oSection1,"EEQ_PREEMB","EEQ","Processo"	,,TamSx3("EEQ_PREEMB")[1] ,.F.,{|| TRB->EEQ_PREEMB })
	TRCell():New(oSection1,"EEQ_FILIAL","EEQ","Filial"		,,TamSx3("EEQ_FILIAL")[1] ,.F.,{|| TRB->EEQ_FILIAL })
	TRCell():New(oSection1,"EEQ_IMPORT","EEQ","Cod. Import"	,,TamSx3("EEQ_IMPORT")[1] ,.F.,{|| TRB->EEQ_IMPORT })
	TRCell():New(oSection1,"EEQ_IMLOJA","EEQ","Loja Import"	,,TamSx3("EEQ_IMLOJA")[1] ,.F.,{|| TRB->EEQ_IMLOJA })
	TRCell():New(oSection1,"EEQ_DESIMP","EEQ","Desc Import"	,,TamSx3("EEQ_DESIMP")[1] ,.F.,{|| TRB->EEQ_DESIMP })

	TRCell():New(oSection1,"EEC_NRODUE","EEC","Nro. da DUE"	,,TamSx3("EEC_NRODUE")[1] ,.F.,{|| TRB->EEC_NRODUE }) // WNM 30/08/18
	TRCell():New(oSection1,"EEC_DTDUE" ,"EEC","Dt DUE"		,,TamSx3("EEC_DTDUE")[1]  ,.F.,{|| stod(dtoc(TRB->EEC_DTDUE))  }) // WNM 30/08/18
	TRCell():New(oSection1,"EEC_CHVDUE","EEC","Chave DUE"	,,TamSx3("EEC_CHVDUE")[1] ,.F.,{|| TRB->EEC_CHVDUE }) // WNM 01/04/19
	TRCell():New(oSection1,"EEC_DUEAVR","EEC","Dt Averb DUE",,TamSx3("EEC_DUEAVR")[1] ,.F.,{|| TRB->EEC_DUEAVR }) // WNM 01/04/19

	TRCell():New(oSection1,"EE9_RE"    ,"EE9","RE"			,,(TamSx3("EE9_RE")[1]+3) ,.F.,{|| TRB->EE9_RE     })
	TRCell():New(oSection1,"EE9_DTRE"  ,"EE9","Data RE"		,,TamSx3("EE9_DTRE")[1]   ,.F.,{|| stod(dtoc(TRB->EE9_DTRE))   })
	TRCell():New(oSection1,"EE9_NRSD"  ,"EE9","Nr. S.D."	,,TamSx3("EE9_NRSD")[1]   ,.F.,{|| TRB->EE9_NRSD   })
	TRCell():New(oSection1,"EE9_DTAVRB","EE9","Averb. S.D."	,,TamSx3("EE9_DTAVRB")[1] ,.F.,{|| stod(dtoc(TRB->EE9_DTAVRB)) })
	TRCell():New(oSection1,"EE9_NF"    ,"EE9","Nota Fiscal"	,,TamSx3("EE9_NF")[1]     ,.F.,{|| TRB->EE9_NF     })
	TRCell():New(oSection1,"EEQ_MOEDA" ,"EEQ","Moeda"		,,TamSx3("EEQ_MOEDA")[1]  ,.F.,{|| TRB->EEQ_MOEDA  })
	TRCell():New(oSection1,"EEQ_VL"    ,"EEQ","Vl.da Parc."	,,TamSx3("EEQ_VL")[1]     ,.F.,{|| nValRE          })

	oSection1:SetTotalInLine(.F.)
	oSection1:SetTotalText("Total")

//	oTotal:= TRFunction():New(oSection1:Cell("EEQ_VL"),NIL,"SUM",/*oBreak*/,"",,{|| TRB->EEQ_VL},.T.,.F.)
//	oTotal:SetTotalInLine(.F.)
Return oReport                                         

Static Function ReportPrint(oReport,cAliasQry1)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local cParam    := ""
	Local cRe       := ""   
	Private nCab := 0

	oReport:SetMeter(TRB->(LastRec())) 
	TRB->(DBGOTOP())
	oSection1:Init()
	WHILE TRB->(!EOF())
		//oSection1:Init()
		IF !EMPTY(TRB->OK ) //.And. nCab <= 10
// WNM 30/08/18			IF ! (alltrim(TRB->EE9_RE)$ cRE)
			IF ! ((alltrim(TRB->EE9_RE)$ cRE) .OR. (alltrim(TRB->EEC_NRODUE)$ cRE) ) // WNM 30/08/18
				nValRE := TRB->EEQ_VL
				IF ! EMPTY(TRB->EE9_RE)                                              // WNM 30/08/18
					cRE    := cRe + TRB->EE9_RE+ " "                                 
				ELSE                                                                 // WNM 30/08/18
					cRE    := cRe + TRB->EEC_NRODUE+ " "                             // WNM 30/08/18
				ENDIF                                                                // WNM 30/08/18
			ELSE
				nValRE := 0
			ENDIF
			oReport:IncMeter(TRB->(LastRec()))
			//oReport:IncMeter()
			oSection1:PRINTLINE() 
			nCab := nCab + 1
            

		ENDIF
		TRB->(DBSKIP())	
	ENDDO

	oSection1:Finish()
Return