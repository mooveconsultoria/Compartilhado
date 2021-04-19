#INCLUDE 'Protheus.ch'
#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ UPDTELCE ∫Autor  ≥Danilo JosÈ Grodzicki∫ Data≥  31/03/2016 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Compatibilizador para: - Tela CE - Comprovante de Entrega. ∫±±
±±∫          ≥                        - Contrato de Parceria.             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AIR BP BRASIL LTDA                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function UPDTELCE()

Local aSay      := {}
Local aButton   := {}
Local aMarcadas := {}
Local cTitulo   := "ATUALIZA«√O DE DICION¡RIOS E TABELAS"
Local cDesc1    := "Esta rotina tem como objetivo realizar a atualizaÁ„o dos dicion·rios do Sistema ( SX?/SIX )."
Local cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja n„o podem haver outros usu·rios "
Local cDesc3    := "ou jobs utilizando o sistema. … extremamente recomend·vel que se faÁa um BACKUP DOS "
Local cDesc4    := "DICION¡RIOS e da BASE DE DADOS antes desta atualizaÁ„o, para que caso ocorra eventuais"
Local cDesc5    := "falhas, esse backup seja restaurado."
Local cDesc6    := ""
Local cDesc7    := ""
Local lOk       := .F.

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, '*OFF' ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

FormBatch(  cTitulo,  aSay,  aButton )

If lOk
	aMarcadas := EscEmpresa()

	If !Empty( aMarcadas )
		If  ApMsgNoYes( 'Confirma a atualizaÁ„o dos dicion·rios ?', cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas ) }, 'Atualizando', 'Aguarde, atualizando ...', .F. )
			oProcess:Activate()

			If lOk
				Final( 'AtualizaÁ„o ConcluÌda.' )
			Else
				Final( 'AtualizaÁ„o n„o Realizada.' )
			EndIf

		Else
			Final( 'AtualizaÁ„o n„o Realizada.' )

		EndIf

	Else
		Final( 'AtualizaÁ„o n„o Realizada.' )

	EndIf

EndIf

