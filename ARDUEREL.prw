#include 'protheus.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} ARDUEREL
Relatório DUE
@author  marcio.katsumata
@since   31/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
user function ARDUEREL()
    Local oReport
    local aRet      as array     //array de retorno da função parambox
    local aParamBox as array     //array para definir os parâmetros a ser apresentados no parambox
    private dDataIni  as date      //data inicial do processamento
    private dDataFim  as date      //data final do processamento
    private cAliasEEC as character //alias temporário


    cAliasEEC := getNextAlias()

    aRet := {}
    aParamBox := {}

    //-------------------------------------------------------------------------
    //Definção dos parâmetros do parambox
    //------------------------------------------------------------------------
    aAdd(aParamBox,{9,"Informe os parâmetros do relatório para DUE" ,150,7,.T.})
    aAdd(aParamBox,{1,"Data Inicial Proc.",Ctod(Space(8)),"","","","",50,.T.}) 
    aAdd(aParamBox,{1,"Data Final Proc.",Ctod(Space(8)),"","","","",50,.T.}) 


    If ParamBox(aParamBox,"Parâmetros",@aRet,,,,,,,.T.,.T.)
        dDataIni := aRet[2]
        dDataFim := aRet[3]

        
        oReport := ReportDef()
        oReport:PrintDialog()
        
        freeObj(oReport)
    endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definição da estrutura do relatório
