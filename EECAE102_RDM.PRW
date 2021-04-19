#include "Rwmake.ch"
#include "EEC.ch"


user function eecae102()

If Type("ParamIXB")     = "A"
   cPonto := ParamIXB[1]
ElseIf Type("ParamIXB") = "C"
   cPonto := ParamIXB
ENDIF 

IF cPonto == "WORKIP_ESTRU"

	IF (aScan(aIpSemSX3, {|x| AllTrim(x) == "EE9_PEDIDO" })) == 0
		aAdd(aIpSemSX3,{"EE9_PEDIDO",AVSX3("EE9_PEDIDO",AV_TIPO),AVSX3("EE9_PEDIDO",AV_TAMANHO),AVSX3("EE9_PEDIDO",AV_DECIMAL)})
    ENDIF
	IF (aScan(aIpSemSX3, {|x| AllTrim(x) == "EE9_SEQUEN" })) == 0
	    aAdd(aIpSemSX3,{"EE9_SEQUEN",AVSX3("EE9_SEQUEN",AV_TIPO),AVSX3("EE9_SEQUEN",AV_TAMANHO),AVSX3("EE9_SEQUEN",AV_DECIMAL)})
    ENDIF
	IF (aScan(aIpSemSX3, {|x| AllTrim(x) == "EE9_SEQEMB" })) == 0
	    aAdd(aIpSemSX3,{"EE9_SEQEMB",AVSX3("EE9_SEQEMB",AV_TIPO),AVSX3("EE9_SEQEMB",AV_TAMANHO),AVSX3("EE9_SEQEMB",AV_DECIMAL)})
    ENDIF
	IF (aScan(aIpSemSX3, {|x| AllTrim(x) == "EE9_SLDINI" })) == 0                                                                //WNM 29/03/17
	    aAdd(aIpSemSX3,{"EE9_SLDINI",AVSX3("EE9_SLDINI",AV_TIPO),AVSX3("EE9_SLDINI",AV_TAMANHO),AVSX3("EE9_SLDINI",AV_DECIMAL)}) //WNM 29/03/17
    ENDIF                                                                                                                        //WNM 29/03/17
	IF (aScan(aIpSemSX3, {|x| AllTrim(x) == "EE9_PRCTOT" })) == 0                                                                //WNM 07/04/17
	    aAdd(aIpSemSX3,{"EE9_PRCTOT",AVSX3("EE9_PRCTOT",AV_TIPO),AVSX3("EE9_PRCTOT",AV_TAMANHO),AVSX3("EE9_PRCTOT",AV_DECIMAL)}) //WNM 07/04/17
    ENDIF                                                                                                                        //WNM 07/04/17


	IF (aScan(aIpSemSX3, {|x| AllTrim(x) == "EE9_PRCINC" })) == 0                                                                //WNM 10/04/17
	    aAdd(aIpSemSX3,{"EE9_PRCINC",AVSX3("EE9_PRCINC",AV_TIPO),AVSX3("EE9_PRCINC",AV_TAMANHO),AVSX3("EE9_PRCINC",AV_DECIMAL)}) //WNM 10/04/17
    ENDIF                                                                                                                        //WNM 10/04/17

	IF (aScan(aIpSemSX3, {|x| AllTrim(x) == "EE9_PSLQTO" })) == 0                                                                //WNM 10/04/17
	    aAdd(aIpSemSX3,{"EE9_PSLQTO",AVSX3("EE9_PSLQTO",AV_TIPO),AVSX3("EE9_PSLQTO",AV_TAMANHO),AVSX3("EE9_PSLQTO",AV_DECIMAL)}) //WNM 10/04/17
    ENDIF                                                                                                                        //WNM 10/04/17

	IF (aScan(aIpSemSX3, {|x| AllTrim(x) == "EE9_PSBRTO" })) == 0                                                                //WNM 10/04/17
	    aAdd(aIpSemSX3,{"EE9_PSBRTO",AVSX3("EE9_PSBRTO",AV_TIPO),AVSX3("EE9_PSBRTO",AV_TAMANHO),AVSX3("EE9_PSBRTO",AV_DECIMAL)}) //WNM 10/04/17
    ENDIF                                                                                                                        //WNM 10/04/17

	IF (aScan(aIpSemSX3, {|x| AllTrim(x) == "EE9_QTDEM1" })) == 0                                                                //WNM 10/04/17
	    aAdd(aIpSemSX3,{"EE9_QTDEM1",AVSX3("EE9_QTDEM1",AV_TIPO),AVSX3("EE9_QTDEM1",AV_TAMANHO),AVSX3("EE9_QTDEM1",AV_DECIMAL)}) //WNM 10/04/17
    ENDIF                                                                                                                        //WNM 10/04/17

	IF (aScan(aIpSemSX3, {|x| AllTrim(x) == "WP_SLDATU"  })) == 0                                                                //WNM 10/04/17
	    aAdd(aIpSemSX3,{"WP_SLDATU",AVSX3("WP_SLDATU"  ,AV_TIPO),AVSX3("WP_SLDATU" ,AV_TAMANHO),AVSX3("WP_SLDATU" ,AV_DECIMAL)}) //WNM 10/04/17
    ENDIF                                                                                                                        //WNM 10/04/17

ENDIF

RETURN(.T.)