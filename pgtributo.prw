#include "rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#define CRLF Chr(13)+Chr(10)

/*
+-----------------------------------------------------------------------------+
|Programa  : PGTRIBUTO                                                        |
|Descrição : Função única para o tratamento de cnab a pagar                   |
+-----------------------------------------------------------------------------+
|Autor     : TI2998 - Julio César Négri                                       |
|Observacao:                  26/09/2016                                      |
|                                                                             |
+-------------------------------------------------+--------+------------------+
|Alterado                                         |Em      | Por              |
|                                                 |DD/MM/AA|                  |
|                                                 |DD/MM/AA|                  |
|                                                 |DD/MM/AA|                  |
|                                                 |DD/MM/AA|                  |
|                                                 |DD/MM/AA|                  |
+-----------------------------------------------------------------------------+

FORNECEDORES
+----------------------+----------+
| Nome Campo           | Parametro|
+----------------------+----------+
| CODIGO AGENCIA       |   PP001  |
| VALOR PAGTO          |   PP002  |
| VALOR DESCONTO       |   PP003  |
| VALOR ACRESCIMO      |   PP004  |
| DV CODIGO DE BARRAS  |   PP005  |
| FATOR VENCTO E VALOR |   PP006  |
| CAMPO LIVRE (CODBAR) |   PP007  |
+----------------------+----------+


TRIBUTOS
+--------------------------------------------------------+----------+
| Nome Campo           								     | Parametro|
+--------------------------------------------------------+----------+
| TIPO DO IMPOSTO  	   								     |   PT000  |
| DADOS DARF / GPS / DARF SIMPLES / FGTS / IPVA / DPVAT  |   PT001  |
| CNPJ DA EMPRESA      								     |   PT002  |
+--------------------------------------------------------+----------+

CAMPOS NECESSARIOS PARA ROTINA
E2_XCODREC
E2_XVLENTI
E2_XETIDIV
E2_XPARDIV
E2_XIDEFGT
E2_XFILBEM - deletado
E2_XCODBEM - deletado
E2_XANOBAS - deletado
E2_XOPCPAG - deletado
T9_XCODMUN - Modelo 25 - IPVA SP ou 27 - DPVAT

*/
User Function PGTRIBUTO(_cOpcao)

Local  _cTipo     := ""
Local  _cRetorno  := ""
Local  _cConta     := ""
Local  _cCampo    := ""
Local  _TtAbat    := 0.00
Local  _Liqui     := 0.00
LOCAL _XCNPJC := ""
Local _aTitPai := {}
Local _aRet	 := {}
Local _cQuery	:= ""
Local _nTamFil	:= 0
Local _cRenavam := ""
Local _cUFEmpla := ""
Local _cXCodMun := ""
Local _cPlaca   := ""
Local _cCondPag := ""
Private _cTipoPag := "99"

