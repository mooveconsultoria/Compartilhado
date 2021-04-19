#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} AIFINP01
Rotina para ler arquivo CSV do Cancur e gerar arquivo TXT para ser importado os lançamentos contábeis

A configuração do arquivo TXT foi planejada da sequinte forma:

===============================================================
Descrição                             |Início | Fim | Tamanho
===============================================================
Número do Lançamento (Sempre Fixo 001)|	1	  | 3	| 3
Conta contábil	                      | 4	  | 18	| 15
Histórico	                          | 19	  | 38	| 20
Valor (sem virgula ou ponto)	      | 39	  | 48	| 10
Tipo (C para crédito e D para débito) | 49	  | 49	| 1
Centro de custo                       | 50	  | 56	| 7
Filial	                              | 57	  | 59	| 3
Item Conta Contábil                   | 60	  | 69	| 9
===============================================================
My Expenses
@author DS2U (SDA)
@since 09/12/2018
@version 1.0

@type function
/*/
User Function AIFINP01()

	local llOk			:= .T.
	local alButton		:= {}
	local alSay			:= {}
	local clTitulo		:= 'IMPORTAÇÃO MY EXPENSES'
	local clDesc1		:= 'Esta rotina tem como objetivo fazer importacao de arquivo do Concur '
	local clDesc2		:= 'no formato csv, e gerar o arquivo para importação no ERP Protheus.'
	local clDesc3		:= ''
	local llFirst		:= .T.
	
	private cpNameFile	:= "myExpenses_" + dToS( date() ) + "_" + strTran( time(), ":", "" ) + ".txt"
	private cpFile		:= ""
	private cpSep		:= ""

	private cpLcCrCBCP	:= allTrim( getMv("ME_TOPCBCP",,"2.1.5.01.00014") )
	private cpLcCrIBCP	:= allTrim( getMv("ME_TOPIBCP",,"2.1.5.01.00015") )
	private cpLcCrCASH	:= allTrim( getMv("ME_TOPCASH",,"2.1.1.01.00001") )
	private apPosCSV	:= aClone( separa( allTrim( getMv("ME_POSCSV",,"42,33,3,27,27,22,18,43") ), ",", .T. ) )
	/*
	DEFINICAO DO ARRAY apPosCSV
	o array armazena o numero da posicao da coluna do arquivo CSV, que vem do parametro ME_POSCSV
	
	O PARAMETRO ME_POSCSV DEVE SEGUIR A SEGUINTE ORDEM DE CONFIGURACAO DE COLUNAS:
	
	LANCAMENTO DEBITO
	TIPO DE OPERACAO
	ID DO FUNCIONARIO NO CONCUR
	CENTRO DE CUSTO CONTA DEBITO
	CENTRO DE CUSTO CONTA CREDITO
	DESCRICAO 1
	DESCRICAO 2
	VALOR
	*/

	if ( len( apPosCSV ) == 8 )

		// Mensagens de Tela Inicial
		AADD( alSay, clDesc1)
		AADD( alSay, clDesc2)
		AADD( alSay, clDesc3)
		
		// Botoes do Formatch
		AADD( alButton, { 01, .T., {|| llOk := .T., fechaBatch() }})
		AADD( alButton, { 02, .T., {|| llOk := .F., fechaBatch() }})
		AADD( alButton, { 05, .T., {|| getParam() } } )
		
		while ( llOk;
		 		.and. ( empty( cpFile ) .or. empty( cpSep ) );
				)
			
			if ( .not. llFirst .and. ( empty( cpFile ) .or. empty( cpSep ) ) )
				alert( "Os parâmetros devem ser preenchidos!" )
				llOk := .F.
			endif
			
			formBatch( clTitulo, alSay, alButton )
			
			llFirst := .F.
			
		endDo
		
		if ( llOk )
			fwMsgRun(,{|oSay| impConcur() },"Aguarde!","Processando arquivo Concur..." )
			msgInfo( "Processamento finalizado!" )
		endif
		
	else
		alert( "Parametrização das colunas não foi realizar. Verificar na documentação como preencher o parâmetro ME_POSCSV!" )
	endif

Return

/*/{Protheus.doc} getParam
Funcao para controlar os parametros da importação
@author DS2U (SDA)
@since 09/12/2018
@version 1.0

@type function
/*/
Static Function getParam()

	local alParamBox	:= {}
	local clTitulo		:= "Parâmetros"
	local alButtons		:= {}
	local llCentered	:= .T.
	local nlPosx		:= Nil
	local nlPosy		:= Nil
	local clLoad		:= ""
	local llCanSave		:= .F.
	local llUserSave	:= .F.
	local llRet			:= .T.
	local clVldDt		:= ".T."
	local clVldSA11		:= ".T."
	local blOk			:= {|| &clVldDt }
	local alParams		:= {}
	
	AADD(alParamBox,{6,"Informe o Arquivo Concur"	,space( 250 )	,"@!",clVldSA11,".T.",75,.T.,"Arquivos .CSV |*.CSV"})
	AADD(alParamBox,{1,"Caracter Separador"			,space( 1 )		,"@!",".T."     ,""  ,"",15,.T.})

	llRet := ParamBox(alParamBox, clTitulo, alParams, blOk, alButtons, llCentered, nlPosx, nlPosy,, clLoad, llCanSave, llUserSave)
	
	if ( llRet )
		cpFile	:= alParams[1]
		cpSep	:= alParams[2]
	endif

