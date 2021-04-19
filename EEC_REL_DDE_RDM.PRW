#Include "Average.ch"
#Include "EICRMAPA.ch"

/*
Programa   : EEC_REL_DDE
Objetivo   : Relatório - Relatório Base DDE
Autor      : Walnir Necho Mandu 
Data/Hora  : 06/01/17
*/ 

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
User Function EEC_DDE()
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
Local oReport

#IFDEF TOP
	If FindFunction("TRepInUse") .And. TRepInUse()
		oReport := ReportDef()
		oReport:PrintDialog()
	Else
		Aviso("Nao disponivel","Esta funcionalidade so esta disponivel para os relatorios personalizaveis",{"Fechar"}) //"Nao disponivel"###"Esta funcionalidade so esta disponivel para os relatorios personalizaveis"###"Fechar"
	Endif
#ELSE
	Aviso("Nao disponivel","Esta funcionalidade so esta disponivel para uso com bancos de dados relacionais",{"Fechar"}) //"Nao disponivel"###"Esta funcionalidade so esta disponivel para uso com bancos de dados relacionais"###"Fechar"
#ENDIF

Return .F.

Static Function ReportDef()
Local oReport  
Local oSection1, oSection2, oBreak1
Local cAliasQry1 := GetNextAlias()
Local nTamanho   := AvSx3("W3_COD_I",3)

Private nTaxa    := 0

oReport := TReport():New("EEC_REL_DDE","Rel. de Exportacoes para DDE","EECAD5",;  
{|oReport| ReportPrint(oReport,cAliasQry1)},"Relatorio Exportacoes - Relatório para emissão da DDE") 

oReport:SetPortrait(.T.)

Pergunte(oReport:uParam,.T.)

oSection1 := TRSection():New(oReport,/*STR0007*/,{"EEC","EE9","EE7","EEQ","SYA","SA1"}, )  

TRCell():New(oSection1,"A1_NOME"   ,"SA1" ,"Cliente"     ,,AvSx3("A1_NOME"     ,AV_TAMANHO) ,.T.,{|| POSICIONE("SA1",1,xFilial("SA1")+(cAliasQry1)->(EEC_IMPORT+EEC_IMLOJA), "A1_NOME") })
TRCell():New(oSection1,"EEC_IMPORT","EEC" ,"Cod Cliente" ,,10                               ,.T.,{|| (cAliasQry1)->(EEC_IMPORT+" "+EEC_IMLOJA)})
TRCell():New(oSection1,"EE7_XNUMCE","EE7" ,"CE"          ,,AvSx3("EE7_XNUMCE"  ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EE7_XNUMCE }) 
TRCell():New(oSection1,"EE7_XDTEMI","EE7" ,"Dt Transacao",,AvSx3("EE7_XDTEMI"  ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EE7_XDTEMI }) 
TRCell():New(oSection1,"EE9_SLDINI","EE9" ,"Volume"      ,,AvSx3("EE9_SLDINI"  ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EE9_SLDINI }) 
// WNM 06/02/16 A PEDIDO DA ANDREZA GRU TRCell():New(oSection1,"EE9_SLDINI","EE9" ,"Vol Galoes"  ,,AvSx3("EE9_SLDINI"  ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EE9_SLDINI / 3.78540 }) 

TRCell():New(oSection1,"EEQ_MOEDA" ,"EEQ" ,"Moeda"       ,,AvSx3("EEQ_MOEDA"   ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EEQ_MOEDA  })