_cTipo    := Alltrim(Upper(_cOpcao))
_XCNPJC := POSICIONE("SA2",1,XFILIAL("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_CGC")


Do Case
	
	Case _cTipo == "PP001"	//  Agencia e Conta Corrente Favorecido
		
		
		// Numero da Conta Corrente
		_cConta := strzero(val(sa2->a2_numcon),10,0)
		
		//--- Formato banco ITAU (341)
		If sa2->a2_banco == "341"
			_cRetorno := "0"+strzero(val(substr(sa2->a2_agencia,1,4)),4)+" "+"0000000"
			_cRetorno +=  STRZERO(VAL(SUBSTR(cConta,1,len(_cConta)-1)),12)+" "+ IIF(SEA->EA_MODELO $ "10/02", "0",Right(_cConta,1))
		Else
			_cRetorno := strzero(val(substr(sa2->a2_agencia,1,5)),5)+" "
			_cRetorno += strzero(val(substr(_cConta,1,12)),12)
		EndIf
		
		//--- Mensagem ALERTA
		If Empty(SA2->A2_AGENCIA) .or. Empty(_cConta)
			
			MsgAlert('Fornecedor '+alltrim(sa2->a2_cod)+"-"+alltrim(sa2->a2_loja)+" "+alltrim(sa2->a2_nome)+' sem banco/agência/conta corrente no titulo '+SE2->E2_PREFIXO+'-'+SE2->E2_NUM+'-'+SE2->E2_PARCELA+'. Atualize os dados no titulo e execute esta rotina novamente.')
			
		EndIf
		
		//--- Mensagem ALERTA
		If Empty(SA2->A2_CGC)
			
			MsgAlert('Fornecedor '+alltrim(sa2->a2_cod)+"-"+alltrim(sa2->a2_loja)+" "+alltrim(sa2->a2_nome)+' sem CNPJ no cadastro. Atualize os dados no cadastro do fornecedor e execute esta rotina novamente.')
			
		EndIf
		
	Case _cTipo == "PP002"	//  Valor Pagamento
		
		_TtAbat := 0.00
		
		//--- Funcao SOMAABAT totaliza todos os titulos com e2_tipo AB- relacionado ao
		//---        titulo do parametro
		_TtAbat   := somaabat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,'P',SE2->E2_MOEDA,DDATABASE,SE2->E2_FORNECE,SE2->E2_LOJA)
		_TtAbat   += Iif(Empty(SE2->E2_BAIXA),SE2->E2_DECRESC,0)
		_Liqui    := (SE2->E2_SALDO-_TtAbat+Iif(Empty(SE2->E2_BAIXA),SE2->E2_ACRESC,0))
		
		_cRetorno :=    StrZero(_Liqui*100,15)
		
	Case _cTipo == "PP003"	//  Valor Abatimento/Desconto
		
		If(Empty(SE2->E2_BAIXA))
           _TtAbat := SE2->E2_DECRESC
        else  
           _TtAbat := SE2->E2_VALOR - u_TAACRE(1)
		endif
		
		_cRetorno := StrZero(_TtAbat*100,15)

		//Case _cTipo == "PP004"	//  Valor Juros
				
	Case _cTipo == "PP005"	//  Digito Verificador (Codigo de Barras)
		
		If     Len(Alltrim(SE2->E2_CODBAR)) < 44       // Antiga Codificacao (Numerica)
			_cRetorno := Substr(SE2->E2_CODBAR,33,1)
		ElseIf Len(Alltrim(SE2->E2_CODBAR)) == 47      // Nova Codificacao (Numerica)
			_cRetorno := Substr(SE2->E2_CODBAR,33,1)
		Else
			_cRetorno := Substr(SE2->E2_CODBAR,5,1)   // Codificacao Cod. Barras
		EndIf
		
		If Empty(SE2->E2_CODBAR)
			
			MsgAlert("Titulo "+alltrim(se2->e2_prefixo)+"-"+alltrim(se2->e2_num)+" "+alltrim(se2->e2_parcela)+" do fornecedor "+alltrim(sa2->a2_cod)+"-"+alltrim(sa2->a2_loja)+" "+alltrim(sa2->a2_nome)+" sem código de barras. Informe o código de barras no título indicado e execute esta rotina novamente.")
			
		EndIf
		
		
	Case _cTipo == "PP006"	//  Fator de Vencimento e Valor do Titulo (Codigo de Barras)
		
		If     Len(Alltrim(SE2->E2_CODBAR)) < 44
			_cCampo := "00000000000000" //Substr(SE2->E2_CODBAR,34,5)
		ElseIf Len(Alltrim(SE2->E2_CODBAR)) == 47
			_cCampo := Substr(SE2->E2_CODBAR,34,14)
		Else
			_cCampo := Substr(SE2->E2_CODBAR,6,14)
		EndIf
		
		_cRetorno := Strzero(Val(_cCampo),14)
		
	Case _cTipo == "PP007"	//  Campo Livre (Codigo de Barras)
		
		If Len(Alltrim(SE2->E2_CODBAR)) < 44
			_cRetorno := Substr(SE2->E2_CODBAR,5,5)+Substr(SE2->E2_CODBAR,11,10)+Substr(SE2->E2_CODBAR,22,10)
		ElseIf Len(Alltrim(SE2->E2_CODBAR)) == 47
			_cRetorno := Substr(SE2->E2_CODBAR,05,05)+ Substr(SE2->E2_CODBAR,11,10)+ Substr(SE2->E2_CODBAR,22,10)
		Else
			_cRetorno := Substr(SE2->E2_CODBAR,20,25)
		EndIf
		
	Case _cTipo == "PP008"	//  Tipo de Conta para DOC (Conta Poupança)
		_cRetorno := ""
		
		If SEA->EA_MODELO=="03"
			_cRetorno := "01"
		EndIf            
		
		
	Case _cTipo == "PP009"	//  Modelo de pagamento (EA_MODELO) para segmento J - titulos com CODBAR  
							//  Modelo de pagamento (EA_MODELO) para segmento O - concessionarias ou DARF com codbar
		
		If 	alltrim(SEA->EA_MODELO) 	$ 	"13#30#31"
			_cTipoPag	:=	"20"
		Else
			_cTipoPag	:=	"22"
		EndIf		
	    
		SEA->EA_TIPOPAG	:=	_cTipoPag
		_cRetorno		:= _cTipoPag


	Case _cTipo == "PP010"	//  Modelo de pagamento (EA_MODELO) para segmento J - titulos com CODBAR  
							//  Modelo de pagamento (EA_MODELO) para segmento O - concessionarias ou DARF com codbar
		 
		If	alltrim(SEA->EA_TIPOPAG)	==	"22"
			_cRetorno	:=	alltrim(SEA->EA_MODELO)
		ElseIf	Substr(SE2->E2_CODBAR,1,3)	==	"341"
					_cRetorno	:=	"30"
			Else 
					_cRetorno	:=	"31"
		EndIf   
	    
			
	Case _cTipo == "PT000"
		
		_cRetorno := ""
		
		//  Dados DARF
		If SEA->EA_MODELO == "16"        // Posicao 018 a 019: Identificacao do Tributo 02-Darf Normal
			_cRetorno := "02"
		ElseIf (SEA->EA_MODELO == "17")  // Posicao 018 a 019: Identificacao do Tributo 01-GPS
			_cRetorno := "01"
		ElseIf  SEA->EA_MODELO == "18"   // Posicao 018 a 019: Identificacao do Tributo 03-Darf Simples
			_cRetorno := "03"
		ElseIf SEA->EA_MODELO == "22"    // Posicao 018 a 019: Identificacao do Tributo 05-ICMS
			_cRetorno := "05"
		ElseIf SEA->EA_MODELO == "35"    // Posicao 018 a 019: Identificacao do Tributo 11-FGTS-GFIP
			_cRetorno := "11"
		ElseIf SEA->EA_MODELO == "25"  .or. SEA->EA_MODELO == "26" .or. SEA->EA_MODELO == "27"  //--- Posicao 018 a 019: Identificacao do Tributo  07-IPVA e 08-DPVAT
			_cRetorno := If(SEA->EA_MODELO=="25","07","08")
		EndIf

	Case _cTipo == "TRIB"
		_cRetorno := ""
		//  Dados DARF
		If SEA->EA_MODELO == "16"
			// Posicao 020 a 023: Codigo da Receita
			_cRetorno += STRZERO(Val(SE2->E2_CODRET),4)
			// Posicao 024 a 024: Tp Inscricao  1-CPF /  2-CNPJ
