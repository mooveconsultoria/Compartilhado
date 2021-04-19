#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A100DEL   ºAutor  ³ jMarcelino         º Data ³ 18.05.2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada valida exclusão de nota fiscal			  º±±
±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³  Air BP				                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function A100DEL()

Local aArea	:= GetArea()
Local lRet	:= .T.

Local cQuery	:= ""
Local cArqTRB	:= CriaTrab(nil,.f.)

cQuery := "SELECT ZC0_CODIGO, ZC0_NFISCA, ZC0_SERIE, ZC0_CODPRO, ZC0_STATUS"
cQuery += "FROM "+RetSqlName("ZC0")"
cQuery += "WHERE D_E_L_E_T_ = '' "
cQuery += "AND ZC0_FILIAL 	= '"+XFilial("ZC0")+"'	"
cQuery += "AND ZC0_NFISCA 	= '"+SF1->F1_DOC+"'		"
cQuery += "AND ZC0_NFISCA 	= '"+SF1->F1_SERIE+"'	"
cQuery += "AND ZC0_STATUS 	<> '2'					"
cQuery := ChangeQuery(cQuery)
If Select("TRB") > 0
	TRB->(dbClosearea())
Endif
dbUseArea( .t., "TopConn", TCGenQry(,,cQuery),"TRB", .F., .F. )

If !TRB->(Eof())
	//If TRB-ZC0_STATUS == "1"
	//	cDescStat := " amarrada com bombeio número "+TRB->ZC0_CODIGO
	If TRB-ZC0_STATUS == "3"
		cDescStat := " possui movimentação estornada manualmente"
	EndIf

	lRet := .F.
	MsgStop(" Esta nota não pode ser excluída: "+cDescStat)
EndIf



RestArea(aArea)

Return(lRet)

