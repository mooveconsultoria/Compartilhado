#include 'protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} ediFtp01
Envio manual FTP - EDI Avianca
@author  ERPSERV
@since   12/11/2018
@version 1.0
@return  nil, nil
/*/
//-------------------------------------------------------------------
user function ediFtp01()

    local oPanel
    local oNewPag
    local cCombo1   := ""
    local oStepWiz  := nil
    local oDlg      := nil
    local oPanelBkg
    local lRet      := .F.
    local  cMsgErr := ""
    local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
    private cGrupo  := ""
    private cCliente:= ""
    private cLoja   := ""
    private aErros  := {}
    private cTipo   := ""
    private cServStart := "\DATA\FTPEDIAVIANCA\TXT\"
    private aServFiles :={ }

    aServFiles := MyDirec( cServStart + '*.*' )
    
    if len (aServFiles) > 0
        oStepWiz:= FWWizardControl():New()//Instancia a classe FWWizard
        oStepWiz:ActiveUISteps()

        //----------------------
        // Pagina 1
        //----------------------
        oNewPag := oStepWiz:AddStep("", {|Panel|cria_pg1(Panel)})
        //Altera a descrição do step
        oNewPag:SetStepDescription("Processamento FTP")
        //Define o bloco ao clicar no botão Próximo
        oNewPag:SetNextAction({||MsgRun("Enviando arquivos via FTP...","EDI AVIANCA", {||sendFtp(cServStart, "", @cMsgErr)}), lRet:=  .T. })
        //Define o bloco ao clicar no botão Cancelar
         oNewPag:SetCancelAction({|| .T.})
         oNewPag:SetCancelWhen({||.T.})

        oStepWiz:Activate()


        oStepWiz:Destroy()

        if !empty(cMsgErr)

            aviso("Erro",  cMsgErr, {"OK"}, 1)
        elseif lRet 
            aviso("Concluido",  "Envio concluido com sucesso!", {"OK"}, 1)
        endif
    else
        aviso("Aviso",  "Não existem arquivos a serem enviados", {"OK"}, 1)
    endif

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pg1
Construção da página 1 do wizard
@author  ERPSERV
@since   12/11/2018
@version 1.0
@param   oPanel, object, painel do wizard.
@return  nil, nil
/*/
//-------------------------------------------------------------------
Static Function cria_pg1(oPanel)
    local nPosArq := 1
    local nPosLbx := 1
    local cPesq   := Space( 30 )
    local lOk     := .F.
    local nI      := 0
    local   nList      := 0
    private CPAISLOC   := ''
    private cAcesso    := ''

    oSay1:= TSay():New(10,10,{||'Esta rotina realizará o envio dos arquivos pendentes para o FTP AVIANCA'},oPanel,,oFont,,,,.T.,,,180,300)

    TListBox():New(65,05,{|u|if(Pcount()>0,nList:=u,nList)},aServFiles,160,100,;
                                 {||},oPanel,,,,.T.)


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MyDirec
Lista os arquivos do diretório.
@author  ERPSERV
@since   12/11/2018
@version 1.0
@param   cPath, character, diretório para a listagem
@return  array, arquivos em formato string 
/*/
//-------------------------------------------------------------------
Static Function MyDirec( cPath )
    Local aDir     := Directory( cPath + '*.*' )
    Local aRet     := {}

    aEval( aDir, { |x| aAdd( aRet, x[1] ) } )

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} sendFtp
Envio FTP de arquivos EDI Avianca
@author  ERPSERV
@since   12/11/2018
@version 1.0
@param   cServStart, character, diretório EDI (Protheus)
@param   cArq      , character, arquivo a ser enviado
/*/
//-------------------------------------------------------------------
static function sendFtp(cServStart, cArq, cMsgErr)
    
    local cURL         := AllTrim(SuperGetMv("MV_XURL2"  ,.F.,""))      
    local nPort        := SuperGetMv("MV_XPORTA2",.F.,21)         
    local cUSR         := AllTrim(SuperGetMv("MV_XUSR2"  ,.F.,""))      
    local cPWD         := AllTrim(SuperGetMv("MV_XPWD2"  ,.F.,""))        
    local cSource      := cServStart 
    local cTarget      := AllTrim(SuperGetMv("MV_XPTH2"  ,.F.,""))   
    local nInd         := 0 
    local lConnect     := .T.
    local lOk          := .T.

    default cArq       := ""
    default cMsgErr    := ""


    //----------------------------
    //Checagem do array aServFiles
    //----------------------------
    if !(type('aServFiles') == 'A')
        aServFiles := {}
    endif

    //-----------------------------------------
    //CONECTA NO FTP
    //-----------------------------------------
    if !ftpconnect(cURL, nPort, cUSR, cPWD, .T.)
          cMsgErr := "NAO FOI POSSIVEL CONECTAR AO FTP."
          lConnect := .F. 
          lOk  := .F.
    else
       //------------------------------------------------------------
       // MUDA PARA O DIRETORIO DESEJADO NO SERVIDOR REMOTO
       //------------------------------------------------------------
       if !empty(cTarget)
            if !ftpdirchange(cTarget)
                 if !ftpdirchange(cTarget)
                     cMsgErr := "NAO FOI POSSIVEL MUDAR PARA O DIRETORIO INFORMADO."
                     lOk := .F.
                 endif
            endif
        endif

       //---------------------------------------------------------------------
       //UPLOAD DO(S) ARQUIVO(S)
       //---------------------------------------------------------------------
       if lOk
            //-------------------------------------
            //Upload de múltiplos arquivos
            //------------------------------------
            if empty(cArq) .and. len(aServFiles) > 0
                for nInd := 1 to len(aServFiles) 
                    if ! ftpupload(cSource+aServFiles[nInd], aServFiles[nInd])
                        cMsgErr := "NAO FOI POSSIVEL REALIZAR O UPLOAD."
                        lOk := .F.
                    else
                        FErase(cSource+aServFiles[nInd])
                    endif
                next nInd
            //-----------------------------------------------------
            //Upload de um único arquivo
            //----------------------------------------------------
            elseif !empty (cArq)
                if ! ftpupload(cSource+cArq, cArq)
                    cMsgErr := "NAO FOI POSSIVEL REALIZAR O UPLOAD."
                    lOk := .F.
                else    
                    FErase(cSource+cArq)
                endif

            endif
       endif

    endif

    //------------------
    //DESCONECTA FTP
    //------------------
    if lConnect 
        ftpdisconnect()  
    endif

return .T.