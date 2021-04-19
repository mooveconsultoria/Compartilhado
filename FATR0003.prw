#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICODE.CH"

STATIC POS_DTN := 1
STATIC POS_APC := 2
STATIC POS_FGN := 3
STATIC POS_ACT := 4
STATIC POS_QTD := 6
STATIC POS_QGL := 7
STATIC POS_APF := 15
STATIC POS_IVN := 16
STATIC POS_VLT := 17	
STATIC POS_FCN := 18

/*
Programa.: FATR0003
Autor....: Danilo José Grodzicki
Data.....: 23/07/2016 
Descricao: Gera EDI Genérico - Excel.
Uso......: AIR BP BRASIL LTDA
*/
User Function FATR0003()

	Local cCaminho   := "C:\EDIGenerico"
	Local cResName
	Local cTargetDir

	Private cPerg    := "EDIGENERIC"

	AjustaSX1(cPerg)

	If !Pergunte(cPerg,.T.)
		Return Nil
	endif
	
	MakeDir(cCaminho)

	cResName   := "EDI Generico" + MV_PAR01 + ".XLS"
	cTargetDir := AllTrim( cGetFile("Edi Generico|"+cResName, OemToAnsi("Salvar Arquivo Como..."),,cCaminho,,GETF_LOCALHARD+GETF_NETWORKDRIVE))
	    
	If File(ALLTRIM(cTargetDir))
	    fErase(ALLTRIM(cTargetDir))
	Endif
	
	fwMsgRun(,{|oSay| execRel( cTargetDir ) },"Aguarde...","Processando relatório..." )

Return

Static Function execRel( cTargetDir )

Local nI
Local cDelivery

Local oExcel     := FWMSEXCEL():New()
Local nTotVolLtr := 0.00
Local nTotVolGls := 0.00
Local nTotFueCos := 0.00
Local nTotAirFee := 0.00
Local nTotTotAmo := 0.00

Private aDados   := {}
Private aDadoTab := {}
Private aFatura  := {}

//if U_ValQtde()
//	MsgStop("Não é possível gerar o EDI Genérico porque, foram encontradas mais de uma fatura para os parâmetros informados.","ATENÇÃO" )
//	Return Nil
//endif

DbSelectArea("SA1")
SA1->(DbSetOrder(01))

DbSelectArea("SM0")
SM0->(DbSetOrder(01))

U_BuscaDad()

if Len(aDados) <= 0
	MsgInfo("Não foram encontrados dados para os parâmetros informados.","ATENÇÃO" )
	Return Nil
endif

aFatura := U_DadoFatura(aDados[01][16])  // Buscar dados da fatura

if Len(aFatura) <= 0
	MsgInfo("Não foram encontrados dados para os parâmetros informados.","ATENÇÃO" )
	Return Nil
endif

SA1->(DbSeek(xFilial("SA1")+MV_PAR01+MV_PAR02))

oExcel:AddworkSheet("Genérico")
oExcel:AddTable ("Genérico","Relatório Genérico",)
oExcel:AddColumn("Genérico","Relatório Genérico","Delivery ticket number",1,1)
oExcel:AddColumn("Genérico","Relatório Genérico","Airport code",1,1)
oExcel:AddColumn("Genérico","Relatório Genérico","Fiscal number",1,1)
oExcel:AddColumn("Genérico","Relatório Genérico","Invoice number",1,1)	
oExcel:AddColumn("Genérico","Relatório Genérico","Flight number",1,1)
oExcel:AddColumn("Genérico","Relatório Genérico","Aircraft",1,1)
oExcel:AddColumn("Genérico","Relatório Genérico","Volume (lts)",1,1)
oExcel:AddColumn("Genérico","Relatório Genérico","Volume (gls)",1,1)
oExcel:AddColumn("Genérico","Relatório Genérico","Fuelling  (delivery) date",1,4)
oExcel:AddColumn("Genérico","Relatório Genérico","Unit price (uscg)",3,1)
oExcel:AddColumn("Genérico","Relatório Genérico","Fuel Cost",3,1)
oExcel:AddColumn("Genérico","Relatório Genérico","Airport Fees",3,1)
oExcel:AddColumn("Genérico","Relatório Genérico","Total Amount (USD)",3,1)

