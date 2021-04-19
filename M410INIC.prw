#Include 'Protheus.ch'

/*
Programa.: M410INIC
Autor....: Danilo José Grodzicki
Data.....: 02/11/2017 
Descricao: Este ponto de entrada é chamado antes da abertura da tela de inclusão do pedido de vendas com o objetivo de permitir a validação do usuário. 
Uso......: AIR BP BRASIL LTDA
*/
User Function M410INIC()

if !U_ZA5TRAVA("SC5")
	Help( ,, 'Trava de Estoque',, 'Filial temporariamente não autorizada a lançar Pedido de Venda.', 1, 0 )
endif

Return Nil