#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------
// VARIAVEIS COM AS POSICOES DO ARRAY DE IMPORTACAO DE DADOS -
// DEVEM ESTAR IGUAIS NO FONTE WSAIR008                      -
//------------------------------------------------------------
STATIC XZA2DESCTA	:= 1
STATIC XZA2CODPRO	:= 2
STATIC XZA3BASE		:= 3
STATIC XZA3CLIENT	:= 4
STATIC XZA3LOJA		:= 5
STATIC XZA3PERDES	:= 6
STATIC XZA2DTINI	:= 7
STATIC XZA2DTFIM	:= 8

/*/{Protheus.doc} AIFATP02
Bilioteca de funcoes para tratamento de tabela de descontos da AirBP
@author DS2U (SDA)
@since 25/09/2018
@version 1.0
@return uRet, retorno da funcao que foi executada
@param nlOpc, numeric, numero da opcao da funcao a ser executada
@param uParam, undefined, parametro a ser enviado para a funcao a ser executada
@type function
/*/
User Function AIFATP02( nlOpc, uParam )

	local uRet		:= nil
	
	default nlOpc	:= 0
	default uParam	:= nil
	
	do Case
	
		case ( nlOpc == 0 )
			uRet := import( uParam )
	
	endCase

Return uRet

/*/{Protheus.doc} import
Responsavel por executar os passos para importacao da tabela de descontos
@author DS2U (SDA)
@since 02/10/2018
@version 1.0
@return apLog, Array bidimensional retornando codigo e descricao do processo
@param alDados, array of logical, Array com informacoes de cabeçalho e itens a serem gravados na tabela de descontos
@type function
/*/
Static Function import( alDados )

	local nlx

	private apLog	:= {}

	default alDados	:= {}
	

	if ( len( alDados ) > 0 )
	
		if ( len( apLog ) == 0 ) // Se nao houve erros
		
			for nlx := 1 to len( alDados )
			
				//---------------------------------
				// Valida preenchimento dos itens -
				//---------------------------------
				if ( validData( alDados[nlx] ) )
				
					//----------------------------------------
					// Grava desconto na tabela de descontos -
					//----------------------------------------
					if ( .not. saveOff( alDados[nlx] ) )
						AADD( apLog, {"#005", "Falha na gravação do registro >> " + varInfo( "alDados", alDados[nlx] ) } )
					endif
				
				endif
			
			next nlx
			
		endif
	
	else
		AADD( apLog, {"#000", "Não há dados para importação!"} )
	endif

Return apLog

/*/{Protheus.doc} validData
Responsavel por validar o registro a ser importado
@author DS2U (SDA)
@since 02/10/2018
@version 1.0
@return llProcOk, Se .T., o registro foi validado, se .F. será desconsiderado pela importacao
@param alDados, array of logical, Array com informacoes do registro que esta sendo lido para a importacao
@type function
/*/
Static Function validData( alDados )

	local alArea	:= getArea()
	local llProcOk	:= .T.
	local dlDtIni	:= alDados[XZA2DTINI]
	local dlDtFim	:= alDados[XZA2DTFIM]
	
	default alDados	:= {}
	
	dbSelectArea( "SB1" )
	SB1->( dbSetOrder( 1 ) )
	
	dbSelectArea( "SA1" )
	SA1->( dbSetOrder( 1 ) )
	
	if ( .not. SB1->( dbSeek( fwxFilial( "SB1" ) + alDados[XZA2CODPRO] ) ) )
		llProcOk := .F.
		AADD( apLog, {"#001", "Atualização de desconto foi desconsidera para o produto [" + alDados[XZA2CODPRO] + "], pois não foi encontrado no ERP!"} )
	endif
	
	if ( llProcOk .and. .not. SA1->( dbSeek( fwxFilial( "SA1" ) + alDados[XZA3CLIENT] + alDados[XZA3LOJA] ) ) )
		llProcOk := .F.
		AADD( apLog, {"#002", "Atualização de desconto foi desconsidera para o Cliente/Loja[" + alDados[XZA3CLIENT] + "/" + alDados[XZA3LOJA] + "], pois não foi encontrado no ERP!"} )
	endif
	
	if ( llProcOk .and. !empty( dlDtIni ) )
		if ( !empty( dlDtFim ) .and. dlDtFim < dlDtIni )
			llProcOk := .F.
			AADD( apLog, {"#003", "Atualização de desconto foi desconsidera. Data Final [" + dToC( dlDtFim ) + "] esta menor que a Data Inicial [" + dToC( dlDtIni ) + "]." } )
		endif
	endif
	
	if ( llProcOk )
		llProcOk := chkFilVld( alDados )
	endif
	
	restArea( alArea )

Return llProcOk

/*/{Protheus.doc} chkFilVld
Responsavel por checar se a filiar do registro a ser importado existe
@author DS2U (SDA)
@since 02/10/2018
@version 1.0
@return llHasFil, Se .T., existe a filial
@param alDados, array of logical, Array com informacoes do registro que esta sendo lido para a importacao
@type function
/*/
Static Function chkFilVld( alDados, clCodFil )

	local alArea	:= getArea()
	local llHasFil	:= .F.
	local clBase	:= ""
	
	default alDados	:= {}
	default clCodFil	:= "      "
	
	clBase := allTrim( alDados[XZA3BASE] )
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
		AADD( apLog, {"#003", "Atualização de desconto foi desconsidera para o Cliente/Loja[" + alDados[XZA3CLIENT] + "/" + alDados[XZA3LOJA] + "] >> Produto [" + alDados[XZA2CODPRO] + "], pois não foi encontrado a base/filial [" + clBase + "] no ERP!"} )
	endif
	
	restArea( alArea )
	