//			If !Empty(_XCNPJC)
//				_cRetorno += Iif (len(alltrim(_XCNPJC))>11,"2","1")
//			Else
				_cRetorno += "2"
//			EndIf
			// Posicao 025 a 038: N Inscricao  //--- CNPJ/CPF do Contribuinte
			//			Ajuste da obtenção do CNPJ para DARF - 03/12/2011
			//            If !Empty(_XCNPJC)
			//               _cRetorno += Strzero(Val(_XCNPJC),14)
			//            Else
			//_cRetorno += Iif(Left(SM0->M0_CODFIL,2)=="13", "60792405000131",Left(SM0->M0_CGC,14))
/*			Do Case
				Case Left(SM0->M0_CODFIL,2)=="01"
					_cRetorno += "43244631000169"
				Case Left(SM0->M0_CODFIL,2)=="03"
					_cRetorno += "64740483000143"
				Case Left(SM0->M0_CODFIL,2)=="05"
					_cRetorno += "03781657000121"
				Case Left(SM0->M0_CODFIL,2)=="13"
					_cRetorno += "60792405000131"
				Case Left(SM0->M0_CODFIL,2)=="14"
					_cRetorno += "06998735000132"
				Otherwise
					_cRetorno += Left(SM0->M0_CGC,14)
			EndCase
*/
			_cRetorno += Left(SM0->M0_CGC,14)
			
			// Posicao 039 a 046: Periodo Apuracao
			_cRetorno += GravaData(SE2->E2_XAPURAC,.F.,5)
			
			// Posicao 047 a 063: Referencia
			_cRetorno +=  REPLICATE("0",17) //Strzero(Val(SE2->E2_XREFER),17)
			
			// Posicao 064 a 077: Valor Principal
			_cRetorno += Strzero(SE2->E2_SALDO*100,14)
			
			// Posicao 078 a 091: Multa
			_cRetorno += STRZERO(SE2->E2_MULTA*100,14)
			
			// Posicao 092 a 105: Juros
			_cRetorno += Strzero((SE2->E2_JUROS+Iif(Empty(SE2->E2_BAIXA),SE2->E2_ACRESC,0))*100,14)
			
			// Posicao 106 a 119: Valor Total (Principal + Multa + Juros)
			// *** Comentado Charbel - 27/09/11 - Avaliar a utilizacao dos campos E2_XMULTA / E2_E_JUROS
			//_cRetorno += STRZERO((SE2->E2_SALDO+SE2->E2_XMULTA+SE2->E2_E_JUROS)*100,14)
			_cRetorno += STRZERO((SE2->E2_SALDO+Iif(Empty(SE2->E2_BAIXA),SE2->E2_ACRESC,0)+SE2->E2_JUROS)*100,14)
			
			// Posicao 120 a 127: Data Vencimento
			_cRetorno += GravaData(SE2->E2_VENCTO,.F.,5)
			
			// Posicao 128 a 135: Data Pagamento
			_cRetorno += GravaData(SE2->E2_VENCREA,.F.,5)
			
			// Posicao 136 a 165: Compl.Registro
			_cRetorno += Space(30)
			
			// Posicao 166 a 195: Nome do Contribuinte
//			If !Empty(_XCNPJC)
//				_cRetorno += Subs(ALLTRIM(SA2->A2_NOME),1,30)
//				If Empty(SA2->A2_NOME)
//					MsgAlert('Nome do Contribuinte não informado para a DARF - Titulo '+alltrim(se2->e2_prefixo)+"-"+alltrim(se2->e2_num)+"-"+alltrim(se2->e2_parcela)+'. Atualize o Nome do Contribuinte no titulo indicado e execute esta rotina novamente.')
//				EndIf
//			Else
				_cRetorno += Subs(SM0->M0_NOMECOM,1,30)
//			EndIf
			
			//--- Mensagem ALERTA que está sem periodo de apuração
			If Empty(SE2->E2_XAPURAC)
				
				MsgAlert('Tributo sem Data de Apuracao. Informe o campo Apuracao no titulo: '+alltrim(se2->e2_prefixo)+" "+alltrim(se2->e2_num)+" "+alltrim(se2->e2_parcela)+" Tipo: "+alltrim(se2->e2_tipo)+" Fornecedor/Loja: "+alltrim(se2->e2_fornece)+"-"+alltrim(se2->e2_loja)+' e execute esta rotina novamente.')
				
			EndIf
			
			// Dados GPS
		ElseIf (SEA->EA_MODELO == "17")
			
			// Linhas abaixo foram habilitadas por causa do ajuste feito em 03/11/2011 - Trazer CNPJ/CPF do Fornecedor do Título Pai

            msgalert("retirar as linhas 333, 334 e 335 do fonte PAGAR341.prw antes de colocar em produção")
		
			RecLock("SE2",.f.)
				SE2->E2_TITPAI := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) 
			MsUnlock()
				
			_aTitPai := GetAdvFVal("SE2",{"E2_FORNECE","E2_LOJA"},xFilial("SE2")+SE2->E2_TITPAI,1,{" "," "})
			_aRet    := GetAdvFVal("SA2",{"A2_CGC","A2_NOME"},xFilial("SA2")+_aTitPai[1]+_aTitPai[2],1,{" "," "})
			
			// Posicao 020 a 023: Codigo Pagamento
