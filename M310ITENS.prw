#Include 'Protheus.ch'

/*
Programa.: M310ITENS
Autor....: Danilo José Grodzicki
Data.....: 22/09/2016 
Descricao: Executada após a montagem do array AItens antes das chamadas das rotinas automáticas que irão gerar os itens do pedido de vendas,
           do documento de entrada ou da fatura de entrada (localizado). É utilizado para permitir que o usuário manipule o array aItens que
           contém os itens do cabeçalho do pedido de vendas, documento de entrada ou fatura de entrada. É passado um parâmetro para identificar
           a rotina a ser executada após o ponto de entrada.
Uso......: AIR BP BRASIL LTDA
*/
User Function M310ITENS()

/*

aItens:

"C6_ITEM"
"C6_PRODUTO"
"C6_LOCAL"
"C6_QTDVEN"
"C6_PRCVEN"
"C6_PRUNIT"
"C6_VALOR"
"C6_TES"
"C6_LOTECTL"
"C6_DTVALID"
"C6_NUMSERI"
"C6_LOCALIZ"
"C6_GRADE"
"C6_ITEMGRD"

*/

Local nI

Local aItens   := PARAMIXB[2]
Local aAreaSB8 := SB8->(GetArea())
Local aAreaSD1 := SD1->(GetArea())

DbSelectArea("SB8")
SB8->(dbSetOrder(05))

DbSelectArea("SD1")
SD1->(dbSetOrder(11))

for nI = 1 to Len(aItens)
	if SB8->(DbSeek(cFilAnt+aItens[nI][02][02]+aItens[nI][09][02])) .and. AllTrim(SB8->B8_ORIGLAN) == "NF"
		if SD1->(DbSeek(cFilAnt+SB8->B8_DOC+SB8->B8_SERIE+SB8->B8_CLIFOR+SB8->B8_LOJA+SB8->B8_PRODUTO+SB8->B8_LOTECTL))
			if  SD1->D1_CUSFF1 > 0 .and. SD1->D1_QUANT > 0
				aItens[nI][05][02] := SD1->D1_CUSFF1/SD1->D1_QUANT
				aItens[nI][06][02] := aItens[nI][05][02]
				aItens[nI][07][02] := Round(aItens[nI][04][02]*aItens[nI][05][02],2)
			endif
		endif
	endif
next

RestArea(aAreaSB8)
RestArea(aAreaSD1)

Return(aItens)