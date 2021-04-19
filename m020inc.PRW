#include "rwmake.ch"

/*

Fabiano Migoto Pinto
Data: 17/03/2016
Teste base Migoto V12, V11, V10, V8, V7, V6 e V5

*/
USER FUNCTION M020INC()
Local aArea := GetArea()

dBSelectArea("CTD")
CTD->(dbSetOrder(1))
CTD->(dbGoTop())
If !CTD->(dBSeek( xFilial("CTD") + "F" + SA2->(A2_COD) ))
	RecLock("CTD",.T.)
		CTD->CTD_FILIAL      := xFilial("CTD")
		CTD->CTD_ITEM        := "F" + SA2->A2_COD
		CTD->CTD_DESC01      := SA2->A2_NOME
		CTD->CTD_CLASSE      := "2"
		CTD->CTD_DTEXIS      := ctod("01/01/2014")
		CTD->CTD_BLOQ        := "2"
	CTD->(MsUnLock())
Endif

RestArea( aArea )

RETURN