//			_cRetorno +=  STRZERO(Val(SE2->E2_XCODREC),4)
			_cRetorno +=  STRZERO(Val(SE2->E2_CODRET),4)
						
			// Posicao 024 a 029: Competencia   MMAAAA
			_cRetorno += STRZERO(MONTH(SE2->E2_XAPURAC),2)+STRZERO(YEAR(SE2->E2_XAPURAC),4)
			
			// Posicao 030 a 043: N Identificacao  //--- CNPJ/CPF do Contribuinte
			//            Linhas abaixo foram desabilitadas por causa do ajuste feito em 03/11/2011
			//            If !Empty(_XCNPJC)
			//               _cRetorno += Strzero(Val(_XCNPJC),14)
			//           Else
			//                _cRetorno += Strzero(Val(SM0->M0_CGC),14)
			//           EndIf           (FIM)
			// Linha abaixo foi habilitada por causa do ajuste feito em 03/11/2011 - Trazer CNPJ/CPF do Fornecedor do Título Pai
			_cRetorno += Left( _aRet[1], 14 )
			
			// Posicao 044 a 057: Valor Principal (Valor Titulo - Outras Entidades)
			_cRetorno += Strzero((SE2->E2_SALDO-SE2->E2_XVLENTI)*100,14)
			
			// Posicao 058 a 071: Valor Outras Entidades
			_cRetorno += Strzero(SE2->E2_XVLENTI*100,14)
			
			// Posicao 072 a 085: Multa
			//_cRetorno += Strzero(SE2->E2_MULTA+SE2->E2_JUROS*100,14)
			_cRetorno += Strzero((SE2->E2_MULTA+SE2->E2_JUROS+Iif(Empty(SE2->E2_BAIXA),SE2->E2_ACRESC,0))*100,14)
			
			// Posicao 086 a 099: Valor Total (Principal + Multa)
			_cRetorno += Strzero((SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS+Iif(Empty(SE2->E2_BAIXA),SE2->E2_ACRESC,0))*100,14)
			
			// Posicao 100 a 107: Data Vencimento
			_cRetorno += GravaData(SE2->E2_VENCREA,.F.,5)
			
			// Posicao 108 a 115: Compl.Registro
			_cRetorno += Space(8)
			
			// Posicao 116 a 165: Informacoes Complementares
			_cRetorno += Space(50)
			
			// Posicao 166 a 195: Nome do Contribuinte
			//            Linhas abaixo foram desabilitadas por causa do ajuste feito em 03/11/2011
			//            If !Empty(_XCNPJC)
			//               _cRetorno += Subs(ALLTRIM(SA2->A2_NOME),1,30)
			//               If Empty(SA2->A2_NOME)
			//                  MsgAlert('Nome do Contribuinte não informado para a GPS - Titulo '+alltrim(se2->e2_prefixo)+"-"+alltrim(se2->e2_num)+"-"+alltrim(se2->e2_parcela)+'. Atualize o Nome do Contribuinte no titulo indicado e execute esta rotina novamente.')
			//               EndIf
			//            Else
			//               _cRetorno += Subs(SM0->M0_NOMECOM,1,30)
			//            EndIf
			// Linha abaixo foi habilitada por causa do ajuste feito em 03/11/2011 - Trazer CNPJ/CPF do Fornecedor do Título Pai
			_cRetorno += Left( _aRet[2] , 30)
			
			//--- Mensagem ALERTA que está sem periodo de apuração
			If Empty(se2->E2_XAPURAC)
				
				MsgAlert('Tributo sem Competencia. Informe o campo Apuração no titulo: '+alltrim(se2->e2_prefixo)+" "+alltrim(se2->e2_num)+" "+alltrim(se2->e2_parcela)+" Tipo: "+alltrim(se2->e2_tipo)+" Fornecedor/Loja: "+alltrim(se2->e2_fornece)+"-"+alltrim(se2->e2_loja)+' e execute esta rotina novamente.')
				
			EndIf
			
			//----- DARF SIMPLES
		ElseIf  SEA->EA_MODELO == "18"
			
			// Posicao 020 a 023: Codigo da Receita  - Para DARF Simples - fixar código 6106
			_cRetorno += "6106"
			
			// Posicao 024 a 024: Tp Inscricao  1-CPF /  2-CNPJ
			If !Empty(_XCNPJC)
				_cRetorno += Iif (len(alltrim(_XCNPJC))>11,"2","1")
			Else
				_cRetorno += "2"
			EndIf
			
			// Posicao 025 a 038: N Inscricao  //--- CNPJ/CPF do Contribuinte
			If !Empty(_XCNPJC)
				_cRetorno += Strzero(Val(_XCNPJC),14)
			Else
				_cRetorno += Subs(SM0->M0_CGC,1,14)
			EndIf
			
			// Posicao 039 a 046: Periodo Apuracao
			_cRetorno += GravaData(SE2->E2_XAPURAC,.F.,5)
			
			// Posicao 047 a 055: Valor da Receita Bruta Acumulada
			_cRetorno += REPLICATE("0",9)
			
			// Posicao 056 a 059: % sobre a Receita Bruta Acumulada
			_cRetorno += REPLICATE("0",4)
			
			// Posicao 060 a 063: Compl.Registro
			_cRetorno += Space(4)
			
			// Posicao 064 a 077: Valor Principal
			_cRetorno += Strzero(SE2->E2_SALDO*100,14)
			
			// Posicao 078 a 091: Multa
			_cRetorno += STRZERO(SE2->E2_MULTA*100,14)
			
			// Posicao 092 a 105: Juros
			_cRetorno += STRZERO((SE2->E2_JUROS+Iif(Empty(SE2->E2_BAIXA),SE2->E2_ACRESC,0))*100,14)
			
			// Posicao 106 a 119: Valor Total (Principal + Multa + Juros)
			_cRetorno += STRZERO((SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS+Iif(Empty(SE2->E2_BAIXA),SE2->E2_ACRESC,0))*100,14)
			
			// Posicao 120 a 127: Data Vencimento
			_cRetorno += GravaData(SE2->E2_VENCTO,.F.,5)
			
			// Posicao 128 a 135: Data Pagamento
			_cRetorno += GravaData(SE2->E2_VENCREA,.F.,5)
			
			// Posicao 136 a 165: Compl.Registro
			_cRetorno += Space(30)
			
			// Posicao 166 a 195: Nome do Contribuinte
			If !Empty(SA2->A2_NOME)
				_cRetorno += Subs(SA2->A2_NOME,1,30)
				If Empty(SA2->A2_NOME)
					MsgAlert('Nome do Contribuinte não informado para a DARF Simples - Titulo '+alltrim(se2->e2_prefixo)+"-"+alltrim(se2->e2_num)+"-"+alltrim(se2->e2_parcela)+'. Atualize o Nome do Contribuinte no titulo indicado e execute esta rotina novamente.')
				EndIf
			Else
				_cRetorno += Subs(SM0->M0_NOMECOM,1,30)
			EndIf
			
			//--- Mensagem ALERTA que está sem periodo de apuração
			If Empty(se2->E2_XAPURAC)
				
				MsgAlert('Tributo sem Data de Apuracao. Informe o campo Apuracao no titulo: '+alltrim(se2->e2_prefixo)+" "+alltrim(se2->e2_num)+" "+alltrim(se2->e2_parcela)+" Tipo: "+alltrim(se2->e2_tipo)+" Fornecedor/Loja: "+alltrim(se2->e2_fornece)+"-"+alltrim(se2->e2_loja)+' e execute esta rotina novamente.')
				
			EndIf
			
		//  Dados DARJ
		ElseIf SEA->EA_MODELO == "21"
			// Posicao 020 a 023: Codigo da Receita
			//_cRetorno += If(!Empty(SE2->E2_XCODREC),STRZERO(Val(SE2->E2_XCODREC),4),STRZERO(Val(SE2->E2_CODRET),4))
			_cRetorno += STRZERO(Val(SE2->E2_CODRET),4)
						
			// Posicao 024 a 024: Tp Inscricao  1-CPF /  2-CNPJ
