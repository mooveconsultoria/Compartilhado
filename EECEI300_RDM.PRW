#include "Rwmake.ch"
#include "EEC.ch"


user function EECEI300()
			  
If Type("ParamIXB")     = "A"
   cPonto := ParamIXB[1]
ElseIf Type("ParamIXB") = "C"
   cPonto := ParamIXB
ENDIF 
EEC->(DBSETORDER(1))

IF cPonto == "PE_RE_DT"

	IF EEC->(DBSEEK(xFilial("EEC")+EE9->EE9_PREEMB))
		EEC->(RecLock("EEC",.F.))

		EEC->EEC_NRCONH := EE9->EE9_RE   // CONHECIMENTO EMBARQUE
		EEC->EEC_DTCONH := EE9->EE9_DTRE // DATA CONHECIMENTO
	
// EECSI100	EE9->EE9_RE     := if(lErro,"",cRe)
// EECSI100 EE9->EE9_DTRE   := if(lErro,AvCtod(""),dDtRe)
	
		EEC->(MsUnlock())
	ELSE
		MSGINFO("Processo : "+ EE9->EE9_PREEMB + " nao encontrado ","Verificar")	
	ENDIF

ENDIF

RETURN .T.
