#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------
// VARIAVEIS COM AS POSICOES DO ARRAY DE IMPORTACAO DE DADOS -
// DEVEM ESTAR IGUAIS NO FONTE WSAIR007                      -
//------------------------------------------------------------
STATIC XZA0CODTAB	:= 1
STATIC XZA0DESCTA	:= 2
STATIC XZA0DTINI	:= 3
STATIC XZA0DTFIM	:= 4
STATIC XZA0CODPRO	:= 5
STATIC XZA0REV  	:= 6
STATIC XZA0OBS		:= 7

STATIC XZA1BASE		:= 1
STATIC XZA1CLIENT	:= 2
STATIC XZA1LOJA		:= 3
STATIC XZA1PRFIM2	:= 4
STATIC XZA1PRFIM1	:= 5
STATIC XZA1AIRFEE	:= 6
STATIC XZA1DIFF		:= 7
STATIC XZA1TXJCLI	:= 8
STATIC XZA1EXREF	:= 9
STATIC XZA1ALIQICM	:= 10
STATIC XZA1TXUS		:= 11
STATIC XZA1FATCVL	:= 12
STATIC XZA1TXHUF1	:= 13
STATIC XZA1TXHUF2	:= 14
STATIC XZA1OBS		:= 15

/*/{Protheus.doc} AIFATP01
Bilioteca de funcoes para tratamento de tabela de preços da AirBP
@author DS2U (SDA)
@since 25/09/2018
@version 1.0
@return uRet, retorno da funcao que foi executada
@param nlOpc, numeric, numero da opcao da funcao a ser executada
@param uParam, undefined, parametro a ser enviado para a funcao a ser executada
@type function
/*/
User Function AIFATP01( nlOpc, uParam )

	local uRet		:= nil
	
	default nlOpc	:= 0
	default uParam	:= nil
	
	do Case
	
		case ( nlOpc == 0 )
			uRet := import( uParam )
	
	endCase

Return uRet

/*/{Protheus.doc} import
Responsavel por executar os passos para importacao da tabela de preços
@author DS2U (SDA)
@since 02/10/2018
@version 1.0
@return apLog, Array bidimensional retornando codigo e descricao do processo
@param alDados, array of logical, Array com informacoes de cabeçalho e itens a serem gravados na tabela de preços
@type function
/*/
Static Function import( alDados )

	local alCab  := aClone( alDados[1] )
	local alItns := aClone( alDados[2] )

	private apLog	:= {}

	default alDados	:= {}
	
	if ( len( alDados ) == 2 )
	
		alCab  := aClone( alDados[1] )
		alItns := aClone( alDados[2] )
		
		if ( len( alCab ) > 0 .and. len( alItns ) > 0 )
		
			//---------------------------------
			// Valida preenchimento dos itens -
			//---------------------------------
			if ( validData( alCab, alItns ) )
			
				execSteps( alCab, alItns )
				
			endif
		
		endif
		
	else
		AADD( apLog, {"#000", "Não há dados para importação!"} )
	endif
	
Return apLog