//			If !Empty(_XCNPJC)
//				_cRetorno += Iif (len(alltrim(_XCNPJC))>11,"2","1")
//			Else
				_cRetorno += "2"
//			EndIf
			
			// Posicao 025 a 038: N Inscricao  //--- CNPJ/CPF do Contribuinte
			_cRetorno += Left(GetAdvFVal("SM0","M0_CGC","01"+SE2->E2_FILORIG,1," "),14)
			
			// Posicao 039 a 046: Periodo Apuracao
//			_cRetorno += GravaData(SE2->E2_APURAC,.F.,5)
			// Posicao 039 a 046: Inscricao Estadual
			_cRetorno += Left(GetAdvFVal("SM0","M0_INSC","01"+SE2->E2_FILORIG,1," "),14)
			
			// Posicao 047 a 062: Numero do Documento Origem  
			//_cRetorno += Strzero(Val(SE2->E2_NUM),16)
                        // ALTERADO CHARBEL 26/12/11
			//_cRetorno += SPACE(16)
			
			// Posicao 063 a 063: Complemento de Registro - BRANCO
			_cRetorno +=  " "
			
			// Posicao 064 a 077: Valor Principal
			_cRetorno += Strzero(SE2->E2_SALDO*100,14)
			
			// Posicao 078 a 091: Atualizacao Monetaria
			_cRetorno += REPLICATE("0",14)
			
			// Posicao 092 a 105: Juros
			_cRetorno += Strzero(SE2->E2_JUROS*100,14)
			
			// Posicao 106 a 119: Multa
			_cRetorno += STRZERO(Iif(Empty(SE2->E2_BAIXA),SE2->E2_ACRESC,0)*100,14)
			
			// Posicao 120 a 133: Valor Total a Recolher (Principal + Multa + Juros)
			_cRetorno += STRZERO((SE2->E2_SALDO+Iif(Empty(SE2->E2_BAIXA),SE2->E2_ACRESC,0))*100,14)
			
			// Posicao 134 a 141: Data Vencimento
			_cRetorno += GravaData(SE2->E2_VENCTO,.F.,5)
			
			// Posicao 142 a 149: Data Pagamento
			_cRetorno += GravaData(SE2->E2_VENCREA,.F.,5)
			
			// Posicao 150 a 155: Periodo - Parcela
			//_cRetorno += STRZERO(VAL(SE2->E2_PARCELA),6)
                        // ALTERADO CHARBEL 26/12/11
			_cRetorno += Strzero(Month(SE2->E2_XAPURAC),2)+Strzero(Year(SE2->E2_XAPURAC),4)
			
			// Posicao 156 a 165: Compl.Registro
			_cRetorno += Space(10)
			
			// Posicao 166 a 195: Nome do Contribuinte        