Return NIL

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSTProc  ∫ Autor ≥ Microsiga        ∫ Data ≥  25/07/2011   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravaÁ„o dos arquivos           ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSTProc  - Gerado por EXPORDIC / Upd. V.4.01 EFS           ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSTProc( lEnd, aMarcadas )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ''
Local   cFile     := ''
Local   cFileLog  := ''
Local   cMask     := 'Arquivos Texto (*.TXT)|*.txt|'
Local   cTCBuild  := 'TCGetBuild'
Local   cTexto    := ''
Local   cTopBuild := ''
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0Ex() )

	dbSelectArea( 'SM0' )
	dbGoTop()

	While !SM0->( EOF() )
		// So adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 2 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			cTexto += Replicate( '-', 128 ) + CRLF
			cTexto += 'Empresa : ' + SM0->M0_CODIGO + '/' + SM0->M0_NOME + CRLF + CRLF

			oProcess:SetRegua1( 8 )

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SX2         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			oProcess:IncRegua1( 'Dicion·rio de arquivos - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuSX2( @cTexto )

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SX3         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			FSAtuSX3( @cTexto )

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SIX         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			oProcess:IncRegua1( 'Dicion·rio de Ìndices - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuSIX( @cTexto )

			oProcess:IncRegua1( 'Dicion·rio de dados - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			oProcess:IncRegua2( 'Atualizando campos/Ìndices')


			// Alteracao fisica dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= '20090811' .AND. TcInternal( 89 ) == 'CLOB_SUPPORTED'
					If ( ( aArqUpd[nX] >= 'NQ ' .AND. aArqUpd[nX] <= 'NZZ' ) .OR. ( aArqUpd[nX] >= 'O0 ' .AND. aArqUpd[nX] <= 'NZZ' ) ) .AND.;
						!aArqUpd[nX] $ 'NQD,NQF,NQP,NQT'
						TcInternal( 25, 'CLOB' )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					ApMsgStop( 'Ocorreu um erro desconhecido durante a atualizaÁ„o da tabela : ' + aArqUpd[nX] + '. Verifique a integridade do dicion·rio e da tabela.', 'ATEN«√O' )
					cTexto += 'Ocorreu um erro desconhecido durante a atualizaÁ„o da estrutura da tabela : ' + aArqUpd[nX] + CRLF
				EndIf

				If cTopBuild >= '20090811' .AND. TcInternal( 89 ) == 'CLOB_SUPPORTED'
					TcInternal( 25, 'OFF' )
				EndIf

			Next nX

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SX6         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			oProcess:IncRegua1( 'Dicion·rio de par‚metros - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuSX6( @cTexto )

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SX7         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			oProcess:IncRegua1( 'Dicion·rio de gatilhos - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuSX7( @cTexto )

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SXA         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			oProcess:IncRegua1( 'Dicion·rio de pastas - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuSXA( @cTexto )

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SXB         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			oProcess:IncRegua1( 'Dicion·rio de consultas padr„o - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuSXB( @cTexto )

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SX5         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			oProcess:IncRegua1( 'Dicion·rio de tabelas sistema - '  + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuSX5( @cTexto )

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SX9         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			oProcess:IncRegua1( 'Dicion·rio de relacionamentos - '  + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuSX9( @cTexto )

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza os helps                 ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			oProcess:IncRegua1( 'Helps de Campo - '  + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuHlp( @cTexto )

			RpcClearEnv()

			If !( lOpen := MyOpenSm0Ex() )
				Exit
			EndIf

		Next nI

		If lOpen

			cAux += Replicate( '-', 128 ) + CRLF
			cAux += Replicate( ' ', 128 ) + CRLF
			cAux += 'LOG DA ATUALIZACAO DOS DICION¡RIOS' + CRLF
			cAux += Replicate( ' ', 128 ) + CRLF
			cAux += Replicate( '-', 128 ) + CRLF
			cAux += CRLF
			cAux += ' Dados Ambiente'        + CRLF
			cAux += ' --------------------'  + CRLF
			cAux += ' Empresa / Filial...: ' + cEmpAnt + '/' + cFilAnt  + CRLF
			cAux += ' Nome Empresa.......: ' + Capital( AllTrim( GetAdvFVal( 'SM0', 'M0_NOMECOM', cEmpAnt + cFilAnt, 1, '' ) ) ) + CRLF
			cAux += ' Nome Filial........: ' + Capital( AllTrim( GetAdvFVal( 'SM0', 'M0_FILIAL' , cEmpAnt + cFilAnt, 1, '' ) ) ) + CRLF
			cAux += ' DataBase...........: ' + DtoC( dDataBase )  + CRLF
			cAux += ' Data / Hora........: ' + DtoC( Date() ) + ' / ' + Time()  + CRLF
			cAux += ' Environment........: ' + GetEnvServer()  + CRLF
			cAux += ' StartPath..........: ' + GetSrvProfString( 'StartPath', '' )  + CRLF
			cAux += ' RootPath...........: ' + GetSrvProfString( 'RootPath', '' )  + CRLF
			cAux += ' Versao.............: ' + GetVersao(.T.)  + CRLF
			cAux += ' Usuario Microsiga..: ' + __cUserId + ' ' +  cUserName + CRLF
			cAux += ' Computer Name......: ' + GetComputerName()  + CRLF

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				cAux += ' '  + CRLF
				cAux += ' Dados Thread' + CRLF
				cAux += ' --------------------'  + CRLF
				cAux += ' Usuario da Rede....: ' + aInfo[nPos][1] + CRLF
				cAux += ' Estacao............: ' + aInfo[nPos][2] + CRLF
				cAux += ' Programa Inicial...: ' + aInfo[nPos][5] + CRLF
				cAux += ' Environment........: ' + aInfo[nPos][6] + CRLF
				cAux += ' Conexao............: ' + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), '' ), Chr( 10 ), '' ) )  + CRLF
			EndIf
			cAux += Replicate( '-', 128 ) + CRLF
			cAux += CRLF

			cTexto := cAux + cTexto

			cFileLog := MemoWrite( CriaTrab( , .F. ) + '.log', cTexto )

			Define Font oFont Name 'Mono AS' Size 5, 12

			Define MsDialog oDlg Title 'Atualizacao concluida.' From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, '' ), If( cFile == '', .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel // Salva e Apaga //'Salvar Como...'

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSAtuSX2 ∫ Autor ≥ Microsiga          ∫ Data ≥  25/07/2011 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao do SX2 - Arquivos      ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuSX2 - Gerado por EXPORDIC / Upd. V.4.01 EFS           ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuSX2( cTexto )
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ''
Local cEmpr     := ''
Local cPath     := ''
Local nI        := 0
Local nJ        := 0

cTexto  += 'Inicio da Atualizacao do SX2' + CRLF + CRLF

aEstrut := { 'X2_CHAVE'  , 'X2_PATH'    , 'X2_ARQUIVO' , 'X2_NOME'    , 'X2_NOMESPA' , 'X2_NOMEENG' , ;
             'X2_ROTINA' , 'X2_MODO'    , 'X2_MODOUN'  , 'X2_MODOEMP' , 'X2_UNICO'   , 'X2_PYME'    , ;
             'X2_MODULO' , 'X2_DISPLAY' ,'X2_SYSOBJ'   , 'X2_USROBJ' }

// Tabela ZB0

aAdd( aSX2, { ;
	'ZB0'						    					, ;  // X2_CHAVE
	cPath						    					, ;  // X2_PATH
	'ZB0'+cEmpr					   					, ;  // X2_ARQUIVO
	'Comprovante de Entrega'  						, ;  // X2_NOME
	'Prueba de entrega'								, ;  // X2_NOMESPA
	'Delivery receipt'			  					, ;  // X2_NOMEENG
	''							    					, ;  // X2_ROTINA
	'E'							    					, ;  // X2_MODO
	'E'							    					, ;  // X2_MODOUN
	'E'							  		  				, ;  // X2_MODOEMP
	''													, ;  // X2_UNICO
	'S'							    					, ;  // X2_PYME
	05							    					, ;  // X2_MODULO
	''													, ;  // X2_DISPLAY
	'' 													, ;  // X2_SYSOBJ
	'' 													} )  // X2_USROBJ

// Tabela ZB1

aAdd( aSX2, { ;
	'ZB1'						    					, ;  // X2_CHAVE
	cPath						    					, ;  // X2_PATH
	'ZB1'+cEmpr					   					, ;  // X2_ARQUIVO
	'CabeÁalho Contrato de Parceria'				, ;  // X2_NOME
	'Cabecera Acuerdo de AsociaciÛn'				, ;  // X2_NOMESPA
	'Partnership Agreement Header' 					, ;  // X2_NOMEENG
	''							    					, ;  // X2_ROTINA
	'C'							    					, ;  // X2_MODO
	'C'							    					, ;  // X2_MODOUN
	'C'							  		  				, ;  // X2_MODOEMP
	''													, ;  // X2_UNICO
	'S'							    					, ;  // X2_PYME
	05							    					, ;  // X2_MODULO
	''													, ;  // X2_DISPLAY
	'' 													, ;  // X2_SYSOBJ
	'' 													} )  // X2_USROBJ

// Tabela ZB2

aAdd( aSX2, { ;
	'ZB2'						    					, ;  // X2_CHAVE
	cPath						    					, ;  // X2_PATH
	'ZB2'+cEmpr					   					, ;  // X2_ARQUIVO
	'Itens Contrato de Parceria'					, ;  // X2_NOME
	'ArtÌculos de Contrato de AsociaciÛn'			, ;  // X2_NOMESPA
	'Partnership Contract Items' 					, ;  // X2_NOMEENG
	''							    					, ;  // X2_ROTINA
	'C'							    					, ;  // X2_MODO
	'C'							    					, ;  // X2_MODOUN
	'C'							  		  				, ;  // X2_MODOEMP
	''													, ;  // X2_UNICO
	'S'							    					, ;  // X2_PYME
	05							    					, ;  // X2_MODULO
	''													, ;  // X2_DISPLAY
	'' 													, ;  // X2_SYSOBJ
	'' 													} )  // X2_USROBJ

dbSelectArea( 'SX2' )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Atualizando dicion·rio
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( 'SX2' )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( 'Atualizando Arquivos (SX2)...')

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + '/'
			cTexto += 'Foi incluÌda a tabela ' + aSX2[nI][1] + CRLF
		EndIf

		RecLock( 'SX2', .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == 'X2_ARQUIVO'
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  '0' )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), ' ', '' ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), ' ', '' ) )
			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + '_UNQ'  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + '|' + RetSqlName( aSX2[nI][1] ) + '_UNQ' )
				cTexto += 'Foi alterada chave unica da tabela ' + aSX2[nI][1] + CRLF
			Else
				cTexto += 'Foi criada   chave unica da tabela ' + aSX2[nI][1] + CRLF
			EndIf
		EndIf

	EndIf

Next nI

cTexto += CRLF + 'Final da Atualizacao do SX2' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return aClone( aSX2 )


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSAtuSX3 ∫ Autor ≥ Microsiga          ∫ Data ≥  25/07/2011   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao do SX3 - Campos        ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuSX3 - Gerado por EXPORDIC / Upd. V.4.01 EFS           ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuSX3( cTexto )
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ''
Local cAliasAtu := ''
Local cMsg      := ''
Local cSeqAtu   := ''
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

cTexto  += 'Inicio da Atualizacao do SX3' + CRLF + CRLF

aEstrut := { 'X3_ARQUIVO' , 'X3_ORDEM'   , 'X3_CAMPO'  , 'X3_TIPO'    , 'X3_TAMANHO' , 'X3_DECIMAL' , ;
             'X3_TITULO'  , 'X3_TITSPA'  , 'X3_TITENG' , 'X3_DESCRIC' , 'X3_DESCSPA' , 'X3_DESCENG' , ;
             'X3_PICTURE' , 'X3_VALID'   , 'X3_USADO'  , 'X3_RELACAO' , 'X3_F3'      , 'X3_NIVEL'   , ;
             'X3_RESERV'  , 'X3_TRIGGER' , 'X3_PROPRI' , 'X3_BROWSE'  , 'X3_VISUAL'  , 'X3_CONTEXT' , ;
             'X3_OBRIGAT' , 'X3_VLDUSER' , 'X3_CBOX'   , 'X3_CBOXSPA' , 'X3_CBOXENG' , 'X3_PICTVAR' , ;
             'X3_WHEN'    , 'X3_INIBRW'  , 'X3_GRPSXG' , 'X3_FOLDER'  , 'X3_PYME'    , 'X3_IDXSRV'  , ;
             'X3_ORTOGRA' , 'X3_IDXFLD'  , 'X3_TELA'   , 'X3_AGRUP' }

//
// Tabela ZB0
//

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'01'													, ;  // X3_ORDEM
	'ZB0_FILIAL'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	6														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Filial'												, ;  // X3_TITULO
	'Sucursal'												, ;  // X3_TITSPA
	'Branch'												, ;  // X3_TITENG
	'Filial do Sistema'									, ;  // X3_DESCRIC
	'Sucursal del Sistema'								, ;  // X3_DESCSPA
	'System Branch'										, ;  // X3_DESCENG
	''														, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)	, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	'033'													, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'02'													, ;  // X3_ORDEM
	'ZB0_NUMCE'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'N˙mero da CE'										, ;  // X3_TITULO
	'N˙mero CE'											, ;  // X3_TITSPA
	'EC Number'											, ;  // X3_TITENG
	'Numero da CE'										, ;  // X3_DESCRIC
	'N˙mero CE'											, ;  // X3_DESCSPA
	'EC Number'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'03'													, ;  // X3_ORDEM
	'ZB0_DTEMIS'											, ;  // X3_CAMPO
	'D'														, ;  // X3_TIPO
	08														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Data Emiss„o'										, ;  // X3_TITULO
	'Fecha EmisiÛn'										, ;  // X3_TITSPA
	'Issuance Date'										, ;  // X3_TITENG
	'Data Emiss„o'										, ;  // X3_DESCRIC
	'Fecha EmisiÛn'										, ;  // X3_DESCSPA
	'Issuance Date'										, ;  // X3_DESCENG
	''														, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	'U_CEDtEmis()'										, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'04'													, ;  // X3_ORDEM
	'ZB0_CODCLI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	06														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Cod. Cliente'										, ;  // X3_TITULO
	'Cod. Cliente'										, ;  // X3_TITSPA
	'Cod. Client'											, ;  // X3_TITENG
	'CÛdigo do Cliente'									, ;  // X3_DESCRIC
	'El cÛdigo de cliente'								, ;  // X3_DESCSPA
	'Client code'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	'SA1'													, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	'S'														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	'U_CEClient()'										, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'05'													, ;  // X3_ORDEM
	'ZB0_LOJCLI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	02														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Loja Cliente'										, ;  // X3_TITULO
	'Tienda Cliente'										, ;  // X3_TITSPA
	'Unit Client'											, ;  // X3_TITENG
	'Loja Cliente'										, ;  // X3_DESCRIC
	'Tienda Cliente'										, ;  // X3_DESCSPA
	'Unit Client'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	'S'														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	'U_CEClieLo()'										, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'06'													, ;  // X3_ORDEM
	'ZB0_PREFIX'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	07														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Pref. Aeron.'										, ;  // X3_TITULO
	'Pref. Aeron.'										, ;  // X3_TITSPA
	'Pref. Aircr.'										, ;  // X3_TITENG
	'Prefixo Aeronave'									, ;  // X3_DESCRIC
	'Prefijo de Aeronaves'								, ;  // X3_DESCSPA
	'Prefix Aircraft'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'07'													, ;  // X3_ORDEM
	'ZB0_CTA'												, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'CTA'													, ;  // X3_TITULO
	'CTA'													, ;  // X3_TITSPA
	'CTA'													, ;  // X3_TITENG
	'CTA'													, ;  // X3_DESCRIC
	'CTA'													, ;  // X3_DESCSPA
	'CTA'													, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	'SBECE'												, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	'U_CECta()'											, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'08'													, ;  // X3_ORDEM
	'ZB0_HORINI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	05														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Hora Inicio'											, ;  // X3_TITULO
	'Tiempo Inicio'										, ;  // X3_TITSPA
	'Time Home'											, ;  // X3_TITENG
	'Hora Inicio'											, ;  // X3_DESCRIC
	'Tiempo Inicio'										, ;  // X3_DESCSPA
	'Hora Inicio'											, ;  // X3_DESCENG
	'99:99'												, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	'U_CEValHor()'										, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'09'													, ;  // X3_ORDEM
	'ZB0_HORFIM'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	05														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Hora TÈrmino'										, ;  // X3_TITULO
	'Hora FinalizaciÛn'									, ;  // X3_TITSPA
	'Time Ending'											, ;  // X3_TITENG
	'Hora TÈrmino'										, ;  // X3_DESCRIC
	'Hora FinalizaciÛn'									, ;  // X3_DESCSPA
	'Time Ending'											, ;  // X3_DESCENG
	'99:99'												, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	'U_CEValHor()'										, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'10'													, ;  // X3_ORDEM
	'ZB0_NUMVOO'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	10														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Num. Voo'												, ;  // X3_TITULO
	'N˙mero Vuelo'										, ;  // X3_TITSPA
	'Flight Number'										, ;  // X3_TITENG
	'N˙mero Voo'											, ;  // X3_DESCRIC
	'N˙mero Vuelo'										, ;  // X3_DESCSPA
	'Flight Number'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'11'													, ;  // X3_ORDEM
	'ZB0_TIPAER'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Tipo Aeronave'										, ;  // X3_TITULO
	'Tipo Aeronave'										, ;  // X3_TITSPA
	'Aircraft Type'										, ;  // X3_TITENG
	'Tipo Aeronave'										, ;  // X3_DESCRIC
	'Tipo de Aeronave'									, ;  // X3_DESCSPA
	'Aircraft Type'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'12'													, ;  // X3_ORDEM
	'ZB0_TSTVIS'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	05														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Teste Visual'										, ;  // X3_TITULO
	'Ensayo Visual'										, ;  // X3_TITSPA
	'Visual Test'											, ;  // X3_TITENG
	'Teste Visual'										, ;  // X3_DESCRIC
	'El Ensayo Visual'									, ;  // X3_DESCSPA
	'Visual Test'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'13'													, ;  // X3_ORDEM
	'ZB0_MATRIC'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Mat.Operador'										, ;  // X3_TITULO
	'Operador Reg'										, ;  // X3_TITSPA
	'Oper. Regist'										, ;  // X3_TITENG
	'MatrÌcula Operador'									, ;  // X3_DESCRIC
	'Operador de Registro'								, ;  // X3_DESCSPA
	'Operator registration'								, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'14'													, ;  // X3_ORDEM
	'ZB0_CODAER'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	03														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Codigo Aeroporto'									, ;  // X3_TITULO
	'CÛdigo Aeropuerto'									, ;  // X3_TITSPA
	'Code Airport'										, ;  // X3_TITENG
	'Codigo Aeroporto'									, ;  // X3_DESCRIC
	'CÛdigo del Aeropuerto'								, ;  // X3_DESCSPA
	'Code Airport'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	'SY9CE'												, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	'U_CEAeropo()'										, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'15'													, ;  // X3_ORDEM
	'ZB0_OBSERV'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	250														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'ObservaÁıes'											, ;  // X3_TITULO
	'Observaciones'										, ;  // X3_TITSPA
	'Comments'												, ;  // X3_TITENG
	'ObservaÁıes'											, ;  // X3_DESCRIC
	'Observaciones'										, ;  // X3_DESCSPA
	'Comments'												, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'16'													, ;  // X3_ORDEM
	'ZB0_PRODUT'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Produto'												, ;  // X3_TITULO
	'Producto'												, ;  // X3_TITSPA
	'Product'												, ;  // X3_TITENG
	'CÛdigo do Produto'									, ;  // X3_DESCRIC
	'CÛdigo de Producto'									, ;  // X3_DESCSPA
	'Product Code'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	'SB1CE'												, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	'U_CEProdut()'										, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'17'													, ;  // X3_ORDEM
	'ZB0_QTDE'												, ;  // X3_CAMPO
	'N'														, ;  // X3_TIPO
	06														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Quantidade'											, ;  // X3_TITULO
	'Cantidad'												, ;  // X3_TITSPA
	'Amount'												, ;  // X3_TITENG
	'Quantidade'											, ;  // X3_DESCRIC
	'Cantidad'												, ;  // X3_DESCSPA
	'Amount'												, ;  // X3_DESCENG
	'@E 999999'											, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'18'													, ;  // X3_ORDEM
	'ZB0_PRCNEG'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	01														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'PreÁo Negociado'										, ;  // X3_TITULO
	'Precio NegociaciÛn'									, ;  // X3_TITSPA
	'Negotiated Price'									, ;  // X3_TITENG
	'PreÁo Negociado'										, ;  // X3_DESCRIC
	'Precio de NegociaciÛn'								, ;  // X3_DESCSPA
	'Negotiated Price'									, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	'"N"'													, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	'Pertence("SN").and.U_CEPrcVen()'					, ;  // X3_VLDUSER
	'S=Sim;N=N„o'											, ;  // X3_CBOX
	'S=Si;N=No'											, ;  // X3_CBOXSPA
	'Y=Yes;N=No'											, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'19'													, ;  // X3_ORDEM
	'ZB0_PRCVEN'											, ;  // X3_CAMPO
	'N'														, ;  // X3_TIPO
	12														, ;  // X3_TAMANHO
	5														, ;  // X3_DECIMAL
	'PreÁo Venda'											, ;  // X3_TITULO
	'Precio Venta'										, ;  // X3_TITSPA
	'Price Sale'											, ;  // X3_TITENG
	'PreÁo Venda'											, ;  // X3_DESCRIC
	'Precio Venta'										, ;  // X3_DESCSPA
	'Price Sale'											, ;  // X3_DESCENG
	'@E 999,999.99999'									, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	'iif(M->ZB0_PRCNEG=="S",.T.,.F.)'					, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'20'													, ;  // X3_ORDEM
	'ZB0_REGIST'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Reg.Med.Ini.'										, ;  // X3_TITULO
	'Reg.Met.Ini.'										, ;  // X3_TITSPA
	'Met.Reg.Ini.'										, ;  // X3_TITENG
	'Registro Medidor Inicial'							, ;  // X3_DESCRIC
	'Inicio registro medidor'							, ;  // X3_DESCSPA
	'Registration Home Meter'							, ;  // X3_DESCENG
	'999999999999999'										, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'21'													, ;  // X3_ORDEM
	'ZB0_LOGOCO'											, ;  // X3_CAMPO
	'M'														, ;  // X3_TIPO
	10														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Log Ocorrencia'										, ;  // X3_TITULO
	'Log Ocorrencia'										, ;  // X3_TITSPA
	'Log Ocorrencia'										, ;  // X3_TITENG
	'Log Ocorrencia'										, ;  // X3_DESCRIC
	'Log Ocorrencia'										, ;  // X3_DESCSPA
	'Log Ocorrencia'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	'iif(Inclui,.F.,.T.)'								, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'22'													, ;  // X3_ORDEM
	'ZB0_STATUS'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	1														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Status CE'											, ;  // X3_TITULO
	'Estado de CE'										, ;  // X3_TITSPA
	'Status CE'											, ;  // X3_TITENG
	'Status CE'											, ;  // X3_DESCRIC
	'Estado de CE'										, ;  // X3_DESCSPA
	'Status CE'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'23'													, ;  // X3_ORDEM
	'ZB0_USUARI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	20														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Nome Usuario'										, ;  // X3_TITULO
	'Nomb.Usuario'										, ;  // X3_TITSPA
	'User Name'											, ;  // X3_TITENG
	'Nome do Usuario'										, ;  // X3_DESCRIC
	'Nombre del Usuario'									, ;  // X3_DESCSPA
	'User Name'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'24'													, ;  // X3_ORDEM
	'ZB0_DTINCL'											, ;  // X3_CAMPO
	'D'														, ;  // X3_TIPO
	08														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Dt. Inclusao'										, ;  // X3_TITULO
	'Fecha Inclu.'										, ;  // X3_TITSPA
	'Inclusion Dt'										, ;  // X3_TITENG
	'Data de inclusao CE'								, ;  // X3_DESCRIC
	'Fecha inclusion en CE'								, ;  // X3_DESCSPA
	'CE Inclusion Date'									, ;  // X3_DESCENG
	''														, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'25'													, ;  // X3_ORDEM
	'ZB0_HRINCL'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	08														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Hr. Inclusao'										, ;  // X3_TITULO
	'Tiempo Inclu.'										, ;  // X3_TITSPA
	'Inclus. hour'										, ;  // X3_TITENG
	'Hora de inclusao CE'								, ;  // X3_DESCRIC
	'Tiempo inclusion en CE'								, ;  // X3_DESCSPA
	'CE Inclusion hour'									, ;  // X3_DESCENG
	'99:99:99'												, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'26'													, ;  // X3_ORDEM
	'ZB0_NOMCLI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	40														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Nome Cliente'										, ;  // X3_TITULO
	'Nombre Clien'										, ;  // X3_TITSPA
	'Client Name'											, ;  // X3_TITENG
	'Nome do cliente'										, ;  // X3_DESCRIC
	'Nombre del cliente'									, ;  // X3_DESCSPA
	'Client Name'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'27'													, ;  // X3_ORDEM
	'ZB0_NOMAER'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	25														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Nome Aerop.'											, ;  // X3_TITULO
	'Nombre Aero.'										, ;  // X3_TITSPA
	'Name Airport'										, ;  // X3_TITENG
	'Nome do aeroporto'									, ;  // X3_DESCRIC
	'Nombre del aeropuerto'								, ;  // X3_DESCSPA
	'Name Airport'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'28'													, ;  // X3_ORDEM
	'ZB0_DESPRO'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	35														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Descr. Prod.'										, ;  // X3_TITULO
	'Descr. Prod.'										, ;  // X3_TITSPA
	'Product Desc'										, ;  // X3_TITENG
	'Descricao do Produto'								, ;  // X3_DESCRIC
	'Descripcion del Producto'							, ;  // X3_DESCSPA
	'Description of Product'								, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'29'													, ;  // X3_ORDEM
	'ZB0_DESEND'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	30														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Desc. Endereco'										, ;  // X3_TITULO
	'Desc.Ubicacion'										, ;  // X3_TITSPA
	'Location Descr'										, ;  // X3_TITENG
	'Descricao do Endereco'								, ;  // X3_DESCRIC
	'Descrip.de la Ubicacion'							, ;  // X3_DESCSPA
	'Location Description'								, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'30'													, ;  // X3_ORDEM
	'ZB0_CONTRA'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	250														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'N˙m.Contrato'										, ;  // X3_TITULO
	'N˙m.Contrato'										, ;  // X3_TITSPA
	'Contr.Number'										, ;  // X3_TITENG
	'Numero do Contrato'									, ;  // X3_DESCRIC
	'N˙mero de Contrato'									, ;  // X3_DESCSPA
	'Contact number'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'31'													, ;  // X3_ORDEM
	'ZB0_CODTAB'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	6														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Cod. Tabela'											, ;  // X3_TITULO
	'Codigo Tabla'										, ;  // X3_TITSPA
	'Code Table'											, ;  // X3_TITENG
	'CÛdigo Tabela PreÁo'								, ;  // X3_DESCRIC
	'CÛdigo Tabla de precios'							, ;  // X3_DESCSPA
	'Code Table Price'									, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'32'													, ;  // X3_ORDEM
	'ZB0_REVTAB'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	3														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Rev. Tabela'											, ;  // X3_TITULO
	'Rev. Tabla'											, ;  // X3_TITSPA
	'Rev. Table'											, ;  // X3_TITENG
	'Revis„o Tabela PreÁo'								, ;  // X3_DESCRIC
	'Tabla opiniÛn Precio'								, ;  // X3_DESCSPA
	'Review Table Price'									, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'33'													, ;  // X3_ORDEM
	'ZB0_HORINT'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	05														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Hora Interm.'										, ;  // X3_TITULO
	'Hora Interm.'										, ;  // X3_TITSPA
	'Time Interm.'										, ;  // X3_TITENG
	'Hora Intermedi·ria'									, ;  // X3_DESCRIC
	'Hora  intermedio'									, ;  // X3_DESCSPA
	'Time Intermediate'									, ;  // X3_DESCENG
	'99:99'												, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	'U_CEValHor()'										, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'34'													, ;  // X3_ORDEM
	'ZB0_REGFIM'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Reg.Med.Fin.'										, ;  // X3_TITULO
	'Reg.Met.Fin.'										, ;  // X3_TITSPA
	'Met.Reg.Fin.'										, ;  // X3_TITENG
	'Registro do Medidor Final'							, ;  // X3_DESCRIC
	'Registro ˙ltimo metro'								, ;  // X3_DESCSPA
	'Registration Final Meter'							, ;  // X3_DESCENG
	'999999999999999'										, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'35'													, ;  // X3_ORDEM
	'ZB0_DENSAB'											, ;  // X3_CAMPO
	'N'														, ;  // X3_TIPO
	6														, ;  // X3_TAMANHO
	4														, ;  // X3_DECIMAL
	'Dens. Ambien'										, ;  // X3_TITULO
	'Dens. Ambien'										, ;  // X3_TITSPA
	'Dens. Enviro'										, ;  // X3_TITENG
	'Densidade Ambiente'									, ;  // X3_DESCRIC
	'Medio Ambiente densidad'							, ;  // X3_DESCSPA
	'Density Environment'								, ;  // X3_DESCENG
	'@E 9.9999'											, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'36'													, ;  // X3_ORDEM
	'ZB0_TEMPAB'											, ;  // X3_CAMPO
	'N'														, ;  // X3_TIPO
	5														, ;  // X3_TAMANHO
	2														, ;  // X3_DECIMAL
	'Temp. Ambie.'										, ;  // X3_TITULO
	'Temp. Ambie.'										, ;  // X3_TITSPA
	'Room Tempera'										, ;  // X3_TITENG
	'Temperatura Ambiente'								, ;  // X3_DESCRIC
	'Temperatura ambiente'								, ;  // X3_DESCSPA
	'Room temperature'									, ;  // X3_DESCENG
	'@E 99.99'												, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'37'													, ;  // X3_ORDEM
	'ZB0_LOCAL'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	2														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Codigo Local'										, ;  // X3_TITULO
	'Codigo Local'										, ;  // X3_TITSPA
	'Codigo Local'										, ;  // X3_TITENG
	'Codigo do Local'										, ;  // X3_DESCRIC
	'Codigo do Local'										, ;  // X3_DESCSPA
	'Codigo do Local'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB0'													, ;  // X3_ARQUIVO
	'38'													, ;  // X3_ORDEM
	'ZB0_PGTVIS'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	1														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Pgto.Vista'											, ;  // X3_TITULO
	'Pgto.Vista'											, ;  // X3_TITSPA
	'Pgto.Vista'											, ;  // X3_TITENG
	'Pagamento a Vista'									, ;  // X3_DESCRIC
	'Pagamento a Vista'									, ;  // X3_DESCSPA
	'Pagamento a Vista'									, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	'"N"'													, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'A'														, ;  // X3_VISUAL
	'R'														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	'Pertence("SN")'										, ;  // X3_VLDUSER
	'S=Sim;N=Nao'											, ;  // X3_CBOX
	'S=Sim;N=Nao'											, ;  // X3_CBOXSPA
	'S=Sim;N=Nao'											, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

