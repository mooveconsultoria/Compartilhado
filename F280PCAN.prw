#Include 'Protheus.ch'

/*
Programa.: F280PCAN
Autor....: Danilo José Grodzicki
Data.....: 26/08/2017 
Descrição: O ponto de entrada F280PCAN será utilizado para permitir ou não o cancelamento da fatura. Não passa nenhum parâmetro e retorna uma variável lógica.
Uso......: AIR BP BRASIL LTDA
*/
User Function F280PCAN()

Local lRet     := .T.
Local aAreaSE1 := SE1->(GetArea())

DbSelectArea("SE1")
SE1->(DbSetOrder(01))

if SE1->(DbSeek(xFilial("SE1")+CPREFCAN+CFATCAN))
	
//	if SE1->E1_XBILLIN == "T" // alterado por Julio.Négri 31.08.17
//	if !Empty(SE1->E1_XDTHRBI) // alterado Julio Négri 23.10.17 - não pode excluir faturas cujo e-billing não foi gerado
	if SE1->E1_XBILLIN == "F"
		MsgStop("Foi gerado eBilling no dia "+DtoC(StoD(Left(SE1->E1_XDTHRBI,8)))+" - "+Right(SE1->E1_XDTHRBI,8)+". - Cancelamento Inválido.","ATENÇÃO")
		lRet := .F.
	endif
	
	if SE1->E1_XISP == "S"
		MsgStop("Foi gerado ISP no dia "+DtoC(StoD(Left(SE1->E1_XISPDT,8)))+" - "+Right(SE1->E1_XISPDT,8)+". - Cancelamento Inválido.","ATENÇÃO")
		lRet := .F.
	endif
	
	if SE1->E1_XIMI == "S"
	MsgStop("Foi gerado IMI no dia "+DtoC(StoD(Left(SE1->E1_XIMIDT,8)))+" - "+Right(SE1->E1_XIMIDT,8)+". - Cancelamento Inválido."+cMsg,"ATENÇÃO")
	lRet := .F.
	
endif
	
	
endif

RestArea(aAreaSE1)

Return(lRet)