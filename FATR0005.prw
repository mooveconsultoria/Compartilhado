#Include 'Protheus.ch'
#Include "Fileio.ch"

/*
Programa.: FATR0005
Autor....: Danilo José Grodzicki
Data.....: 27/10/2016 
Descricao: Gera EDI Genérico - PDF.
Uso......: AIR BP BRASIL LTDA
*/
User Function FATR0005()

Private cFatura
Private cEmissao
Private cDtVencto

Private cPerg     := "EDIGENERIC"
Private aDados    := {}
Private aFatura   := {}
Private cAliasTmp := GetNextAlias()

DbSelectArea("SM0")
SM0->(DbSetOrder(01))

DbSelectArea("SYA")
SYA->(DbSetOrder(01))

DbSelectArea("SE4")
SE4->(DbSetOrder(01))

DbSelectArea("SA1")
SA1->(DbSetOrder(01))

AjustaSX1(cPerg)

If !Pergunte(cPerg,.T.)
	Return Nil
endif

//if U_ValQtde()
//	MsgStop("Não é possível gerar o EDI Genérico porque, foram encontradas mais de uma fatura para os parâmetros informados.","ATENÇÃO" )
//	Return Nil
//endif

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

cFatura   := aDados[01][16]
cEmissao  := Subs(aFatura[01][03],5,2)+"/"+Right(aFatura[01][03],2)+"/"+Left(aFatura[01][03],4)
cDtVencto := Subs(aFatura[01][01],5,2)+"/"+Right(aFatura[01][01],2)+"/"+Left(aFatura[01][01],4)

Processa({ || ProcRegua( 0 ), GeraPdf()},"Aguarde...","Gerando EDI Genérico - PDF.")

Return Nil

/*
Programa.: AjustaSX1
Autor....: Danilo José Grodzicki
Data.....: 27/10/2016 
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
Programa.: GeraPdf
Autor....: Danilo José Grodzicki
Data.....: 27/10/2016 
Descricao: Gera EDI Genérico - PDF.
Uso......: AIR BP BRASIL LTDA
*/
Static Function GeraPdf()

Local nI
Local nLin
Local nItens
Local cDelivery

Local cTitulo    := ""
Local nTotVolLtr := 0.00
Local nTotVolGls := 0.00
Local nTotFueCos := 0.00
Local nTotAirFee := 0.00
Local nTotTotAmo := 0.00

Private oPrint
Private oArial08  := TFont():New("Arial",,08 ,,.F.,,,,,.F.,.F.)
Private oArial08N := TFont():New("Arial",,08 ,,.T.,,,,,.F.,.F.)

SA1->(DbSeek(xFilial("SA1")+MV_PAR01+MV_PAR02))
SYA->(DbSeek(xFilial("SYA")+SA1->A1_PAIS))
SE4->(DbSeek(xFilial("SE4")+SA1->A1_COND))

oPrint := TMSPrinter():New( cTitulo )

oPrint:SetPaperSize(1)
oPrint:SetLandscape(.T.)
oPrint:Setup()

Cabec()  // Imprime o cabeçalho
		
nLin := 500