/*/{Protheus.doc} execSteps
Funcao de controle das etapas a serem processadas conforme parametros enviados pelo WS
@author DS2U (SDA)
@since 10/04/2019
@version 1.0
@param alCab, array of logical, Array de cabeçalho da tabela de preços
@param alItns, array of logical, Array de itens da tabela de preços
@type function
/*/
Static Function execSteps( alCab, alItns )

	local clTab := ""
	local clRev := ""
	local clNewRev := ""
	local clPrd := PADR( alCab[XZA0CODPRO], tamSX3("ZA0_CODPRO")[1] )
	local llProcOk := .T.

	if ( empty( alCab[XZA0REV] ) )
	
		// Identifica ultima tabela ativa
		lastTbAtiv( alCab, @clTab, @clRev )
		
		if ( .not. empty( clTab ) )
		
			// Desativa a tabela ativa
			if ( desativaTb( clTab, clRev, clPrd ) )
			
				// Clona tabela para uma nova versão
				cloneTbPrc( clTab, clRev, clPrd, @clNewRev )
				
				// Atualiza PREÇOS enviados pelo WS
				mantemPrc( alCab, alItns, clTab, clNewRev )
				
			endif
			
		endif
		
	else
	
		// Valida se o produto / revisao existem no banco de dados
		// Se nao existir, desativa a tabela de preços vigente
		llProcOk := .T.
		if ( .not. existTbRev( alCab[XZA0CODTAB], alCab[XZA0REV], alCab[XZA0CODPRO], alCab[XZA0DTINI] ) )
			
			// Identifica ultima tabela ativa
			lastTbAtiv( alCab, @clTab, @clRev, .F. )
			
			// Desativa a tabela ativa
			if ( desativaTb( clTab, clRev, clPrd ) )
				llProcOk := .F.
			endif
		
		else
			llProcOk := .T.
		endif
		
		// Inclui / atualiza conforme produto / versao enviada
		mantemPrc( alCab, alItns, alCab[XZA0CODTAB], alCab[XZA0REV] )
	
	endif

Return

/*/{Protheus.doc} existTbRev
Funcao auxiliar para identificar se uma tabela de preços existe conforme parametros da funcao
@author DS2U (SDA)
@since 10/04/2019
@version 1.0
@return llRet, Se .T., existe
@param clCodTab, characters, Codigo da tabela de preço a ser consultada
@param clRev, characters, Codigo da revisão da tabela de preços a ser consultada
@param clCodPrd, characters, Código do produto da tabela de preço a ser consultado
@param clDtIni, characters, Data inicial da vigencia da tabela de preços
@type function
/*/
Static Function existTbRev( clCodTab, clRev, clCodPrd, clDtIni )

	local llRet := .F.

	dbSelectArea( "ZA0" )
	ZA0->( dbSetOrder( 1 ) ) // ZA0_FILIAL, ZA0_CODTAB, ZA0_REV, ZA0_CODPRO, ZA0_DTINI, R_E_C_N_O_, D_E_L_E_T_
	llRet := ZA0->( dbSeek( fwxFilial("ZA0") + PADR( clCodTab, tamSX3("ZA0_CODTAB")[1] ) + PADR( clRev, tamSX3("ZA0_REV")[1] ) + PADR( clCodPrd, tamSX3("ZA0_CODPRO")[1] ) + dToS( clDtIni ) ) )
	
Return llRet

/*/{Protheus.doc} lastTbAtiv
Funcao para identificar a ultima tabela ativa do produto em questao
@author DS2U (SDA)
@since 10/04/2019
@version 1.0
@param alCab, array of logical, Array do cabeçalho da tabela de preços vinda do WS
@param clTab, characters, Variavel passada por referencia para armazenar o codigo da tabela ativa
@param clRev, characters, Variavel passada por referencia para armazenar o codigo da revisao da tabela ativa
@type function
/*/
Static Function lastTbAtiv( alCab, clTab, clRev, lLog )

	Default lLog := .T.

	dbSelectArea( "ZA0" )
	ZA0->( dbSetOrder( 2 ) )  // ZA0_FILIAL, ZA0_CODPRO, ZA0_DTINI, ZA0_ATIVA, R_E_C_N_O_, D_E_L_E_T_
	if ( ZA0->( dbSeek( fwxFilial("ZA0") + PADR( alCab[XZA0CODPRO], tamSX3("ZA0_CODPRO")[1] ) + dToS( alCab[XZA0DTINI] )  + "1", .T.) ) )
		clTab := ZA0->ZA0_CODTAB
		clRev := ZA0->ZA0_REV
	else
		if ( lLog )
			AADD( apLog, {"#006", "Nao foi identificado tabela ativa para o produto " + alCab[XZA0CODPRO] } )
		endif
	endif

Return

