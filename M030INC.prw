#Include 'Protheus.ch'

/*
Programa.: M030INC
Autor....: Danilo José Grodzicki
Data.....: 19/07/2016 
Descricao: Este Ponto de Entrada é chamado após a inclusão dos dados do cliente no Arquivo. 
Uso......: AIR BP BRASIL LTDA
*/
User Function M030INC()

	Local nGrefAtu
	Local nGrefFim
	Local aArea := GetArea()

	If PARAMIXB <> 3  // grava o novo global reference number.
		if Empty(AllTrim(SA1->A1_XGREF))  // grava o novo global reference number.
			nGrefFim := GetMv("MV_XGREFFI")
			nGrefAtu := GetMV("MV_XGREFAT")
			nGrefAtu := nGrefAtu+1
			If RecLock("SA1",.F.)
				SA1->A1_XGREF := AllTrim(Str(nGrefAtu,15,0))+"00"
				SA1->(MsUnlock())
			endif
			PutMv("MV_XGREFAT",nGrefAtu)
			MsgInfo("Foi criado o Global Reference Number: "+AllTrim(Str(nGrefAtu,15,0))+". O final da faixa é o número: "+AllTrim(Str(nGrefFim,15,0))+".","ATENÇÃO")
		endif
	endif

	/*
	Fabiano Migoto Pinto
	Data: 15/03/2016
	Base Fabiano P12 - Inclusão automática do Item Contábil ao gravar o cadastro de clientes
	*/

	dBSelectArea("CTD")
	CTD->(dbSetOrder(1))
	CTD->(dbGoTop())
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

	/*
	Rafael de Campos Falco
	Data: 27/11/2017
	Inclusão automática da regra de excessão de fatura, sempre cadastrar como padrão ZA4_REGRA = 2
	Ajuste solicitado por Sandra Helena de Souza
	*/
	DbSelectArea( "ZA4" )
	ZA4->( DbSetOrder( 1 ) )
	ZA4->( DbGoTop() )
	If !ZA4->( DbSeek( xFilial("ZA4") + SA1->A1_COD ))
		RecLock("ZA4",.T.)
		ZA4->ZA4_FILIAL	:= xFilial("ZA4")
		ZA4->ZA4_CODCLI	:= SA1->A1_COD
		ZA4->ZA4_NOMCLI	:= SA1->A1_NOME
		ZA4->ZA4_REGRA	:= "2"
		ZA4->ZA4_USUARI	:= cUserName
		ZA4->ZA4_DTINCL	:= Date()
		ZA4->ZA4_HRINCL	:= Time()
		ZA4->( MsUnLock() )
	Endif


	RestArea( aArea )

Return Nil