// WNM 06/02/16 A PEDIDO DA ANDREZA GRU TRCell():New(oSection1,"EE9_PRECO" ,"EE9" ,"Preco"       ,,AvSx3("EE9_PRCTOT"  ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EE9_PRECO  }) 
// WNM 06/02/16 A PEDIDO DA ANDREZA GRU TRCell():New(oSection1,"EE9_PRECO" ,"EE9" ,"Preco/Galoes",,AvSx3("EE9_PRCTOT"  ,AV_TAMANHO) ,.T.,{|| ((cAliasQry1)->EE9_PRCTOT / ((cAliasQry1)->EE9_SLDINI / 3.78540)) }) 
TRCell():New(oSection1,"EE9_PRCTOT","EE9" ,"TOTAL na Moeda",,AvSx3("EE9_PRCTOT"  ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EE9_PRCTOT }) 
//nTaxa := BuscaTaxa("US$", (cAliasQry1)->EE7_XDTEMI ,,.F.)



// WNM 06/02/16 A PEDIDO DA ANDREZA GRU TRCell():New(oSection1,"EE9_PRECO" ,"EE9" ,"Preco/R$"    ,,AvSx3("EE9_PRCTOT"  ,AV_TAMANHO) ,.T.,{|| IIF((cAliasQry1)->EEQ_MOEDA == "BRL" .OR. (cAliasQry1)->EEQ_MOEDA == "R$" ,(cAliasQry1)->EE9_PRECO ,(cAliasQry1)->EE9_PRECO  * BuscaTaxa((cAliasQry1)->EEQ_MOEDA, (cAliasQry1)->EE7_XDTEMI ,,.F.)) }) 

TRCell():New(oSection1,"EE9_PRCTOT","EE9" ,"TOTAL BRL"   ,,AvSx3("EE9_PRCTOT"  ,AV_TAMANHO) ,.T.,{|| IIF((cAliasQry1)->EEQ_MOEDA == "BRL" .OR. (cAliasQry1)->EEQ_MOEDA == "R$" ,(cAliasQry1)->EE9_PRCTOT,(cAliasQry1)->EE9_PRCTOT * BuscaTaxa((cAliasQry1)->EEQ_MOEDA, (cAliasQry1)->EE7_XDTEMI ,,.F.)) })  // to

TRCell():New(oSection1,"EEC_NRODUE","EEC" ,"DUE"         ,,AvSx3("EEC_NRODUE"  ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EEC_NRODUE }) // WNM 30/08/18
TRCell():New(oSection1,"EEC_DTDUE" ,"EEC" ,"Dt DUE"      ,,AvSx3("EEC_DTDUE"   ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EEC_DTDUE  }) // WNM 30/08/18 

TRCell():New(oSection1,"EE9_RE"    ,"EE9" ,"RE"          ,,AvSx3("EE9_RE"      ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EE9_RE     }) 
TRCell():New(oSection1,"EE9_DTRE"  ,"EE9" ,"Dt RE"       ,,AvSx3("EE9_DTRE"    ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EE9_DTRE   }) 
// DDE
// DATA DDE
// STATUS AVERBACAO
// DATA AVERBACAO
TRCell():New(oSection1,"EEC_PAISDT","EEC" ,"Cod Pais"    ,,AvSx3("EEC_PAISDT"  ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EEC_PAISDT }) 
TRCell():New(oSection1,"YA_DESCR"  ,"SYA" ,"Pais Dest"   ,,AvSx3("YA_DESCR"    ,AV_TAMANHO) ,.T.,{|| POSICIONE("SYA",1,xFilial("SYA")+(cAliasQry1)->EEC_PAISDT, "YA_DESCR") })
// WNM 06/02/16 A PEDIDO DA ANDREZA GRU TRCell():New(oSection1,"EEC_ORIGEM","EEC" ,"Cod Estab"   ,,AvSx3("EEC_ORIGEM"  ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EEC_ORIGEM }) 
// WNM 06/02/16 A PEDIDO DA ANDREZA GRU TRCell():New(oSection1,"EEQ_DTCE"  ,"EEQ" ,"Dt Cred Ext" ,,AvSx3("EEQ_DTCE"    ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EEQ_DTCE   })
// WNM 06/02/16 A PEDIDO DA ANDREZA GRU TRCell():New(oSection1,"EEQ_NROP"  ,"EEQ" ,"Fech Cambio" ,,AvSx3("EEQ_NROP"    ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EEQ_NROP   })
// WNM 06/02/16 A PEDIDO DA ANDREZA GRU TRCell():New(oSection1,"EEQ_PGT"   ,"EEQ" ,"Fech Cambio" ,,AvSx3("EEQ_PGT"     ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EEQ_PGT    })

