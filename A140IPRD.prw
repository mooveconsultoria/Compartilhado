/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A140IPRD  ºAutor  ³ Alex Rodrigues     º Data ³  15/07/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada na rotina MATA140I.PRW para definir o     º±±
±±º          ³ código de produto antes de olhar em produtosXfornecedir    º±±
±±º          ³ no schedule do Totvs Colaboração                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Air BP                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function A140IPRD() 

Local cFornec := PARAMIXB[1]
Local cLoja := PARAMIXB[2]
Local cPRD := PARAMIXB[3]
Local oDetItem := PARAMIXB[4] 
Local cNewPRD := ""         
Local lTemImp := .F.

Conout("A140IPRD -> Fornecedor/Produto: "+cFornec+"/"+cPrd)

If ALLTRIM(cFornec) == "000001"  //PETROBRÁS - TODAS AS LOJAS

	//Tag IPI->cEnq = 002 - Internacional
	//Tag IPI->cEnq = 004 - Nacional
	If Alltrim(oDetItem:_imposto:_IPI:_cEnq:Text) == "004"
		lTemImp := .T.
		Conout("A140IPRD -> tem imposto")	
	EndIf

	If Alltrim(cPrd) == "PB641" 
		If lTemImp //QUEROSENE DE AVIAÇÃO - CODIGO PETROBRÁS
			cNewPRD := SuperGETMV("XCEJENA",.F.,"A08601N") //JET NACIONAL
			Conout("A140IPRD -> Produto: Nacional -> "+cNewPRD)			
		Else                                                             
			cNewPRD := SuperGETMV("XCEJEEX",.F.,"A08601E") //JET EXPORTAÇÃO
			Conout("A140IPRD -> Produto: Exportação -> "+cNewPRD)						
		Endif
	Endif
Endif

//se o retorno for em branco, ele irá buscar no cadastro de produto x fornecedor
Return cNewPRD