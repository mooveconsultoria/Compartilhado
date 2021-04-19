#include 'protheus.ch'
#include 'parmtype.ch'

User Function SPDFIS07()

	Local cCodProduto := PARAMIXB[1] 	// Codigo do Produto
	Local nSituacao   := PARAMIXB[2] 	// Situação do Inventário
	Local cRetorno    := ""
/*
	0- Item de propriedade do informante e em seu poder
   	1- Item de propriedade do informante em posse de terceiros
   	2- Item de propriedade de terceiros em posse do informante

*/

If	nSituacao == "0"
	If		ALLTRIM(cCodProduto)	== "A08601N"
		cRetorno 	:= "1170100002"
	ElseIf 	ALLTRIM(cCodProduto)	== "A08601E"
		cRetorno 	:= "1170100005"
	ElseIf 	ALLTRIM(cCodProduto)	== "A08240N"
		cRetorno 	:= "1170100003"
	ElseIf	ALLTRIM(cCodProduto)	== "P5000"
		cRetorno 	:= "1170100004"
	Else
		cRetorno 	:= SB1->B1_CONTA
	EndIf

Elseif nSituacao == "1"
	If		ALLTRIM(cCodProduto)	== "A08601N"
		cRetorno 	:= "1170100002"
	ElseIf 	ALLTRIM(cCodProduto)	== "A08601E"
		cRetorno 	:= "1170100005"
	ElseIf 	ALLTRIM(cCodProduto)	== "A08240N"
		cRetorno 	:= "1170100003"
	ElseIf	ALLTRIM(cCodProduto)	== "P5000"
		cRetorno 	:= "1170100004"
	Else
		cRetorno 	:= SB1->B1_CONTA
	EndIf

Elseif nSituacao == "2"
	If		ALLTRIM(cCodProduto)	==  "A08601N"
		cRetorno 	:= "1170100002"
	ElseIf 	ALLTRIM(cCodProduto)	==  "A08601E"
		cRetorno 	:= "1170100005"
	ElseIf 	ALLTRIM(cCodProduto)	==  "A08240N"
		cRetorno 	:= "1170100003"
	ElseIf	ALLTRIM(cCodProduto)	==  "P5000"
		cRetorno 	:= "1170100004"
	Else
		cRetorno 	:= SB1->B1_CONTA
	EndIf

Endif

Return 	cRetorno