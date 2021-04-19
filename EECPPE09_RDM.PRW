#Include 'Protheus.ch'

/*
Programa.: EECPPE09
Autor....: Danilo José Grodzicki  / Walnir Necho Madu	
Data.....: 30/05/2016 
Descricao: Este ponto de entrada é executado ao clicar no botão OK e pode ser usado para validar a confirmação das operações: incluir,  alterar, copiar 
           e excluir. Se o ponto de entrada retorna o conteúdo .T., o sistema continua a operação, caso contrário, volta para a tela do pedido.
Uso......: AIR BP BRASIL LTDA
*/
User Function EECPPE09()

Local aAreaZB0
Local aAreaSBE
	
aAreaZB0 := ZB0->(GetArea())
aAreaSBE := SBE->(GetArea())
	
DbSelectArea("ZB0")
ZB0->(DbSetOrder(01))

DbSelectArea("SBE")
SBE->(DbSetOrder(01))
	
if ZB0->(DbSeek(xFilial("ZB0")+EE7->EE7_XNUMCE+EE7->EE7_IMPORT+EE7->EE7_IMLOJA+DtoS(EE7->EE7_XDTEMI)+EE7->EE7_XHORIN))
	If RecLock("ZB0",.F.)
		ZB0->ZB0_STATUS := "2"
		ZB0->ZB0_OBSERV := "Pedido de venda excluído: "+EE7->EE7_PEDFAT 
		ZB0->ZB0_USUARI := cUserName
		ZB0->ZB0_DTINCL := Date()
		ZB0->ZB0_HRINCL := Time()
		ZB0->(MsUnlock())
	endif
endif

if EE8->(DbSeek(xFilial("EE8")+EE7->EE7_PEDIDO))  // Atualiza o Meter
	while EE8->EE8_FILIAL+EE8->EE8_PEDIDO == EE7->EE7_FILIAL+EE7->EE7_PEDIDO .and. EE8->(!Eof())
		If SBE->(DbSeek(xFilial("SBE")+EE8->EE8_LOCAL+EE7->EE7_XCTA))
			If RecLock("SBE",.F.)
				SBE->BE_XMETER := SBE->BE_XMETER-EE8->EE8_SLDINI
				SBE->(MsUnlock())
			endif
		EndIf
		EE8->(DbSkip())
	enddo
endif
	
RestArea(aAreaZB0)
RestArea(aAreaSBE)

Return(.T.)