for nI = 1 to Len(aDados)
	
	cDelivery := Subs(DtoS(aDados[nI][08]),5,2)+"/"+Right(DtoS(aDados[nI][08]),2)+"/"+Left(DtoS(aDados[nI][08]),4)
	
	oExcel:AddRow("Genérico","Relatório Genérico",{aDados[nI][POS_DTN],;
	                                               aDados[nI][POS_APC],; 
	                                               aDados[nI][POS_FCN],;
	                                               aDados[nI][POS_IVN],;
	                                               aDados[nI][POS_FGN],;
	                                               aDados[nI][POS_ACT],;
	                                               Round(aDados[nI][POS_QTD],0),;
	                                               Round(aDados[nI][POS_QGL],0),;
	                                               cDelivery,;
	                                               Round((Round(aDados[nI][POS_VLT],2)-(Round(aDados[nI][POS_QGL]*aDados[nI][POS_APF],2)))/ Round(aDados[nI][POS_QTD],6),5),;
	                                               Round(Round(aDados[nI][POS_VLT],2)-(Round(aDados[nI][POS_QGL]*aDados[nI][POS_APF],2)),2),;
	                                               Round(Round(aDados[nI][POS_QGL]*aDados[nI][POS_APF],2),2),;
	                                               Round(aDados[nI][POS_VLT],2)})
	nTotVolLtr += Round(aDados[nI][POS_QTD],0)
	nTotVolGls += Round(aDados[nI][POS_QGL],0)
	nTotFueCos += Round(Round(aDados[nI][POS_VLT],2)-(Round(aDados[nI][POS_QGL]*aDados[nI][POS_APF],2)),2)
	nTotAirFee += Round(Round(aDados[nI][POS_QGL]*aDados[nI][POS_APF],2),2)
	nTotTotAmo += Round(aDados[nI][POS_VLT],2)
next

oExcel:AddRow("Genérico","Relatório Genérico",{'',;
                                               '',; 
                                               '',;
                                               '',;
                                               '',;
                                               '',;
                                               Round(nTotVolLtr,0),;
                                               Round(nTotVolGls,0),;
                                               '',;
                                               '',;
                                               Round(nTotFueCos,2),;
                                               Round(nTotAirFee,5),;
                                               Round(nTotTotAmo,2)})

oExcel:Activate()
oExcel:GetXMLFile(cTargetDir)

oExcelApp:= MsExcel():New()
oExcelApp:WorkBooks:Open( AllTrim( cTargetDir ) )
oExcelApp:SetVisible(.T.)
    
Return Nil

/*
Programa.: AjustaSX1
Autor....: Danilo José Grodzicki
Data.....: 23/07/2016 
Descricao: Ajusta arquivo SX1.
Uso......: AIR BP BRASIL LTDA
*/
Static Function AjustaSX1(cPerg)

Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpEsp := {}

Aadd(aHelpPor,{"Informe o código do cliente."   }) // 01
Aadd(aHelpPor,{"Informe a loja do cliente."     }) // 02
Aadd(aHelpPor,{"Informe a data inicial."        }) // 03
Aadd(aHelpPor,{"Informe a data final."          }) // 04

Aadd(aHelpEng,{"Enter the client code."         }) // 01
Aadd(aHelpEng,{"Enter the customer's shop."     }) // 02
Aadd(aHelpEng,{"Enter the start date."          }) // 03
Aadd(aHelpEng,{"Enter the end date."            }) // 04

