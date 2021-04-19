#include "rwmake.ch"
User Function FA280()
SetPrvt("aArea")
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � FA280    � Autor � jMarcelino		� Data � 24.08.2017   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋escri噭o � ajusta campo E1_TXMOEDA com conte鷇o dos t韙ulos originais 罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � Air BP 			               		                      罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
aArea := GetArea()
If nMoedFat <> 1
	cFatura := SE1->E1_NUM
	
	//  buscar titulos aglutinados por fatura
	cQuery := "SELECT E1_FILIAL, E1_NUM, E1_PREFIXO, E1_CLIENTE, E1_LOJA, E1_PARCELA, E1_TIPO, E1_EMISSAO, E1_VENCREA, E1_MOEDA, E1_TXMOEDA
	cQuery += "FROM "+RetSqlName("SE1")+" SE1
	cQuery += "WHERE SE1.E1_FATURA = '"+cFatura+"' "
	cQuery += "AND   SE1.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery( cQuery )
	
	If Select("TRB") > 0
		TRB->(dbClosearea())
	Endif
	dbUseArea( .t., "TopConn", TCGenQry(,,cQuery),"TRB", .F., .F. )
	
	dbSelectArea("TRB")
	dbGoTop()
	nTaxa := 0
	lFlgGrv := .F.
	While !Eof()
		If TRB->E1_MOEDA <> 1
			dDataTitulo := StoD(TRB->E1_EMISSAO)
			
			dbSelectArea("SM2")
			dbSeek(dDataTitulo)
			nTaxa := SM2->M2_MOEDA2
			
			If !Empty(nTaxa)
				lFlgGrv := .T.
				Exit
			EndIf
		EndIf
		
		dbSelectArea("TRB")
		TRB->(dbSkip())
	EndDo
	
	If lFlgGrv
		RecLock("SE1",.F.)
		SE1->E1_TXMOEDA := nTaxa
		MsUnlock()
	EndIf
EndIf

RestArea(aArea)

Return Nil
