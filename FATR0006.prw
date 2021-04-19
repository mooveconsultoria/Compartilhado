#INCLUDE "PROTHEUS.CH"
#include "TBICONN.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'
#include "TbiCode.ch"

#DEFINE ENTER CHR(13)+CHR(10)
#DEFINE DIVISOR  ";"

USER FUNCTION FATR0006()

Local nI

Local cCodAer    := space(03)
Local cQuery     := ""
Local cCaminho   := "C:\Ethiopian"
Local nConta     := 0
Local nContador  := 0
Local cMensagem  := ""
Local aHelp      := {}
Local oExcel     := FWMSEXCEL():New()
Local cAliasTmp  := GetNextAlias() 
Local nNetPr     := 0
Local nFPrice    := 0
Local nFPrice2   := 0
Local nTotUSD    := 0 		
Local nAirporFee := 0 		
Local cCodEthi   := AllTrim(SuperGetMv("MV_XETHIOP",,""))

Private cPerg  := Padr("BP_ETHIOP",10)
Private aDados := {}

AjustaSx1(cPerg)
Pergunte(cPerg,.T.)

DbSelectArea("SM0")
SM0->(DbSetOrder(01))

cQuery := "SELECT DISTINCT(R1.C5_XNUMCE) AS C5_XNUMCE, "
cQuery += "       SUM(SD2.D2_QUANT) AS D2_QUANT, "
cQuery += "       SUM(SD2.D2_TOTAL) AS D2_TOTAL, "
cQuery += "       SD2.D2_DOC AS D2_DOC, "
cQuery += "       SD2.D2_EMISSAO AS D2_EMISSAO, "
cQuery += "       R1.C5_XCODAER AS C5_XCODAER, "
cQuery += "       R1.C5_XDTEMIS AS C5_XDTEMIS, "
cQuery += "       R1.C5_XPREFIX AS C5_XPREFIX, "
cQuery += "       R1.C5_XNUMVOO AS C5_XNUMVOO, "
cQuery += "       R1.C5_XHORINI AS C5_XHORINI, "
cQuery += "       R1.C5_CLIENTE AS C5_CLIENTE, "
cQuery += "       R1.C5_LOJACLI AS C5_LOJACLI, "
cQuery += "       R1.C6_QTDVEN AS C6_QTDVEN, "
cQuery += "       R1.ZA1_EXREF AS ZA1_EXREF, "
cQuery += "       R1.ZA1_AIRFEE AS ZA1_AIRFEE, "
cQuery += "       R1.ZA1_DIFF AS ZA1_DIFF, "
cQuery += "       R1.ZA1_ALQICM AS ZA1_ALQICM, "
cQuery += "       R1.ZA1_TXUS AS ZA1_TXUS, "
cQuery += "       R1.ZA1_FATCVL AS ZA1_FATCVL, "
cQuery += "       R1.C6_PRCVEN AS C6_PRCVEN, "
cQuery += "       R1.C6_FILIAL AS C6_FILIAL, "
cQuery += "       R1.C6_NUM AS C6_NUM, "
cQuery += "       SD2.D2_DOC AS D2_DOC, "
cQuery += "       SD2.D2_SERIE AS D2_SERIE, "
cQuery += "       R1.C6_ITEM AS C6_ITEM "
cQuery += "FROM ( "
cQuery += "SELECT SC5.C5_XCODAER AS C5_XCODAER, "
cQuery += "       SC5.C5_XNUMCE AS C5_XNUMCE, "
cQuery += "       SC5.C5_XDTEMIS AS C5_XDTEMIS, "
cQuery += "       SC5.C5_XPREFIX AS C5_XPREFIX, "
cQuery += "       SC5.C5_XNUMVOO AS C5_XNUMVOO, "
cQuery += "       SC5.C5_XHORINI AS C5_XHORINI, "
cQuery += "       SC5.C5_CLIENTE AS C5_CLIENTE, "
cQuery += "       SC5.C5_LOJACLI AS C5_LOJACLI, "
cQuery += "       SC6.C6_QTDVEN AS C6_QTDVEN, "
cQuery += "       ZA1.ZA1_EXREF AS ZA1_EXREF, "
cQuery += "       ZA1.ZA1_AIRFEE AS ZA1_AIRFEE, "
cQuery += "       ZA1.ZA1_DIFF AS ZA1_DIFF, "
cQuery += "       ZA1.ZA1_ALQICM AS ZA1_ALQICM, "
cQuery += "       ZA1.ZA1_TXUS AS ZA1_TXUS, "
cQuery += "       ZA1.ZA1_FATCVL AS ZA1_FATCVL, "
cQuery += "       SC6.C6_PRCVEN AS C6_PRCVEN, "
cQuery += "       SC6.C6_FILIAL AS C6_FILIAL, "
cQuery += "       SC6.C6_NUM AS C6_NUM, "
cQuery += "       SC6.C6_ITEM AS C6_ITEM "
cQuery += "FROM " + RetSqlName("SC5") + " SC5, " + RetSqlName("SC6") + " SC6, " + RetSqlName("ZA1") + " ZA1, " + RetSqlName("ZB0") + " ZB0 "
cQuery += "WHERE ZB0.D_E_L_E_T_ <> '*' "
cQuery += "  AND ZB0.ZB0_CODCLI = '"+cCodEthi+"' "
cQuery += "  AND ZB0.ZB0_LOJCLI = '01' "
cQuery += "  AND ZB0.ZB0_DTEMIS BETWEEN '"+ DTOS(mv_par01)	+"' AND '"+	DTOS(mv_par02) +"' "
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
cQuery += "  AND ZA1.ZA1_FILIAL = '" + xFilial("ZA1") + "' "
cQuery += "  AND ZA1.ZA1_BASE = ZB0.ZB0_FILIAL "
cQuery += "  AND ZA1.ZA1_CODTAB = ZB0_CODTAB "
cQuery += "  AND ZA1.ZA1_REV = ZB0_REVTAB "
cQuery += "  AND ZA1_CLIENT = ZB0.ZB0_CODCLI "
cQuery += "  AND ZA1_LOJA = ZB0.ZB0_LOJCLI "
cQuery += ") R1, " + RetSqlName("SD2") + " SD2 "
cQuery += "WHERE SD2.D_E_L_E_T_ <> '*' "
cQuery += "  AND SD2.D2_FILIAL = R1.C6_FILIAL "
cQuery += "  AND SD2.D2_PEDIDO = R1.C6_NUM "
cQuery += "GROUP BY R1.C5_XNUMCE, SD2.D2_DOC, SD2.D2_EMISSAO, R1.C5_XDTEMIS, R1.C5_XPREFIX, R1.C5_XNUMVOO, R1.C5_XHORINI, R1.C5_XCODAER, R1.C5_CLIENTE, R1.C5_LOJACLI, R1.C6_QTDVEN, R1.ZA1_EXREF, R1.ZA1_AIRFEE, R1.ZA1_DIFF, R1.ZA1_ALQICM, R1.ZA1_TXUS, R1.ZA1_FATCVL, R1.C6_PRCVEN, R1.C6_FILIAL, R1.C6_NUM, SD2.D2_DOC, SD2.D2_SERIE, R1.C6_ITEM "
cQuery += "ORDER BY C5_XCODAER, C5_XNUMCE, C5_CLIENTE, C5_LOJACLI, C5_XDTEMIS, C5_XHORINI"
cQuery := ChangeQuery(cQuery) 
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTmp,.F.,.T.)

