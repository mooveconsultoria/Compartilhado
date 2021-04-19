#include 'protheus.ch'



//-------------------------------------------------------------------
/*/{Protheus.doc} F460E5
Tratamento do título na Liquidação 
Utilizado para retirar as informações de fatura pela rotina de 
liquidação.
@author  ERPSERV
@since   13/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
user function F460E5()



        Reclock("SE1", .F.)
        SE1->E1_TIPOFAT  := ""
        SE1->E1_DTFATUR := stod("")
        SE1->E1_FATPREF:= ""
        SE1->E1_FATURA := ""
        SE1->(msUnlock())
    


return