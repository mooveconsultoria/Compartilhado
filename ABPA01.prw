#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} ABPA01

Cadastro utilizado para configurar processos e etapas

@author DS2U (SDA)
@since 02/05/2019
@version 1.0

@type function
/*/
User Function ABPA01()

Local oMBrowse := NIL

oMBrowse:= FWMBrowse():New()	
oMBrowse:SetAlias('PI2')
oMBrowse:SetDescription('Processos x Etapas')
oMBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Funcao para gerar os menus da Browse principal
@author DS2U (SDA)
@since 02/05/2019
@version 1.0
@return aRotina, Array de menus da Browse

@type function
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"				ACTION "PesqBrw"		OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE "Visualizar"				ACTION "VIEWDEF.ABPA01"	OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE "Incluir"					ACTION "VIEWDEF.ABPA01"	OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE "Alterar"					ACTION "VIEWDEF.ABPA01"	OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE "Excluir"					ACTION "VIEWDEF.ABPA01"	OPERATION 5 ACCESS 0 // "Excluir" 

Return aRotina

/*/{Protheus.doc} ModelDef
Funcao de modelagem dos dados da rotina de cadastro de Processos x Etapas
@author DS2U (SDA)
@since 02/05/2019
@version 1.0
@return oModel, objeto do modelo de dados do cadastro

@type function
/*/
Static Function ModelDef()

Local oModel	:= MPFormModel():New( 'ABPA01MVC', /* bPreValidacao*/,/*bPosValidacao{ |oModel| tudoOk( oModel ) }*/, )
Local oStruPI2	:= FWFormStruct(1,'PI2')
Local oStruPI3	:= FWFormStruct(1,'PI3')

oModel:SetDescription("Processos x Etapas")
oModel:AddFields( 'PI2MASTER',, oStruPI2 )
oModel:SetPrimaryKey({"PI2_FILIAL","PI2_ID"})

oModel:AddGrid("PI3DETAIL", "PI2MASTER", oStruPI3 )
oModel:SetRelation('PI3DETAIL',{{'PI3_FILIAL','FWxFilial("PI3")'},{'PI3_IDPROC','PI2_ID'}}, PI3->( IndexKey( 1 ) ) )
oModel:GetModel('PI3DETAIL'):setUniqueLine({"PI3_FILIAL","PI3_ID"} )

oModel:GetModel('PI3DETAIL' ):SetDescription( "Etapas" )

Return oModel

/*/{Protheus.doc} ViewDef
Funcao para configuração da view do cadastro de Processos x Etapas
@author DS2U (SDA)
@since 02/05/2019
@version 1.0
@return oView, Objeto da view a ser criado a interface com o usuário

@type function
/*/
Static Function ViewDef()

Local oModel		:= FWLoadModel("ABPA01")
Local oView			:= FWFormView():New()
Local oStruPI2		:= FWFormStruct(2,'PI2' )
Local oStruPI3		:= FWFormStruct(2,'PI3' )

oView:SetModel( oModel )

oView:AddField('VIEW_PI2'	,oStruPI2	,'PI2MASTER')
oView:AddGrid('VIEW_PI3'	,oStruPI3	,'PI3DETAIL')

oView:CreateHorizontalBox('PRINCIPAL'	,30)
oView:CreateHorizontalBox('ITENS'		,70)

oView:SetOwnerView('VIEW_PI2'	,'PRINCIPAL' )
oView:SetOwnerView('VIEW_PI3'	,'ITENS'	)

oView:AddIncrementField("VIEW_PI3", "PI3_ID")

oView:EnableTitleView( 'VIEW_PI3'	, oModel:GetModel('PI3DETAIL'):GetDescription() )	

oView:SetCloseOnOk({||.T.})

Return oView