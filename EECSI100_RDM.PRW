#include "Rwmake.ch"
#include "EEC.ch"


//-------------------------------------------------
user function EECSI100()
//-------------------------------------------------			  
U_EECPSI00()
RETURN .T.


//-------------------------------------------------
user function EECPSI00
//-------------------------------------------------
Local cPonto := ""                            
Local Retorna
If Type("ParamIXB")     = "A"
   cPonto := ParamIXB[1]
ElseIf Type("ParamIXB") = "C"
   cPonto := ParamIXB
ENDIF 

IF cPonto == "ANTES_TELA"
	MsgRun("Aguarde.... Gerando Embarque Automatico...",, {||U_Emb_Auto()})
//	U_Emb_Auto()
	Retorna := .T.

ELSEIF cPonto == "QB"
	Retorna := .F.
                 
ELSEIF cPonto == "GR_DSC_SISC"
	Retorna := cDESCTEMP

ENDIF

RETURN Retorna