/*/{Protheus.doc} desativaTb
Funcao auxiliar para desativar uma tabela de preços
@author DS2U (SDA)
@since 10/04/2019
@version 1.0
@return llRet, Se .T., foi desativada. Se .F., nao possivel desativar
@param clTab, characters, Codigo da tabela de preços a ser desativada
@param clRev, characters, Codigo da revisao da tabela de preços a ser desativada
@param clPrd, characters, Codigo do produto da tabela de preço a ser desativada
@type function
/*/
Static Function desativaTb( clTab, clRev, clPrd )

	local llRet := .T.

	if ( tcSqlExec( "UPDATE " + retSqlName( "ZA0" ) + " SET ZA0_ATIVA = '2' WHERE D_E_L_E_T_ = ' ' AND ZA0_CODTAB = '" + clTab + "' AND ZA0_REV = '" + clRev + "' AND ZA0_CODPRO = '" + clPrd + "'" ) < 0 )
		llRet := .F.
		AADD( apLog, {"#007", "Falha na desativação da tabela '" + clTab + "' / Revisao '" + clRev + "' >> " + tcSqlError() } )
	endif

Return llRet

/*/{Protheus.doc} cloneTbPrc
Funcao para realizar o clone de uma tabela de preços
@author DS2U (SDA)
@since 10/04/2019
@version 1.0
@param clTab, characters, Codigo da tabela de preços a ser clonada
@param clRev, characters, Codigo da revisao da tabela de preços a ser clonada
@param clPrd, characters, Codigo do produto do cabeçalho da tabela de preços a ser clonada
@param clNewRev, characters, Variavel passada por referencia para armazenar o codigo da nova revisao
@type function
/*/
Static Function cloneTbPrc( clTab, clRev, clPrd, clNewRev )

	local clAliasCab
	local clAliasItm	
	local nlx
	local clNotFields   := "D_E_L_E_T_/R_E_C_N_O_/R_E_C_D_E_L_/ZA0_REV/ZA1_REV"
	
	default clNewRev    := ""
	
	conOut( "Realizando o cliente da tabela " + clTab + " / revisao " + clRev )
	
	clNewRev   := soma1( clRev )
	
	// Clonando cabeçalho
	clAliasCab := getNextAlias()
	
	BEGINSQL ALIAS clAliasCab
	
		SELECT *
		FROM
			%TABLE:ZA0% ZA0
			
		WHERE
			ZA0.ZA0_FILIAL = %XFILIAL:ZA0%
			AND ZA0.ZA0_CODTAB = %EXP:clTab%
			AND ZA0.ZA0_REV = %EXP:clRev%
			AND ZA0.ZA0_CODPRO = %EXP:clPrd%
			AND ZA0.%NOTDEL%
	
	ENDSQL
	
	while ( .not. ( clAliasCab )->( eof() ) )
	
		if ( recLock( "ZA0", .T. ) )
		
			for nlx := 1 to ( clAliasCab )->( FCount() )
			
				if ( .not. ( ( clAliasCab )->( fieldName( nlx ) ) $ clNotFields ) )
					if ( tamSX3( ( clAliasCab )->( fieldName( nlx ) ) )[3] == "D" )
						ZA0->&( ( clAliasCab )->( fieldName( nlx ) ) ) := sToD( ( clAliasCab )->&( ( clAliasCab )->( fieldName( nlx ) ) ) )
					else
						ZA0->&( ( clAliasCab )->( fieldName( nlx ) ) ) := ( clAliasCab )->&( ( clAliasCab )->( fieldName( nlx ) ) )
					endif
				endif
				
			next nlx
			
			ZA0->ZA0_REV := clNewRev
		
			ZA0->( msUnLock() )
		endif
	
		( clAliasCab )->( dbSkip() )		
	endDo
	( clAliasCab )->( dbCloseArea() )
	
	
	// Clonando Itens
	clAliasItm := getNextAlias()
	
	BEGINSQL ALIAS clAliasItm
	
		SELECT *
		FROM
			%TABLE:ZA1% ZA1
			
		WHERE
			ZA1.ZA1_FILIAL = %XFILIAL:ZA1%
			AND ZA1.ZA1_CODTAB = %EXP:clTab%
			AND ZA1.ZA1_REV = %EXP:clRev%
			AND ZA1.%NOTDEL%
	
	ENDSQL
	
	while ( .not. ( clAliasItm )->( eof() ) )
	
		if ( recLock( "ZA1", .T. ) )
		
			for nlx := 1 to ( clAliasItm )->( FCount() )
				if ( .not. ( ( clAliasItm )->( fieldName( nlx ) ) $ clNotFields ) )
					if ( tamSX3( ( clAliasItm )->( fieldName( nlx ) ) )[3] == "D" )
						ZA1->&( ( clAliasItm )->( fieldName( nlx ) ) ) := sToD( ( clAliasItm )->&( ( clAliasItm )->( fieldName( nlx ) ) ) )
					else
						ZA1->&( ( clAliasItm )->( fieldName( nlx ) ) ) := ( clAliasItm )->&( ( clAliasItm )->( fieldName( nlx ) ) )
					endif
				endif
			next nlx
			
			ZA1->ZA1_REV := clNewRev
		
			ZA1->( msUnLock() )
		endif
	
		( clAliasItm )->( dbSkip() )		
	endDo
	( clAliasItm )->( dbCloseArea() )
	
