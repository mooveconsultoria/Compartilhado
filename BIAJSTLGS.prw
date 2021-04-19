#include 'protheus.ch'


user function BIAJSTLGS()
    local cAliasLG as character
    local aRet    as array
    local aParamBox as array
    local lOk   as logical
    local lOracle as logical

    lOracle := upper(alltrim(TCGetDB())) == "ORACLE"	
    lOk := .T.
    aRet := {}
    aParamBox := {}

    aAdd(aParamBox,{9,"Ajuste do conteudo USERLGI",70,7,.T.})
    aAdd(aParamBox,{1,"Tabela",Space(3),"","","","",0,.T.}) // Tipo caractere
    aAdd(aParamBox,{1,"Condicao",Space(200),"","","","",0,.T.}) // Tipo caractere

    If ParamBox(aParamBox,"Ajuste USERLGI",@aRet)
        cAliasLG := aRet[2]
        cString   := " 0#  0@  00† 004 "
        cCondicao := alltrim(aRet[3])
        aSX3Fields   := FWSX3Util():GetAllFields( cAliasLG , .F. ) 
        if len(aSX3Fields) > 0 
            cPrefix := substr(aSX3Fields[1], 1, at("_",aSX3Fields [1])-1)	
    
            if len(cPrefix) == 2
                cUserLGI := cPrefix+"_USERLGI"
            else
                cUserLGI := cPrefix+"_USERGI"
            endif 
        endif
        
        if lOracle
            cScript  := "UPDATE "+retSqlName(cAliasLG)+" SET "+cUserLGI+"='"+cString+"' WHERE TRIM("+cUserLGI+") IS NULL "
            if !empty(cCondicao)
                cScript += " AND "+cCondicao
            endif
        else
            cScript  := "UPDATE "+retSqlName(cAliasLG)+" SET "+cUserLGI+"='"+cString+"' WHERE RTRIM(LTRIM("+cUserLGI+")) ='' "
            if !empty(cCondicao)
                cScript += " AND "+cCondicao
            endif
        endif
  

        if tcSqlExec(cScript) < 0
            eecview("ERRO: "+tcSqlError())
        endif
    endif

return