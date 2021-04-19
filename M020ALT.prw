#Include 'Protheus.ch'

/*
Programa.: M020ALT
Autor....: Julio César Négri
Data.....: 19/09/2016 
Descricao: Este Ponto de Entrada é chamado após a confirmação da alteração dos dados do fornecedor no Arquivo. 
Uso......: AIR BP BRASIL LTDA
*/


User Function M020ALT()

Local cFil := ParamIXB[1]
// Atualização de arquivos ou campos do usuário após a alteração do fornecedor

//If cFil == 1
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
//Endif

Return nil


