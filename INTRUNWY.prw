#include "protheus.ch"


//-------------------------------------------------------------------
/*/{Protheus.doc} INTRUNWY
Função para gerar em excel informações do cadastro de clientes
via menu como também via job. (Integração RUN WAY)
@author  ERPSERV
@since   24/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
user function INTRUNWY(aParJob)


    local cEmp          as character
    local cFil          as character
    local cDirectory    as character
    local lTypeCSV      as logical
    local aRet          as array
    local aParamBox     as array
    private lJob        as logical
    private cArquivo    as character
    

    default aParJob := {}

    //---------------------------
    //Inicialização de variáveis
    //---------------------------
    lJob        := .F.
    cEmp        := ""
    cFil        := ""
    cDirectory    := ""
    cArquivo    := 'runway'+dtos(date())+strtran(time(),":","")



    lJob := !empty(aParJob)

    if lJob
        
        cEmp := aParJob[1]
        cFil := aParJob[2]
        If Empty(cEmp) .Or. Empty(cFil)
            ConOut("INTEGRACAO RUNWAY - JOB não recebeu Empresa e/ou Filial")
        Else
            RpcSetType(3)
            RpcSetEnv(cEmp, cFil,,,"FAT")

            cDirectory := lower(superGetMv("MV_XDIRRWY", .F., "runway\"))
            lTypeCSV   := superGetMv("MV_XCSVRWY", .F., .F.)
            
            cDirectory := "data\"+cDirectory
            if !existDir (cDirectory)
                makeDir(cDirectory)
            endif
            cArquivo := cArquivo +iif(lTypeCSV, ".csv", ".xml")
            cArquivo := cDirectory+"\"+cArquivo

            ProcItens(lTypeCSV)

        endif
    else

        aRet := {}
        aParamBox := {}

        //-------------------------------------------------------------------------
        //Definção dos parâmetros do parambox
        //------------------------------------------------------------------------
        aAdd(aParamBox,{9,"Informe os parâmetros da integração runway" ,150,7,.T.})
        aAdd(aParamBox,{6,"Diretorio",Space(50),"","","",50,.F.,"",,GETF_LOCALHARD+GETF_RETDIRECTORY}) 
        aAdd(aParamBox,{2,"Gera Excel-CSV ou Excel-XML",1,{"","CSV","XML"},50,"",.T.})


        If ParamBox(aParamBox,"Parâmetros",@aRet,,,,,,,.T.,.T.)
            cDirectory := alltrim(aRet[2])
            lTypeCSV   := iif (aRet[3]=='CSV', .T., .F.)
                
            if empty(cDirectory)
                cDirectory := lower(superGetMv("MV_XDIRRWY", .F., "runway\"))
                cDirectory := "data\"+cDirectory
                if !existDir (cDirectory)
                    makeDir(cDirectory)
                endif
            endif

            cArquivo := cArquivo +iif(lTypeCSV, ".csv", ".xml")
            cArquivo := cDirectory+"\"+cArquivo
            Processa({||ProcItens(lTypeCSV)}, "Processando arquivo runway...", "Aguarde...", .F.)

            if file(cArquivo)
                //Abrindo o excel e abrindo o arquivo xml/csv
                oExcel := MsExcel():New()             //Abre uma nova conexÃƒÂ£o com Excel
                oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
                oExcel:SetVisible(.T.)                 //Visualiza a planilha
                oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
                freeObj(oExcel)

                msgInfo("Arquivo gerado com sucesso.")
            endif
        
        endif

        aSize(aRet,0)
        aSize(aParambox,0)
    endif
    
return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcItens
Query do cadastro de clientes com filtros e condição definido no escopo
@author  ERPSERV
@since   28/08/2018
@version 1.0
@param   lTypeCSV, logical, o arquivo a ser gerado é CSV ou XML? .T. = CSV, .F. = XML
@return  nil, nil   
/*/
//-------------------------------------------------------------------
Static Function ProcItens(lTypeCSV)

    local cAliasTmp  as character
    local oFWMsExcel as object
    local nQtdRegs   as numeric
    local nInd       as numeric
    local aItens     as array
    local aLine      as array
    local lContinua  as logical

    cAliasTmp := GetNextAlias()
    nInd      := 1
    lContinua := .T.

    if lTypeCsv
        aItens    := {}
        nHandle := FCreate(cArquivo,,,.F.)
        lContinua := nHandle != 1
    else
        //Criando o objeto que irá gerar o conteúdo do Excel
        oFWMsExcel := FWMSExcel():New()

        //Aba
        oFWMsExcel:AddworkSheet("runway work")

        //Definindo o estilo da tabela
        oFWMsExcel:SetBgGeneralColor("#ffffff") 
        oFWMsExcel:SetTitleFrColor("#000000")    
        oFWMsExcel:SetFrColorHeader("#000000")  

        //Criando as colunas da tabela
        oFWMsExcel:AddTable("runway work","runway")

        oFWMsExcel:AddColumn("runway work","runway","ProtheusCode"    ,1) 
        oFWMsExcel:AddColumn("runway work","runway","Customer name"    ,1) 
        oFWMsExcel:AddColumn("runway work","runway","Customer GRN"     ,1)
        oFWMsExcel:AddColumn("runway work","runway","Sales Area"       ,1)
        oFWMsExcel:AddColumn("runway work","runway","BILLINGSTREET"    ,1)
        oFWMsExcel:AddColumn("runway work","runway","BILLINGSTATE"     ,1)
        oFWMsExcel:AddColumn("runway work","runway","BILLINGPOSTALCODE",1)
        oFWMsExcel:AddColumn("runway work","runway","BILLINGCITY"      ,1)
        oFWMsExcel:AddColumn("runway work","runway","BILLINGCOUNTRY"   ,1)
        oFWMsExcel:AddColumn("runway work","runway","Payment currency" ,1)
        oFWMsExcel:AddColumn("runway work","runway","ModifiedAt"       ,1)
        oFWMsExcel:AddColumn("runway work","runway","Invoice Frequency",1)
        oFWMsExcel:AddColumn("runway work","runway","Credit days"      ,1) 

    endif

    beginSql alias cAliasTmp
        SELECT * FROM %table:SA1% SA1 
        WHERE SUBSTRING(A1_COD,1,1) = 'C' 
        AND A1_XMCOB = '1' 
        AND A1_XSEGM NOT IN ('FOR','PRM') 
        AND A1_MSBLQL <> '1' 
        AND SA1.D_E_L_E_T_ = ' '
    endSql

    nQtdRegs := contar(cAliasTmp, "!eof()")

    if !lJob
        ProcRegua(nQtdRegs)
    endif

    (cAliasTmp)->(dbGoTop())
    
    if lContinua
        while (cAliasTmp)->(!eof()) 
            if !lJob
                IncProc("Processando registro "+alltrim(cValToChar(nInd))+"/"+alltrim(cValToChar(nQtdRegs)))
                SysRefresh()
                ProcessMessage()
            endif

            if substr((cAliasTmp)->A1_COND,1,1)="D"
                cCond := "Daily"
            elseif substr((cAliasTmp)->A1_COND,1,1) ==" W"
                cCond := "Weekly"
            elseif substr((cAliasTmp)->A1_COND,1,1) =="F"
                cCond := "Fortnightly"
            elseif substr((cAliasTmp)->A1_COND,1,1) =="M"
                cCond := "Monthly"
            else
                cCond := "Ten"
            endif

            aLine := {;
            (cAliasTmp)->A1_COD + "_" + (cAliasTmp)->A1_LOJA,;
            alltrim((cAliasTmp)->A1_NOME),;
            alltrim((cAliasTmp)->A1_XGREF),;
            alltrim((cAliasTmp)->A1_XSEGM),;
            alltrim((cAliasTmp)->A1_END) + " " + alltrim((cAliasTmp)->A1_COMPLEMEN) + " " + alltrim((cAliasTmp)->A1_BAIRRO),;
            alltrim((cAliasTmp)->A1_EST),;
            alltrim((cAliasTmp)->A1_CEP),;
            alltrim((cAliasTmp)->A1_MUN),;
            alltrim((cAliasTmp)->A1_PAIS),;
            alltrim(SuperGetMv("MV_SIMB"+(cAliasTmp)->A1_XMCOB, .F.,"")),;
            alltrim((cAliasTmp)->A1_XDTHRBI),;
            cCond,;
            SUBSTR((cAliasTmp)->A1_COND,2,2) }
            
            if lTypeCSV
                FWrite(nHandle, ArrTokStr(aLine,";")+ CRLF)
            else
                oFWMsExcel:AddRow("runway work","runway", aClone(aLine)) 
            endif

            aSize(aLine,0)
            
            (cAliasTmp)->(dbSkip())
            nInd++
        enddo
    endif

    (cAliasTmp)->(dbCloseArea())

    if lTypeCsv 
        if lContinua
            FClose(nHandle)
        endif
    else
        //Ativando o arquivo e gerando o xml
        oFWMsExcel:Activate()
        oFWMsExcel:GetXMLFile(cArquivo)
        freeObj(oFWMsExcel)
    endif

    
return