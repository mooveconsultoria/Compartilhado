#include "Rwmake.ch"
     
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ EECfat2  ³ Autor ³ Walnir Necho Mandu  	  ³ Data ³ 06.05.16	³±±
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
User Function EECFAT2()

LOCAL cPonto := ""
LOCAL nPos   := 0
LOCAL nI     := 0

If Type("ParamIXB") = "A"
   cPonto := ParamIXB[1]
ElseIf Type("ParamIXB") = "C"
   cPonto := ParamIXB
ENDIF        

IF cPonto == "PE_GRVITEM" .AND. (nOpc == 3)

	if VALTYPE(cLocProd) # "U"
		If (nPos := aScan(aReg, {|x| x[1] == "C6_LOCAL" })) > 0   
    		aReg[nPos][2] := cLocProd
	    EndIf
		aAdd(aReg,{"C6_LOCAL",cLocProd,nil})
	endif               
	
	nPos := 0
	
    If (nPos := aScan(aReg, {|x| x[1] == "C6_NUM" })) > 0     // WNM 01/07/16 INCLUIDO POR ERRO NO ITEM NO MATA410
          aDel(aReg, nPos)
          aReg := aSize(aReg, Len(aReg)-1)
    EndIf

	

ENDIF

RETURN .T.