//			If !Empty(_XCNPJC)
//				_cRetorno += Subs(ALLTRIM(SA2->A2_NOME),1,30)
//				If Empty(SA2->A2_NOME)
//					MsgAlert('Nome do Contribuinte não informado para a DARJ - Titulo '+alltrim(se2->e2_prefixo)+"-"+alltrim(se2->e2_num)+"-"+alltrim(se2->e2_parcela)+'. Atualize o Nome do Contribuinte no titulo indicado e execute esta rotina novamente.')
//				EndIf
//			Else
//				_cRetorno += Subs(SM0->M0_NOMECOM,1,30)
				_cRetorno += Left(GetAdvFVal("SM0","M0_NOMECOM","01"+SE2->E2_FILORIG,1," "),30)

//			EndIf
			
			//--- Mensagem ALERTA que está sem periodo de apuração
			If Empty(SE2->E2_XAPURAC)
				MsgAlert('Tributo sem Data de Apuracao. Informe o campo Apuracao no titulo: '+alltrim(se2->e2_prefixo)+" "+alltrim(se2->e2_num)+" "+alltrim(se2->e2_parcela)+" Tipo: "+alltrim(se2->e2_tipo)+" Fornecedor/Loja: "+alltrim(se2->e2_fornece)+"-"+alltrim(se2->e2_loja)+' e execute esta rotina novamente.')
			EndIf
			
			//--- GARE ICMS SP
		ElseIf SEA->EA_MODELO == "22" //--- GARE ICMS - SP
			
			// Posicao 111 a 116: Codigo da Receita
			_cRetorno +=  "  " + STRZERO(Val(SE2->E2_XCODREC),4)
			
			// Posicao 117 a 118: Tp Inscricao  01-CPF / 02-CNPJ
			_cRetorno += "02"
			
			// Posicao 119 a 132: N Inscricao  //--- CNPJ/CPF do Contribuinte
//			_cRetorno += Left(GetAdvFVal("SM0","M0_CGC","01"+SE2->E2_FILORIG,1," "),14)
  			_cRetorno += Left(SM0->M0_CGC,14)
  						
			//--- Posicao 133 a 134: Codigo identificação do tributo -