Return llHasFil

/*/{Protheus.doc} saveOff
Responsavel por gravar os dados da importacao de tabela de descontos
@author DS2U (SDA)
@since 02/10/2018
@version 1.0
@return llProcOk, Se .T., a gravação ocorreu com sucesso.
@param alDados, array of logical, Array com informacoes dos campos da tabela ZA2 / ZA3 a serem gravados
@type function
/*/
Static Function saveOff( alDados )

	local alArea	:= getArea()
	local llProcOk	:= .F.
	local llFindZA2	:= .F.
	local llFindZA3	:= .F.
	local clCodTab	:= ""
	local clRev		:= ""
	local clCodFil	:= "      "
	local llConfirm	:= .F.
	
	dbSelectArea( "SB1" )
	SB1->( dbSetOrder( 1 ) )
	
	dbSelectArea( "SA1" )
	SA1->( dbSetOrder( 1 ) )
	
	if ( SB1->( dbSeek( fwxFilial( "SB1" ) + PADR( alDados[XZA2CODPRO], tamSX3("B1_COD")[1] ) ) ); 
		.and. SA1->( dbSeek( fwxFilial( "SA1" ) + PADR( alDados[XZA3CLIENT], tamSX3("A1_COD")[1] ) + PADR( alDados[XZA3LOJA], tamSX3("A1_LOJA")[1] ) ) ); 
	   )
	
		dbSelectArea( "ZA2" )
		ZA2->( dbSetOrder( 2 ) )  // ZA2_FILIAL+ZA2_CODPRO+ZA2_ATIVA
		
		dbSelectArea( "ZA3" )
		ZA3->( dbSetOrder( 1 ) )  // ZA3_FILIAL+ZA3_CODTAB+ZA3_REV+ZA3_BASE+ZA3_CLIENT+ZA3_LOJA                                                                                                      
		
		if ( llFindZA2 := ZA2->( dbSeek( fwxFilial("ZA2") + PADR( alDados[XZA2CODPRO], tamSX3("ZA2_CODPRO")[1] ) + dToS( alDados[XZA2DTINI] ) + "1", .T.) ) )
			clCodTab	:= ZA2->ZA2_CODTAB	
			clRev		:= ZA2->ZA2_REV
		else
			clCodTab := getSXENum("ZA2","ZA2_CODTAB")
			clRev    := "001"
			llConfirm := .T.
		endif
		
		//---------------
		// Busca filial -
		//---------------
		chkFilVld( alDados, @clCodFil )
		
		llFindZA3 := ZA3->( dbSeek( fwxFilial("ZA3") + PADR( clCodTab, tamSX3("ZA2_CODTAB")[1] ) + PADR( clRev, tamSX3("ZA3_REV")[1] ) + PADR( clCodFil, tamSX3("ZA3_BASE")[1] ) + SA1->A1_COD + SA1->A1_LOJA , .T.) )
		
		begin transaction
	
			if ( reclock("ZA2", .not. llFindZA2 ) )
			
				ZA2->ZA2_FILIAL	:= fwxFilial( "ZA2" )				// Filial
				ZA2->ZA2_CODTAB	:= clCodTab							// Código da tabela
				ZA2->ZA2_REV	:= clRev							// Numero da revisão da tabela
				ZA2->ZA2_DESCTA	:= allTrim( alDados[XZA2DESCTA] )	// Descrição da tabela
				ZA2->ZA2_CODPRO	:= alDados[XZA2CODPRO]				// Codigo do Produto
				ZA2->ZA2_DESCPR	:= SB1->B1_DESC						// Descrição do Produto
				ZA2->ZA2_DTINI	:= alDados[XZA2DTINI]				// Data Inicial
				ZA2->ZA2_DTFIM  := alDados[XZA2DTFIM]				// Data Final
				ZA2->ZA2_ATIVA	:= "1"								// 1-Ativa ou 2-Inativa
				ZA2->ZA2_OBS	:= ""								// Observação geral
			
				if ( .not. llFindZA2 )
					ZA2->ZA2_DTINC   := date()						// Data da importação/inclusão da tabela de desconto
					ZA2->ZA2_HRINC   := time()						// Hora da importação/inclusão da tabela de desconto
				endif
				
				ZA2->( msUnlock() )
				
			endif
			
			if ( reclock("ZA3", .not. llFindZA3 ) )
			
				ZA3->ZA3_FILIAL  := fwxFilial( "ZA3" )	// Filial
				ZA3->ZA3_CODTAB  := clCodTab			// Codigo da tabela
				ZA3->ZA3_REV     := clRev				// Numero revisão da tabela
				ZA3->ZA3_BASE	 := clCodFil			// Base-Filial a que se refere a tabela
				ZA3->ZA3_CLIENT  := SA1->A1_COD			// Codigo do cliente
				ZA3->ZA3_LOJA    := SA1->A1_LOJA		// Loja do cliente
				ZA3->ZA3_NOMCLI  := SA1->A1_NOME		// Nome do Cliente
				ZA3->ZA3_PERDES  := alDados[XZA3PERDES]	// Percentual de desconto
				ZA3->ZA3_OBSERV  := ""					// Observação
				ZA3->( msUnlock() )
				
			endif
			
			if ( llConfirm )
				confirmSX8()
			endif
	
			llProcOk := .T. 
		
		end transaction
		
	endif  
	
	restArea( alArea )

Return llProcOk