Return

/*/{Protheus.doc} mantemPrc
Funcao que faz a manutencao da tabela de precos
@author DS2U (SDA)
@since 10/04/2019
@version 1.0
@param alCab, array of logical, Array de cabeçalho da tabela de precos
@param alItns, array of logical, Array de itens da tabela de precos
@param clTab, characters, Codigo da tabela a ser mantida
@param clRev, characters, Codigo da revisao da tabela a ser mantida
@type function
/*/
Static Function mantemPrc( alCab, alItns, clTab, clRev )

	local llFindZA0 := .F.
	local nlx
	local clCodFil
	local clCodTab
	
	dbSelectArea( "SB1" )
	SB1->( dbSetOrder( 1 ) )
	
	dbSelectArea( "SA1" )
	SA1->( dbSetOrder( 1 ) )
	
	if ( SB1->( dbSeek( fwxFilial( "SB1" ) + PADR( alCab[XZA0CODPRO], tamSX3("B1_COD")[1] ) ) ) ) 
	
		if ( empty( clTab ) )
			clCodTab := alCab[XZA0CODTAB]
		else
			clCodTab := clTab
		endif
		
		if ( !empty( clCodTab ) )
		
			for nlx := 1 to len( alItns )
			
				if ( SA1->( dbSeek( fwxFilial( "SA1" ) + PADR( alItns[nlx][XZA1CLIENT], tamSX3("A1_COD")[1] ) + PADR( alItns[nlx][XZA1LOJA], tamSX3("A1_LOJA")[1] ) ) ) )
		
					//---------------
					// Busca filial -
					//---------------
					chkFilVld( alCab, alItns[nlx], @clCodFil )
		
					llFindZA0 := existTbRev( clCodTab, clRev, alCab[XZA0CODPRO], alCab[XZA0DTINI] ) 
					
					dbSelectArea( "ZA1" )
					ZA1->( dbSetOrder( 1 ) )  // ZA1_FILIAL+ZA1_CODTAB+ZA1_REV+ZA1_BASE+ZA1_CLIENT+ZA1_LOJA
					llFindZA1 := ZA1->( dbSeek( fwxFilial("ZA1") + PADR( clCodTab, tamSX3("ZA0_CODTAB")[1] ) + PADR( clRev, tamSX3("ZA1_REV")[1] ) + PADR( clCodFil, tamSX3("ZA1_BASE")[1] ) + SA1->A1_COD + SA1->A1_LOJA , .T.) )
					
					begin transaction
	
						if ( reclock("ZA0", .not. llFindZA0 ) )
								
							ZA0->ZA0_FILIAL	:= fwxFilial("ZA0")					// Filial
							ZA0->ZA0_CODTAB	:= clCodTab							// Código da tabela
							ZA0->ZA0_REV	:= clRev							// Numero da revisão da tabela
							ZA0->ZA0_DESCTA	:= allTrim( alCab[XZA0DESCTA] )	    // Descrição da tabela
							ZA0->ZA0_DTINI	:= alCab[XZA0DTINI]				    // Data validade INICIAL
							ZA0->ZA0_DTFIM	:= alCab[XZA0DTFIM]				    // Data validade FINAL
							ZA0->ZA0_CODPRO	:= alCab[XZA0CODPRO]				// Codigo do Produto
							ZA0->ZA0_DESCPR	:= SB1->B1_DESC						// Descrição do Produto
							ZA0->ZA0_ATIVA	:= "1"								// 1-Ativa ou 2-Inativa
							ZA0->ZA0_OBS	:= alCab[XZA0OBS]					//Observação geral
							
							if ( .not. llFindZA0 )
								ZA0->ZA0_DTINC   := date()						// Data da importação/inclusão da tabela de preço
								ZA0->ZA0_HRINC   := time()						// Hora da importação/inclusão da tabela de preço
							endif
							
							ZA0->( msUnlock() )
							
						endif
						
						if ( reclock("ZA1", .not. llFindZA1 ) )
						
							ZA1->ZA1_FILIAL  := fwxFilial("ZA1")			// Filial
							ZA1->ZA1_CODTAB  := clCodTab					// Codigo da tabela
							ZA1->ZA1_REV     := clRev						// Numero revisão da tabela
							ZA1->ZA1_BASE	 := clCodFil					// Base-Filial a que se refere a tabela
							ZA1->ZA1_CLIENT  := SA1->A1_COD					// Codigo do cliente
							ZA1->ZA1_LOJA    := SA1->A1_LOJA				// loja do cliente
							ZA1->ZA1_NOMCLI  := SA1->A1_NOME				// Nome do Cliente
							ZA1->ZA1_PRFIM2  := alItns[nlx][XZA1PRFIM2]		// Preço unitário em reais
							ZA1->ZA1_PRFIM1  := alItns[nlx][XZA1PRFIM1]		// Preço unitário em U$				
							ZA1->ZA1_AIRFEE  := alItns[nlx][XZA1AIRFEE]		// Air Fee
							ZA1->ZA1_DIFF    := alItns[nlx][XZA1DIFF]		// Diff
							ZA1->ZA1_TXJCLI  := alItns[nlx][XZA1TXJCLI]		// Tx de juros do cliente
							ZA1->ZA1_EXREF   := alItns[nlx][XZA1EXREF]		// Ex Refinaria
							ZA1->ZA1_ALQICM  := alItns[nlx][XZA1ALIQICM]	// Aliquota Icms
							ZA1->ZA1_TXUS    := alItns[nlx][XZA1TXUS]		// Taxa dolar
							ZA1->ZA1_FATCVL  := alItns[nlx][XZA1FATCVL]		// Fator conversão Galão/Litro
							ZA1->ZA1_TXHUF1  := alItns[nlx][XZA1TXHUF1]		// Fator conversão Galão/Litro
							ZA1->ZA1_TXHUF2  := alItns[nlx][XZA1TXHUF2]		// Fator conversão Galão/Litro
							ZA1->ZA1_OBSERV  := alItns[nlx][XZA1OBS]		// Observação
							ZA1->( msUnlock() )
							
						endif
					
					end transaction
					
				else
					AADD( apLog, {"#009", "Cliente " + alItns[nlx][XZA1CLIENT] + "/" + alItns[nlx][XZA1LOJA] + " nao encontrado" } )
				endif
				
			next nlx
			
		else
			AADD( apLog, {"#010", "Codigo da tabela nao encontrado" } )
		endif
		
	else
		AADD( apLog, {"#008", "Produto " + alCab[XZA0CODPRO] + " nao encontrado" } )
	endif

