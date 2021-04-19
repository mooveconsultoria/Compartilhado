#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} ABPA17
Rotina para geração de liquidação de faturas a receber

@trello ID01 - Api para faturamento

@author DS2U (SDA)
@since 12/07/2019
@version 1.0
@type function
/*/
User Function ABPA18()

Local cBody     := PARAMIXB[2]
Local oBody     := JsonObject():New()
Local aDados
Local nlx
Local uInfo
Local aRet
Local nTamDoc   := tamSX3("F2_DOC")[1]
Local nTamSerie := tamSX3("F2_SERIE")[1]
Local nTamCli   := tamSX3("A2_COD")[1]
Local nTamLj    := tamSX3("A2_LOJA")[1]
Local aNFs      := {}
Local cCliente
Local cLoja
Local cNf
Local cSerie

oBody:fromJson( cBody )
aDados  := oBody:getJsonObject( "DADOS" )

for nlx := 1 to len( aDados )

	uInfo  := aDados[nlx]:getJsonText( "CLIENTE" )
	cCliente := PADR( uInfo, nTamCli )
	
	uInfo  := aDados[nlx]:getJsonText( "LOJA" )
	cLoja := PADR( uInfo, nTamLj )

	uInfo  := aDados[nlx]:getJsonText( "NF" )
	cNf := PADR( uInfo, nTamDoc )
	
	uInfo  := aDados[nlx]:getJsonText( "SERIE" )
	cSerie := PADR( uInfo, nTamSerie )
		
	AADD( aNFs, { cCliente, cLoja, cNf, cSerie } )

next nlx

if ( empty( aNFs ) )
	aRet := { .F., "Não foi encontrado notas fiscais nos parametros do request!" }
else
	aRet := execFT( aNFs )
endif

Return aRet

/*/{Protheus.doc} execFT
Funcao de execucao das etapas para geração da liquidação
@author DS2U (SDA)
@since 13/07/2019
@version 1.0
@return ${return}, Retorno [1] .T., Se o processamento ocorreu com sucesso
                           [2] Mensagem de erro ou de processamento
                           [3] array de retorno específico, no formato de 2 elementos, titulo e conteudo
