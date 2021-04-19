#Include 'Protheus.ch'

/*
Programa.: M030PALT
Autor....: Julio César Négri
Data.....: 19/09/2016 
Descricao: Este Ponto de Entrada é chamado após a confirmação da alteração dos dados do cliente no Arquivo. 
Uso......: AIR BP BRASIL LTDA
*/

User Function M030PALT()

Local nOpcao	:= PARAMIXB[1]

Local lRet	 	:= .T.

dBSelectArea("CTD")
CTD->(dbSetOrder(1))
CTD->(dbGoTop())

If nOpcao == 1	
	If !CTD->(dBSeek( xFilial("CTD") + "C" + SA1->(A1_COD) ))
		RecLock("CTD",.T.)
			CTD->CTD_FILIAL      := xFilial("CTD")
			CTD->CTD_ITEM	       := "C" + SA1->A1_COD
			CTD->CTD_DESC01      := SA1->A1_NOME
			CTD->CTD_CLASSE      := "2"
			CTD->CTD_DTEXIS      := ctod("01/01/2014")
			CTD->CTD_BLOQ        := "2"
		CTD->(MsUnLock())
	Endif
EndIf

Return lRet