Aadd(aHelpEsp,{"Introduce el código de cliente."}) // 01
Aadd(aHelpEsp,{"Dile a la tienda de cliente."   }) // 02
Aadd(aHelpEsp,{"Introduzca la fecha de inicio." }) // 03
Aadd(aHelpEsp,{"Introduzca la fecha de ",;
               "finalización."                  }) // 04

//     cGrupo,cOrdem,cPergunt        ,cPergSpa         ,cPergEng         ,cVar    ,cTipo,nTamanho,nDecimal,nPreSel,cGSC,cValid,cF3  ,cGrpSXG,cPyme,cVar01    ,cDef01  ,cDefSpa1 ,cDefEng1 ,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor    ,aHelpEng    ,aHelpSpa    )
PutSx1(cPerg ,"01"  ,"Cliente?"      ,"¿Cliente?"      ,"Customer?"      ,"MV_CH1","C"  ,06      ,0       ,0      ,"G" ,""    ,"SA1","001"  ,""   ,"MV_PAR01",""      ,""       ,""       ,""    ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,aHelpPor[01],aHelpEng[01],aHelpEsp[01])
PutSx1(cPerg ,"02"  ,"Loja?"         ,"¿Tienda?"       ,"Store?"         ,"MV_CH2","C"  ,02      ,0       ,0      ,"G" ,""    ,""   ,""     ,""   ,"MV_PAR02",""      ,""       ,""       ,""    ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,aHelpPor[02],aHelpEng[02],aHelpEsp[02])
PutSx1(cPerg ,"03"  ,"Data De?"      ,"¿De Fecha?"     ,"From Date?"     ,"MV_CH3","D"  ,08      ,0       ,0      ,"G" ,""    ,""   ,""     ,""   ,"MV_PAR03",""      ,""       ,""       ,""    ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,aHelpPor[03],aHelpEng[03],aHelpEsp[03])
PutSx1(cPerg ,"04"  ,"Data Ate?"     ,"¿A Fecha?"      ,"To Date?"       ,"MV_CH4","D"  ,08      ,0       ,0      ,"G" ,""    ,""   ,""     ,""   ,"MV_PAR04",""      ,""       ,""       ,""    ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,aHelpPor[04],aHelpEng[04],aHelpEsp[04])

Return Nil

/*
Programa.: ValQtde
Autor....: Danilo José Grodzicki
Data.....: 26/07/2016 
Descricao: Verifica se existe mais de uma fatura para os parâmetros informados.
Uso......: AIR BP BRASIL LTDA
*/
/*
User Function ValQtde()

Local lRet      := .F.
Local cQuery    := ""
Local cAliasTm1 := GetNextAlias()

cQuery := "SELECT COUNT(DISTINCT(SE1.E1_FATURA)) AS QTDE "
cQuery += "FROM "+RetSqlName("SE1")+" SE1, "+RetSqlName("SD2")+" SD2, "+RetSqlName("SC6")+" SC6, "+RetSqlName("SC5")+" SC5 "
cQuery += "WHERE SE1.D_E_L_E_T_ <> '*' "
cQuery += "  AND SE1.E1_CLIENTE = '"+MV_PAR01+"' "
cQuery += "  AND SE1.E1_LOJA = '"+MV_PAR02+"' "
cQuery += "  AND RTRIM(SE1.E1_FATURA) IS NOT NULL "
cQuery += "  AND SE1.E1_DTFATUR BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"' "
cQuery += "  AND SD2.D_E_L_E_T_ <> '*' "
cQuery += "  AND SD2.D2_FILIAL = SE1.E1_FILORIG "
cQuery += "  AND SD2.D2_DOC = SE1.E1_NUM "
cQuery += "  AND SD2.D2_SERIE = SE1.E1_XPREORI "
cQuery += "  AND SD2.D2_CLIENTE = SE1.E1_CLIENTE "
cQuery += "  AND SD2.D2_LOJA = SE1.E1_LOJA "
cQuery += "  AND SC6.D_E_L_E_T_ <> '*' "
cQuery += "  AND SC6.C6_FILIAL = SD2.D2_FILIAL "
cQuery += "  AND SC6.C6_NUM = SD2.D2_PEDIDO "
cQuery += "  AND SC5.D_E_L_E_T_ <> '*' "
cQuery += "  AND SC5.C5_FILIAL = SC6.C6_FILIAL "
cQuery += "  AND SC5.C5_NUM = SC6.C6_NUM "
cQuery += "  AND RTRIM(SC5.C5_XNUMCE) IS NOT NULL"
cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTm1,.F.,.T.)
(cAliasTm1)->(DbGoTop())
if (cAliasTm1)->(!Eof())
	if (cAliasTm1)->QTDE > 1
		lRet := .T.
	endif
endif
(cAliasTm1)->( dbCloseArea() )
If Select(cAliasTm1) == 0
	Ferase(cAliasTm1+GetDBExtension())
Endif

Return(lRet)
*/

