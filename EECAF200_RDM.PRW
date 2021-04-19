#include "Rwmake.ch"
     
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ EECAF200  ³ Autor ³ Walnir Necho Mandu  	  ³ Data ³ 06.05.16	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para avaliar condicao de pagamento com dias prazo.  	³±±
±±³          ³ Esta rotina e parte da funcao condicao do SIGA.			   	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					   	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO					   	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      | 						                        ³±±
±±³              ³        ³      | 						                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function EECAF200()

LOCAL cPonto := ""
LOCAL nOpc   := ""
LOCAL nI     := 0

If Type("ParamIXB") = "A"
   cPonto := ParamIXB[1]
   nOpc   := ParamIXB[2]
ElseIf Type("ParamIXB") = "C"
   cPonto := ParamIXB
ENDIF        

IF cPonto == "PE_ALT_PARC"
	SY6->(DBSETORDER(1))
	SY6->(dbSeek(xFilial("SY6")+EEC->(EEC_CONDPA+Str(EEC_DIASPA, 3)) ))
	SE4->(DBSETORDER(1))
	SE4->(dbSeek(xFilial("SE4")+SY6->Y6_SIGSE4))
	FOR nI := 1 TO LEN(aParc)
		
		aParc[nI][2] :=	CalcVEn(dDTEMBA)
	
	NEXT

ENDIF

RETURN .T.


//------------------------------------------------------------------------------------------------------------------
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Descri‡…o ³ Rotina para avaliar condicao de pagamento com dias prazo.  	³±±
//±±³          ³ Esta rotina e parte da funcao condicao do SIGA.			   	³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//------------------------------------------------------------------------------------------------------------------

Static Function CalcVEn(dDta0)

Local dProxd,nDias,nDia,nMes,nAno

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para o campo E4_DDD									  ³
//³	  D = Data do dia 												  ³
//³	  L = Fora o dia												  ³
//³	  S = Fora a semana												  ³
//³	  Z = Fora a dezena				 								  ³
//³	  Q = Fora a quinzena											  ³
//³	  F = Fora o mes												  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SE4->E4_DDD == "D"
	dProxd := dDta0 
ElseIf SE4->E4_DDD =="L"
	dProxd := dDta0 + 1	
ElseIf SE4->E4_DDD == "S"
	nDias   := Dow(ddta0)
	If nDias == 7					  // Sabado
		dProxd := dDta0 + 1
	ElseIf nDias == 6 				  // Sexta
		dProxd := dDta0 + 2
	ElseIf nDias == 5 				  // Quinta
		dProxd := dDta0 + 3
	ElseIf nDias == 4 				  // Quarta
		dProxd := dDta0 + 4
	ElseIf nDias == 3 				  // Terca
		dProxd := dDta0 + 5
	ElseIf nDias == 2 				  // Segunda
		dProxd := dDta0 + 6
	ElseIf nDias == 1 				  // Domingo
		dProxd := dDta0 + 7
	EndIf
ElseIf SE4->E4_DDD == "Z"
	nDia := day(dDta0)
	nMes := month(dDta0)
	nAno := year(dDta0)
	If nDia >= 01 .And. nDia <= 10
		nDia := 11
	ElseIf nDia >= 11 .And. nDia <= 20
		nDia := 21
	Else
		nDia := 01
		nMes := nMes + 1
	EndIf
	If nMes == 13
		nMes := 01
		nAno := nAno + 1
	EndIf
	nDia	  := strzero(nDia,2)
	nMes	  := strzero(nMes,2)
	nAno	  := substr(lTrim(str(nAno)),3,2)
	dproxd   := CtoD(nDia+"/"+nMes+"/"+nAno,"ddmmyy")
ElseIf SE4->E4_DDD == "Q"
	nMes := month(dDta0)
	nAno := year (dDta0)
	If day(dDta0) > 15
		nDia := 01
		nMes		:= nMes + 1
	Else
		nDia := 16
	EndIf
	If nMes == 13
		nMes		:= 01
		nAno := nAno + 1
	EndIf
	nDia	  := strzero(nDia,2)
	nMes	  := strzero(nMes,2)
	nAno	  := substr(lTrim(str(nAno)),3,2)
	dproxd   := CtoD(nDia+"/"+nMes+"/"+nAno,"ddmmyy")
ElseIf SE4->E4_DDD == "F"
	nDia := 01
	nMes := month(dDta0) + 1
	nAno := year (dDta0)
	If nMes == 13
		nMes		:= 01
		nAno := nAno + 1
	EndIf
	nDia	  := strzero(nDia,2)
	nMes	  := strzero(nMes,2)
	nAno	  := substr(lTrim(str(nAno)),3,2)
	dproxd   := CtoD(nDia+"/"+nMes+"/"+nAno,"ddmmyy")
Else
	dProxd := dDataBase	
EndIf

Return(dProxd)

