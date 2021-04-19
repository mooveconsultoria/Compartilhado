#Include 'Protheus.ch'

/*
Programa.: FA740BRW
Autor....: Danilo José Grodzicki
Data.....: 08/09/2016 
Descricao: O ponto de entrada FA740BRW foi desenvolvido para adicionar itens no menu da mBrowse.
           Retorna array com os novas opções e manda como parâmetro o array com as opções padrão.
Uso......: AIR BP BRASIL LTDA
*/
User Function FA740BRW()

Local aBotao := {}

aadd(aBotao, {"Impressão Boleto Fatura","U_RFATA013(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, , .F.)", 0 , 3})

Return(aBotao)