@param aNFs, array, Array com NFs envolvidas
@type function
/*/
Static Function execFT( aNFs )

Local clFilial
Local clCliente := aNFs[1][1]
Local clLoja    := aNFs[1][2]
Local nlValor   := 0
Local alDataTit := {}
Local clNumFat
Local clPrefix 
Local clNaturez
Local clTipo
Local clNumBco
Local clNumAg
Local clAccount
Local nlMoeda
Local aRet		:= {}
Local cMsg		:= ""
Local clCond := ""
Local aRetEsp := {}

Private lMsErroAuto := .F.
Private lMsHelpAuto	:= .T.
Private lAutoErrNoFile := .T.

Default aNFs := {}

//-----------------------------------------
// Consulta condição de pagamento das NFs -
//-----------------------------------------
clCond := getCondPg( aNFs[1] )

//------------------------------------------------------------------------------
// Constroi os titulos que devem ser baixados e gerado novo valor pelo faturas -
//------------------------------------------------------------------------------
alDataTit := getDataTit( aNFs, @nlValor )

if ( len( alDataTit ) > 0 )

	clPrefix  := PADR( right( cFilAnt, 2 ) + "1", tamSX3("E1_PREFIXO")[1] ) // Regra do prefixo	
	clNaturez := PADR( allTrim( getMv( "ES_NATUREZ",,"31101" ) ), tamSX3("E1_NATUREZ")[1] )
	clTipo    := PADR( allTrim( getMv( "ES_TIPO",,"FT" ) ), tamSX3("E1_TIPO")[1] )
	clNumBco  := PADR( allTrim( getMv( "ES_BCONUM",,"033" ) ), tamSX3("E1_BCOCHQ")[1] )
	clNumAg	  := PADR( allTrim( getMv( "ES_AGNUM",,"2271" ) ), tamSX3("E1_AGECHQ")[1] )
	clAccount := PADR( allTrim( getMv( "ES_NCONTA",,"13006692" ) ), tamSX3("E1_CTACHQ")[1] )
	nlMoeda	  := getMv( "ES_MOEDAAF",,1 )
	
	clNumFat  := PADR( getNextNFT( clFilial, clPrefix, clTipo ), tamSX3("E1_NUM")[1] )
	
	aRet := liquidar( clCond, clNaturez, clTipo, clCliente, clLoja, nlMoeda, clPrefix, clNumFat, clNumBco, clNumAg, clAccount, nlValor, alDataTit )
	lMsErroAuto := aRet[1] 
	cMsg 		:= aRet[2]
	aRetEsp		:= aClone( aRet[3] )

else
	cMsg := "Nao foram encontrados titulos para a geracao de FT"
endif

Return { lMsErroAuto, cMsg, aRetEsp }

/*/{Protheus.doc} getDataTit
Constroi a listagem de titulos a receber que devem ser considerados na execauto de faturas a receber
@author DS2U (SDA)
@since 12/07/2019
@version 1.0
@return alDataTit, Lista de recnos dos titulos a serem considerados para geração de faturas
@param aNFs, array, Array com as informações abaixo
nlValor, numeric, Variavel passada por referencia para guardar o valor total
@type function
/*/
Static Function getDataTit( aNFs, nlValor )

	Local alDataTit	:= {}
	Local nlx
	Local alArea	:= getArea()
	Local alAreaSE1	:= {}
	Local cAlias    := getTitByNf( aNFs )
	
	if ( !empty( cAlias ) )

		dbSelectArea( "SE1" )
		alAreaSE1 := SE1->( getArea() )
		
		SE1->( dbSetOrder( 2 ) ) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
		
		while ( !( cAlias )->( eof() ) )
		
			if ( SE1->( dbSeek(	( cAlias )->( E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA ) ) ) )
				
				if ( SE1->E1_SALDO > 0 )
					nlValor += ( cAlias )->E1_VALOR
					AADD( alDataTit, {"RECNO", allTrim( cValToChar( SE1->( recno() ) ) ) } ) // R_E_C_N_O_ do registro selecionado
				endif
				
			endif
				
			( cAlias )->( dbSkip() )
		endDo
		( cAlias )->( dbCloseArea() )

		restArea( alAreaSE1 )
		
	endif

	restArea( alArea )

Return alDataTit

/*/{Protheus.doc} getTitByNf
Funcao de consulta dos titulos envolvidos para geracao de Faturas
@author DS2U (SDA)
@since 13/07/2019
@version 1.0
@return cAlias, Alias da consulta dos titulos
@param aNFs, array, Array com as informações abaixo
clCliente, characters, Codigo do cliente
clLoja, characters, Loja do cliente
cNf, characters, Nota
cSerie, characters, Serie
@type function
/*/
Static Function getTitByNf( aNFs )

Local cAlias := getNextAlias()
Local clCliente
Local clLoja
Local cNf
Local cSerie
Local nlx
Local cFiltro := ""
Local nTo     := len( aNFs )

Default aNFs := {}

for nlx := 1 to nTo

	clCliente := aNFs[nlx][1]
	clLoja    := aNFs[nlx][2]
	cNf       := aNFs[nlx][3]
	cSerie    := aNFs[nlx][4]
	
	cFiltro += "(E1_CLIENTE = '" + clCliente + "'"
	cFiltro += " AND E1_LOJA = '" + clLoja + "'"
	cFiltro += " AND E1_NUM = '" + cNf + "'"
	cFiltro += " AND F2_SERIE = '" + cSerie + "')"
	
	if !( nlx == nTo )
		cFiltro += " OR "
	endif

next nlx

cFiltro := "%" + cFiltro + "%"

BEGINSQL ALIAS cAlias

	SELECT
		E1_FILIAL 
		, E1_CLIENTE
		, E1_LOJA
		, E1_PREFIXO
		, E1_NUM
		, E1_PARCELA
		, E1_VALOR
	
	FROM	
		%TABLE:SE1% SE1
		
	INNER JOIN
		%TABLE:SF2% SF2 ON
		SF2.F2_FILIAL = %XFILIAL:SF2%
		AND SF2.F2_FILIAL = SE1.E1_FILORIG
		AND SF2.F2_DUPL = SE1.E1_NUM
		AND SF2.F2_CLIENTE = SE1.E1_CLIENTE
		AND SF2.F2_LOJA = SE1.E1_LOJA
		AND SF2.%NOTDEL%
		
	WHERE
		SE1.E1_FILIAL = %XFILIAL:SE1%
		AND %EXP:cFiltro%
		AND SE1.E1_SALDO > 0
		AND SE1.%NOTDEL%

ENDSQL

if ( ( cAlias )->( eof() ) )
	( cAlias )->( dbCloseArea() )
	cAlias := ""
endif

Return cAlias

/*/{Protheus.doc} liquidar
Funcao para processamento da rotina de liquidação de titulos (FINA460)
@author DS2U (SDA)
@since 12/07/2019
@version 1.0
@return llRet, Se .T., a geracao de faturas foi realizada com sucesso
@param clCond, characters, Codigo da condicao de pagamento 
@param clNaturez, characters, Codigo da natureza
@param clTipo, characters, Codigo do tipo do titulo
@param clCliente, characters, Codigo do cliente
@param clLoja, characters, Codigo da loja do cliente
@param nlMoeda, numeric, Codigo da moeda
@param clPrefix, characters, Prefixo do titulo a ser gerado
@param clNumFat, characters, Numero do titulo a ser gerado
@param clNumBco, characters,  Numero do banco a ser amarrado ao titulo de liquidacao
@param clNumAg, characters, Numero da agencia a ser amarrado ao titulo de liquidacao
@param clAccount, characters, Numero da conta a ser amarrado ao titulo de liquidacao
@param nlValor, numeric, Valor a ser gerado o titulo de fatura
@param alRecnosSE1, array of logical, Array com os recnos do SE1 que serao liquidados para geracao do Faturas
@type function
/*/
Static Function liquidar( clCond, clNaturez, clTipo, clCliente, clLoja, nlMoeda, clPrefix, clNumFat, clNumBco, clNumAg, clAccount, nlValor, alRecnosSE1 )

Local aCab		:= {}
Local aItens	:= {}
Local aParcelas	:= {}
Local nZ
Local clParcela	:= space( tamSx3("E1_PARCELA")[1] )
Local cFiltro	:= ""
Local nlRecno	:= 0
Local clFilEsp	:= ""
Local nlOpc		:= 3
Local llRet		:= .F.
Local nlVlrAcres:= 0
Local nlVlrDecre:= 0
Local clMsgErro	:= ""
Local aRetEsp   := {}
Local cTitulos  := ""

Private INCLUI	:= .T.

if ( len( alRecnosSE1 ) > 0 )

	dbSelectArea( "SE1" )

	// Filtra os titulos envolvidos
	for nZ := 1 to len( alRecnosSE1 )

		SE1->( dbGoTo( val( alRecnosSE1[nz][2] ) ) )

		if ( SE1->( recno() ) == val( alRecnosSE1[nz][2] ) )
			cTitulos += SE1->E1_NUM + "/"
		endif

	next nZ

	cFiltro := "E1_FILIAL == '" + fwxFilial("SE1") + "' .and. "
	cFiltro += "E1_CLIENTE == '" + clCliente + "' .and. "
	cFiltro += "E1_LOJA == '" + clLoja + "' .and. "
	cFiltro += "E1_SITUACA $ '0FG' .and. "
	cFiltro += "E1_SALDO > 0 .and. "
	cFiltro += "E1_NUM $ '" + cTitulos + "' .and. "
	cFiltro += 'Empty(E1_NUMLIQ)'

	aCab := {	{"cCondicao",	clCond },;
				{"cNatureza",	clNaturez },;
				{"E1_TIPO" ,	clTipo },;
				{"cCLIENTE",	clCliente },;
				{"nMoeda",		nlMoeda },; 
				{"cLOJA",		clLoja }}

	//----------------------------------------------------------
	// Monta as parcelas de acordo com a condição de pagamento -
	//----------------------------------------------------------
	aParcelas := Condicao( nlValor, clCond,, dDataBase)
	
	if ( len( aParcelas ) == 0 )
		AADD( aParcelas, { dDataBase, nlValor } )
	elseif ( len( aParcelas ) > 1 )
		clParcela := strZero( 1, tamSx3("E1_PARCELA")[1] )
	endif
	
	//--------------------------------------------------------------
	//Não é possivel mandar Acrescimo e Decrescimo junto.
	//Se mandar os dois valores maiores que zero considera Acrescimo
	//--------------------------------------------------------------
	For nZ := 1 to Len(aParcelas)
	
		//-------------------------------------
		// Dados das parcelas a serem geradas -
		//-------------------------------------
		AADD(aItens,{	{"E1_PREFIXO"	, clPrefix },;		//Prefixo
						{"E1_BCOCHQ"	, clNumBco },;		//Banco
						{"E1_AGECHQ"	, clNumAg },;		//Agencia
						{"E1_CTACHQ"	, clAccount },;		//Conta
						{"E1_NUM"		, clNumFat },;		//Nro. cheque (dará origem ao numero do titulo)
						{"E1_PARCELA"	, clParcela },;		//Nro. cheque (dará origem ao numero do titulo)
						{"E1_EMITCHQ"	, "AUTO" },; 		//Emitente do cheque
						{"E1_VENCTO"	, aParcelas[nZ,1]},;//Data boa 
						{"E1_VLCRUZ"	, aParcelas[nZ,2]}})//Valor do cheque/titulo
						//{"E1_ACRESC"	, nlVlrAcres },;	//Acrescimo
						//{"E1_DECRESC"	, nlVlrDecre }})	//Decrescimo
		
		if ( nZ > 1 )
			clParcela := soma1( clParcela, Len( alltrim( clParcela ) ) )
		endif
		
		if ( nZ == 1 )
			AADD( aRetEsp, { "prefixo", "" } )
			AADD( aRetEsp, { "titulo", "" } )
			AADD( aRetEsp, { "tipo", clTipo } )
		endif
		AADD( aRetEsp, { "parcela" + allTrim( cValToChar( nZ ) ), clParcela } )		
		AADD( aRetEsp, { "valor" + allTrim( cValToChar( nZ ) ), aParcelas[nZ,2] } )
		AADD( aRetEsp, { "vencimento" + allTrim( cValToChar( nZ ) ), aParcelas[nZ,1] } )		
		 
	Next nZ
	
	FINA460(, aCab, aItens, nlOpc, cFiltro)
	
	aEval( getAutoGRLog(), {|x| clMsgErro += x } )
	
	llRet := empty( clMsgErro )
	
	if ( llRet )
		aRetEsp[1][2] := cPreFatR11 // Variavel do sistema q guarda o prefixo gerado pela liuidacao
		aRetEsp[2][2] := cNumFatR11 // Variavel do sistema q guarda o titulo gerado pela liuidacao
	else
		aRetEsp := {}
	endif
	
endif
 
Return { llRet, clMsgErro, aRetEsp }

/*/{Protheus.doc} getNextNFT
Consulta o ultimo ID gerado para o cliente + tipo e retorna o proximo ID
@author DS2U (SDA)
@since 13/07/2019
@version 1.0
@return clID, ID a ser utilizado para novas faturas
@param clFilial, characters, Codigo da filial em que sera gerado a fatura
@param clPrefixo, characters, Codigo do prefixo
@param clTipo, characters, Tipo do titulo que representa faturas
@type function
/*/
Static Function getNextNFT( clFilial, clPrefixo, clTipo )

	local clID		:= strZero( 1, tamSX3("E1_NUM")[1] )
	local clAlias	:= getNextAlias()
	
	default clFilial	:= fwxFilial( "SE1" )
	default clPrefixo	:= ""
	default clTipo		:= ""
	
	// SE1990_UNQ
	// E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_D_E_L_
	
	BEGINSQL ALIAS clAlias
	
		SELECT
			MAX( E1_NUM ) AS MAXNUM
		
		FROM
			%TABLE:SE1% SE1
			
		WHERE
			SE1.E1_FILIAL = %EXP:clFilial%
			//AND E1_PREFIXO = %EXP:clPrefixo%
			AND E1_TIPO = %EXP:clTipo%
			AND SE1.%NOTDEL%
	
	ENDSQL
	
	if ( .not. ( clAlias )->( eof() ) )
		clID := soma1( ( clAlias )->MAXNUM )
	endif
	( clAlias )->( dbCloseArea() )
	
Return clID

/*/{Protheus.doc} getCondPg
Funcao para identificar a condicao de pagamento das NFs envolvidas
@type  Static Function
@author DS2U (SDA)
@since 26/10/2019
@version 1.0
@param aNF, array, Array com as informações da NF a ser consultada (todas as NFS deve ter a mesma condição de pagamento)
@return cCond, caracter, Condição de pagamento
/*/
Static Function getCondPg( aNF )
	
Local cCli   := aNF[1]
Local cLoja  := aNF[2]
Local cNF    := aNF[3]
Local cSerie := aNF[4]
Local cAlias	:= getNextAlias()
Local cCond  := ""

BEGINSQL ALIAS cAlias
	
	SELECT
		F2_COND
	FROM
		%TABLE:SF2% SF2
	WHERE
		F2_FILIAL = %XFILIAL:SF2%
		AND F2_DOC = %EXP:cNF%
		AND F2_SERIE = %EXP:cSerie%
		AND F2_CLIENTE = %EXP:cCli%
		AND F2_LOJA = %EXP:cLoja%
		AND SF2.%NOTDEL%

ENDSQL

if ( .not. ( cAlias )->( eof() ) )
	cCond := ( cAlias )->F2_COND
endif
( cAlias )->( dbCloseArea() )

Return cCond