//
// Tabela SC5
//

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'69'													, ;  // X3_ORDEM
	'C5_MENNOTA'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	250														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Mens.p/ Nota'										, ;  // X3_TITULO
	'Mens.p.Fact.'										, ;  // X3_TITSPA
	'NF Message'											, ;  // X3_TITENG
	'Mensagem para Nota Fiscal'							, ;  // X3_DESCRIC
	'Mensaje para la Factura'							, ;  // X3_DESCSPA
	'Message for Invoice'								, ;  // X3_DESCENG
	'@S45'													, ;  // X3_PICTURE
	'texto().Or.Vazio()'									, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	''														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'D8'													, ;  // X3_ORDEM
	'C5_XNUMCE'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'N˙mero da CE'										, ;  // X3_TITULO
	'N˙mero CE'											, ;  // X3_TITSPA
	'EC Number'											, ;  // X3_TITENG
	'Numero da CE'										, ;  // X3_DESCRIC
	'N˙mero CE'											, ;  // X3_DESCSPA
	'EC Number'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'D9'													, ;  // X3_ORDEM
	'C5_XDTEMIS'											, ;  // X3_CAMPO
	'D'														, ;  // X3_TIPO
	08														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Dt. Emis. CE'										, ;  // X3_TITULO
	'Fec.Emis. CE'										, ;  // X3_TITSPA
	'Issu.Date CE'										, ;  // X3_TITENG
	'Data Emiss„o CE'										, ;  // X3_DESCRIC
	'Fecha EmisiÛn CE'									, ;  // X3_DESCSPA
	'Issuance Date CE'									, ;  // X3_DESCENG
	''														, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'E0'													, ;  // X3_ORDEM
	'C5_XPREFIX'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	07														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Pref. Aeron.'										, ;  // X3_TITULO
	'Pref. Aeron.'										, ;  // X3_TITSPA
	'Pref. Aircr.'										, ;  // X3_TITENG
	'Prefixo Aeronave'									, ;  // X3_DESCRIC
	'Prefijo de Aeronaves'								, ;  // X3_DESCSPA
	'Prefix Aircraft'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'E1'													, ;  // X3_ORDEM
	'C5_XCTA'												, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'CTA'													, ;  // X3_TITULO
	'CTA'													, ;  // X3_TITSPA
	'CTA'													, ;  // X3_TITENG
	'CTA'													, ;  // X3_DESCRIC
	'CTA'													, ;  // X3_DESCSPA
	'CTA'													, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'E2'													, ;  // X3_ORDEM
	'C5_XHORINI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	05														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Hora Ini. CE'										, ;  // X3_TITULO
	'Tiempo Ini.CE'										, ;  // X3_TITSPA
	'Time Home CE'										, ;  // X3_TITENG
	'Hora Inicio CE'										, ;  // X3_DESCRIC
	'Tiempo Inicio CE'									, ;  // X3_DESCSPA
	'Hora Inicio CE'										, ;  // X3_DESCENG
	'99:99'												, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'E3'													, ;  // X3_ORDEM
	'C5_XHORFIM'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	05														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Hora TÈrm.CE'										, ;  // X3_TITULO
	'Hr.Final. CE'										, ;  // X3_TITSPA
	'Time End. CE'										, ;  // X3_TITENG
	'Hora TÈrmino CE'										, ;  // X3_DESCRIC
	'Hora FinalizaciÛn CE'								, ;  // X3_DESCSPA
	'Time Ending CE'										, ;  // X3_DESCENG
	'99:99'												, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'E4'													, ;  // X3_ORDEM
	'C5_XNUMVOO'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	10														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Num. Voo'												, ;  // X3_TITULO
	'N˙mero Vuelo'										, ;  // X3_TITSPA
	'Flight Number'										, ;  // X3_TITENG
	'N˙mero Voo'											, ;  // X3_DESCRIC
	'N˙mero Vuelo'										, ;  // X3_DESCSPA
	'Flight Number'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'E5'													, ;  // X3_ORDEM
	'C5_XTIPAER'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Tipo Aeronave'										, ;  // X3_TITULO
	'Tipo Aeronave'										, ;  // X3_TITSPA
	'Aircraft Type'										, ;  // X3_TITENG
	'Tipo Aeronave'										, ;  // X3_DESCRIC
	'Tipo de Aeronave'									, ;  // X3_DESCSPA
	'Aircraft Type'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'E6'													, ;  // X3_ORDEM
	'C5_XTSTVIS'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	05														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Teste Visual'										, ;  // X3_TITULO
	'Ensayo Visual'										, ;  // X3_TITSPA
	'Visual Test'											, ;  // X3_TITENG
	'Teste Visual'										, ;  // X3_DESCRIC
	'El Ensayo Visual'									, ;  // X3_DESCSPA
	'Visual Test'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'E7'													, ;  // X3_ORDEM
	'C5_XMATRIC'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	05														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Mat. Operador'										, ;  // X3_TITULO
	'Operador Registro'									, ;  // X3_TITSPA
	'Oper. Registration'									, ;  // X3_TITENG
	'MatrÌcula Operador'									, ;  // X3_DESCRIC
	'Operador de Registro'								, ;  // X3_DESCSPA
	'Operator registration'								, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'E8'													, ;  // X3_ORDEM
	'C5_XCODAER'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	03														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Cod.Aer.IATA'										, ;  // X3_TITULO
	'Cod.Aer.IATA'										, ;  // X3_TITSPA
	'Cod.Aer.IATA'										, ;  // X3_TITENG
	'Codigo Aeroporto IATA'								, ;  // X3_DESCRIC
	'CÛdigo del Aeropuerto IATA'						, ;  // X3_DESCSPA
	'Code Airport IATA'									, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'E9'													, ;  // X3_ORDEM
	'C5_XOBSERV'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	250														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Observ. CE'											, ;  // X3_TITULO
	'Observ. CE'											, ;  // X3_TITSPA
	'Comments CE'											, ;  // X3_TITENG
	'ObservaÁıes CE'										, ;  // X3_DESCRIC
	'Observaciones CE'									, ;  // X3_DESCSPA
	'Comments CE'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP
aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'F0'													, ;  // X3_ORDEM
	'C5_XPRCNEG'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	01														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'PreÁo Negociado'										, ;  // X3_TITULO
	'Precio NegociaciÛn'									, ;  // X3_TITSPA
	'Negotiated Price'									, ;  // X3_TITENG
	'PreÁo Negociado'										, ;  // X3_DESCRIC
	'Precio de NegociaciÛn'								, ;  // X3_DESCSPA
	'Negotiated Price'									, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	'Pertence("SN")'										, ;  // X3_VLDUSER
	'S=Sim;N=N„o'											, ;  // X3_CBOX
	'S=Si;N=No'											, ;  // X3_CBOXSPA
	'S=Yes;N=No'											, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'F1'													, ;  // X3_ORDEM
	'C5_XREGIST'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Reg. Medidor'										, ;  // X3_TITULO
	'Registro Metros'										, ;  // X3_TITSPA
	'Meter Registration'									, ;  // X3_TITENG
	'Registro do Medidor'								, ;  // X3_DESCRIC
	'Registro Metros'										, ;  // X3_DESCSPA
	'Meter Registration'									, ;  // X3_DESCENG
	'999999999999999'										, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'F2'													, ;  // X3_ORDEM
	'C5_XCODTA'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	6														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Cod. Tabela'											, ;  // X3_TITULO
	'Codigo Tabla'										, ;  // X3_TITSPA
	'Code Table'											, ;  // X3_TITENG
	'CÛdigo Tabela PreÁo'								, ;  // X3_DESCRIC
	'CÛdigo Tabla de precios'							, ;  // X3_DESCSPA
	'Code Table Price'									, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'F3'													, ;  // X3_ORDEM
	'C5_XREVTA'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	3														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Rev. Tabela'											, ;  // X3_TITULO
	'Rev. Tabla'											, ;  // X3_TITSPA
	'Rev. Table'											, ;  // X3_TITENG
	'Revis„o Tabela PreÁo'								, ;  // X3_DESCRIC
	'Tabla opiniÛn Precio'								, ;  // X3_DESCSPA
	'Review Table Price'									, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC5'													, ;  // X3_ARQUIVO
	'F5'													, ;  // X3_ORDEM
	'C5_XHORINT'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	5														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Hora Interm.'										, ;  // X3_TITULO
	'Hora Interm.'										, ;  // X3_TITSPA
	'Hora Interm.'										, ;  // X3_TITENG
	'Hora Intermediaria'									, ;  // X3_DESCRIC
	'Hora Intermediaria'									, ;  // X3_DESCSPA
	'Hora Intermediaria'									, ;  // X3_DESCENG
	'99:99'												, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'A'														, ;  // X3_VISUAL
	'R'														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

//
// Tabela EE7
//