memowrite('c:\EXTBOLETO\fatr0006.txt',cQuery)

TcSetField(cAliasTmp,"D2_QUANT"	,"N",TamSx3("D2_QUANT")[1],TamSx3("D2_QUANT"	)[2]) 
TcSetField(cAliasTmp,"C5_XDTEMIS","D")
TcSetField(cAliasTmp,"D2_EMISSAO","D",TamSx3("D2_EMISSAO")[1],TamSx3("D2_EMISSAO"	)[2]) 
TcSetField(cAliasTmp,"D2_TOTAL","N",TamSx3("D2_TOTAL")[1],TamSx3("D2_TOTAL"	)[2])
TcSetField(cAliasTmp,"ZA1_EXREF","N",14,4)
TcSetField(cAliasTmp,"ZA1_AIRFEE","N",14,5)
TcSetField(cAliasTmp,"ZA1_DIFF","N",14,4)
TcSetField(cAliasTmp,"ZA1_ALQICM","N",14,2)
TcSetField(cAliasTmp,"ZA1_FATCVL","N",14,5)
TcSetField(cAliasTmp,"C6_PRCVEN","N",TamSx3("C6_PRCVEN")[1],TamSx3("C6_PRCVEN"	)[2])

(cAliasTmp)->( dbGoTop() )   
While (cAliasTmp)->( !Eof() )
	if U_NFDevolv((cAliasTmp)->C6_FILIAL, (cAliasTmp)->D2_DOC, (cAliasTmp)->D2_SERIE, (cAliasTmp)->C6_ITEM)  // Verifica se a NF foi devolvida.
		(cAliasTmp)->(DbSkip())
		loop
	endif
	aadd(aDados,{(cAliasTmp)->C5_XCODAER, (cAliasTmp)->C5_XNUMCE, (cAliasTmp)->C5_XDTEMIS, (cAliasTmp)->C5_XPREFIX, (cAliasTmp)->C5_XNUMVOO,;
	             (cAliasTmp)->C6_QTDVEN, (cAliasTmp)->D2_DOC, (cAliasTmp)->D2_EMISSAO, (cAliasTmp)->D2_QUANT, (cAliasTmp)->D2_TOTAL,;
	             (cAliasTmp)->ZA1_EXREF, (cAliasTmp)->ZA1_AIRFEE, (cAliasTmp)->ZA1_DIFF, (cAliasTmp)->ZA1_ALQICM, (cAliasTmp)->ZA1_TXUS,;
	             (cAliasTmp)->ZA1_FATCVL, (cAliasTmp)->C6_PRCVEN, (cAliasTmp)->C6_FILIAL})
	(cAliasTmp)->( dbSkip() )