@author  marcio.katsumata
@since   31/08/2019
@version 1.0
@return  object, objeto TReport.
/*/
//-------------------------------------------------------------------
static function ReportDef()

    Local oReport   as object
    Local oSection1 as object


    oReport:= TReport():New("ARDUEREL","Relatório para DUE",, {|oReport| ReportPrint(oReport)},"Relatório para Due")
    oReport:SetLandscape()

    oSection1 := TRSection():New(oReport,"Relatório para DUE")


    TRCell():New(oSection1,"EEC_FILIAL" ,cAliasEEC,"Filial"          ,PesqPict("EEC","EEC_FILIAL"),TamSX3("EEC_FILIAL")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"EEC_PREEMB" ,cAliasEEC,"Processo"        ,PesqPict("EEC","EEC_PREEMB"),TamSX3("EEC_PREEMB")[1],/*lPixel*/,/*{|| code-block de impressao }*/)    
    TRCell():New(oSection1,"EEC_DTPROC" ,cAliasEEC,"Dt.Processo"     ,PesqPict("EEC","EEC_DTPROC"),TamSX3("EEC_DTPROC")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"EEC_FIM_PE" ,cAliasEEC,"Dt.Encerramento" ,PesqPict("EEC","EEC_FIM_PE"),TamSX3("EEC_FIM_PE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"EEC_IMPODE" ,cAliasEEC,"Importador"      ,PesqPict("EEC","EEC_IMPODE"),TamSX3("EEC_IMPODE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"EEC_STTDES" ,cAliasEEC,"Status"          ,PesqPict("EEC","EEC_STTDES"),TamSX3("EEC_STTDES")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"EEC_FORNDE" ,cAliasEEC,"Fornecedor"      ,PesqPict("EEC","EEC_FORNDE"),TamSX3("EEC_FORNDE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"EEC_MOEDA"  ,cAliasEEC,"Moeda"           ,PesqPict("EEC","EEC_MOEDA") ,TamSX3("EEC_MOEDA")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"EEC_PESLIQ" ,cAliasEEC,"Peso Liquido"    ,PesqPict("EEC","EEC_PESLIQ"),TamSX3("EEC_PESLIQ")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"EEC_DTEMBA" ,cAliasEEC,"Data Embarque"   ,PesqPict("EEC","EEC_DTEMBA"),TamSX3("EEC_DTEMBA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"EEC_TOTFOB" ,cAliasEEC,"Total FOB"       ,PesqPict("EEC","EEC_TOTFOB"),TamSX3("EEC_TOTFOB")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"EEC_EMFRRC" ,cAliasEEC,"Tipo Despach"    ,PesqPict("EEC","EEC_EMFRRC"),TamSX3("EEC_EMFRRC")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"EEC_RECALF" ,cAliasEEC,"Recinto Alf."    ,PesqPict("EEC","EEC_RECALF"),TamSX3("EEC_RECALF")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"EEC_STTDUE" ,cAliasEEC,"Status DU-E"     ,PesqPict("EEC","EEC_STTDUE"),TamSX3("EEC_STTDUE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"EEC_NRODUE" ,cAliasEEC,"Nro. da DUE"     ,PesqPict("EEC","EEC_NRODUE"),TamSX3("EEC_NRODUE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"EEC_NRORUC" ,cAliasEEC,"Nro. RUC"        ,PesqPict("EEC","EEC_NRORUC"),TamSX3("EEC_NRORUC")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"EEC_DTDUE"  ,cAliasEEC,"Data DUE"        ,PesqPict("EEC","EEC_DTDUE") ,TamSX3("EEC_DTDUE")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"EEC_CHVDUE" ,cAliasEEC,"Chave DUE"       ,PesqPict("EEC","EEC_CHVDUE"),TamSX3("EEC_CHVDUE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"F2_CHVNFE"  ,cAliasEEC,"Chave NFe"       ,PesqPict("SF2","F2_CHVNFE") ,TamSX3("F2_CHVNFE")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)

return oReport


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Realiza a impressão do relatório
@author  marcio.katsumata
@since   31/08/2019
@version 1.0
@param   oReport, object, objeto TReport
@return  nil, nil
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)
 
    Local oSection1 as object
    local nRecTotal as numeric
    local nIndReg   as numeric

    oSection1 := oReport:Section(1) 
    nIndReg := 1

    
    
    BeginSql Alias cAliasEEC
        SELECT EEC.*, SF2.F2_CHVNFE
        FROM %table:EEC% EEC
        INNER JOIN %table:SF2% SF2 ON (SF2.F2_FILIAL  = EEC.EEC_FILIAL AND 
                                       SF2.F2_CLIENTE = EEC.EEC_IMPORT AND
                                       SF2.F2_LOJA    = EEC.EEC_IMLOJA AND
                                       SF2.F2_DOC     = EEC.EEC_PREEMB AND
                                       SF2.%notDel%)
        WHERE EEC.EEC_DTPROC BETWEEN %exp:dtos(dDataIni)% AND %exp:dtos(dDataFim)% AND
              EEC.%notDel%
    EndSql

  
    //-------------------------------------------
    //Inicio da impressao do fluxo do relatório 
    //-------------------------------------------
    oSection1:Init()

    //--------------------------------------------
    //Verificando o numero de registros e defindo 
    //o tamanho da barra de progresso
    //--------------------------------------------
    nRecTotal := contar(cAliasEEC, "!eof()")
    (cAliasEEC)->(dbGoTop())
    oReport:SetMeter(nRecTotal)

    While (cAliasEEC)->(!EOF())

        //-------------------------------
        //Incrementa barra de progresso
        //-------------------------------
        oReport:IncMeter()
        oReport:SetMsgPrint("Imprimindo registro "+alltrim(cValToChar(nIndReg))+" de "+alltrim(cValToChar(nRecTotal)))
        SysRefresh()
        ProcessMessage()

        //--------------------------------------------------
        //Verifica se o relatorio foi cancelado pelo usuário
        //--------------------------------------------------
        If oReport:Cancel()
               Exit
        EndIf
        
        //----------------------------
        //Realiza a impressão da linha
        //----------------------------
        oSection1:PrintLine()

        (cAliasEEC)->(DbSkip())
        nIndReg++
    enddo
        
    oSection1:Finish()

    (cAliasEEC)->(dbCloseArea())

return