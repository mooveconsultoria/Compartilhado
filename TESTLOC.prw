#INCLUDE 'PROTHEUS.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} TESTLOC
O Ponto de Entrada TESTELOC deve ser utilizado para realizar uma validação no produto com controle de localização
Localizado na função de verificação de produtos com endereço

Link de referência: https://tdn.totvs.com/pages/releaseview.action?pageId=225264709

@author  DS2U (SDA)
@since   28/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
User Function TESTLOC()

Local lRet := PARAMIXB[1]

if ( fwIsInCallStack("VldLocaliz") )

	// Inicia variavel nPosLocaliz, pois estava dando erro na função VLDLOCALIZ do padrao 
	// type mismatch in array subscriptor - expected N->C on VLDLOCALIZ line : 4213

	_SetNamedPrvt( "nPosLocaliza" , aScan( aHeader, {|x| allTrim(x[2]) == "C6_LOCALIZ" } ) , "VldLocaliz" )
	_SetNamedPrvt( "nPosLocaliz" , nPosLocaliza , "VldLocaliz" )
	
endif

Return lRet