Return

/*/{Protheus.doc} impConcur
Funcao para realizar a leitura do arquivo CSV
@author DS2U (SDA)
@since 09/12/2018
@version 1.0

@type function
/*/
Static Function impConcur()

	local clDir			:= subs( cpFile, 1, rat( "\", cpFile ) )
	local clFullName	:= clDir + cpNameFile
	local alDados		:= {}
	local nlLin			:= 1
	local olFileRead	:= fwFileReader():New( cpFile )
	local llFileOk		:= .T.
	local llFirstLn		:= .T.
	
	private opFileWrit	:= fwFileWriter():New(clFullName, .F.)
	
	olFileRead:nBufferSize := 5000
	
	if ( olFileRead:open() )
	
		if ( .not. olFileRead:eof() )
			
			if ( .not. opFileWrit:create() )
				
				llFileOk := .F.
				alert( "Não foi possível criar arquivo " + clFullName )
			
			endif
			
		endif
		
		if ( llFileOk )
	
			while ( olFileRead:hasLine() )
				
				if ( nlLin > 1 )
				
					alDados := aClone( separa( olFileRead:getLine(), cpSep, .T. ) )
					
					if ( len( alDados ) >= 43 )
						writeLin( alDados, .not. llFirstLn )
						llFirstLn := .F.
					endif
					
				else
					olFileRead:getLine()
				endif
				
				nlLin++
							
			endDo
	
			opFileWrit:close()
			
		endif
		
		olFileRead:close()
		
	else
	   msgAlert("Erro de abertura do arquivo!", "ERRO!")
	endif
	
Return

/*/{Protheus.doc} writeLin
Funcao para escrever linha a linha o arquivo txt para ser importado no ERP Protheus
@author DS2U (SDA)
@since 09/12/2018
@version 1.0
@param alDados, array of logical, Array com o conteudo das colunas do arquivo do concur, ( deve ser enviado linha a linha )
@type function
/*/
Static Function writeLin( alDados, llEnter )

	local clTexto		:= ""
	local nlx
	local clTpLancto	:= ""
	local clPrefix		:= allTrim( getMv( "ME_PREITCT",, "F" ) )
	local nlPosLctoDb	:= val( apPosCSV[1] )
	local nlPosTpOper	:= val( apPosCSV[2] )
	local nlPosIdFunc	:= val( apPosCSV[3] )
	local nlPosCCdeb	:= val( apPosCSV[4] )
	local nlPosCCcred	:= val( apPosCSV[5] )
	local nlPosDesc1	:= val( apPosCSV[6] )
	local nlPosDesc2	:= val( apPosCSV[7] )
	local nlPosValor	:= val( apPosCSV[8] )
	local cCRLF		    := CHR(13)+CHR(10)
	
	default alDados := {}
	default llEnter	:= .T.

	if ( len( alDados ) > 0 )
	
		// É gerado sempre 2 linhas, 1 para credito e outra para débito
		for nlx := 1 to 2
		
			clTexto := ""
		
			//if ( llEnter )
			//	clTexto += cCRLF
			//else
			//	llEnter := .T.
			//endif
		
			clTpLancto := iif( nlx == 1, "D", "C" )

			// Número do Lançamento (Sempre Fixo 001)
			clTexto += "001"
			
			// Conta contábil
			clTexto += trataStr( getLctoCTB( clTpLancto, alDados, nlPosTpOper, nlPosLctoDb ), 15 )
			
			// Histórico
			clTexto += trataStr( alDados[nlPosDesc1] + " " + alDados[nlPosDesc2], 19 )
			
			// Complemento de espaço
			clTexto += space( 1 )
			
			// Valor (sem virgula ou ponto)
			clTexto += trataStr( strTran( strTran( strTran( trataStr( alDados[nlPosValor], 10 ), ",", ""), ".", ""), "-", ""), 10 )
			
			// Tipo (C para crédito e D para débito)
			clTexto += clTpLancto
			
			// Centro de custo
			clTexto += trataStr( alDados[ iif( clTpLancto == "D", nlPosCCdeb, nlPosCCcred )], 7 )
			
			// Filial
			clTexto += trataStr( getFilial(), 3)
			
			// Item Contabil
			clTexto += trataStr( iif( clTpLancto == "D", getMv("ME_ITCTBDC",,""), clPrefix + getItCTB( alDados[nlPosIdFunc] ) ), 9)

			// Quebra de linha
			clTexto += cCRLF

			opFileWrit:write( clTexto )
			
		next nlx
		
	endif
		
Return

/*/{Protheus.doc} getItCTB
Funcao auxiliar para consultar o item contábil do funcionario
@author DS2U (SDA)
@since 28/12/2018
@version 1.0
@return clItemCTB, Código do item contábil do funcionario
@param clIdFunc, characters, ID do funcionário no Concur
@type function
/*/
Static Function getItCTB( clIdFunc )

	local clAlias	:= getNextAlias()
	local clItemCTB	:= ""
	local clQuery	:= ""
	
	default clIdFunc := ""
	
	clIdFunc := trataStr(clIdFunc, tamSx3("A2_XIDCONC")[1])
	
	clQuery += "SELECT "
	clQuery += "	A2_COD "
	clQuery += "FROM "
	clQuery += "	" + retSqlTab( "SA2" )
	clQuery += " WHERE "
	clQuery += "	A2_FILIAL = '" + fwxFilial( "SA2" ) + "' "
	clQuery += "	AND A2_XIDCONC = '" + clIdFunc + "' "
	clQuery += "	AND SA2.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,clQuery), clAlias, .F., .T.)
	
	if ( .not. ( clAlias )->( eof() ) )
		clItemCTB := allTrim( ( clAlias )->A2_COD )
	endif
	( clAlias )->( dbCloseArea() )

Return clItemCTB

/*/{Protheus.doc} getLctoCTB
Funcao para tratar como pegar o lacamento contabil de credito ou debito
@author DS2U (SDA)
@since 09/12/2018
@version 1.0
@return clLancto, Codigo da conta do lancamento contabil
@param clTpLancto, characters, Tipo do lancamento ( D=Debito;C=Credito)
@param alDados, array of logical, Array com o conteudo das colunas lidas do arquivo
@param nlPosTpOper, numeric, Posicao da coluna para identificar o tipo de operacao ( CASH=Reembolso de despesa;IBCP=Cartão pessoal;CBCP=PCard )
@param nlPosLctoDb, numeric, Posicao para identificar o codigo do lancamento contabil de debito
@type function
/*/
Static Function getLctoCTB( clTpLancto, alDados, nlPosTpOper, nlPosLctoDb )

	local clLancto	:= ""
	
	if ( clTpLancto == "D" )
		clLancto := alDados[nlPosLctoDb]
	elseif ( clTpLancto == "C" )
	
		if ( "CBCP" == trataStr( alDados[nlPosTpOper], 4 ) )
			clLancto := cpLcCrCBCP
		elseif ( "IBCP" == trataStr( alDados[nlPosTpOper], 4 ) )
			clLancto := cpLcCrIBCP
		elseif ( "CASH" == trataStr( alDados[nlPosTpOper], 4 ) )
			clLancto := cpLcCrCASH
		endif
	
	endif
	
	clLancto := strTran( clLancto, ".", "" )

Return clLancto

/*/{Protheus.doc} trataStr
Funcao auxiliar para tratar as String para a geração do arquivo texto
@author DS2U (SDA)
@since 09/12/2018
@version 1.0
@return clString, String tratada
@param clString, characters, String a ser tratada
@param nlTam, numeric, Tamanha que a string deve obedecer
@type function
/*/
Static Function trataStr( clString, nlTam )

	local nlx
	local clCaracter	:= ""
	local clTxtAux		:= ""
	
	default nlTam		:= 0

	//------------------------------------------------------------------------------------------
	// Tratativa necessaria pois a String vem com caracter asc 0 (com espaços) entre as letras -
	// Exemplo: M Y   E X P E N S E S                                                          -
	//------------------------------------------------------------------------------------------
	for nlx := 1 to len( clString )
	
		clCaracter := subs( clString, nlx, 1 )
	
		if ( .not. asc( clCaracter ) == 0 )
			clTxtAux += subs( clString, nlx, 1 )
		endif
	
	next nlx
	
	//-------------------------------------------------------------------------------------------------------------------
	// Trata o tamanho da String para nao deixar ultrapassar o tamanho configurado para o arquivo de contabilizacao TXT -
	//-------------------------------------------------------------------------------------------------------------------
	if ( nlTam > 0 .and. len( clTxtAux ) > nlTam )
		clTxtAux := subs( clTxtAux, 1, nlTam )
	endif

	clString := PADR( clTxtAux, nlTam )

Return clString

/*/{Protheus.doc} getFilial
Funcao auxiliar para retornar a filial no formato esperado
@author DSs2U (SDA)
@since 12/12/2018
@version 1.0
@return ret, Codigo da filial

@type function
/*/
Static Function getFilial()
Return subs( SM0->M0_FILIAL,1,3 )