#Include 'Protheus.ch'

/*
Programa.: CorDen20
Autor....: Danilo José Grodzicki
Data.....: 31/05/2016 
Descricao: Função para cálculo da densidade a vinte graus centígrados.
Uso......: AIR BP BRASIL LTDA
*/
User Function CorDen20(nDen,nTemp)

Local nHyc
Local nP1
Local nP2
Local nP3
Local nP4
Local nD20

Local nD     := nDen
Local nFator := 0

Private nA1
Private nA2
Private nB1
Private nB2

// Cálculo da correção do hidrômetro
nHyc := 1 - 0.000023 * (nTemp - 20) - 0.00000002 * ((nTemp - 20) ^ 2)

TabConstan(nDen)

nP1 := (9 / 5) * (0.999042) * (nA1 + (16 * nB1) - ((8 * nA1 + 64 * nB1) * (nA2 + 16 * nB2) / (1 + 8 * nA2 + 64 * nB2)))
nP2 := (9 / 5) * ((nA2 + 16 * nB2) / (1 + 8 * nA2 + 64 * nB2))
nP3 := (81 / 25) * (0.999042) * ((nB1 - ((8 * nA1 + 64 * nB1) * nB2) / (1 + 8 * nA2 + 64 * nB2)))
nP4 := (81 / 25) * (nB2 / (1 + 8 * nA2 + 64 * nB2))

// Cálculo da densidade a vinte graus
nD20 := Round(((nD - nP1 * (nTemp - 20) - nP3 * ((nTemp - 20) ^ 2)) / (1 + nP2 * (nTemp - 20) + nP4 * ((nTemp - 20) ^ 2))) * nHyc,4)

if !(nA1 == 0 .and. nA2 == 0 .and. nB1 == 0 .and. nB2 = 0)
	nX1  := nA1
	nX2  := nA2
	nY1  := nB1
	nY2  := nB2
endif

nFator := FatCorVol(nD20,nTemp)

Return(Round(nFator,4))

/*
Programa.: FatCorVol
Autor....: Danilo José Grodzicki
Data.....: 31/05/2016 
Descricao: Função para cálculo do fator de correção de volume a vinte graus centígrados.
Uso......: AIR BP BRASIL LTDA
*/
Static Function FatCorVol(nDen,nTemp)

Local nDtq
Local nFator

TabConstan(nDen)

nP1 := (9 / 5) * (0.999042) * (nA1 + (16 * nB1) - ((8 * nA1 + 64 * nB1) * (nA2 + 16 * nB2) / (1 + 8 * nA2 + 64 * nB2)))
nP2 := (9 / 5) * ((nA2 + 16 * nB2) / (1 + 8 * nA2 + 64 * nB2))
nP3 := (81 / 25) * (0.999042) * ((nB1 - ((8 * nA1 + 64 * nB1) * nB2) / (1 + 8 * nA2 + 64 * nB2)))
nP4 := (81 / 25) * (nB2 / (1 + 8 * nA2 + 64 * nB2))

// Cálculo da densidade do tanque
nDtq := (nDen * (1 + nP2 * (nTemp - 20) + nP4 * ((nTemp - 20) ^ 2))) + nP1 * (nTemp - 20) + nP3 * ((nTemp - 20) ^ 2)

// Cálculo do fator de correção de volume
if nDen <> 0
	nFator := nDtq / nDen
else
	nFator := 0
endif

Return(nFator)

/*
Programa.: TabConstan
Autor....: Danilo José Grodzicki
Data.....: 31/05/2016 
Descricao: Tabela de constantes.
Uso......: AIR BP BRASIL LTDA
*/
Static Function TabConstan(nDen)

if nDen <= 0.498
	nA1 := -0.002462
	nA2 := 0.003215
	nB1 := -0.00001014
	nB2 := 0.00001738
elseif nDen > 0.498 .and. nDen <= 0.518
	nA1 := -0.002391
	nA2 := 0.003074
	nB1 := -0.00000841
	nB2 := 0.00001398
elseif nDen > 0.518 .and. nDen <= 0.539
	nA1 := -0.002294
	nA2 := 0.002887
	nB1 := -0.00000839
	nB2 := 0.00001387
elseif nDen > 0.539 .and. nDen <= 0.559
	nA1 := -0.002146
	nA2 := 0.002615
	nB1 := -0.00000546
	nB2 := 0.0000855
elseif nDen > 0.559 .and. nDen <= 0.579
	nA1 := -0.00192
	nA2 := 0.002214
	nB1 := -0.00000551
	nB2 := 0.00000855
elseif nDen > 0.579 .and. nDen <= 0.6
	nA1 := -0.002358
	nA2 := 0.002962
	nB1 := -0.00001225
	nB2 := 0.00002015
elseif nDen > 0.6 .and. nDen <= 0.615
	nA1 := -0.001361
	nA2 := 0.0013
	nB1 := -0.00000049
	nB2 := 0.0000006
elseif nDen > 0.615 .and. nDen <= 0.635
	nA1 := -0.001237
	nA2 := 0.0011
	nB1 := -0.00000049
	nB2 := 0.0000006
elseif nDen > 0.635 .and. nDen <= 0.655
	nA1 := -0.001077
	nA2 := 0.00085
	nB1 := -0.00000049
	nB2 := 0.0000006
elseif nDen > 0.655 .and. nDen <= 0.675
	nA1 := -0.001011
	nA2 := 0.00075
	nB1 := -0.00000049
	nB2 := 0.0000006
elseif nDen > 0.675 .and. nDen <= 0.695
	nA1 := -0.000977
	nA2 := 0.0007
	nB1 := -0.00000049
	nB2 := 0.0000006
elseif nDen > 0.695 .and. nDen <= 0.746
	nA1 := -0.001005
	nA2 := 0.00074
	nB1 := -0.00000049
	nB2 := 0.0000006
elseif nDen > 0.746 .and. nDen <= 0.766
	nA1 := -0.001238
	nA2 := 0.00105
	nB1 := -0.00000049
	nB2 := 0.0000006
elseif nDen > 0.766 .and. nDen <= 0.786
	nA1 := -0.001084
	nA2 := 0.00085
	nB1 := -0.00000049
	nB2 := 0.0000006
elseif nDen > 0.786 .and. nDen <= 0.806
	nA1 := -0.000965
	nA2 := 0.0007
	nB1 := -0.00000049
	nB2 := 0.0000006
elseif nDen > 0.806 .and. nDen <= 0.826
	nA1 := -0.0008435
	nA2 := 0.00055
	nB1 := -0.00000049
	nB2 := 0.0000006
elseif nDen > 0.826 .and. nDen <= 0.846
	nA1 := -0.000719
	nA2 := 0.0004
	nB1 := -0.00000049
	nB2 := 0.0000006
elseif nDen > 0.846 .and. nDen <= 0.871
	nA1 := -0.000617
	nA2 := 0.00028
	nB1 := -0.00000049
	nB2 := 0.0000006
elseif nDen > 0.871 .and. nDen <= 0.896
	nA1 := -0.000512
	nA2 := 0.00016
	nB1 := -0.00000049
	nB2 := 0.0000006
elseif nDen > 0.896 .and. nDen <= 0.996
	nA1 := -0.0003948
	nA2 := 0.00003
	nB1 := -0.00000049
	nB2 := 0.0000006
elseif nDen > 0.996
	nA1 := -0.0005426
	nA2 := 0.0001778
	nB1 := -0.00000231
	nB2 := 0.0000022
endif

Return Nil