// WNM 06/02/16 A PEDIDO DA ANDREZA GRU TRCell():New(oSection1,"A1_CGC"    ,"SA1" ,"CNPJ"        ,,AvSx3("A1_CGC"      ,AV_TAMANHO) ,.T.,{|| POSICIONE("SA1",1,xFilial("SA1")+(cAliasQry1)->(EEC_IMPORT+EEC_IMLOJA), "A1_CGC") })
TRCell():New(oSection1,"EEC_PREEMB","EEC" ,"Invoice"     ,,AvSx3("EEC_PREEMB"  ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EEC_PREEMB }) 
TRCell():New(oSection1,"EE9_NF"    ,"EE9" ,"NF"          ,,AvSx3("EE9_NF"      ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EE9_NF     }) 
TRCell():New(oSection1,"EE9_SERIE" ,"EE9" ,"Serie"       ,,AvSx3("EE9_SERIE"   ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EE9_SERIE  }) 
// WNM 06/02/16 A PEDIDO DA ANDREZA GRU TRCell():New(oSection1,"EEQ_VCT"   ,"EEQ" ,"Vencimento"  ,,AvSx3("EEQ_VCT"     ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EEQ_VCT    })
// WNM 06/02/16 A PEDIDO DA ANDREZA GRU TRCell():New(oSection1,"EEC_FILIAL","EEC" ,"Filial"      ,,AvSx3("EEC_FILIAL"  ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EEC_FILIAL }) 
//LINHA
TRCell():New(oSection1,"EE7_XPREFI","EE7" ,"Prefx Aviao" ,,AvSx3("EE7_XPREFI"  ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EE7_XPREFI }) 
TRCell():New(oSection1,"EE7_XNUMVO","EE7" ,"Num Voo"     ,,AvSx3("EE7_XNUMVO"  ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EE7_XNUMVO }) 
TRCell():New(oSection1,"EE9_PSLQTO","EE9" ,"Peso"        ,,AvSx3("EE9_PSLQTO"  ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EE9_PSLQTO }) 
// WNM 06/02/16 A PEDIDO DA ANDREZA GRU TRCell():New(oSection1,"EE9_COD_I" ,"EE9" ,"Item"        ,,AvSx3("EE9_COD_I"   ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EE9_COD_I  }) 
// WNM 06/02/16 A PEDIDO DA ANDREZA GRU TRCell():New(oSection1,"EE9_CF"    ,"EE9" ,"CFOP"        ,,AvSx3("EE9_CF"      ,AV_TAMANHO) ,.T.,{|| (cAliasQry1)->EE9_CF     }) 

oSection1:SetTotalInLine(.T.)

Return oReport                                         

/* 
Funcao     : ReportPrint() 
Parametros : Nenhum 
Retorno    : 
Objetivos  : 
*/
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
Static Function ReportPrint(oReport,cAliasQry1)
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

Local   aQueryReg := {}
Private oSection1 := oReport:Section(1)
Private oSection2 := oReport:Section(2)
Private cParam    := ""
Private lParam    := .F.
Private cBreak    := "" 
                    
// WNM 30/08/18 cParam := " EE9.EE9_RE <> '"+SPACE(LEN(EE9->EE9_RE))+"' AND EE9.EE9_NRSD = '"+SPACE(LEN(EE9->EE9_NRSD))+"' AND EEQ_EVENT <> '802'"
cParam := "( EE9.EE9_RE <> '"+SPACE(LEN(EE9->EE9_RE))+"' OR EEC.EEC_NRODUE <> '"+SPACE(LEN(EEC->EEC_NRODUE))+"'  ) AND EE9.EE9_NRSD = '"+SPACE(LEN(EE9->EE9_NRSD))+"' AND EEQ_EVENT <> '802'" // WNM 30/08/18