Enddo

//Abre caixa de dialogo para indicar o diretório a salvar
cResName   := "Ethiopian Invoicing" + DTOS(DATE()) + ".XLS"
cTargetDir := AllTrim( cGetFile("Edi Ethiopian|"+cResName, OemToAnsi("Salvar Arquivo Como..."),,cCaminho,,GETF_LOCALHARD+GETF_NETWORKDRIVE))

MakeDir(cCaminho)
    
If File(ALLTRIM(cTargetDir))
    fErase(ALLTRIM(cTargetDir))
Endif

for nI = 1 to Len(aDados)
	SM0->(DbSeek('01'+AllTrim(aDados[nI][18])))
	aDados[nI][01] := Left(SM0->M0_FILIAL,3)
next
 
nConta  := Len(aDados)
cCodAer := space(03)

for nI = 1 to Len(aDados)
	if AllTrim(aDados[nI][01]) <> AllTrim(cCodAer)
		cCodAer := aDados[nI][01]
		oExcel:AddworkSheet(cCodAer)
		oExcel:AddTable (cCodAer,"Relatório Ethiopian",)
		oExcel:AddColumn(cCodAer,"Relatório Ethiopian","Date",1,4)
		oExcel:AddColumn(cCodAer,"Relatório Ethiopian","Danfe",1,1)	
		oExcel:AddColumn(cCodAer,"Relatório Ethiopian","Delivery Ticket",1,1)
		oExcel:AddColumn(cCodAer,"Relatório Ethiopian","Registration",1,1)
		oExcel:AddColumn(cCodAer,"Relatório Ethiopian","Flight",1,1)
		oExcel:AddColumn(cCodAer,"Relatório Ethiopian","Volume",1,1)
		oExcel:AddColumn(cCodAer,"Relatório Ethiopian","Ref 45",1,1)
		oExcel:AddColumn(cCodAer,"Relatório Ethiopian","Airport Fee",1,1)
		oExcel:AddColumn(cCodAer,"Relatório Ethiopian","Differential",1,1)
		oExcel:AddColumn(cCodAer,"Relatório Ethiopian","Net Price",1,3)
		oExcel:AddColumn(cCodAer,"Relatório Ethiopian","VAT",1,1)
		oExcel:AddColumn(cCodAer,"Relatório Ethiopian","Final Price",1,3)
		oExcel:AddColumn(cCodAer,"Relatório Ethiopian","Total R$",1,3)
		oExcel:AddColumn(cCodAer,"Relatório Ethiopian","Final Price (U$/Lt)",1,3)
		oExcel:AddColumn(cCodAer,"Relatório Ethiopian","Total USD",1,3)
	endif
	nNetPr     := aDados[nI][11] + aDados[nI][12] + aDados[nI][13]
	nFPrice2   := (aDados[nI][11] + aDados[nI][12] + aDados[nI][13]) / aDados[nI][15]
	nTotUSD    := ((aDados[nI][11] + aDados[nI][12] + aDados[nI][13]) / aDados[nI][15]) * aDados[nI][09]
	nAirporFee := (aDados[nI][12] / aDados[nI][15]) * aDados[nI][16]
	oExcel:AddRow(cCodAer,"Relatório Ethiopian",{aDados[nI][03],;                 // DATA EMISSAO
	                                             aDados[nI][07],;                 // Número do Documento 
	                                             aDados[nI][02],;                 // Delivery Ticket ou Número da CE
	                                             aDados[nI][04],;                 // Registration ou Prefixo
	                                             aDados[nI][05],;                 // Número do Voo ou Flight
	                                             aDados[nI][06],;                 // Volume
	                                             aDados[nI][11],;                 // Referência 45
	                                             Round(aDados[nI][12],5),;                 // Airport Fee
	                                             Round(aDados[nI][13],4),;                 // Differential
	                                             Round(nNetPr,4),;                         // Net Price
	                                             aDados[nI][14],;                 // VAT
	                                             Round(aDados[nI][17],4),;                 // Final Price
	                                             aDados[nI][10],;                 // Total do Abastecimento
	                                             nFprice2,;                       // Final Price 2
	                                             aDados[nI][10]/aDados[nI][15];   // Total USD
	                                            })

	nContador ++
