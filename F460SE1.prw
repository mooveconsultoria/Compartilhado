#include 'protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} F460SE1
Informa dados complementares do título
O ponto de entrada F460SE1 sera utilizado para informar dados 
necessarios à gravacao complementar, dos titulos gerados apos a liquidacao.
@author  ERPSERV    
@since   08/03/2019
@version 1.0
@param   PARAMIXB[1], array, Complemento
@return  nil, nil
/*/
//-------------------------------------------------------------------
user function F460SE1( )
    local aOrigSE1 := {}

    if ValType(PARAMIXB) == 'A' .and. !empty(PARAMIXB)
        aOrigSE1 := PARAMIXB
    endif
    
    aadd( aOrigSE1, SE1->(recno()) )


return aOrigSE1