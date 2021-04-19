#Include 'Protheus.ch'

/*
Programa.: A103CLAS
Autor....: Danilo José Grodzicki
Data.....: 19/09/2016 
Descricao: Ponto de Entrada que permite manipular o item do aCols.
Uso......: AIR BP BRASIL LTDA
*/
User Function A103CLAS()

Local nI

Local aAreaSB1   := SB1->(GetArea())
Local nPosTModal := ascan(aHeader,{|x| x[2] == "D1_T_MODAL"})
Local nPosProd   := ascan(aHeader,{|x| x[2] == "D1_COD    "})

DbSelectArea("SB1")
SB1->(DbSetOrder(01))

if nPosTModal > 0 .and. nPosProd > 0
	for nI = 1 to Len(aCols)
		if SB1->(dbSeek(xFilial("SB1")+aCols[nI,nPosProd])) .and. AllTrim(SB1->B1_GRUPO) = "01"  // Grupo combustível
			aCols[nI,nPosTModal] := "01"
		endif
	next
endif

RestArea(aAreaSB1)

Return Nil