If !Empty(MV_PAR01)            
   cParam += If(!Empty(cParam)," AND ","")+" EE7.EE7_XDTEMI  >= '" + dToS(mv_par01) + "'"
EndIf
If !Empty(MV_PAR02)
   cParam += If(!Empty(cParam)," AND ","")+" EE7.EE7_XDTEMI  <= '" + DToS(mv_par02) + "'"
EndIf

If !Empty(cParam)
   cParam := "%WHERE" + cParam //+ " ORDER BY SW2.W2_IMPORT%"
EndIf

If !lParam
   If !Empty(cParam)
      cParam += " ORDER BY EEC.EEC_DTPROC , EEC.EEC_PREEMB , EE9.EE9_NF, EE9.EE9_SERIE %"
   Else
      cParam := "%ORDER BY EEC.EEC_DTPROC , EEC.EEC_PREEMB , EE9.EE9_NF, EE9.EE9_SERIE %"
   EndIf   
EndIf
     

oSection1:BeginQuery()


	BeginSql Alias cAliasQry1


		SELECT DISTINCT EEC.EEC_PREEMB, EEC.EEC_IMPORT, EEC.EEC_IMLOJA, EE7.EE7_XNUMCE, EE7.EE7_XDTEMI, EE9.EE9_PEDIDO, EE9.EE9_SLDINI, 
						EE9.EE9_RE    , EE9.EE9_DTRE  , EEC.EEC_PAISDT, EEC.EEC_ORIGEM, EEQ.EEQ_DTCE  , EE9.EE9_NF    , EE9.EE9_SERIE ,
		                EEQ.EEQ_VCT   , EEC.EEC_FILIAL, EE9.EE9_SEQEMB, EE7.EE7_XPREFI, EE7.EE7_XNUMVO, EE9.EE9_PSLQTO, EE9.EE9_COD_I , 
		                EE9.EE9_CF    , EE9.EE9_NRSD  , EEC.EEC_DTPROC, EE9.EE9_PRCTOT, EE9.EE9_PRECO , EEQ.EEQ_NROP  , EEQ.EEQ_PGT   , 
		                EEQ.EEQ_MOEDA , EEC.EEC_NRODUE, EEC.EEC_DTDUE
		
		
		FROM %table:EEC% EEC LEFT OUTER JOIN %table:EE9% EE9 ON     EEC.EEC_PREEMB = EE9.EE9_PREEMB 
			             										AND EEC.%NotDel% 
																AND EEC.EEC_FILIAL = %xFilial:EEC%
			             										AND EE9.%NotDel% 
																AND EE9.EE9_FILIAL = %xFilial:EE9%
				             LEFT OUTER JOIN %table:EEQ% EEQ ON     EEC.EEC_PREEMB = EEQ.EEQ_PREEMB 
			                                                 	AND EEQ.%NotDel% 
			                                                 	AND EEQ.EEQ_FILIAL = EEC.EEC_FILIAL
				             LEFT OUTER JOIN %table:EE7% EE7 ON     EE9.EE9_PEDIDO = EE7.EE7_PEDIDO 
			                                                 	AND EE7.%NotDel% 
			                                                 	AND EE7.EE7_FILIAL = %xFilial:EE7%            
        %Exp:cParam%
            

	EndSql

aQueryReg := GetLastQuery()
	
oSection1:EndQuery() 

(cAliasQry1)->(DBGOTOP())

WHILE (cAliasQry1)->(!EOF())

	oSection1:Init()                                     
	oReport:IncMeter((cAliasQry1)->(LastRec())) 
	oSection1:PRINTLINE()	 
    
	(cAliasQry1)->(DBSKIP())	
	
ENDDO

oSection1:Finish()
Return           