//			_cRetorno += LEFT(GetAdvFVal("SM0","M0_INSC","01"+SE2->E2_FILORIG,1," "),12)
//			_cRetorno += Left(SM0->M0_INSC,12)
			_cRetorno += "22"
						
			//--- Posicao 135 a 142: Data de vencimento
			_cRetorno +=  GRAVADATA(SE2->E2_VENCREA,.F.,5)
			
			//--- Posicao 143 a 154: Insc Estadual / Cod Municipio / Num Declaracao
			_cRetorno += Left(SM0->M0_INSC,12) 
			
			//--- Posicao 155 a 167: Divida Ativa / Etiqueta
			_cRetorno +=  Strzero(SE2->E2_XETIDIV,13)

			//--- Posicao 168 a 173: Periodo de Referencia (Mes/Ano)  Formato MMAAAA
			_cRetorno += Strzero(Month(SE2->E2_XAPURAC),2)+Strzero(Year(SE2->E2_XAPURAC),4)
			
			//--- Posicao 174 a 186: N. Parcela / Notificação
			_cRetorno +=  Strzero(SE2->E2_XPARDIV,13)			
			
			//--- Posicao 187 a 201: Valor da Receita (Principal)
			_cRetorno += Strzero(SE2->E2_SALDO*100,14)
			
			//--- Posicao 202 a 215: Valor Juros/Encargos
			_cRetorno += Strzero((SE2->E2_JUROS+Iif(Empty(SE2->E2_BAIXA),SE2->E2_ACRESC,0))*100,14)
			
			//--- Posicao 216 a 229: Valor da Multa
			_cRetorno += Strzero(SE2->E2_MULTA*100,14)
			
			//--- Posicao 230 a 230: Brancos
			_cRetorno += Space(1)
			

			//--- 25 - IPVA SP
			//--- 27 - DPVAT
		ElseIf SEA->EA_MODELO == "25"  .or. SEA->EA_MODELO == "27"
			
			//--- Posicao 020 a 023 - Brancos
			_cRetorno += Space(4)
			
			// Posicao 024 a 024: Tp Inscricao  1-CPF /  2-CNPJ
			_cRetorno += "2"
			
			
			// Posicao 025 a 038: N Inscricao  //--- CNPJ/CPF do Contribuinte
			_cRetorno += Subs(SM0->M0_CGC,1,14)
			
			
			//--- Posicao 039 a 042 - Exercicio Ano Base
			_cRetorno += Strzero(Year(SE2->E2_VENCTO),4)
			
			//--- Posicao 043 a 051 - Renavam
			_cRetorno +=  _cRenavam
			
			//--- Posicao 052 a 053 - Unidade Federação
			_cRetorno +=  _cUFEmpla
			
			//--- Posicao 054 a 058 - Codigo do Municipio
			_cRetorno += _cXCodMun
			
			//--- Posicao 059 a 065 - Placa
			_cRetorno += _cPlaca
			
			//--- Posicao 066 a 066 - Opção de Pagamento - Para DPVAT sempre opção 0
			If SEA->EA_MODELO == "25"
				_cRetorno += _cCondPag
			Else
				_cRetorno += "0"   //--- Para 27-DPVAT e 26-Licenciamento é obrigatório utilizar o código 0.
			EndIf
			
			//--- Posicao 067 a 080 - Valor do IPVA/DPVAT
			_cRetorno += Strzero((SE2->E2_SALDO+Iif(Empty(SE2->E2_BAIXA),SE2->E2_ACRESC,0))*100,14)
			
			//--- Posicao 081 a 094 - Valor do Desconto
			_cRetorno += Strzero(Iif(Empty(SE2->E2_BAIXA),SE2->E2_DECRESC,0)*100,14)
			
			//--- Posicao 095 a 108 - Valor do Pagamento
			_cRetorno += Strzero((SE2->E2_SALDO+Iif(Empty(SE2->E2_BAIXA),SE2->E2_ACRESC,0)-Iif(Empty(SE2->E2_BAIXA),SE2->E2_DECRESC,0))*100,14)
			
			//--- Posicao 109 a 116: Data de Vencimento   Formato DDMMAAAA
			_cRetorno += Gravadata(SE2->E2_VENCTO,.F.,5)
			
			//--- Posicao 117 a 124: Data de Pagamento-  Formato DDMMAAAA
			_cRetorno += Gravadata(SE2->E2_VENCREA,.F.,5)
			
			//--- Posicao 125 a 165: Brancos
			_cRetorno += Space(41)
			
			//--- Posicao 166 a 195: Nome do Contribuinte
			
			_cRetorno += Subs(SM0->M0_NOMECOM,1,30)
			
			
			//--- 35 - FGTS
		ElseIf SEA->EA_MODELO == "35"
			
			// Posicao 177 a 178: Codigo da Receita
			_cRetorno +=  "01"
			
			// Posicao 179 a 184: Codigo da Receita
			_cRetorno +=  STRZERO(Val(SE2->E2_XCODREC),4)
//			_cRetorno +=  STRZERO(Val(SE2->E2_CODRET),4)			
			
			// Posicao 185 a 186: Tp Inscricao  1-CPF /  2-CNPJ
			_cRetorno += "2"
						
			// Posicao 187 a 200: N Inscricao  //--- CNPJ/CPF do Contribuinte
			//If !Empty(_XCNPJC)
			//   _cRetorno += Strzero(Val(_XCNPJC),14)
			//Else
			_cRetorno += Subs(SM0->M0_CGC,1,14)
			//EndIf
			
			// Posicao 039 a 086: Codigo de Barras
//			_cRetorno += SE2->E2_CODBAR
//			_cRetorno += SE2->E2_LINDIG
			
			// Posicao 201 a 216: Identificador do FGTS
			_cRetorno += Strzero(SE2->E2_XIDEFGT,16)
			
			// Posicao 217 a 225: Lacre de Conectividade Social
			_cRetorno += REPLICATE("0",9)//Strzero(Val(SE2->E2_LACRE),9)
			
			// Posicao 226 a 227: Digito do Lacre de Conectividade Social
			_cRetorno += REPLICATE("0",2) //Strzero(Val(SE2->E2_DGLACR),2)
			
			// Posicao 114 a 143: Nome do Contribuinte
			//If !Empty(_XCNPJC)
			//_cRetorno += Subs(SA2->A2_NOME,1,30)
			//If Empty(SA2->A2_NOME)
			//   MsgAlert('Nome do Contribuinte não informado para o FGTS - Titulo '+alltrim(se2->e2_prefixo)+"-"+alltrim(se2->e2_num)+"-"+alltrim(se2->e2_parcela)+'. Atualize o Nome do Contribuinte no titulo indicado e execute esta rotina novamente.')
			//EndIf
			//Else
//			_cRetorno += Subs(SM0->M0_NOMECOM,1,30)
//			_cRetorno += Iif(SE2->E2_NATUREZ=="FOL0000009",Left(SM0->M0_NOMECOM,30),Left(GetAdvFVal("SM0","M0_NOMECOM","01"+SE2->E2_FILORIG,1," "),30))
			//EndIf
			
			// Posicao 144 a 151: Data Pagamento
			_cRetorno += GravaData(SE2->E2_VENCREA,.F.,5)
			
			// Posicao 152 a 165: Valor do Pagamento
			// *** Comentado Charbel - 27/09/11 - Avaliar a utilizacao dos campos E2_XMULTA / E2_E_JUROS
			//_cRetorno += STRZERO((SE2->E2_SALDO+SE2->E2_XMULTA+SE2->E2_E_JUROS-SE2->E2_DECRESC)*100,14)
			_cRetorno += STRZERO((SE2->E2_SALDO-Iif(Empty(SE2->E2_BAIXA),SE2->E2_DECRESC,0))*100,14)
			
			// Posicao 166 a 195: Compl.Registro
			_cRetorno += Space(30)
			
		EndIf