/*
Programa.: BuscaDad
Autor....: Danilo José Grodzicki
Data.....: 26/07/2016 
Descricao: Verifica se existe mais de uma fatura para os parâmetros informados.
Uso......: AIR BP BRASIL LTDA
*/
User Function BuscaDad()

Local cQuery    := ""
Local cAliasTmp := GetNextAlias()
Local nI

cQuery := "SELECT DISTINCT(R1.ZB0_NUMCE) AS ZB0_NUMCE, "
cQuery += "       SUM(SD2.D2_QUANT) AS D2_QUANT, "
cQuery += "       SUM(SD2.D2_TOTAL) AS D2_TOTAL, "
cQuery += "       SD2.D2_PRCVEN AS D2_PRCVEN, "
cQuery += "       R1.ZB0_CODAER AS ZB0_CODAER, "
cQuery += "       R1.ZB0_NUMVOO AS ZB0_NUMVOO, "
cQuery += "       R1.ZB0_PREFIX AS ZB0_PREFIX, "
cQuery += "       R1.C6_NOTA AS C6_NOTA, "
cQuery += "       R1.C6_NUM AS C6_NUM, "
cQuery += "       0 AS QTDEGAL, "
cQuery += "       R1.ZB0_DTEMIS AS ZB0_DTEMIS, "
cQuery += "       R1.E1_EMISSAO AS E1_EMISSAO, "
cQuery += "       R1.C6_FILIAL AS C6_FILIAL, "
cQuery += "       0 AS USCG, "
cQuery += "       0 AS TOTALUSD, "
cQuery += "       0 AS AIRPORFEES, "
cQuery += "       R1.FATURA AS FATURA, "
cQuery += "       R1.C6_VALOR AS C6VALOR, "
cQuery += "       SD2.D2_DOC AS D2_DOC, "
cQuery += "       SD2.D2_SERIE AS D2_SERIE, "
cQuery += "       R1.C6_ITEM AS C6_ITEM "
cQuery += "FROM ( "
cQuery += "SELECT ZB0.ZB0_NUMCE AS ZB0_NUMCE, "
cQuery += "       ZB0.ZB0_CODAER AS ZB0_CODAER, "
cQuery += "       ZB0.ZB0_NUMVOO AS ZB0_NUMVOO, "
cQuery += "       ZB0.ZB0_PREFIX AS ZB0_PREFIX, "
cQuery += "       SC6.C6_NOTA AS C6_NOTA, "
cQuery += "       ZB0.ZB0_DTEMIS AS ZB0_DTEMIS, "
cQuery += "       SE1.E1_EMISSAO AS E1_EMISSAO, "
cQuery += "       SC6.C6_FILIAL AS C6_FILIAL, "
cQuery += "       SC6.C6_NUM AS C6_NUM, "
cQuery += "       SE1.E1_FATURA AS FATURA, "
cQuery += "       SC6.C6_VALOR AS C6_VALOR, "
cQuery += "       SC6.C6_ITEM AS C6_ITEM "
cQuery += "FROM "+RetSqlName("ZB0")+" ZB0, "+RetSqlName("SC5")+" SC5, "+RetSqlName("SC6")+" SC6, "+RetSqlName("SE1")+" SE1 "
cQuery += "WHERE ZB0.D_E_L_E_T_ <> '*' "
cQuery += "  AND ZB0.ZB0_CODCLI = '"+MV_PAR01+"' "
cQuery += "  AND ZB0.ZB0_LOJCLI = '"+MV_PAR02+"' "
cQuery += "  AND ZB0.ZB0_DTEMIS BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"' "
cQuery += "  AND SC5.D_E_L_E_T_ <> '*' "
cQuery += "  AND SC5.C5_FILIAL = ZB0.ZB0_FILIAL "
cQuery += "  AND SC5.C5_XNUMCE = ZB0.ZB0_NUMCE "
cQuery += "  AND SC5.C5_CLIENTE = ZB0.ZB0_CODCLI "
cQuery += "  AND SC5.C5_LOJACLI = ZB0.ZB0_LOJCLI "
cQuery += "  AND SC5.C5_XDTEMIS = ZB0.ZB0_DTEMIS "
cQuery += "  AND SC5.C5_XHORINI = ZB0.ZB0_HORINI "
cQuery += "  AND SC6.D_E_L_E_T_ <> '*' "
cQuery += "  AND SC6.C6_FILIAL = SC5.C5_FILIAL "
cQuery += "  AND SC6.C6_NUM = SC5.C5_NUM "
cQuery += "  AND SE1.D_E_L_E_T_ <> '*' "
cQuery += "  AND SE1.E1_FILIAL = '" + xFilial("ZE1") + "' "
cQuery += "  AND SE1.E1_FILORIG = SC5.C5_FILIAL "
cQuery += "  AND SE1.E1_NUM = SC6.C6_NOTA "
cQuery += "  AND RTRIM(SUBSTR(SE1.E1_PREFIXO,1,2)) = RTRIM(SUBSTR(SC5.C5_FILIAL,5,2)) "
cQuery += "  AND SE1.E1_CLIENTE = SC5.C5_CLIENTE "
cQuery += "  AND SE1.E1_LOJA = SC5.C5_LOJACLI "
cQuery += ") R1, " + RetSqlName("SD2") + " SD2 "
cQuery += "WHERE SD2.D_E_L_E_T_ <> '*' "
cQuery += "  AND SD2.D2_FILIAL = R1.C6_FILIAL "   
cQuery += "  AND SD2.D2_PEDIDO = R1.C6_NUM "
cQuery += "GROUP BY R1.ZB0_NUMCE, SD2.D2_PRCVEN, R1.ZB0_CODAER, R1.ZB0_NUMVOO, R1.ZB0_PREFIX, R1.C6_NOTA, R1.C6_NUM, R1.ZB0_DTEMIS, R1.E1_EMISSAO, R1.C6_FILIAL, R1.FATURA, R1.C6_VALOR, SD2.D2_DOC, SD2.D2_SERIE, R1.C6_ITEM "
cQuery += "ORDER BY ZB0_DTEMIS, ZB0_NUMCE"

