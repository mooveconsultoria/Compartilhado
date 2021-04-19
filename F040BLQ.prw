#Include 'Protheus.ch'

/*
Programa.: F040BLQ
Autor....: Danilo José Grodzicki
Data.....: 16/08/2017 
Descrição: O ponto de entrada F040BLQ é utilizado para, em determinadas situações, bloquear a utilização das rotinas de inclusão, exclusão, alteração e
substituição de titulos a receber. Este ponto de entrada possui retorno lógico.
Uso......: AIR BP BRASIL LTDA
*/
User Function F040BLQ()

	Local cMsg

	Local lRet := .T.

	if Inclui
		Return(lRet)
	endif

	if Altera
		cMsg := "Alteração Inválida."
	else
		if Right(cCadastro,10) == "SUBSTITUIR"
			cMsg := "Substituir Inválido."
		else
			cMsg := "Exclusão Inválida."
		endif
	endif

	//if SE1->E1_XBILLIN == "T" // alterado Julio Négri 23.10.17 - não pode excluir faturas cujo e-billing não foi gerado
	if SE1->E1_XBILLIN == "F" .AND. SE1->E1_MOEDA <> 1
		MsgStop("Foi gerado eBilling no dia "+DtoC(StoD(Left(SE1->E1_XDTHRBI,8)))+" - "+Right(SE1->E1_XDTHRBI,8)+". - "+cMsg,"ATENÇÃO")
		lRet := .F.
	endif

	if SE1->E1_XISP == "S" .AND. SE1->E1_MOEDA <> 1
		MsgStop("Foi gerado ISP no dia "+DtoC(StoD(Left(SE1->E1_XISPDT,8)))+" - "+Right(SE1->E1_XISPDT,8)+". - "+cMsg,"ATENÇÃO")
		lRet := .F.
	endif

	if SE1->E1_XIMI == "S" .AND. SE1->E1_MOEDA <> 1
		MsgStop("Foi gerado IMI no dia "+DtoC(StoD(Left(SE1->E1_XIMIDT,8)))+" - "+Right(SE1->E1_XIMIDT,8)+". - "+cMsg,"ATENÇÃO")
		lRet := .F.
	endif

Return(lRet)