next

oExcel:Activate()
oExcel:GetXMLFile(cTargetDir)

oExcelApp:= MsExcel():New()
oExcelApp:WorkBooks:Open( AllTrim( cTargetDir ) )
oExcelApp:SetVisible(.T.)
    
If Select(cAliasTmp) > 0
 (cAliasTmp)->( dbCloseArea() )
Endif    
        
Return Nil

Static Function AjustaSx1(cPerg)

Local _nx     := 0
Local _nh     := 0
Local _nlh    := 0
Local _aHelp  := Array(8,1)
Local _aRegs  := {}
Local _sAlias := Alias()
Local _aHead  := {"X1_GRUPO","X1_ORDEM","X1_PERGUNTE","X1_PERSPA","X1_PERENG	","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_DEF02","X1_DEF03","X1_DEF04","X1_DEF05","X1_F3"}

AADD(_aRegs,{cPerg,'01',"Data Inicial ?" ,"Emissao Inicial ?" ,"Emissao Inicial ?" ,'mv_ch1','D',08,0,0,'G','','mv_par01','','','','',"",""})
AADD(_aRegs,{cPerg,'02',"Data Final? "   ,"Emissao Final? "   ,"Emissao Final? "   ,'mv_ch2','D',08,0,0,'G','','mv_par02','','','','',"",""})

DbSelectArea('SX1')
SX1->(DbSetOrder(1))

For _nx:=1 to Len(_aRegs)
	If	RecLock('SX1',Iif(!SX1->(DbSeek(_aRegs[_nx][01]+_aRegs[_nx][02])),.t.,.f.))
		For _nlh:=1 to Len(_aHead)
			If	( _nlh <> 10 )
				Replace &(_aHead[_nlh]) With _aRegs[_nx][_nlh]
			EndIf
		Next _nlh
		MsUnlock()
	Else
		Help('',1,'REGNOIS')
	Endif
	
Next _nx

Return Nil