cQuery := ChangeQuery( cQuery )
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTmp,.F.,.T.)

TcSetField(cAliasTmp,"D2_QUANT"	,"N",TamSx3("D2_QUANT")[1],TamSx3("D2_QUANT"	)[2])
TcSetField(cAliasTmp,"ZB0_DTEMIS","D",TamSx3("ZB0_DTEMIS")[1],TamSx3("ZB0_DTEMIS"	)[2])
TcSetField(cAliasTmp,"E1_EMISSAO","D",TamSx3("E1_EMISSAO")[1],TamSx3("E1_EMISSAO"	)[2]) 
TcSetField(cAliasTmp,"D2_PRCVEN","N",TamSx3("D2_PRCVEN")[1],TamSx3("D2_PRCVEN"	)[2])
TcSetField(cAliasTmp,"D2_TOTAL","N",TamSx3("D2_TOTAL")[1],TamSx3("D2_TOTAL"	)[2])
TcSetField(cAliasTmp,"D2_TOTAL","N",TamSx3("D2_TOTAL")[1],TamSx3("D2_TOTAL"	)[2])
TcSetField(cAliasTmp,"C6_VALOR","N",TamSx3("C6_VALOR")[1],TamSx3("C6_VALOR"	)[2])

(cAliasTmp)->( dbGoTop() )   
if (cAliasTmp)->( Eof() )   
	MsgStop("Não foram encontrados dados para gerar o EDI Genérico para os parâmetros informados.","ATENÇÃO" )
	If Select(cAliasTmp) > 0
	 (cAliasTmp)->( dbCloseArea() )
	Endif
	Return Nil    