cNumFat := space(09)
for nI = 1 to Len(aDados)
	
	if cNumFat <> aDados[nI][16]
		
		if nI > 1
			oPrint:EndPage(.T.)
		endif

		cNumFat    := aDados[nI][16]
		nTotVolLtr := 0.00
		nTotVolGls := 0.00
		nTotFueCos := 0.00
		nTotAirFee := 0.00
		nTotTotAmo := 0.00
		
		oPrint:StartPage(.T.)

		Cabec()  // Imprime o cabeçalho

		nLin := 500
		
		for nItens = nI to Len(aDados)
			
			if cNumFat <> aDados[nItens][16]
				exit
			endif
			
			if nLin > 2320
				oPrint:EndPage(.T.)
				oPrint:StartPage(.T.)
				Cabec()  // Imprime o cabeçalho
				nLin := 500
			endif
			
			cDelivery := Subs(DtoS(aDados[nItens][08]),5,2)+"/"+Right(DtoS(aDados[nItens][08]),2)+"/"+Left(DtoS(aDados[nItens][08]),4)
			
			oPrint:Say(nLin,0100,aDados[nItens][01]                                                                                                   ,oArial08)  // Delivery ticket number
			oPrint:Say(nLin,0440,aDados[nItens][02]                                                                                                   ,oArial08)  // Airport code
			oPrint:Say(nLin,0540,aDados[nItens][03]                                                                                                   ,oArial08)  // Flight number
			oPrint:Say(nLin,0770,aDados[nItens][04]                                                                                                   ,oArial08)  // Aircraft
			oPrint:Say(nLin,0970,Str(Round(aDados[nItens][06],6),6,0)                                                                                 ,oArial08)  // Volume (litros)
			oPrint:Say(nLin,1160,Str(Round(aDados[nItens][07],6),6,0)                                                                                 ,oArial08)  // Volume (gls)
			oPrint:Say(nLin,1360,cDelivery                                                                                                            ,oArial08)  // Fuelling  (delivery) date
			oPrint:Say(nLin,1625,Str((Round(aDados[nItens][17],2)-(Round(aDados[nItens][07]*aDados[nItens][15],2)))/ Round(aDados[nItens][06],6),11,5),oArial08)  // Unit price (uscg)
			oPrint:Say(nLin,1820,Str(Round(aDados[nItens][17],2)-(Round(aDados[nItens][07]*aDados[nItens][15],2)),12,2)                               ,oArial08)  // Fuel cost
			oPrint:Say(nLin,2060,Str(Round(aDados[nItens][07]*aDados[nItens][15],2),12,2)                                                             ,oArial08)  // Airport Fees
			oPrint:Say(nLin,2390,Str(Round(aDados[nItens][17],2),12,2)                                                                                ,oArial08)  // Total Amount (USD)
			
			nTotVolLtr += Round(aDados[nItens][06],0)
			nTotVolGls += Round(aDados[nItens][07],0)
			nTotFueCos += Round(aDados[nItens][17],2)-(Round(aDados[nItens][07]*aDados[nItens][15],2))
			nTotAirFee += Round(aDados[nItens][07]*aDados[nItens][15],2)
			nTotTotAmo += Round(aDados[nItens][17],2)
			
			nLin += 40
		next
		
		oPrint:Line(nLin,0100,nLin,3200)
		nLin += 40
		oPrint:Say(nLin,0950,Str(nTotVolLtr,9,0) ,oArial08N)  // Total Volume (litros)
		oPrint:Say(nLin,1160,Str(nTotVolGls,6,0) ,oArial08N)  // Total Volume (gls)
		oPrint:Say(nLin,1820,Str(nTotFueCos,12,2),oArial08N)  // Total Fuel cost
		oPrint:Say(nLin,2060,Str(nTotAirFee,12,2),oArial08N)  // Total Airport Fees
		oPrint:Say(nLin,2390,Str(nTotTotAmo,12,2),oArial08N)  // Total Amount (USD)
		nLin += 40
		oPrint:Line(nLin,0100,nLin,3200)
		
	endif
	
next

oPrint:Preview()

Return Nil

/*
Programa.: Cabec
Autor....: Danilo José Grodzicki
Data.....: 27/10/2016 
Descricao: Cabeçalho.
Uso......: AIR BP BRASIL LTDA
*/
Static Function Cabec()

oPrint:SayBitmap( 100,0100,"\SYSTEM\logobp.bmp",300,150 )

oPrint:Say(100,0700,AllTrim(SA1->A1_NOME)                       ,oArial08 )
oPrint:Say(100,2400,"Invoice No         : "+cFatura             ,oArial08N)

oPrint:Say(140,0700,AllTrim(SA1->A1_END)                        ,oArial08 )
oPrint:Say(140,2400,"Invoice Date       :  "+cEmissao           ,oArial08 )

oPrint:Say(180,0700,SA1->A1_CEP+" - "+AllTrim(SA1->A1_MUN)      ,oArial08 )
oPrint:Say(180,2400,"Due Date            : "+cDtVencto          ,oArial08 )

oPrint:Say(220,0700,SA1->A1_EST+" - "+AllTrim(SYA->YA_DESCR)    ,oArial08 )
oPrint:Say(220,2400,"Payment terms   : "+AllTrim(SE4->E4_XDESING),oArial08 )

oPrint:Say(260,2400,"Global reference number : "+SA1->A1_XGREF  ,oArial08 )

oPrint:Line(320,0100,320,3200)

oPrint:Say(380,0440,"Airport"                                   ,oArial08 )
oPrint:Say(380,1345,"Fuelling"                                  ,oArial08 )

oPrint:Say(410,0100,"Delivery ticket number"                    ,oArial08 )
oPrint:Say(410,0455,"Code"                                      ,oArial08 )
oPrint:Say(410,0550,"Flight Number"                             ,oArial08 )
oPrint:Say(410,0780,"Aircraft"                                  ,oArial08 )
oPrint:Say(410,0920,"Volume (lts)"                              ,oArial08 )  // NOVA COLUNA
oPrint:Say(410,1120,"Volume (gls)"                              ,oArial08 )
oPrint:Say(410,1345,"(delivery) date"                           ,oArial08 )
oPrint:Say(410,1570,"Unit price (uscg)"                         ,oArial08 )
oPrint:Say(410,1850,"Fuel Cost"                                 ,oArial08 )  // NOVA COLUNA
oPrint:Say(410,2070,"Airport Fees"                              ,oArial08 )
oPrint:Say(410,2320,"Total Amount (USD)"                        ,oArial08 )

oPrint:Line(470,0100,470,3200)

Return Nil