Return

/*/{Protheus.doc} validData
Responsavel por validar o registro a ser importado
@author DS2U (SDA)
@since 02/10/2018
@version 1.0
@return llProcOk, Se .T., o registro foi validado, se .F. será desconsiderado pela importacao
@param alCab, array of logical, Array com informações do cabeçalho
@param alItns, array of logical, Array com informacoes do registro que esta sendo lido para a importacao
@type function
/*/
Static Function validData( alCab, alItns )

	local alArea	:= getArea()
	local nlx
	local llProcOk	:= .T.
	local dlDtIni	:= alCab[XZA0DTINI]
	local dlDtFim	:= alCab[XZA0DTFIM]
	
	default alItns	:= {}
	
	dbSelectArea( "SB1" )
	SB1->( dbSetOrder( 1 ) )
	
	dbSelectArea( "SA1" )
	SA1->( dbSetOrder( 1 ) )
	
	for nlx := 1 to len( alItns )
	
		if ( .not. SB1->( dbSeek( fwxFilial( "SB1" ) + PADR( alCab[XZA0CODPRO], tamSX3( "B1_COD" )[1] ) ) ) )
			llProcOk := .F.
			AADD( apLog, {"#001", "Atualização de preço foi desconsidera para o produto [" + alCab[XZA0CODPRO] + "], pois não foi encontrado no ERP!"} )
		endif
		
		if ( llProcOk .and. .not. SA1->( dbSeek( fwxFilial( "SA1" ) + PADR( alItns[nlx][XZA1CLIENT], tamSX3( "A1_COD" )[1] ) + PADR( alItns[nlx][XZA1LOJA], tamSX3( "A1_LOJA" )[1] ) ) ) )
			llProcOk := .F.
			AADD( apLog, {"#002", "Atualização de preço foi desconsidera para o Cliente/Loja[" + alItns[nlx][XZA1CLIENT] + "/" + alItns[nlx][XZA1LOJA] + "], pois não foi encontrado no ERP!"} )
		endif
		
		if ( llProcOk .and. dlDtFim < dlDtIni .or. empty( dlDtFim ) )
			llProcOk := .F.
			AADD( apLog, {"#003", "Atualização de preço foi desconsidera. Data Final [" + dToC( dlDtFim ) + "] esta menor que a Data Inicial [" + dToC( dlDtIni ) + "]." } )
		endif
		
		if ( llProcOk )
			llProcOk := chkFilVld( alCab, alItns[nlx] )
		endif
		
	next nlx
	
	restArea( alArea )