endif

(cAliasTmp)->( dbGoTop() )   
While (cAliasTmp)->( !Eof() )
	if U_NFDevolv((cAliasTmp)->C6_FILIAL, (cAliasTmp)->D2_DOC, (cAliasTmp)->D2_SERIE, (cAliasTmp)->C6_ITEM)  // Verifica se a NF foi devolvida.
		(cAliasTmp)->(DbSkip())
		loop
	endif
	aadd(aDados, {	(cAliasTmp)->ZB0_NUMCE,;	// [1]
					(cAliasTmp)->ZB0_CODAER,;	// [2]
					(cAliasTmp)->ZB0_NUMVOO,;	// [3]
					(cAliasTmp)->ZB0_PREFIX,;	// [4]
					(cAliasTmp)->C6_NOTA,;		// [5]
					(cAliasTmp)->D2_QUANT,;		// [6]
					(cAliasTmp)->QTDEGAL,;		// [7]
					(cAliasTmp)->ZB0_DTEMIS,;	// [8]
					(cAliasTmp)->E1_EMISSAO,;	// [9]
					(cAliasTmp)->D2_PRCVEN,;	// [10]
					(cAliasTmp)->D2_TOTAL,;		// [11]
					(cAliasTmp)->C6_FILIAL,;	// [12]
					(cAliasTmp)->USCG,;			// [13]
					(cAliasTmp)->TOTALUSD,;		// [14]
					(cAliasTmp)->AIRPORFEES,;	// [15]
					(cAliasTmp)->FATURA,;		// [16]
					(cAliasTmp)->C6VALOR,;		// [17]
					(cAliasTmp)->D2_DOC})		// [18]
					
	(cAliasTmp)->( dbSkip() )
Enddo

If Select(cAliasTmp) > 0
 (cAliasTmp)->( dbCloseArea() )
Endif    

for nI = 1 to Len(aDados)
	SM0->(DbSeek('01'+AllTrim(aDados[nI][12])))
	aDados[nI][02] := Left(SM0->M0_FILIAL,3)
	aDadoTab := {}
	aDadoTab := U_DadoTabe(aDados[nI][09],aDados[nI][12],MV_PAR01,MV_PAR02)  // Buscar taxa do dolar e fator conversão galão
	if Len(aDadoTab) > 0
		aDados[nI][07] := Round(aDados[nI][06]/aDadoTab[01][02],6)  // Converte a quantidade em galões
		aDados[nI][13] := Round(aDados[nI][10]/aDadoTab[01][01],4)  // Converte o preço unitário em dolar
		aDados[nI][14] := Round(aDados[nI][11]/aDadoTab[01][01],4)  // Converte o preço total em dolar
		aDados[nI][15] := Round(((aDadoTab[01][03]/aDadoTab[01][01])*aDadoTab[01][02]),5)  // airport fees total abastecimento = (((ZA1.ZA1_AIRFEE / ZA1.ZA1_TXUS) * ZA1.ZA1_FATCVL))
	endif
next

Return Nil