aAdd( aSX3, { ;
	'EE7'													, ;  // X3_ARQUIVO
	'C9'													, ;  // X3_ORDEM
	'EE7_XNUMCE'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'N˙mero da CE'										, ;  // X3_TITULO
	'N˙mero CE'											, ;  // X3_TITSPA
	'EC Number'											, ;  // X3_TITENG
	'Numero da CE'										, ;  // X3_DESCRIC
	'N˙mero CE'											, ;  // X3_DESCSPA
	'EC Number'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'EE7'													, ;  // X3_ARQUIVO
	'D0'													, ;  // X3_ORDEM
	'EE7_XDTEMI'											, ;  // X3_CAMPO
	'D'														, ;  // X3_TIPO
	08														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Data Emiss„o'										, ;  // X3_TITULO
	'Fecha EmisiÛn'										, ;  // X3_TITSPA
	'Issuance Date'										, ;  // X3_TITENG
	'Data Emiss„o'										, ;  // X3_DESCRIC
	'Fecha EmisiÛn'										, ;  // X3_DESCSPA
	'Issuance Date'										, ;  // X3_DESCENG
	''														, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'EE7'													, ;  // X3_ARQUIVO
	'D1'													, ;  // X3_ORDEM
	'EE7_XPREFI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	07														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Pref. Aeron.'										, ;  // X3_TITULO
	'Pref. Aeron.'										, ;  // X3_TITSPA
	'Pref. Aircr.'										, ;  // X3_TITENG
	'Prefixo Aeronave'									, ;  // X3_DESCRIC
	'Prefijo de Aeronaves'								, ;  // X3_DESCSPA
	'Prefix Aircraft'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'EE7'													, ;  // X3_ARQUIVO
	'D2'													, ;  // X3_ORDEM
	'EE7_XCTA'												, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'CTA'													, ;  // X3_TITULO
	'CTA'													, ;  // X3_TITSPA
	'CTA'													, ;  // X3_TITENG
	'CTA'													, ;  // X3_DESCRIC
	'CTA'													, ;  // X3_DESCSPA
	'CTA'													, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'EE7'													, ;  // X3_ARQUIVO
	'D3'													, ;  // X3_ORDEM
	'EE7_XHORIN'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	05														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Hora Inicio'											, ;  // X3_TITULO
	'Tiempo Inicio'										, ;  // X3_TITSPA
	'Time Home'											, ;  // X3_TITENG
	'Hora Inicio'											, ;  // X3_DESCRIC
	'Tiempo Inicio'										, ;  // X3_DESCSPA
	'Hora Inicio'											, ;  // X3_DESCENG
	'99:99'												, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'EE7'													, ;  // X3_ARQUIVO
	'D4'													, ;  // X3_ORDEM
	'EE7_XHORFI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	05														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Hora TÈrmino'										, ;  // X3_TITULO
	'Hora FinalizaciÛn'									, ;  // X3_TITSPA
	'Time Ending'											, ;  // X3_TITENG
	'Hora TÈrmino'										, ;  // X3_DESCRIC
	'Hora FinalizaciÛn'									, ;  // X3_DESCSPA
	'Time Ending'											, ;  // X3_DESCENG
	'99:99'												, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'EE7'													, ;  // X3_ARQUIVO
	'D5'													, ;  // X3_ORDEM
	'EE7_XNUMVO'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	10														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Num. Voo'												, ;  // X3_TITULO
	'N˙mero Vuelo'										, ;  // X3_TITSPA
	'Flight Number'										, ;  // X3_TITENG
	'N˙mero Voo'											, ;  // X3_DESCRIC
	'N˙mero Vuelo'										, ;  // X3_DESCSPA
	'Flight Number'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'EE7'													, ;  // X3_ARQUIVO
	'D6'													, ;  // X3_ORDEM
	'EE7_XTIPAE'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Tipo Aeronave'										, ;  // X3_TITULO
	'Tipo Aeronave'										, ;  // X3_TITSPA
	'Aircraft Type'										, ;  // X3_TITENG
	'Tipo Aeronave'										, ;  // X3_DESCRIC
	'Tipo de Aeronave'									, ;  // X3_DESCSPA
	'Aircraft Type'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'EE7'													, ;  // X3_ARQUIVO
	'D7'													, ;  // X3_ORDEM
	'EE7_XTSTVI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	05														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Teste Visual'										, ;  // X3_TITULO
	'Ensayo Visual'										, ;  // X3_TITSPA
	'Visual Test'											, ;  // X3_TITENG
	'Teste Visual'										, ;  // X3_DESCRIC
	'El Ensayo Visual'									, ;  // X3_DESCSPA
	'Visual Test'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'EE7'													, ;  // X3_ARQUIVO
	'D8'													, ;  // X3_ORDEM
	'EE7_XMATRI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	05														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Mat. Operador'										, ;  // X3_TITULO
	'Operador Registro'									, ;  // X3_TITSPA
	'Oper. Registration'									, ;  // X3_TITENG
	'MatrÌcula Operador'									, ;  // X3_DESCRIC
	'Operador de Registro'								, ;  // X3_DESCSPA
	'Operator registration'								, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'EE7'													, ;  // X3_ARQUIVO
	'D9'													, ;  // X3_ORDEM
	'EE7_XCODAE'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	03														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Codigo Aeroporto'									, ;  // X3_TITULO
	'CÛdigo Aeropuerto'									, ;  // X3_TITSPA
	'Code Airport'										, ;  // X3_TITENG
	'Codigo Aeroporto'									, ;  // X3_DESCRIC
	'CÛdigo del Aeropuerto'								, ;  // X3_DESCSPA
	'Code Airport'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'EE7'													, ;  // X3_ARQUIVO
	'E0'													, ;  // X3_ORDEM
	'EE7_XOBSER'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	250														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'ObservaÁıes'											, ;  // X3_TITULO
	'Observaciones'										, ;  // X3_TITSPA
	'Comments'												, ;  // X3_TITENG
	'ObservaÁıes'											, ;  // X3_DESCRIC
	'Observaciones'										, ;  // X3_DESCSPA
	'Comments'												, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP
aAdd( aSX3, { ;
	'EE7'													, ;  // X3_ARQUIVO
	'E1'													, ;  // X3_ORDEM
	'EE7_XPRCNE'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	01														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'PreÁo Negociado'										, ;  // X3_TITULO
	'Precio NegociaciÛn'									, ;  // X3_TITSPA
	'Negotiated Price'									, ;  // X3_TITENG
	'PreÁo Negociado'										, ;  // X3_DESCRIC
	'Precio de NegociaciÛn'								, ;  // X3_DESCSPA
	'Negotiated Price'									, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	'Pertence("SN")'										, ;  // X3_VLDUSER
	'S=Sim;N=N„o'											, ;  // X3_CBOX
	'S=Si;N=No'											, ;  // X3_CBOXSPA
	'S=Yes;N=No'											, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'EE7'													, ;  // X3_ARQUIVO
	'E2'													, ;  // X3_ORDEM
	'EE7_XREGIS'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Reg. Medidor'										, ;  // X3_TITULO
	'Registro Metros'										, ;  // X3_TITSPA
	'Meter Registration'									, ;  // X3_TITENG
	'Registro do Medidor'								, ;  // X3_DESCRIC
	'Registro Metros'										, ;  // X3_DESCSPA
	'Meter Registration'									, ;  // X3_DESCENG
	'999999999999999'										, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'EE7'													, ;  // X3_ARQUIVO
	'E3'													, ;  // X3_ORDEM
	'EE7_XCODTA'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	6														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Cod. Tabela'											, ;  // X3_TITULO
	'Codigo Tabla'										, ;  // X3_TITSPA
	'Code Table'											, ;  // X3_TITENG
	'CÛdigo Tabela PreÁo'								, ;  // X3_DESCRIC
	'CÛdigo Tabla de precios'							, ;  // X3_DESCSPA
	'Code Table Price'									, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'EE7'													, ;  // X3_ARQUIVO
	'E4'													, ;  // X3_ORDEM
	'EE7_XREVTA'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	3														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Rev. Tabela'											, ;  // X3_TITULO
	'Rev. Tabla'											, ;  // X3_TITSPA
	'Rev. Table'											, ;  // X3_TITENG
	'Revis„o Tabela PreÁo'								, ;  // X3_DESCRIC
	'Tabla opiniÛn Precio'								, ;  // X3_DESCSPA
	'Review Table Price'									, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

//
// Tabela SA1
//

aAdd( aSX3, { ;
	'SA1'													, ;  // X3_ARQUIVO
	'P4'													, ;  // X3_ORDEM
	'A1_XCLISCC'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	01														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Car.Starling'										, ;  // X3_TITULO
	'Tar.Starling'										, ;  // X3_TITSPA
	'StarlingCard'										, ;  // X3_TITENG
	'Cart„o Starling'										, ;  // X3_DESCRIC
	'Tarjeta de Starling'								, ;  // X3_DESCSPA
	'Starling Card'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	'"N"'													, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	'Pertence("SN")'										, ;  // X3_VLDUSER
	'S=Sim;N=Nao'											, ;  // X3_CBOX
	'S=Si;N=No'											, ;  // X3_CBOXSPA
	'S=Yes;N=No'											, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SA1'													, ;  // X3_ARQUIVO
	'P5'													, ;  // X3_ORDEM
	'A1_XACFINA'											, ;  // X3_CAMPO
	'N'														, ;  // X3_TIPO
	05														, ;  // X3_TAMANHO
	2														, ;  // X3_DECIMAL
	'Acres.Finan.'										, ;  // X3_TITULO
	'Aum. Finan.'											, ;  // X3_TITSPA
	'Fin.Increase'										, ;  // X3_TITENG
	'AcrÈscimo Financeiro'								, ;  // X3_DESCRIC
	'Aumento financiera'									, ;  // X3_DESCSPA
	'Financial increase'									, ;  // X3_DESCENG
	'@E 99.99'												, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	'Positivo()'											, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SA1'													, ;  // X3_ARQUIVO
	'P6'													, ;  // X3_ORDEM
	'A1_XDESVOL'											, ;  // X3_CAMPO
	'N'														, ;  // X3_TIPO
	05														, ;  // X3_TAMANHO
	2														, ;  // X3_DECIMAL
	'Desc. Volume'										, ;  // X3_TITULO
	'Desc.Volumen'										, ;  // X3_TITSPA
	'Vol.Discount'										, ;  // X3_TITENG
	'Desconto de volume'									, ;  // X3_DESCRIC
	'Descuento por volumen'								, ;  // X3_DESCSPA
	'Volume Discount'										, ;  // X3_DESCENG
	'@E 99.99'												, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	'Positivo()'											, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SA1'													, ;  // X3_ARQUIVO
	'P7'													, ;  // X3_ORDEM
	'A1_XPRAZO'											, ;  // X3_CAMPO
	'N'														, ;  // X3_TIPO
	03														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Prazo Pgto.'											, ;  // X3_TITULO
	'Fecha Lim.Pg'										, ;  // X3_TITSPA
	'Dead.Payment'										, ;  // X3_TITENG
	'Prazo para pagamento'								, ;  // X3_DESCRIC
	'Fecha lÌmite de pago'								, ;  // X3_DESCSPA
	'Deadline for payment'								, ;  // X3_DESCENG
	'@E 999'												, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	'Positivo()'											, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SA1'													, ;  // X3_ARQUIVO
	'S3'													, ;  // X3_ORDEM
	'A1_XPEICMS'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	1														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Red.Per.ICMS'										, ;  // X3_TITULO
	'Red.Per.ICMS'										, ;  // X3_TITSPA
	'Red.Per.ICMS'										, ;  // X3_TITENG
	'Percentual ReduÁ„o ICMS'							, ;  // X3_DESCRIC
	'Percentual ReduÁ„o ICMS'							, ;  // X3_DESCSPA
	'Percentual ReduÁ„o ICMS'							, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	'"N"'													, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	'Pertence("SN")'										, ;  // X3_VLDUSER
	'S=Sim;N=Nao'											, ;  // X3_CBOX
	'S=Sim;N=Nao'											, ;  // X3_CBOXSPA
	'S=Sim;N=Nao'											, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

//
// Tabela SB1
//

aAdd( aSX3, { ;
	'SB1'													, ;  // X3_ARQUIVO
	'U1'													, ;  // X3_ORDEM
	'B1_XPRODCE'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	01														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Produto CE'											, ;  // X3_TITULO
	'Producto CE'											, ;  // X3_TITSPA
	'Product CE'											, ;  // X3_TITENG
	'Produto CE'											, ;  // X3_DESCRIC
	'Producto del CE'										, ;  // X3_DESCSPA
	'Product CE'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	'"N"'													, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	'Pertence("SN")'										, ;  // X3_VLDUSER
	'S=Sim;N=Nao'											, ;  // X3_CBOX
	'S=Si;N=No'											, ;  // X3_CBOXSPA
	'S=Yes;N=No'											, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

//
// Tabela ZB1
//

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'01'													, ;  // X3_ORDEM
	'ZB1_FILIAL'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	6														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Filial'												, ;  // X3_TITULO
	'Sucursal'												, ;  // X3_TITSPA
	'Branch'												, ;  // X3_TITENG
	'Filial do Sistema'									, ;  // X3_DESCRIC
	'Sucursal del Sistema'								, ;  // X3_DESCSPA
	'System Branch'										, ;  // X3_DESCENG
	''														, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)	, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	'033'													, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'02'													, ;  // X3_ORDEM
	'ZB1_CONTRA'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'N˙m.Contrato'										, ;  // X3_TITULO
	'N˙m.Contrato'										, ;  // X3_TITSPA
	'Contr.Number'										, ;  // X3_TITENG
	'Numero do Contrato'									, ;  // X3_DESCRIC
	'N˙mero de Contrato'									, ;  // X3_DESCSPA
	'Contact number'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'03'													, ;  // X3_ORDEM
	'ZB1_ATIVO'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	01														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Ativo'												, ;  // X3_TITULO
	'Activo'												, ;  // X3_TITSPA
	'Active'												, ;  // X3_TITENG
	'Contrato ativo'										, ;  // X3_DESCRIC
	'Contrato vigente'									, ;  // X3_DESCSPA
	'Active contract'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	'"N"'													, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	'Pertence("SN")'										, ;  // X3_VLDUSER
	'S=Sim;N=Nao'											, ;  // X3_CBOX
	'S=Si;N=No'											, ;  // X3_CBOXSPA
	'S=Yes;N=No'											, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'04'													, ;  // X3_ORDEM
	'ZB1_TPCONT'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	01														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Tp. Contrato'										, ;  // X3_TITULO
	'Tp. Empleo'											, ;  // X3_TITSPA
	'Type Cont.'											, ;  // X3_TITENG
	'Tipo Contrato'										, ;  // X3_DESCRIC
	'Tipo de Empleo'										, ;  // X3_DESCSPA
	'Type of contract'									, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	'"N"'													, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	'Pertence("NR")'										, ;  // X3_VLDUSER
	'N=Normal;R=Residual'								, ;  // X3_CBOX
	'N=Normal;R=Residual'								, ;  // X3_CBOXSPA
	'N=Normal;R=Residue'									, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'05'													, ;  // X3_ORDEM
	'ZB1_CODCLI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	06														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Cod. Cliente'										, ;  // X3_TITULO
	'Cod. Cliente'										, ;  // X3_TITSPA
	'Cod. Client'											, ;  // X3_TITENG
	'CÛdigo do Cliente'									, ;  // X3_DESCRIC
	'El cÛdigo de cliente'								, ;  // X3_DESCSPA
	'Client code'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	'SA1'													, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	'S'														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	'U_CPClient()'										, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'06'													, ;  // X3_ORDEM
	'ZB1_LOJCLI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	02														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Loja Cliente'										, ;  // X3_TITULO
	'Tienda Cliente'										, ;  // X3_TITSPA
	'Unit Client'											, ;  // X3_TITENG
	'Loja Cliente'										, ;  // X3_DESCRIC
	'Tienda Cliente'										, ;  // X3_DESCSPA
	'Unit Client'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	'S'														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	'U_CPClieLo()'										, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'07'													, ;  // X3_ORDEM
	'ZB1_NOMCLI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	40														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Nome Cliente'										, ;  // X3_TITULO
	'Nombre Clien'										, ;  // X3_TITSPA
	'Client Name'											, ;  // X3_TITENG
	'Nome do cliente'										, ;  // X3_DESCRIC
	'Nombre del cliente'									, ;  // X3_DESCSPA
	'Client Name'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'08'													, ;  // X3_ORDEM
	'ZB1_DTINI'											, ;  // X3_CAMPO
	'D'														, ;  // X3_TIPO
	08														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Data Inicial'										, ;  // X3_TITULO
	'Fecha Inicia'										, ;  // X3_TITSPA
	'Start Date'											, ;  // X3_TITENG
	'Data Inicial'										, ;  // X3_DESCRIC
	'Fecha Inicial'										, ;  // X3_DESCSPA
	'Start Date'											, ;  // X3_DESCENG
	''														, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'09'													, ;  // X3_ORDEM
	'ZB1_DTFIM'											, ;  // X3_CAMPO
	'D'														, ;  // X3_TIPO
	08														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Data Final'											, ;  // X3_TITULO
	'Fecha Final'											, ;  // X3_TITSPA
	'Final Date'											, ;  // X3_TITENG
	'Data Final'											, ;  // X3_DESCRIC
	'Fecha Final'											, ;  // X3_DESCSPA
	'Final Date'											, ;  // X3_DESCENG
	''														, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'10'													, ;  // X3_ORDEM
	'ZB1_OBSERV'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	250														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Observacao'											, ;  // X3_TITULO
	'Observacion'											, ;  // X3_TITSPA
	'Note'													, ;  // X3_TITENG
	'Observacao'											, ;  // X3_DESCRIC
	'Observacion'											, ;  // X3_DESCSPA
	'Note'													, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'11'													, ;  // X3_ORDEM
	'ZB1_STATUS'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	1														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Status'												, ;  // X3_TITULO
	'Estado'												, ;  // X3_TITSPA
	'Status'												, ;  // X3_TITENG
	'Status do Contrato'									, ;  // X3_DESCRIC
	'Estado de Contrato'									, ;  // X3_DESCSPA
	'Contratic Status'									, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP
aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'12'													, ;  // X3_ORDEM
	'ZB1_USUARI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	20														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Nome Usuario'										, ;  // X3_TITULO
	'Nomb.Usuario'										, ;  // X3_TITSPA
	'User Name'											, ;  // X3_TITENG
	'Nome do Usuario'										, ;  // X3_DESCRIC
	'Nombre del Usuario'									, ;  // X3_DESCSPA
	'User Name'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'13'													, ;  // X3_ORDEM
	'ZB1_DTINCL'											, ;  // X3_CAMPO
	'D'														, ;  // X3_TIPO
	08														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Dt. Inclusao'										, ;  // X3_TITULO
	'Fecha Inclu.'										, ;  // X3_TITSPA
	'Inclusion Dt'										, ;  // X3_TITENG
	'Data de inclusao Contrato Parceria'				, ;  // X3_DESCRIC
	'Fecha inclusion en Contrato Parceria'				, ;  // X3_DESCSPA
	'Contrato Parceria Inclusion Date'					, ;  // X3_DESCENG
	''														, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'14'													, ;  // X3_ORDEM
	'ZB1_HRINCL'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	08														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Hr. Inclusao'										, ;  // X3_TITULO
	'Tiempo Inclu.'										, ;  // X3_TITSPA
	'Inclus. hour'										, ;  // X3_TITENG
	'Hora de inclusao Contrato Parceria'				, ;  // X3_DESCRIC
	'Tiempo inclusion en Contrato Parceria'			, ;  // X3_DESCSPA
	'Contrato Parceria Inclusion hour'					, ;  // X3_DESCENG
	'99:99:99'												, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'15'													, ;  // X3_ORDEM
	'ZB1_BASE'												, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	06														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Base/Filial'											, ;  // X3_TITULO
	'Base/Filial'											, ;  // X3_TITSPA
	'Base/Filial'											, ;  // X3_TITENG
	'Base/Filial'											, ;  // X3_DESCRIC
	'Base/Filial'											, ;  // X3_DESCSPA
	'Base/Filial'											, ;  // X3_DESCENG
	'999999'												, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	'SM0'													, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'16'													, ;  // X3_ORDEM
	'ZB1_NFREM'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	09														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'NF. Remessa'											, ;  // X3_TITULO
	'NF. Remessa'											, ;  // X3_TITSPA
	'NF. Remessa'											, ;  // X3_TITENG
	'Nota Fiscal de Remessa'								, ;  // X3_DESCRIC
	'Nota Fiscal de Remessa'								, ;  // X3_DESCSPA
	'Nota Fiscal de Remessa'								, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	'iif(M->ZB1_TPCONT="R",.T.,.F.)'					, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'17'													, ;  // X3_ORDEM
	'ZB1_SERNF'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	03														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Serie NF Rem'										, ;  // X3_TITULO
	'Serie NF Rem'										, ;  // X3_TITSPA
	'Serie NF Rem'										, ;  // X3_TITENG
	'Serie Nota Fiscal Remessa'							, ;  // X3_DESCRIC
	'Serie Nota Fiscal Remessa'							, ;  // X3_DESCSPA
	'Serie Nota Fiscal Remessa'							, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	'iif(M->ZB1_TPCONT="R",.T.,.F.)'					, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

//
// Tabela ZB2
//

aAdd( aSX3, { ;
	'ZB2'													, ;  // X3_ARQUIVO
	'01'													, ;  // X3_ORDEM
	'ZB2_FILIAL'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	6														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Filial'												, ;  // X3_TITULO
	'Sucursal'												, ;  // X3_TITSPA
	'Branch'												, ;  // X3_TITENG
	'Filial do Sistema'									, ;  // X3_DESCRIC
	'Sucursal del Sistema'								, ;  // X3_DESCSPA
	'System Branch'										, ;  // X3_DESCENG
	''														, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)	, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	'033'													, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB2'													, ;  // X3_ARQUIVO
	'02'													, ;  // X3_ORDEM
	'ZB2_ITEM'												, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	02														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Item'													, ;  // X3_TITULO
	'Item'													, ;  // X3_TITSPA
	'Item'													, ;  // X3_TITENG
	'Numero do Item do Contrato'						, ;  // X3_DESCRIC
	'N˙mero del ArtÌculo de Contrato'					, ;  // X3_DESCSPA
	'Number of the Contract Item'						, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB2'													, ;  // X3_ARQUIVO
	'03'													, ;  // X3_ORDEM
	'ZB2_PRODUT'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Produto'												, ;  // X3_TITULO
	'Producto'												, ;  // X3_TITSPA
	'Product'												, ;  // X3_TITENG
	'Codigo do Produto'									, ;  // X3_DESCRIC
	'Codigo del Producto'								, ;  // X3_DESCSPA
	'Code of Product'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	'SB1'													, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	'U_CPProdut()'										, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB2'													, ;  // X3_ARQUIVO
	'04'													, ;  // X3_ORDEM
	'ZB2_DESPRO'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	30														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Descr. Prod.'										, ;  // X3_TITULO
	'Descr. Prod.'										, ;  // X3_TITSPA
	'Product Desc'										, ;  // X3_TITENG
	'Descricao do Produto'								, ;  // X3_DESCRIC
	'Descripcion del Producto'							, ;  // X3_DESCSPA
	'Description of Product'								, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB2'													, ;  // X3_ARQUIVO
	'05'													, ;  // X3_ORDEM
	'ZB2_QTDE'												, ;  // X3_CAMPO
	'N'														, ;  // X3_TIPO
	06														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Quantidade'											, ;  // X3_TITULO
	'Cantidad'												, ;  // X3_TITSPA
	'Amount'												, ;  // X3_TITENG
	'Quantidade'											, ;  // X3_DESCRIC
	'Cantidad'												, ;  // X3_DESCSPA
	'Amount'												, ;  // X3_DESCENG
	'@E 999999'											, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	Chr(128)												, ;  // X3_OBRIGAT
	'U_CPQtde()'											, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB2'													, ;  // X3_ARQUIVO
	'06'													, ;  // X3_ORDEM
	'ZB2_PRCVEN'											, ;  // X3_CAMPO
	'N'														, ;  // X3_TIPO
	12														, ;  // X3_TAMANHO
	5														, ;  // X3_DECIMAL
	'Valor'												, ;  // X3_TITULO
	'Valor'												, ;  // X3_TITSPA
	'Value'												, ;  // X3_TITENG
	'Valor'												, ;  // X3_DESCRIC
	'Valor'												, ;  // X3_DESCSPA
	'Value'												, ;  // X3_DESCENG
	'@E 999,999.99999'									, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	'Positivo()'											, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB2'													, ;  // X3_ARQUIVO
	'07'													, ;  // X3_ORDEM
	'ZB2_PREBAS'											, ;  // X3_CAMPO
	'N'														, ;  // X3_TIPO
	12														, ;  // X3_TAMANHO
	5														, ;  // X3_DECIMAL
	'Preco Basico'										, ;  // X3_TITULO
	'Preco Basico'										, ;  // X3_TITSPA
	'Preco Basico'										, ;  // X3_TITENG
	'Preco Basico'										, ;  // X3_DESCRIC
	'Preco Basico'										, ;  // X3_DESCSPA
	'Preco Basico'										, ;  // X3_DESCENG
	'@E 999,999.99999'									, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	'Positivo()'											, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB2'													, ;  // X3_ARQUIVO
	'08'													, ;  // X3_ORDEM
	'ZB2_SALDO'											, ;  // X3_CAMPO
	'N'														, ;  // X3_TIPO
	06														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Saldo'												, ;  // X3_TITULO
	'Equilibrio'											, ;  // X3_TITSPA
	'Balance'												, ;  // X3_TITENG
	'Saldo do Contrato'									, ;  // X3_DESCRIC
	'Saldo del Contrato'									, ;  // X3_DESCSPA
	'Balance of the Contract'							, ;  // X3_DESCENG
	'@E 999999'											, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	''														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB2'													, ;  // X3_ARQUIVO
	'09'													, ;  // X3_ORDEM
	'ZB2_CONTRA'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'N˙m.Contrato'										, ;  // X3_TITULO
	'N˙m.Contrato'										, ;  // X3_TITSPA
	'Contr.Number'										, ;  // X3_TITENG
	'Numero do Contrato'									, ;  // X3_DESCRIC
	'N˙mero de Contrato'									, ;  // X3_DESCSPA
	'Contact number'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB2'													, ;  // X3_ARQUIVO
	'10'													, ;  // X3_ORDEM
	'ZB2_CODCLI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	06														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Cod. Cliente'										, ;  // X3_TITULO
	'Cod. Cliente'										, ;  // X3_TITSPA
	'Cod. Client'											, ;  // X3_TITENG
	'CÛdigo do Cliente'									, ;  // X3_DESCRIC
	'El cÛdigo de cliente'								, ;  // X3_DESCSPA
	'Client code'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	'SA1'													, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB2'													, ;  // X3_ARQUIVO
	'11'													, ;  // X3_ORDEM
	'ZB2_LOJCLI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	02														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Loja Cliente'										, ;  // X3_TITULO
	'Tienda Cliente'										, ;  // X3_TITSPA
	'Unit Client'											, ;  // X3_TITENG
	'Loja Cliente'										, ;  // X3_DESCRIC
	'Tienda Cliente'										, ;  // X3_DESCSPA
	'Unit Client'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB2'													, ;  // X3_ARQUIVO
	'12'													, ;  // X3_ORDEM
	'ZB2_DTINI'											, ;  // X3_CAMPO
	'D'														, ;  // X3_TIPO
	08														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Data Inicial'										, ;  // X3_TITULO
	'Fecha Inicia'										, ;  // X3_TITSPA
	'Start Date'											, ;  // X3_TITENG
	'Data Inicial'										, ;  // X3_DESCRIC
	'Fecha Inicial'										, ;  // X3_DESCSPA
	'Start Date'											, ;  // X3_DESCENG
	''														, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'ZB1'													, ;  // X3_ARQUIVO
	'13'													, ;  // X3_ORDEM
	'ZB2_BASE'												, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	06														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Base/Filial'											, ;  // X3_TITULO
	'Base/Filial'											, ;  // X3_TITSPA
	'Base/Filial'											, ;  // X3_TITENG
	'Base/Filial'											, ;  // X3_DESCRIC
	'Base/Filial'											, ;  // X3_DESCSPA
	'Base/Filial'											, ;  // X3_DESCENG
	'999999'												, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

//
// Tabela SC9
//

aAdd( aSX3, { ;
	'SC9'													, ;  // X3_ARQUIVO
	'66'													, ;  // X3_ORDEM
	'C9_XNUMCE'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	15														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'N˙mero da CE'										, ;  // X3_TITULO
	'N˙mero CE'											, ;  // X3_TITSPA
	'EC Number'											, ;  // X3_TITENG
	'Numero da CE'										, ;  // X3_DESCRIC
	'N˙mero CE'											, ;  // X3_DESCSPA
	'EC Number'											, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	''														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

//
// Atualizando dicion·rio
//

nPosArq := aScan( aEstrut, { |x| AllTrim( x ) == 'X3_ARQUIVO' } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x ) == 'X3_ORDEM'   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x ) == 'X3_CAMPO'   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x ) == 'X3_TAMANHO' } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x ) == 'X3_GRPSXG'  } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( 'SX3' )
dbSetOrder( 2 )
cAliasAtu := ''

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajsuta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				cTexto += 'O tamanho do campo ' + aSX3[nI][nPosCpo] + ' nao atualizado e foi mantido em ['
				cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + ']'+ CRLF
				cTexto += '   por pertencer ao grupo de campos [' + SX3->X3_GRPSXG + ']' + CRLF + CRLF
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + '/'
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := '00'
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + 'ZZ', .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( 'SX3', .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == 2    // Ordem
				FieldPut( FieldPos( aEstrut[nJ] ), cSeqAtu )

			ElseIf FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		cTexto += 'Criado o campo ' + aSX3[nI][nPosCpo] + CRLF

	Else

		//
		// Verifica se o campo faz parte de um grupo e ajsuta tamanho
		//
		If !Empty( SX3->X3_GRPSXG ) .AND. SX3->X3_GRPSXG <> aSX3[nI][nPosSXG]
			SXG->( dbSetOrder( 1 ) )
			If SXG->( MSSeek( SX3->X3_GRPSXG ) )
				If aSX3[nI][nPosTam] <> SXG->XG_SIZE
					aSX3[nI][nPosTam] := SXG->XG_SIZE
					cTexto += 'O tamanho do campo ' + aSX3[nI][nPosCpo] + ' nao atualizado e foi mantido em ['
					cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + ']'+ CRLF
					cTexto += '   por pertencer ao grupo de campos [' + SX3->X3_GRPSXG + ']' + CRLF + CRLF
				EndIf
			EndIf
		EndIf

		//
		// Verifica todos os campos
		//
		For nJ := 1 To Len( aSX3[nI] )

			//
			// Se o campo estiver diferente da estrutura
			//
			If aEstrut[nJ] == SX3->( FieldName( nJ ) ) .AND. ;
				PadR( StrTran( AllToChar( SX3->( FieldGet( nJ ) ) ), ' ', '' ), 250 ) <> ;
				PadR( StrTran( AllToChar( aSX3[nI][nJ] )           , ' ', '' ), 250 ) .AND. ;
				AllTrim( SX3->( FieldName( nJ ) ) ) <> 'X3_ORDEM'

				cMsg := 'O campo ' + aSX3[nI][nPosCpo] + ' est· com o ' + SX3->( FieldName( nJ ) ) + ;
				' com o conte˙do' + CRLF + ;
				'[' + RTrim( AllToChar( SX3->( FieldGet( nJ ) ) ) ) + ']' + CRLF + ;
				'que ser· substituido pelo NOVO conte˙do' + CRLF + ;
				'[' + RTrim( AllToChar( aSX3[nI][nJ] ) ) + ']' + CRLF + ;
				'Deseja substituir ? '

				If      lTodosSim
					nOpcA := 1
				ElseIf  lTodosNao
					nOpcA := 2
				Else
					nOpcA := Aviso( 'ATUALIZA«√O DE DICION¡RIOS E TABELAS', cMsg, { 'Sim', 'N„o', 'Sim p/Todos', 'N„o p/Todos' }, 3,'DiferenÁa de conte˙do - SX3' )
					lTodosSim := ( nOpcA == 3 )
					lTodosNao := ( nOpcA == 4 )

					If lTodosSim
						nOpcA := 1
						lTodosSim := ApMsgNoYes( 'Foi selecionada a opÁ„o de REALIZAR TODAS alteraÁıes no SX3 e N√O MOSTRAR mais a tela de aviso.' + CRLF + 'Confirma a aÁ„o [Sim p/Todos] ?' )
					EndIf

					If lTodosNao
						nOpcA := 2
						lTodosNao := ApMsgNoYes( 'Foi selecionada a opÁ„o de N√O REALIZAR nenhuma alteraÁ„o no SX3 que esteja diferente da base e N√O MOSTRAR mais a tela de aviso.' + CRLF + 'Confirma esta aÁ„o [N„o p/Todos]?' )
					EndIf

				EndIf

				If nOpcA == 1
					cTexto += 'Alterado o campo ' + aSX3[nI][nPosCpo] + CRLF
					cTexto += '   ' + PadR( SX3->( FieldName( nJ ) ), 10 ) + ' de [' + AllToChar( SX3->( FieldGet( nJ ) ) ) + ']' + CRLF
					cTexto += '            para [' + AllToChar( aSX3[nI][nJ] )          + ']' + CRLF + CRLF

					RecLock( 'SX3', .F. )
					FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )
					dbCommit()
					MsUnLock()

				EndIf

			EndIf

		Next

	EndIf

	oProcess:IncRegua2( 'Atualizando Campos de Tabelas (SX3)...' )

Next nI

cTexto += CRLF + 'Final da Atualizacao do SX3' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return aClone( aSX3 )


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSAtuSIX ∫ Autor ≥ Microsiga          ∫ Data ≥  25/07/2011 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao do SIX - Indices       ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuSIX - Gerado por EXPORDIC / Upd. V.4.01 EFS           ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuSIX( cTexto )
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

cTexto  += 'Inicio da Atualizacao do SIX' + CRLF + CRLF

aEstrut := { 'INDICE'  , 'ORDEM'  , 'CHAVE' , 'DESCRICAO' , 'DESCSPA'  , ;
             'DESCENG' , 'PROPRI' , 'F3'    , 'NICKNAME'  , 'SHOWPESQ' }   

//  Tabela ZB0

aAdd( aSIX, { ;
	'ZB0'																													, ; //INDICE
	'1'																														, ; //ORDEM
	'ZB0_FILIAL+ZB0_NUMCE+ZB0_CODCLI+ZB0_LOJCLI+DTOS(ZB0_DTEMIS)+ZB0_HORINI'										, ; //CHAVE
	'Filial + CE + Cliente + Loja + Emiss„o + Hora Inicial'															, ; //DESCRICAO
	'Sucursal + CE + Cliente + Loja + Emiss„o + Hora Inicial'														, ; //DESCSPA
	'System + CE + Cliente + Loja + Emiss„o + Hora Inicial'															, ; //DESCENG
	'U'																														, ; //PROPRI
	''																														, ; //F3
	'ZB00000001'																											, ; //NICKNAME
	'S'																														} ) //SHOWPESQ

//  Tabela ZB1

aAdd( aSIX, { ;
	'ZB1'																													, ; //INDICE
	'1'																														, ; //ORDEM
	'ZB1_FILIAL+ZB1_BASE+ZB1_CONTRA+ZB1_CODCLI+ZB1_LOJCLI+DTOS(ZB1_DTINI)'										, ; //CHAVE
	'Filial + Base/Filial + N˙m.Contrato + Cod. Cliente + Loja Cliente + Data Inicial'							, ; //DESCRICAO
	'Sucursal + Base/Filial + N˙m.Contrato + Cod. Cliente + Tienda Cliente + Fecha Data'						, ; //DESCSPA
	'System + Base/Filial + Contr.Number + Cod. Client + Unit Client + Start Date'								, ; //DESCENG
	'U'																														, ; //PROPRI
	''																														, ; //F3
	'ZB10000001'																											, ; //NICKNAME
	'S'																														} ) //SHOWPESQ

//  Tabela ZB2

aAdd( aSIX, { ;
	'ZB2'																													, ; //INDICE
	'1'													 							 			 							, ; //ORDEM
	'ZB2_FILIAL+ ZB2_BASE +ZB2_CONTRA+ZB2_CODCLI+ZB2_LOJCLI+DTOS(ZB2_DTINI)+ZB2_ITEM+ZB2_PRODUT'				, ; //CHAVE
	'Filial + Base/Filial + N˙m.Contrato + Cod. Cliente + Loja Cliente + Data Inicial + Item + Produto'	  	, ; //DESCRICAO
	'Sucursal + Base/Filial + N˙m.Contrato + Cod. Cliente + Tienda Cliente + Fecha Data + Item + Producto'	, ; //DESCSPA
	'System + Base/Filial + Contr.Number + Cod. Client + Unit Client + Start Date + Item + Produt'		  		, ; //DESCENG
	'U'																														, ; //PROPRI
	''																														, ; //F3
	'ZB20000001'																											, ; //NICKNAME
	'S'																														} ) //SHOWPESQ

//
// Atualizando dicion·rio
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( 'SIX' )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		RecLock( 'SIX', .T. )
		lDelInd := .F.
		cTexto += 'Õndice criado ' + aSIX[nI][1] + '/' + aSIX[nI][2] + ' - ' + aSIX[nI][3] + CRLF
	Else
		lAlt := .F.
		RecLock( 'SIX', .F. )
	EndIf

	If !StrTran( Upper( AllTrim( CHAVE )       ), ' ', '') == ;
	    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), ' ', '' )
		aAdd( aArqUpd, aSIX[nI][1] )

		If lAlt
			lDelInd := .T.  // Se for alteracao precisa apagar o indice do banco
			cTexto += 'Õndice alterado ' + aSIX[nI][1] + '/' + aSIX[nI][2] + ' - ' + aSIX[nI][3] + CRLF
		EndIf

		For nJ := 1 To Len( aSIX[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
			EndIf
		Next nJ

		If lDelInd
			TcInternal( 60, RetSqlName( aSIX[nI][1] ) + '|' + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] ) // Exclui sem precisar baixar o TOP
		EndIf

	EndIf

	dbCommit()
	MsUnLock()

	oProcess:IncRegua2( 'Atualizando Ìndices...' )

Next nI

cTexto += CRLF + 'Final da Atualizacao do SIX' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return aClone( aSIX )


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSAtuSX6 ∫ Autor ≥ Microsiga          ∫ Data ≥  25/07/2011 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao do SX6 - Par‚metros    ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuSX6 - Gerado por EXPORDIC / Upd. V.4.01 EFS           ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuSX6( cTexto )
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ''
Local cMsg      := ''
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

cTexto  += 'Inicio da Atualizacao do SX6' + CRLF + CRLF

aEstrut := { 'X6_FIL'    , 'X6_VAR'  , 'X6_TIPO'   , 'X6_DESCRIC', 'X6_DSCSPA' , 'X6_DSCENG' , 'X6_DESC1'  , 'X6_DSCSPA1',;
             'X6_DSCENG1', 'X6_DESC2', 'X6_DSCSPA2', 'X6_DSCENG2', 'X6_CONTEUD', 'X6_CONTSPA', 'X6_CONTENG', 'X6_PROPRI' , 'X6_PYME' }

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCEPNAC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CE - TES DO PEDIDO DE VENDA - NACIONAL'							, ; //X6_DESCRIC
	'CE - TES SOLICITUD DE VENTAS - NACIONAL'							, ; //X6_DSCSPA
	'CE - TES SALES APPLICATION - NATIONAL'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'501'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCEPEXP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CE - TES DO PEDIDO DE VENDA - EXPORTA«√O'						, ; //X6_DESCRIC
	'CE - TES ORDEN DE VENTA - EXPORTACI”N'							, ; //X6_DSCSPA
	'CE - TES SALES ORDER - EXPORT'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'502'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCEPTNA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CE - TES PODER DE TERCEIROS - NACIONAL'							, ; //X6_DESCRIC
	'CE - TES TERCERA POTENCIA - NACIONAL'								, ; //X6_DSCSPA
	'CE - TES THIRD POWER - NATIONAL'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'501'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCEPTEX'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CE - TES PODER DE TERCEIROS - EXPORTA«√O'						, ; //X6_DESCRIC
	'CE - TES TERCERA POTENCIA - EXPORTACI”N'							, ; //X6_DSCSPA
	'CE - TES THIRD POWER - EXPORT'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'502'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCEJENA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CE - CODIGO PRODUTO JET - NACIONAL'								, ; //X6_DESCRIC
	'CE - C”DIGO DEL PRODUCTO JET - NACIONAL'							, ; //X6_DSCSPA
	'CE - PRODUCT CODE JET - NATIONAL'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'JET - N'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCEJEEX'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CE - CODIGO PRODUTO JET - EXPORTA«√O'								, ; //X6_DESCRIC
	'CE - C”DIGO DEL PRODUCTO - EXPORTACI”N'							, ; //X6_DSCSPA
	'CE - PRODUCT CODE JET - EXPORT'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'JET - E'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCEAVGA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CE - CODIGO PRODUTO AVGAS'											, ; //X6_DESCRIC
	'CE - C”DIGO DEL PRODUCTO AVGAS'									, ; //X6_DSCSPA
	'CE - PRODUCT CODE AVGAS'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'AVGAS'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCEPRIS'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CE - CODIGO PRODUTO PRIST'											, ; //X6_DESCRIC
	'CE - C”DIGO DEL PRODUCTO PRIST'									, ; //X6_DSCSPA
	'CE - PRODUCT CODE PRIST'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'PRIST'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCETSCC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CE - CODIGO DA TABELA DE PRE«O SCC'								, ; //X6_DESCRIC
	'CE - El SCC cÛdigo de precio TABLA'								, ; //X6_DSCSPA
	'CE - THE PRICE TABLE SCC CODE'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SCC'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCELSCC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CE - CODIGO DA LOJA DA TABELA DE PRE«O SCC'						, ; //X6_DESCRIC
	'CE - C”DIGO DE TALLER DE PRECIOS TABLA SCC'						, ; //X6_DSCSPA
	'CE - CODE SHOP PRICE TABLE SCC'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'01'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCETPAD'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CE - CODIGO DA TABELA DE PRE«O PADR√O'							, ; //X6_DESCRIC
	'CE - PRECIO EST¡NDAR TABLA DE C”DIGOS'							, ; //X6_DSCSPA
	'CE - STANDARD PRICE TABLE CODE'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'PADRAO'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCELPAD'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CE - CODIGO DA LOJA DA TABELA DE PRE«O PADR√O'					, ; //X6_DESCRIC
	'CE - PRECIO EST¡NDAR TABLA TIENDA C”DIGOS'						, ; //X6_DSCSPA
	'CE - STANDARD PRICE TABLE STORE CODE'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'01'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCEVDMI'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'CE - PRE«O DE VENDA MÕNIMO'										, ; //X6_DESCRIC
	'CE - PRECIO DE VENTA MÕNIMO'										, ; //X6_DSCSPA
	'CE - PRICE MINIMUM SALE'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1.00'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCEVDMA'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'CE - PRE«O DE VENDA M¡XIMO'										, ; //X6_DESCRIC
	'CE - PRECIO DE VENTA M¡XIMO'										, ; //X6_DSCSPA
	'CE - MAXIMUM SELLING PRICE'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'10.00'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCEUFIC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CE - ESTADOS COM ISENCAO ICMS - AVGAS'							, ; //X6_DESCRIC
	'CE - ESTADOS COM ISENCAO ICMS - AVGAS'							, ; //X6_DSCSPA
	'CE - ESTADOS COM ISENCAO ICMS - AVGAS'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'ESGOMTRJ'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XJETNIC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Venda interna de JET NAC destinado a consumidor'				, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ou usuario final sem ICMS e com ICMS ST retido'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'anteriormente.'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'517'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XJETNCR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Venda interna de JET NAC destinado a consumidor'				, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ou usuario final com reducao de BC do ICMS.'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'516'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XJETNIN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Venda interestadual de JET NAC destinado a'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'consumidor ou usuario final sem ICMS e com'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'ICMS ST.'																, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'515'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XAVGNIC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Venda interna de AVGAS destinado a consumidor'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ou usuario final sem ICMS e com ICMS ST retido'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'anteriormente.'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'505'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XAVGNIN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Venda interestadual de AVGAS destinado a'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'consumidor ou usuario final sem ICMS'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'e com ICMS ST.'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'504'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XAPRIST'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES venda de PRIST no CE'											, ; //X6_DESCRIC
	'TES venda de PRIST no CE'											, ; //X6_DSCSPA
	'TES venda de PRIST no CE'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'532'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCECPNA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condicao pagamento a vista no CE - Nacional'						, ; //X6_DESCRIC
	'Condicao pagamento a vista no CE - Nacional'						, ; //X6_DSCSPA
	'Condicao pagamento a vista no CE - Nacional'						, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0001'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCECPIN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Cond. pgto. a vista e numero dias no CE - Exportac'				, ; //X6_DESCRIC
	'Cond. pgto. a vista e numero dias no CE - Exportac'				, ; //X6_DSCSPA
	'Cond. pgto. a vista e numero dias no CE - Exportac'				, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00001;-1'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XTAVGAS'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES venda de AVGAS no CE exportacao'								, ; //X6_DESCRIC
	'TES venda de AVGAS no CE exportacao'								, ; //X6_DSCSPA
	'TES venda de AVGAS no CE exportacao'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'00001;-1'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCODTRA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigo da transportadora na tela do CE'							, ; //X6_DESCRIC
	'Codigo da transportadora na tela do CE'							, ; //X6_DSCSPA
	'Codigo da transportadora na tela do CE'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'000018'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XTAVGAN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES venda de AVGAS no CE nacional'								, ; //X6_DESCRIC
	'TES venda de AVGAS no CE nacional'								, ; //X6_DSCSPA
	'TES venda de AVGAS no CE nacional'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'506'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XUFICJE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CE - ESTADOS COM ISENCAO ICMS - JET'								, ; //X6_DESCRIC
	'CE - ESTADOS COM ISENCAO ICMS - JET'								, ; //X6_DSCSPA
	'CE - ESTADOS COM ISENCAO ICMS - JET'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'ESGO'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'      '																, ; //X6_FIL
	'MV_XCEEXPF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Exportacao gera faturamento.'									, ; //X6_DESCRIC
	'TES Exportacao gera faturamento.'									, ; //X6_DSCSPA
	'TES Exportacao gera faturamento.'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'712'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

//
// Atualizando dicion·rio
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		cTexto += "Foi incluÌdo o par‚metro " + aSX6[nI][1] + aSX6[nI][2] + " Conte˙do [" + AllTrim( aSX6[nI][13] ) + "]"+ CRLF
	EndIf

	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf

		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf

	oProcess:IncRegua2( "Atualizando Arquivos (SX6)..." )

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return aClone( aSX6 )


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSAtuSX7 ∫ Autor ≥ Microsiga          ∫ Data ≥  25/07/2011   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao do SX7 - Gatilhos      ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuSX7 - Gerado por EXPORDIC / Upd. V.4.01 EFS           ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuSX7( cTexto )
Local aEstrut   := {}
Local aSX7      := {}
Local cAlias    := ''
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )

cTexto  += 'Inicio da Atualizacao do SX7' + CRLF + CRLF

aEstrut := { 'X7_CAMPO', 'X7_SEQUENC', 'X7_REGRA', 'X7_CDOMIN', 'X7_TIPO', 'X7_SEEK', ;
             'X7_ALIAS', 'X7_ORDEM'  , 'X7_CHAVE', 'X7_PROPRI', 'X7_CONDIC' }

//
// Campo ZB0_CODCLI
//

aAdd( aSX7, { ;
	'ZB0_CODCLI'																			, ; //X7_CAMPO
	'001'																					, ; //X7_SEQUENC
	'Posicione("SA1", 1, xFilial("SA1")+M->ZB0_CODCLI,"A1_LOJA")'					, ; //X7_REGRA
	'ZB0_LOJCLI'																			, ; //X7_CDOMIN
	'P'																						, ; //X7_TIPO
	'N'																						, ; //X7_SEEK
	''																						, ; //X7_ALIAS
	0																						, ; //X7_ORDEM
	''																						, ; //X7_CHAVE
	'U'																						, ; //X7_PROPRI
	''																						} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZB0_CODCLI'																			, ; //X7_CAMPO
	'002'																					, ; //X7_SEQUENC
	'Posicione("SA1", 1, xFilial("SA1")+M->ZB0_CODCLI+M->ZB0_LOJCLI,"A1_NOME")'	, ; //X7_REGRA
	'ZB0_NOMCLI'																			, ; //X7_CDOMIN
	'P'																						, ; //X7_TIPO
	'N'																						, ; //X7_SEEK
	''																						, ; //X7_ALIAS
	0																						, ; //X7_ORDEM
	''																						, ; //X7_CHAVE
	'U'																						, ; //X7_PROPRI
	''																						} ) //X7_CONDIC

//
// Campo ZB0_LOJCLI
//

aAdd( aSX7, { ;
	'ZB0_LOJCLI'																			, ; //X7_CAMPO
	'001'																					, ; //X7_SEQUENC
	'Posicione("SA1", 1, xFilial("SA1")+M->ZB0_CODCLI+M->ZB0_LOJCLI,"A1_NOME")'	, ; //X7_REGRA
	'ZB0_NOMCLI'																			, ; //X7_CDOMIN
	'P'																						, ; //X7_TIPO
	'N'																						, ; //X7_SEEK
	''																						, ; //X7_ALIAS
	0																						, ; //X7_ORDEM
	''																						, ; //X7_CHAVE
	'U'																						, ; //X7_PROPRI
	''																						} ) //X7_CONDIC

//
// Campo ZB1_CODCLI
//

aAdd( aSX7, { ;
	'ZB1_CODCLI'																			, ; //X7_CAMPO
	'001'																					, ; //X7_SEQUENC
	'Posicione("SA1", 1, xFilial("SA1")+M->ZB1_CODCLI,"A1_LOJA")'					, ; //X7_REGRA
	'ZB1_LOJCLI'																			, ; //X7_CDOMIN
	'P'																						, ; //X7_TIPO
	'N'																						, ; //X7_SEEK
	''																						, ; //X7_ALIAS
	0																						, ; //X7_ORDEM
	''																						, ; //X7_CHAVE
	'U'																						, ; //X7_PROPRI
	''																						} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZB1_CODCLI'																			, ; //X7_CAMPO
	'002'																					, ; //X7_SEQUENC
	'Posicione("SA1", 1, xFilial("SA1")+M->ZB1_CODCLI+M->ZB1_LOJCLI,"A1_NOME")'	, ; //X7_REGRA
	'ZB1_NOMCLI'																			, ; //X7_CDOMIN
	'P'																						, ; //X7_TIPO
	'N'																						, ; //X7_SEEK
	''																						, ; //X7_ALIAS
	0																						, ; //X7_ORDEM
	''																						, ; //X7_CHAVE
	'U'																						, ; //X7_PROPRI
	''																						} ) //X7_CONDIC

//
// Campo ZB1_LOJCLI
//

aAdd( aSX7, { ;
	'ZB1_LOJCLI'																			, ; //X7_CAMPO
	'001'																					, ; //X7_SEQUENC
	'Posicione("SA1", 1, xFilial("SA1")+M->ZB1_CODCLI+M->ZB1_LOJCLI,"A1_NOME")'	, ; //X7_REGRA
	'ZB1_NOMCLI'																			, ; //X7_CDOMIN
	'P'																						, ; //X7_TIPO
	'N'																						, ; //X7_SEEK
	''																						, ; //X7_ALIAS
	0																						, ; //X7_ORDEM
	''																						, ; //X7_CHAVE
	'U'																						, ; //X7_PROPRI
	''																						} ) //X7_CONDIC

//
// Atualizando dicion·rio
//

oProcess:SetRegua2( Len( aSX7 ) )

dbSelectArea( "SX7" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX7 )

	If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )

		If !( aSX7[nI][1] $ cAlias )
			cAlias += aSX7[nI][1] + "/"
			cTexto += "Foi incluÌdo o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] + CRLF
		EndIf

		RecLock( "SX7", .T. )
		For nJ := 1 To Len( aSX7[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

	EndIf
	oProcess:IncRegua2( "Atualizando Arquivos (SX7)..." )

Next nI

cTexto += CRLF + 'Final da Atualizacao do SX7' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return aClone( aSX7 )


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSAtuSXA ∫ Autor ≥ Microsiga          ∫ Data ≥  25/07/2011   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao do SXA - Pastas        ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuSXA - Gerado por EXPORDIC / Upd. V.4.01 EFS           ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuSXA( cTexto )
Local aEstrut   := {}
Local aSXA      := {}
Local cAlias    := ''
Local nI        := 0
Local nJ        := 0

cTexto  += 'Inicio da Atualizacao do SXA' + CRLF + CRLF

aEstrut := { 'XA_ALIAS', 'XA_ORDEM', 'XA_DESCRIC', 'XA_DESCSPA', 'XA_DESCENG', 'XA_PROPRI' }

cTexto += CRLF + 'Final da Atualizacao do SXA' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return aClone( aSXA )


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSAtuSXB ∫ Autor ≥ Microsiga          ∫ Data ≥  25/07/2011 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao do SXB - Consultas Pad ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuSXB - Gerado por EXPORDIC / Upd. V.4.01 EFS           ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuSXB( cTexto )
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ''
Local cMsg      := ''
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0

cTexto  += 'Inicio da Atualizacao do SXB' + CRLF + CRLF

aEstrut := { 'XB_ALIAS',  'XB_TIPO'   , 'XB_SEQ'    , 'XB_COLUNA' , ;
             'XB_DESCRI', 'XB_DESCSPA', 'XB_DESCENG', 'XB_CONTEM' }

//
// Consulta SY9CE
//

aAdd( aSXB, { ;
	'SY9CE'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta padrao CE'													, ; //XB_DESCRI
	'Consulta padrao CE'													, ; //XB_DESCSPA
	'Standard Query EC'													, ; //XB_DESCENG
	'SY9'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SY9CE'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sigla'																, ; //XB_DESCRI
	'Sigla'																, ; //XB_DESCSPA
	'Abbrv.'																, ; //XB_DESCENG
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SY9CE'																, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'														, ; //XB_DESCRI
	'Incluye Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SY9CE'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sigla'																, ; //XB_DESCRI
	'Sigla'																, ; //XB_DESCSPA
	'Abbrv.'																, ; //XB_DESCENG
	'Y9_SIGLA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SY9CE'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'															, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	'Y9_DESCR'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SY9CE'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	'SY9->Y9_SIGLA'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SY9CE'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	'SY9->Y9_DESCR'														} ) //XB_CONTEM

//
// Consulta SB1CE
//

aAdd( aSXB, { ;
	'SB1CE'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Produtos CE'															, ; //XB_DESCRI
	'Poductos de las CE'													, ; //XB_DESCSPA
	'Producgts CE'														, ; //XB_DESCENG
	'SB1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1CE'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1CE'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao + Codigo'													, ; //XB_DESCRI
	'Descripcion + Codigo'												, ; //XB_DESCSPA
	'Description + Produc'												, ; //XB_DESCENG
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1CE'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	'B1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1CE'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'															, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	'B1_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1CE'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'															, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	'B1_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1CE'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	'B1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1CE'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	'SB1->B1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1CE'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	'SB1->B1_DESC+" / "+SB1->B1_UM'										} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1CE'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	'SB1->B1_XPRODCE == "S"'												} ) //XB_CONTEM

//
// Consulta SBECE
//

aAdd( aSXB, { ;
	'SBECE'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Localizacao Fisica'													, ; //XB_DESCRI
	'Localizacao Fisica'													, ; //XB_DESCSPA
	'Localizacao Fisica'													, ; //XB_DESCENG
	'SBE'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBECE'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Armazem + Endereco'													, ; //XB_DESCRI
	'Deposito + Ubicacion'												, ; //XB_DESCSPA
	'Warehouse + Address'												, ; //XB_DESCENG
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBECE'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Armazem'																, ; //XB_DESCRI
	'Deposito'																, ; //XB_DESCSPA
	'Warehouse'															, ; //XB_DESCENG
	'BE_LOCAL'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBECE'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Endereco'																, ; //XB_DESCRI
	'Ubicacion'															, ; //XB_DESCSPA
	'Address'																, ; //XB_DESCENG
	'BE_LOCALIZ'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBECE'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao'															, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	'BE_DESCRIC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBECE'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	'SBE->BE_LOCALIZ'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBECE'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	'SBE->BE_DESCRIC'														} ) //XB_CONTEM

//
// Atualizando dicion·rio
//

oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				cTexto += "Foi incluÌda a consulta padr„o " + aSXB[nI][1] + CRLF
			EndIf

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If !Empty( FieldName( FieldPos( aEstrut[nJ] ) ) )
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
					 StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )

					cMsg := "A consulta padrao " + aSXB[nI][1] + " est· com o " + SXB->( FieldName( nJ ) ) + ;
					" com o conte˙do" + CRLF + ;
					"[" + RTrim( AllToChar( SXB->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
					", e este È diferente do conte˙do" + CRLF + ;
					"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZA«√O DE DICION¡RIOS E TABELAS", cMsg, { "Sim", "N„o", "Sim p/Todos", "N„o p/Todos" }, 3, "DiferenÁa de conte˙do - SXB" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a opÁ„o de REALIZAR TODAS alteraÁıes no SXB e N√O MOSTRAR mais a tela de aviso." + CRLF + "Confirma a aÁ„o [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a opÁ„o de N√O REALIZAR nenhuma alteraÁ„o no SXB que esteja diferente da base e N√O MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta aÁ„o [N„o p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

						If !( aSXB[nI][1] $ cAlias )
							cAlias += aSXB[nI][1] + "/"
							cTexto += "Foi Alterada a consulta padrao " + aSXB[nI][1] + CRLF
						EndIf

					EndIf

				EndIf

			Next

		EndIf

	EndIf

	oProcess:IncRegua2( "Atualizando Consultas Padroes (SXB)..." )

Next nI

cTexto += CRLF + 'Final da Atualizacao do SXB' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return aClone( aSXB )


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSAtuSX5 ∫ Autor ≥ Microsiga          ∫ Data ≥  25/07/2011 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao do SX5 - Indices       ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuSX5 - Gerado por EXPORDIC / Upd. V.4.01 EFS           ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuSX5( cTexto )
Local aEstrut   := {}
Local aSX5      := {}
Local cAlias    := ''
Local nI        := 0
Local nJ        := 0

cTexto  += 'Inicio Atualizacao SX5' + CRLF + CRLF

aEstrut := { 'X5_FILIAL', 'X5_TABELA', 'X5_CHAVE', 'X5_DESCRI', 'X5_DESCSPA', 'X5_DESCENG' }

//
// Atualizando dicion·rio
//

cTexto += CRLF + 'Final da Atualizacao do SX5' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return aClone( aSX5 )


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSAtuSX9 ∫ Autor ≥ Microsiga          ∫ Data ≥  25/07/2011 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao do SX9 - Relacionament ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuSX9 - Gerado por EXPORDIC / Upd. V.4.01 EFS           ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuSX9( cTexto )
Local aEstrut   := {}
Local aSX9      := {}
Local cAlias    := ''
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX9->X9_DOM )

cTexto  += 'Inicio da Atualizacao do SX9' + CRLF + CRLF

aEstrut := { 'X9_DOM'   , 'X9_IDENT'  , 'X9_CDOM'   , 'X9_EXPDOM', 'X9_EXPCDOM' ,'X9_PROPRI', ;
             'X9_LIGDOM', 'X9_LIGCDOM', 'X9_CONDSQL', 'X9_USEFIL', 'X9_ENABLE' }

cTexto += CRLF + 'Final da Atualizacao do SX9' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return aClone( aSX9 )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSAtuHlp ∫ Autor ≥ Microsiga          ∫ Data ≥  25/07/2011 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao dos Helps de Campos    ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuHlp - Gerado por EXPORDIC / Upd. V.4.01 EFS           ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuHlp( cTexto )
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}

cTexto += 'Inicio da Atualizacao ds Helps de Campos' + CRLF + CRLF

//
// Helps Tabela ZB0
//

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Filial do Sistema." )
aAdd( aHlpEng, "System Branch." )
aAdd( aHlpSpa, "SubdivisiÛn del Sistema." )
PutHelp( "PZB0_FILIAL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_FILIAL" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "N˙mero da CE." )
aAdd( aHlpEng, "CE Number." )
aAdd( aHlpSpa, "Numero da CE." )
PutHelp( "PZB0_NUMCE", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_NUMCE" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Nesse campo deve ser digitado o dia em  " )
aAdd( aHlpPor, "que foi emitido a CE." )
aAdd( aHlpEng, "This field must be entered the day it   " )
aAdd( aHlpEng, "was sent to EC." )
aAdd( aHlpSpa, "Este campo se debe ingresar el dÌa en   " )
aAdd( aHlpSpa, "que fue enviado a la CE." )
PutHelp( "PZB0_DTEMIS", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_DTEMIS" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "CÛdigo do Cliente digitado ou buscado   " )
aAdd( aHlpPor, "via F3 (consulta padr„o)" )
aAdd( aHlpEng, "Client code entered or searched via F3  " )
aAdd( aHlpEng, "(standard query)" )
aAdd( aHlpSpa, "El cÛdigo de cliente allanado ni        " )
aAdd( aHlpSpa, "registrado por medio de F3 (consulta    " )
aAdd( aHlpSpa, "est·ndar)" )
PutHelp( "PZB0_CODCLI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_CODCLI" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Prefixo da Aeronave.                    " )
aAdd( aHlpEng, "Prefix Aircraft.                        " )
aAdd( aHlpSpa, "Prefijo de Aeronaves.                   " )
PutHelp( "PZB0_PREFIX", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_PREFIX" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "CÛdigo do caminh„o de abastecimento.    " )
aAdd( aHlpEng, "Supply truck code.                      " )
aAdd( aHlpSpa, "CÛdigo camiÛn de abastecimiento.        " )
PutHelp( "PZB0_CTA", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_CTA" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Hor·rio de inÌcio do abastecimento.    " )
aAdd( aHlpEng, "Beginning of the supply schedule.      " )
aAdd( aHlpSpa, "A partir de la curva de oferta.        " )
PutHelp( "PZB0_HORINI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_HORINI" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Hor·rio do tÈrmino do abastecimento.   " )
aAdd( aHlpEng, "Supply the end of time.                " )
aAdd( aHlpSpa, "Suministrar el fin de los tiempos.     " )
PutHelp( "PZB0_HORFIM", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_HORFIM" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "N˙mero do Voo.                         " )
aAdd( aHlpEng, "Flight number.                         " )
aAdd( aHlpSpa, "N˙mero de vuelo.                       " )
PutHelp( "PZB0_NUMVOO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_NUMVOO" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Tipo da Aeronave.                      " )
aAdd( aHlpEng, "Type Aircraft.                         " )
aAdd( aHlpSpa, "El tipo de aeronave.                   " )
PutHelp( "PZB0_TIPAER", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_TIPAER" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Nota do teste visual.                  " )
aAdd( aHlpEng, "Note the visual test.                  " )
aAdd( aHlpSpa, "Tenga en cuenta el examen de la vista. " )
PutHelp( "PZB0_TSTVIS", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_TSTVIS" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "CÛdigo da MatrÌcula do operador.       " )
aAdd( aHlpEng, "Registration code operator.            " )
aAdd( aHlpSpa, "Operador de cÛdigo de registro.        " )
PutHelp( "PZB0_MATRIC", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_MATRIC" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "CÛdigo IATA do aeroporto.              " )
aAdd( aHlpEng, "Airport code IATA.                     " )
aAdd( aHlpSpa, "Aeropuerto cÛdigo IATA.                " )
PutHelp( "PZB0_CODAER", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_CODAER" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "ObservaÁıes gerais da CE.              " )
aAdd( aHlpEng, "General remarks CE.                    " )
aAdd( aHlpSpa, "Observaciones generales CE.            " )
PutHelp( "PZB0_OBSERV", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_OBSERV" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "CÛdigo do produto.                     " )
aAdd( aHlpEng, "product code.                          " )
aAdd( aHlpSpa, "cÛdigo de producto.                    " )
PutHelp( "PZB0_PRODUT", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_PRODUT" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Quantidade de litros.                  " )
aAdd( aHlpEng, "Volume liters.                         " )
aAdd( aHlpSpa, "Litros de volumen.                     " )
PutHelp( "PZB0_QTDE", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_QTDE" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Identifica se o preÁo ser· buscado na  " )
aAdd( aHlpPor, "tabela de preÁo do cliente ou ser· um  " )
aAdd( aHlpPor, "valor negociado pelo operador.         " )
aAdd( aHlpEng, "Identifies whether the price will be   " )
aAdd( aHlpEng, "sought in the customer's price list or " )
aAdd( aHlpEng, "a value will be negotiated by the      " )
aAdd( aHlpEng, "operator." )
aAdd( aHlpSpa, "Identifica si el precio va a ser       " )
aAdd( aHlpSpa, "buscado en la lista de precios del     " )
aAdd( aHlpSpa, "cliente o un valor ser· negociada por  " )
aAdd( aHlpSpa, "el operador." )
PutHelp( "PZB0_PRCNEG", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_PRCNEG" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "PreÁo de venda por litro.              " )
aAdd( aHlpEng, "Selling price per liter.               " )
aAdd( aHlpSpa, "El precio de venta por litro.          " )
PutHelp( "PZB0_PRCVEN", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_PRCVEN" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "N˙mero retirado do Meter (Medidor).    " )
aAdd( aHlpEng, "Number removed from the Meter (Meter). " )
aAdd( aHlpSpa, "N˙mero retira del Meter (Medidor).     " )
PutHelp( "PZB0_REGIST", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_REGIST" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "AcrÈscimo financeiro que ir· compor o  " )
aAdd( aHlpPor, "preÁo unit·rio." )
aAdd( aHlpEng, "Financial increase that will compose   " )
aAdd( aHlpEng, "the unit price." )
aAdd( aHlpSpa, "Aumento financiera que han de integrar " )
aAdd( aHlpSpa, "el precio unitario." )
PutHelp( "PA1_XACFINA", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "A1_XACFINA" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Desconto por volume que ir· compor o   " )
aAdd( aHlpPor, "preÁo unit·rio." )
aAdd( aHlpEng, "Volume discount that will compose the  " )
aAdd( aHlpEng, "unit price." )
aAdd( aHlpSpa, "Descuento por volumen que han de       " )
aAdd( aHlpSpa, "integrar el precio unitario." )
PutHelp( "PA1_XDESVOL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "A1_XDESVOL" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Prazo para pagamento que ser· utilizado " )
aAdd( aHlpPor, "na fÛrmula para c·lculo do desconto ou  " )
aAdd( aHlpPor, "acrÈscimo financeiro." )
aAdd( aHlpEng, "Deadline for payment to be used in the  " )
aAdd( aHlpEng, "formula for calculating the discount or " )
aAdd( aHlpEng, "financial increase." )
aAdd( aHlpSpa, "Fecha lÌmite de pago que se utilizar· en" )
aAdd( aHlpSpa, " la fÛrmula para calcular el descuento o" )
aAdd( aHlpSpa, " incremento financiera." )
PutHelp( "PA1_XPRAZO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "A1_XPRAZO" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Informa se o produto ser· utilizado no  " )
aAdd( aHlpPor, "CE - Comprovante de Entrega." )
aAdd( aHlpEng, "Tells whether the product will be used  " )
aAdd( aHlpEng, "in the EC - Proof of Delivery." )
aAdd( aHlpSpa, "Indica si el producto ser· utilizado en " )
aAdd( aHlpSpa, "la CE - Prueba de entrega." )
PutHelp( "PB1_XPRODCE", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "B1_XPRODCE" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Informe o n˙mero do contrato.           " )
aAdd( aHlpEng, "Enter the contract number.              " )
aAdd( aHlpSpa, "Introduce el n˙mero de contrato.        " )
PutHelp( "PZB1_CONTRA", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB1_CONTRA" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Se o contrato esta ativo ou n„o.        " )
aAdd( aHlpEng, "If the contract is active or not.       " )
aAdd( aHlpSpa, "Si el contrato est· activo o no.        " )
PutHelp( "PZB1_ATIVO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB1_ATIVO" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Informe o cÛdigo do cliente.            " )
aAdd( aHlpEng, "Enter the client code.                  " )
aAdd( aHlpSpa, "Introduce el cÛdigo de cliente.         " )
PutHelp( "PZB1_CODCLI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB1_CODCLI" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Informe a loja do cliente.              " )
aAdd( aHlpEng, "Tell the customer shop.                 " )
aAdd( aHlpSpa, "Dile a la tienda de cliente.            " )
PutHelp( "PZB1_LOJCLI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB1_LOJCLI" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Informe a data inicial do contrato.     " )
aAdd( aHlpEng, "Enter the start date of the contract.   " )
aAdd( aHlpSpa, "Introduzca la fecha de inicio del       " )
aAdd( aHlpSpa, "contrato." )
PutHelp( "PZB1_DTINI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB1_DTINI" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Informe a data final do contrato.       " )
aAdd( aHlpEng, "Enter the end date of the contract.     " )
aAdd( aHlpSpa, "Introduzca la fecha de finalizaciÛn del " )
aAdd( aHlpSpa, "contrato." )
PutHelp( "PZB1_DTFIM", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB1_DTFIM" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Informe a observaÁ„o do contrato.       " )
aAdd( aHlpEng, "Enter the contract notice.              " )
aAdd( aHlpSpa, "Introduzca el anuncio de licitaciÛn.    " )
PutHelp( "PZB1_OBSERV", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB1_OBSERV" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Informe o produto.                      " )
aAdd( aHlpEng, "Enter the product.                      " )
aAdd( aHlpSpa, "Introduzca el producto.                 " )
PutHelp( "PZB2_PRODUT", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB2_PRODUT" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Informe a quantidade.                   " )
aAdd( aHlpEng, "Enter the amount.                       " )
aAdd( aHlpSpa, "Introduzca la cantidad.                 " )
PutHelp( "PZB2_QTDE", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB2_QTDE" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Informe o valor.                        " )
aAdd( aHlpEng, "Enter the amount.                       " )
aAdd( aHlpSpa, "introduzca el importe.                  " )
PutHelp( "PZB2_PRCVEN", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB2_PRCVEN" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Hor·rio intermedi·rio do abastecimento." )
aAdd( aHlpEng, "Intermediate time of supply.           " )
aAdd( aHlpSpa, "Tiempo intermedio de suministro.       " )
PutHelp( "PZB0_HORINT", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_HORFIM" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "N˙mero retirado do Meter (Medidor).    " )
aAdd( aHlpEng, "Number removed from the Meter (Meter). " )
aAdd( aHlpSpa, "N˙mero retira del Meter (Medidor).     " )
PutHelp( "PZB0_REGFIM", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_REGIST" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Densidade do ambiente.                 " )
aAdd( aHlpEng, "Density Environment.                   " )
aAdd( aHlpSpa, "Medio Ambiente densidad.               " )
PutHelp( "PZB0_DENSAB", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_REGIST" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Temperatura do ambiente.                 " )
aAdd( aHlpEng, "Room temperature.                        " )
aAdd( aHlpSpa, "Temperatura do ambiente.                 " )
PutHelp( "PZB0_TEMPAB", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "ZB0_REGIST" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Tem Percentual ReduÁ„o ICMS.             " )
aAdd( aHlpEng, "Tem Percentual ReduÁ„o ICMS.             " )
aAdd( aHlpSpa, "Tem Percentual ReduÁ„o ICMS.             " )
PutHelp( "PZB0_LOCAL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "A1_XPEICMS" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Armazem onde se encontra o endereÁo.     " )
aAdd( aHlpEng, "Armazem onde se encontra o endereÁo.     " )
aAdd( aHlpSpa, "Armazem onde se encontra o endereÁo.     " )
PutHelp( "PA1_XPEICMS", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "A1_XPEICMS" + CRLF

cTexto += CRLF + 'Final da Atualizacao dos Helps de Campos' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return {}


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Rotina    ≥ESCEMPRESA∫Autor  ≥ Ernani Forastieri  ∫ Data ≥  27/09/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao Generica para escolha de Empresa, montado pelo SM0_ ∫±±
±±∫          ≥ Retorna vetor contendo as selecoes feitas.                 ∫±±
±±∫          ≥ Se nao For marcada nenhuma o vetor volta vazio.            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Generico                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function EscEmpresa()
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Parametro  nTipo                           ≥
//≥ 1  - Monta com Todas Empresas/Filiais      ≥
//≥ 2  - Monta so com Empresas                 ≥
//≥ 3  - Monta so com Filiais de uma Empresa   ≥
//≥                                            ≥
//≥ Parametro  aMarcadas                       ≥
//≥ Vetor com Empresas/Filiais pre marcadas    ≥
//≥                                            ≥
//≥ Parametro  cEmpSel                         ≥
//≥ Empresa que sera usada para montar selecao ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
Local   aSalvAmb := GetArea()
Local   aSalvSM0 := {}
Local   aRet     := {}
Local   aVetor   := {}
Local   oDlg     := NIL
Local   oChkMar  := NIL
Local   oLbx     := NIL
Local   oMascEmp := NIL
Local   oMascFil := NIL
Local   oButMarc := NIL
Local   oButDMar := NIL
Local   oButInv  := NIL
Local   oSay     := NIL
Local   oOk      := LoadBitmap( GetResources(), 'LBOK' )
Local   oNo      := LoadBitmap( GetResources(), 'LBNO' )
Local   lChk     := .F.
Local   lOk      := .F.
Local   lTeveMarc:= .F.
Local   cVar     := ''
Local   cNomEmp  := ''
Local   cMascEmp := '??'
Local   cMascFil := '??'

Local   aMarcadas  := {}


If !MyOpenSm0Ex()
	ApMsgStop( 'N„o foi possÌvel abrir SM0 exclusivo.' )
	Return aRet
EndIf


dbSelectArea( 'SM0' )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title '' From 0, 0 To 270, 396 Pixel

oDlg:cToolTip := 'Tela para M˙ltiplas SeleÁıes de Empresas/Filiais'

oDlg:cTitle := 'Selecione a(s) Empresa(s) para AtualizaÁ„o'

@ 10, 10 Listbox  oLbx Var  cVar Fields Header ' ', ' ', 'Empresa' Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt 'Todos'   Message 'Marca / Desmarca Todos' Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

@ 123, 10 Button oButInv Prompt '&Inverter'  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message 'Inverter SeleÁ„o' Of oDlg

// Marca/Desmarca por mascara
@ 113, 51 Say  oSay Prompt 'Empresa' Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet  oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture '@!'  Valid (  cMascEmp := StrTran( cMascEmp, ' ', '?' ), cMascFil := StrTran( cMascFil, ' ', '?' ), oMascEmp:Refresh(), .T. ) ;
Message 'M·scara Empresa ( ?? )'  Of oDlg
@ 123, 50 Button oButMarc Prompt '&Marcar'    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message 'Marcar usando m·scara ( ?? )'    Of oDlg
@ 123, 80 Button oButDMar Prompt '&Desmarcar' Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message 'Desmarcar usando m·scara ( ?? )' Of oDlg

Define SButton From 111, 125 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop 'Confirma a SeleÁ„o'  Enable Of oDlg
Define SButton From 111, 158 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) OnStop 'Abandona a SeleÁ„o' Enable Of oDlg
Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( 'SM0' )
dbCloseArea()

Return  aRet


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Rotina    ≥MARCATODOS∫Autor  ≥ Ernani Forastieri  ∫ Data ≥  27/09/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao Auxiliar para marcar/desmarcar todos os itens do    ∫±±
±±∫          ≥ ListBox ativo                                              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Generico                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Rotina    ≥INVSELECAO∫Autor  ≥ Ernani Forastieri  ∫ Data ≥  27/09/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao Auxiliar para inverter selecao do ListBox Ativo     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Generico                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Rotina    ≥RETSELECAO∫Autor  ≥ Ernani Forastieri  ∫ Data ≥  27/09/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao Auxiliar que monta o retorno com as selecoes        ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Generico                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Rotina    ≥ MARCAMAS ∫Autor  ≥ Ernani Forastieri  ∫ Data ≥  20/11/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao para marcar/desmarcar usando mascaras               ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Generico                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == '?' .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == '?' .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] :=  lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Rotina    ≥ VERTODOS ∫Autor  ≥ Ernani Forastieri  ∫ Data ≥  20/11/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao auxiliar para verificar se estao todos marcardos    ∫±±
±±∫          ≥ ou nao                                                     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Generico                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ MyOpenSM ∫ Autor ≥ Microsiga          ∫ Data ≥  25/07/2011   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento abertura do SM0 modo exclusivo     ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ MyOpenSM - Gerado por EXPORDIC / Upd. V.4.01 EFS           ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function MyOpenSM0Ex()

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , 'SIGAMAT.EMP', 'SM0', .F., .F. )

	If !Empty( Select( 'SM0' ) )
		lOpen := .T.
		dbSetIndex( 'SIGAMAT.IND' )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	ApMsgStop( 'N„o foi possÌvel a abertura da tabela ' + ;
		'de empresas de forma exclusiva.', 'ATEN«√O' )
EndIf

Return lOpen