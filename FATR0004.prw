#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "TbiConn.ch"
#Include "RwMake.ch"
#Include "MSOLE.CH"

#DEFINE CRLF Chr(13)+Chr(10)

/*/{Protheus.doc} FATR0004
//EDI COMAER Comando da Aeronautica
@author fernando.tadeu
@since 08/04/2016
/*/
User Function FATR0004()

Local cPerg := "BP_EDIPCOM"	
Local aHelp := {}

Private nI
Private nHandle
Private cTargetDir
Private cResName := "COMAER_" + dToS(dDataBase) + "_" + Replace(Time(),":", "") + ".txt"
Private cDirIni  := SuperGetMv("MV_XDIRCOM",,"C:\EDICOMAER")
Private cLinha   := ""	
Private nTotalNf := 0
Private nTotal   := 0
Private cDoc     := space(09)
Private cAlias   := GetNextAlias()
Private aDados   := {}
	
Aadd(aHelp,{{"Informe a data incial..."},{"Enter the base incial date..."},{""}})
Aadd(aHelp,{{"Informe a data final..." },{"Enter the base final date..." },{""}})
		
PutSx1(cPerg,"01","Data Inicial?","Fecha Inicial?","Initial Date?","mv_ch1","D",8,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",aHelp[1][1],aHelp[1][2],aHelp[1][3])
PutSx1(cPerg,"02","Data Final  ?","Fecha Final  ?","Final Date  ?","mv_ch2","D",8,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",aHelp[2][1],aHelp[2][2],aHelp[2][3])
	
If Pergunte(cPerg,.T.)
	
	DbSelectArea("SM0")
	SM0->(DbSetOrder(01))
	
	DbSelectArea("SY9")
	SY9->(DbSetOrder(02))
	
	Processa({ || ProcRegua( 0 ), fExecQry()},"Aguarde...","Buscando dados para gerar o EDI COMAER.")
	
	if Len(aDados) <= 0
		Alert("Não existem dados a serem gravados, verifique os parametros usados!")
		Return Nil
	endif
	
	Processa({ || ProcRegua( 0 ), fGeraArq()},"Aguarde...","Gerando arquivo EDI COMAER.")
	
EndIf		

Return

/*/{Protheus.doc} fGeraArq
@author fernando.vernier
@since 28/03/2016
/*/
Static Function fGeraArq()

Local aInfo := {}
Local aSize := MsAdvSize(.T.)
Local nI

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	
	MakeDir(cDirIni)                        
		
	cTargetDir := AllTrim( cGetFile("Edi COMAER|"+cResName, OemToAnsi("Salvar Arquivo Como..."),,cDirIni,,GETF_LOCALHARD+GETF_NETWORKDRIVE))
		
	nHandle := MsfCreate(cTargetDir,0)
	
	//Corrigi o aeroporto de abastecimento
	for nI = 1 to Len(aDados)
		SM0->(DbSeek('01'+AllTrim(aDados[nI][21])))
		aDados[nI][17] := Left(SM0->M0_FILIAL,3)
		if SY9->(DbSeek(xFilial("SY9")+aDados[nI][17]))
			aDados[nI][24] := Left(SM0->M0_FILIAL,3)
			aDados[nI][25] := SY9->Y9_XICAO
		endif			 
	next
	
	aSort( aDados,,, { |x,y| x[03]+x[17]+x[12]+x[22]+x[16] < y[03]+y[17]+y[12]+y[22]+y[16] } )
	
	for nI = 1 to Len(aDados)
		if U_NFDevolv(aDados[nI][21], aDados[nI][28], aDados[nI][29], aDados[nI][30])  // Verifica se a NF foi devolvida.
			loop
		endif
		nTotal++
		if cDoc <> aDados[nI][04]
			nTotalNf++
			cDoc := aDados[nI][04]
		endif
	next
	
	// 1-Controle de Lote
	cLinha := "1"
	cLinha += "BP"+space(04)
	cLinha += "BP"+Subs(DtoS(dDataBase),3,2)+SubStr(DtoS(dDataBase),5,2)+Left(RetSem(dDataBase),2)
	cLinha += DtoS(dDatabase)+space(36)
	cLinha += StrZero(nTotalNf,4)
	cLinha += StrZero(nTotal,5)
	Fwrite(nHandle,cLinha+CRLF)
	
	cDoc := space(09)
	for nI = 1 to Len(aDados)
		if U_NFDevolv(aDados[nI][21], aDados[nI][28], aDados[nI][29], aDados[nI][30])  // Verifica se a NF foi devolvida.
			loop
		endif
		if cDoc <> aDados[nI][04]
			cLinha := "2"
			cLinha += "BP"
			cLinha += aDados[nI][25]                                 // Localidade do abastecimento
			cLinha += Right(aDados[nI][04],8)                        // Número da nota fiscal
			cLinha += DtoS(aDados[nI][05])                           // Data da Emissão da NF
			cLinha += aDados[nI][27]                                 // Produto comaer
			cLinha += StrZero(aDados[nI][06],7)                      // Quantidade
			cLinha += StrZero(aDados[nI][08]*100,10)                 // Valor total
			cLinha += iif(!Empty(aDados[nI][16]),"T","G")+space(23)  // Modalidade do Fornecimento T=BOCA DE TANQUE / G=GRANEL
			cLinha += PadR(aDados[nI][14],300)                       // Observações
			Fwrite(nHandle,cLinha+CRLF)
			cDoc := aDados[nI][04]
		endif
		
		cLinha := "3"                                  // Tipo de Registro
		cLinha += "BP"                                 // Fornecedor
		cLinha += aDados[nI][25]                       // Localidade do Abastecimento
		cLinha += Right(aDados[nI][04],8)              // Numero da NF
		cLinha += aDados[nI][15]                       // Data da Emissão do CPA (yyyymmdd)
		cLinha += aDados[nI][27]                       // Produto
		cLinha += StrZero(aDados[nI][10],7)+space(11)  // Quantidade do produto fornecida no CPA
		cLinha += Left(aDados[nI][16],10)              // Numero do CPA
		cLinha += Left(aDados[nI][19],4)               // Matricula do Abastecível
		Fwrite(nHandle,cLinha+CRLF)
	next
	
   	fClose(nHandle)

	ApMsgInfo("Arquivo gerado com sucesso.","SUCESSO")
	
//	ShellExecute( "Open", cTargetDir , cTargetDir, cTargetDir,1) 			
	
Return Nil
		
/*/{Protheus.doc} fExecQry
//Query do EDI COMAER
@author fernando.tadeu
@since 08/04/2016
/*/  
Static Function fExecQry()

Local aInfo      := {}
Local aSize      := MsAdvSize(.T.)
Local cCnpjComae := AllTrim(SuperGetMv("MV_XCGCCOM",,""))
Local cExpCgc    := FormatIn(cCnpjComae,',')

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }

cQuery := "SELECT DISTINCT(R1.C5_XNUMCE) AS C5_XNUMCE, "
cQuery += "       SUM(SD2.D2_QUANT) AS D2_QUANT, "
cQuery += "       SUM(SD2.D2_TOTAL) AS D2_TOTAL, "
cQuery += "       SD2.D2_PRCVEN AS D2_PRCVEN, "
cQuery += "       R1.A1_NOME AS A1_NOME, "
cQuery += "       R1.A1_NREDUZ AS A1_NREDUZ, "
cQuery += "       R1.A1_CGC AS A1_CGC, "
cQuery += "       R1.F2_DOC AS F2_DOC, "
cQuery += "       R1.F2_EMISSAO AS F2_EMISSAO, "
cQuery += "       R1.F2_SERIE AS F2_SERIE, "
cQuery += "       R1.F2_CLIENTE AS F2_CLIENTE, "
cQuery += "       R1.F2_LOJA AS F2_LOJA, "
cQuery += "       R1.F2_FILIAL AS F2_FILIAL, "
cQuery += "       R1.C6_NOTA AS C6_NOTA, "
cQuery += "       R1.C6_QTDVEN AS C6_QTDVEN, "
cQuery += "       R1.C5_EMISSAO AS C5_EMISSAO, "
cQuery += "       R1.C5_NOTA AS C5_NOTA, "
cQuery += "       R1.C5_FILIAL AS C5_FILIAL, "
cQuery += "       R1.C5_MENNOTA AS C5_MENNOTA, "
cQuery += "       R1.C5_XDTEMIS AS C5_XDTEMIS, "
cQuery += "       R1.C5_XCODAER AS C5_XCODAER, "
cQuery += "       R1.C5_XPREFIX AS C5_XPREFIX, "
cQuery += "       R1.C5_XMATRIC AS C5_XMATRIC, "
cQuery += "       R1.C5_XNUMVOO AS C5_XNUMVOO, "
cQuery += "       R1.C6_FILIAL AS C6_FILIAL, "
cQuery += "       R1.C6_NUM AS C6_NUM, "
cQuery += "       R1.C6_PRODUTO AS C6_PRODUTO, "
cQuery += "       R1.C6_ITEM AS C6_ITEM, "
cQuery += "       R1.Y9_SIGLA AS Y9_SIGLA, "
cQuery += "       R1.Y9_XICAO AS Y9_XICAO, "
cQuery += "       R1.E1_VENCREA AS E1_VENCREA, "
cQuery += "       R1.B1_XCODFAB AS B1_XCODFAB, "
cQuery += "       SD2.D2_DOC AS D2_DOC, "
cQuery += "       SD2.D2_SERIE AS D2_SERIE "
cQuery += "FROM ( "
cQuery += "SELECT SA1.A1_NOME AS A1_NOME, "
cQuery += "       SA1.A1_NREDUZ AS A1_NREDUZ, "
cQuery += "       SA1.A1_CGC AS A1_CGC, "
cQuery += "       SF2.F2_DOC AS F2_DOC, "
cQuery += "       SF2.F2_EMISSAO AS F2_EMISSAO, "
cQuery += "       SF2.F2_SERIE AS F2_SERIE, "
cQuery += "       SF2.F2_CLIENTE AS F2_CLIENTE, "
cQuery += "       SF2.F2_LOJA AS F2_LOJA, "
cQuery += "       SF2.F2_FILIAL AS F2_FILIAL, "
cQuery += "       SC6.C6_NOTA AS C6_NOTA, "
cQuery += "       SC6.C6_QTDVEN AS C6_QTDVEN, "
cQuery += "       SC5.C5_EMISSAO AS C5_EMISSAO, "
cQuery += "       SC5.C5_NOTA AS C5_NOTA, "
cQuery += "       SC5.C5_FILIAL AS C5_FILIAL, "
cQuery += "       SC5.C5_MENNOTA AS C5_MENNOTA, "
cQuery += "       SC5.C5_XDTEMIS AS C5_XDTEMIS, "
cQuery += "       SC5.C5_XNUMCE AS C5_XNUMCE, "
cQuery += "       SC5.C5_XCODAER AS C5_XCODAER, "
cQuery += "       SC5.C5_XPREFIX AS C5_XPREFIX, "
cQuery += "       SC5.C5_XMATRIC AS C5_XMATRIC, "
cQuery += "       SC5.C5_XNUMVOO AS C5_XNUMVOO, "
cQuery += "       SC6.C6_FILIAL AS C6_FILIAL, "
cQuery += "       SC6.C6_NUM AS C6_NUM, "
cQuery += "       SC6.C6_PRODUTO AS C6_PRODUTO, "
cQuery += "       SC6.C6_ITEM AS C6_ITEM, "
cQuery += "       SY9.Y9_SIGLA AS Y9_SIGLA, "
cQuery += "       SY9.Y9_XICAO AS Y9_XICAO, "
cQuery += "       SE1.E1_VENCREA AS E1_VENCREA, "
cQuery += "       SB1.B1_XCODFAB AS B1_XCODFAB "
cQuery += "FROM " + RetSqlName("SA1") + " SA1, " + RetSqlName("SC5") + " SC5, " + RetSqlName("SC6") + " SC6, " + RetSqlName("SF2") + " SF2, " + RetSqlName("SY9") + " SY9, " + RetSqlName("SE1") + " SE1, "+ RetSqlName("SB1") + " SB1 "
cQuery += "WHERE SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
cQuery += "  AND SA1.A1_CGC IN "+cExpCgc+" " 
cQuery += "  AND SA1.D_E_L_E_T_ <> '*' "
cQuery += "  AND SC5.C5_CLIENTE = SA1.A1_COD "
cQuery += "  AND SC5.C5_LOJACLI = SA1.A1_LOJA "
cQuery += "  AND SC5.D_E_L_E_T_ <> '*' "
cQuery += "  AND SC5.C5_XDTEMIS BETWEEN '"+ DTOS(mv_par01)	+"' AND '"+ DTOS(mv_par02) +"' "   
cQuery += "  AND SC6.C6_FILIAL = SC5.C5_FILIAL "
cQuery += "  AND SC6.C6_NUM = SC5.C5_NUM "
cQuery += "  AND SC6.D_E_L_E_T_ <> '*' "
cQuery += "  AND SF2.F2_DOC = SC6.C6_NOTA "
cQuery += "  AND SF2.D_E_L_E_T_<>'*' "
cQuery += "  AND SF2.F2_FILIAL = SC6.C6_FILIAL "
cQuery += "  AND SY9.Y9_SIGLA = SC5.C5_XCODAER "
cQuery += "  AND SY9.D_E_L_E_T_ <> '*' "
cQuery += "  AND SY9.Y9_FILIAL = '" + xFilial("SY9") + "' "
cQuery += "  AND SE1.E1_FILORIG = SC6.C6_FILIAL "
cQuery += "  AND SE1.E1_NUM = SC6.C6_NOTA "
cQuery += "  AND RTRIM(SUBSTR(SE1.E1_PREFIXO,1,2)) = RTRIM(SUBSTR(SC6.C6_FILIAL,5,2)) "
cQuery += "  AND SE1.E1_CLIENTE = SC6.C6_CLI "
cQuery += "  AND SE1.E1_LOJA = SC6.C6_LOJA "
cQuery += "  AND SE1.D_E_L_E_T_<>'*' "
cQuery += "  AND SB1.D_E_L_E_T_<>'*' "
cQuery += "  AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += "  AND SB1.B1_COD = SC6.C6_PRODUTO "
cQuery += ") R1, " + RetSqlName("SD2") + " SD2 "
cQuery += "WHERE SD2.D_E_L_E_T_ <> '*' "
cQuery += "  AND SD2.D2_DOC = R1.F2_DOC "
cQuery += "  AND SD2.D2_SERIE = R1.F2_SERIE "
cQuery += "  AND SD2.D2_CLIENTE = R1.F2_CLIENTE "
cQuery += "  AND SD2.D2_LOJA = R1.F2_LOJA "
cQuery += "  AND SD2.D2_PEDIDO = R1.C6_NUM "
cQuery += "  AND SD2.D2_ITEMPV = R1.C6_ITEM "
cQuery += "  AND SD2.D2_FILIAL = R1.F2_FILIAL "
cQuery += "GROUP BY R1.C5_XNUMCE, SD2.D2_PRCVEN, R1.A1_NOME, R1.A1_NREDUZ, R1.A1_CGC, R1.F2_DOC, R1.F2_EMISSAO, R1.F2_SERIE, R1.F2_CLIENTE, R1.F2_LOJA, R1.F2_FILIAL, R1.C6_NOTA, R1.C6_QTDVEN, R1.C5_EMISSAO, R1.C5_NOTA, R1.C5_FILIAL, R1.C5_MENNOTA, R1.C5_XDTEMIS, R1.C5_XCODAER, R1.C5_XPREFIX, R1.C5_XMATRIC, R1.C5_XNUMVOO, R1.C6_FILIAL, R1.C6_NUM, R1.C6_PRODUTO, R1.C6_ITEM, R1.Y9_SIGLA, R1.Y9_XICAO, R1.E1_VENCREA, R1.B1_XCODFAB, SD2.D2_DOC, SD2.D2_SERIE "
cQuery += "ORDER BY A1_CGC, C5_XCODAER, C6_NOTA, C6_NUM, C5_XNUMCE"
cQuery := ChangeQuery(cQuery) 
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)
TcSetField(cAlias, "F2_EMISSAO"	,"D")    
TcSetField(cAlias, "C5_EMISSAO"	,"D")    
TcSetField(cAlias, "E1_VENCREA"	,"D")    
TcSetField(cAlias, "D2_QUANT"	,"N",TamSx3("D2_QUANT"	)[1],TamSx3("D2_QUANT"	)[2])    
TcSetField(cAlias, "D2_PRCVEN"	,"N",TamSx3("D2_PRCVEN"	)[1],TamSx3("D2_PRCVEN"	)[2])   
TcSetField(cAlias, "D2_TOTAL"	,"N",TamSx3("D2_TOTAL"	)[1],TamSx3("D2_TOTAL"	)[2])   
(cAlias)->(DbGoTop())
while (cAlias)->(!Eof())
	aadd(aDados,{(cAlias)->A1_NOME, (cAlias)->A1_NREDUZ, (cAlias)->A1_CGC, (cAlias)->F2_DOC, (cAlias)->F2_EMISSAO, (cAlias)->D2_QUANT, (cAlias)->D2_PRCVEN,;
	             (cAlias)->D2_TOTAL, (cAlias)->C6_NOTA, (cAlias)->C6_QTDVEN, (cAlias)->C5_EMISSAO, (cAlias)->C5_NOTA, (cAlias)->C5_FILIAL,;
	             (cAlias)->C5_MENNOTA, (cAlias)->C5_XDTEMIS, (cAlias)->C5_XNUMCE, (cAlias)->C5_XCODAER, (cAlias)->C5_XPREFIX, (cAlias)->C5_XMATRIC,;
	             (cAlias)->C5_XNUMVOO, (cAlias)->C6_FILIAL, (cAlias)->C6_NUM, (cAlias)->C6_PRODUTO, (cAlias)->Y9_SIGLA, (cAlias)->Y9_XICAO,;
	             (cAlias)->E1_VENCREA, (cAlias)->B1_XCODFAB, (cAlias)->D2_DOC, (cAlias)->D2_SERIE, (cAlias)->C6_ITEM})
	(cAlias)->(DbSkip())
enddo
(cAlias)->( dbCloseArea() )
If Select(cAlias) == 0
	Ferase(cAlias+GetDBExtension())
Endif

Return Nil