Return llProcOk

/*/{Protheus.doc} chkFilVld
Responsavel por checar se a filiar do registro a ser importado existe
@author DS2U (SDA)
@since 02/10/2018
@version 1.0
@return llHasFil, Se .T., existe a filial
@param alCab, array of logical, Array com informações do cabeçalho
@param alItns, array of logical, Array com informacoes do registro que esta sendo lido para a importacao
@param clCodFil, characteres, Parametro passada por referencia para ser preenchido o codigo da filial 
@type function
/*/
Static Function chkFilVld( alCab, alItns, clCodFil )

	local alArea	:= getArea()
	local llHasFil	:= .F.
	local clBase	:= ""
	
	default alItns	:= {}
	default clCodFil	:= "      "
	
	clBase := allTrim( alItns[XZA1BASE] )
	clBase := subs( clBase, 1, 3 )

	dbSelectArea("SM0")
	dbGotop()
	
	while ( .not. SM0->( eof() ) )
		
		if ( subs( SM0->M0_FILIAL,1,3) == clBase )
			clCodFil := SM0->M0_CODFIL
			llHasFil := .T.
			exit
		endif
		
		SM0->( dbskip() )
	endDo
	
	if ( .not. llHasFil )
		AADD( apLog, {"#004", "Atualização de preço foi desconsiderada para o Cliente/Loja[" + alItns[XZA1CLIENT] + "/" + alItns[XZA1LOJA] + "] >> Produto [" + alCab[XZA0CODPRO] + "], pois não foi encontrado a base/filial [" + clBase + "] no ERP!"} )
	endif
	
	restArea( alArea )
	
Return llHasFil