/*    
	Case _cTipo == "IDTRIB"
		_cRetorno := ""
		If SEA->EA_MODELO == "16"      // DARF
			// Posicao 018 a 019: Identificacao do Tributo 02-Darf 03-Darf Simples
			_cRetorno := "02"
		ElseIf SEA->EA_MODELO == "17"  // GPS
			_cRetorno := "01"
		ElseIf SEA->EA_MODELO == "18"  // DARF SIMPLES
			_cRetorno := "03"
		ElseIf SEA->EA_MODELO == "21"  // DARJ
			_cRetorno := "04"
		ElseIf SEA->EA_MODELO == "22" //--- GARE ICMS - SP
			_cRetorno := "05"
		ElseIf SEA->EA_MODELO == "25"  .or. SEA->EA_MODELO == "27"  // 25 - IPVA SP - 27 - DPVAT
			_cQuery := "SELECT T9_RENAVAM, T9_UFEMPLA, T9_XCODMUN, T9_PLACA, TS1_CONPAG " + CRLF
			_cQuery += "FROM " + CRLF
			_cQuery += RetSqlName("TS1")+" TS1, " + CRLF
			_cQuery += RetSqlName("ST9")+" ST9 " + CRLF
			_cQuery += "WHERE 1=1 " + CRLF
			_nTamFil := Len(AllTrim(SE2->E2_FILIAL))
			_cQuery += Iif(_nTamFil>0,"AND SUBSTR(TS1.TS1_FILIAL,1,"+AllTrim(Str(_nTamFil))+") = '"+AllTrim(SE2->E2_FILIAL)+"' ","") + CRLF
			_cQuery += "AND TS1.TS1_PREFIX = '"+Trim(SE2->E2_PREFIXO)+"' " + CRLF
			_cQuery += "AND TS1.TS1_NUMSE2 = '"+Trim(SE2->E2_NUM)+"' " + CRLF
			_cQuery += "AND TS1.TS1_FORNEC = '"+Trim(SE2->E2_FORNECE)+"' " + CRLF
			_cQuery += "AND TS1.TS1_LOJA = '"+Trim(SE2->E2_LOJA)+"' " + CRLF
			_cQuery += "AND TS1.TS1_TIPO = '"+Trim(SE2->E2_TIPO)+"' " + CRLF
			_cQuery += "AND TS1.TS1_DTVENC = '"+DtoS(SE2->E2_VENCTO)+"' " + CRLF
			_cQuery += "AND ST9.T9_FILIAL = TS1.TS1_FILIAL " + CRLF
			_cQuery += "AND ST9.T9_CODBEM = TS1.TS1_CODBEM " + CRLF
			_cQuery += "AND ST9.T9_PLACA = TS1.TS1_PLACA "   + CRLF
			_cQuery += "AND TS1.D_E_L_E_T_=' ' " + CRLF
			_cQuery += "AND ST9.D_E_L_E_T_=' ' " + CRLF
			Memowrite("IPVASISP.sql",_cQuery)
			_cQuery := ChangeQuery(_cQuery)

			If Select("TRB")>0
				TRB->(dbCloseArea())
			Endif

			dbUseArea(.T., 'TOPCONN', TCGenQry(,,_cQuery),"TRB", .F., .T.)
			
			TRB->(DbGoTop())
			If !TRB->(Eof())
				_cRenavam := StrZero(Val(TRB->T9_RENAVAM),9)
				_cUFEmpla := Upper(TRB->T9_UFEMPLA)
				_cXCodMun := StrZero(Val(TRB->T9_XCODMUN),5)
				_cPlaca   := Left(TRB->T9_PLACA,7)
				_cCondPag := Iif(SEA->EA_MODELO="27","0",AllTrim(Str(Val(SE2->E2_PARCELA)+2)))
			EndIf

			If Select("TRB")>0
				TRB->(dbCloseArea())
			Endif
			
			_cRetorno := If(SEA->EA_MODELO=="25","07","08")

		ElseIf _cTipo == "35"  // FGTS
			_cRetorno := "11"
		EndIf

*/	
		
/*
	Case _cTipo == "PT002"
		
/*		Do Case
			Case Left(SM0->M0_CODFIL,2)=="01"
				_cRetorno := "43244631000169"
			Case Left(SM0->M0_CODFIL,2)=="03"
				_cRetorno := "64740483000143"
			Case Left(SM0->M0_CODFIL,2)=="05"
				_cRetorno := "03781657000121"
			Case Left(SM0->M0_CODFIL,2)=="13"
				_cRetorno := "60792405000131"
			Case Left(SM0->M0_CODFIL,2)=="14"
				_cRetorno := "06998735000132"
			Otherwise
				_cRetorno := Left(SM0->M0_CGC,14)
		EndCase
*/

//				_cRetorno := Left(SM0->M0_CGC,14)
						
	Otherwise  //  Parametro não existente
		
		MsgAlert('Não foi encontrado o Parametro '+ _cTipo + "."+;
		'Solicite à informática para verificar o fonte PAGAR341, ou o arquivo de configuração do CNAB.')
		
EndCase


return(_cRetorno)
