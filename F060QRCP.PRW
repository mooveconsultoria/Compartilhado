
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
// este ponto de entrada tratará a inclusão do campo A1_EST na tela de seleção.

/*
Programa.: F060QRCP
Autor....: Julio César Négri
Data.....: 18/05/2017 
Descricao: Filtro na geração do borderô a receber. Tratamento para que só sejam visualizados títulos com E1_NUMBCO <> vazio
Uso......: AIR BP BRASIL LTDA
*/

USER FUNCTION F060QRCP()
Local aStru 	:= {}
Local cQuery	:= ""
Local nj		:= 0
Local cQryOri	:= PARAMIXB[1]  
// query padrão do sistema

aStru := dbStruct()

cQuery := "SELECT "
For nj:= 1 to Len(aStru)	
	cQuery += aStru[nj,1]+", "
Next

cQuery += "SE1.R_E_C_N_O_ RECNO , A1_EST"
cQuery += "  FROM "+	RetSqlName("SE1") + " SE1 "
cQuery += "  INNER JOIN "+	RetSqlName('SA1') + " SA1 ON E1_CLIENTE = SA1.A1_COD AND E1_LOJA = SA1.A1_LOJA "
cQuery += " WHERE E1_NUMBOR = '      '"
cQuery += "   AND E1_NUMBCO <> ''"
cQuery += "   AND E1_EMISSAO Between '" + DTOS(dEmisDe) + "' AND '" + DTOS(dEmisAte) + "'"
cQuery += "   AND E1_CLIENTE between '" + cCliDe        + "' AND '" + cCliAte        + "'"
cQuery += "   AND E1_VENCREA between '" + DTOS(dVencIni)+ "' AND '" + DTOS(dVencFim) + "'"
cQuery += "   AND E1_MOEDA = "+ str(nmoeda)
cQuery += "   AND E1_PREFIXO Between '" + cPrefDe + "' AND '" + cPrefAte + "'"
cQuery += "   AND E1_NUM between '"     + cNumDe  + "' AND '" + cNumAte  + "'"
cQuery += "   AND ( E1_SALDO > 0  OR E1_OCORREN = '02' ) "
//Seleciona Tipos
If mv_par12 == 1	
	cQuery += "   AND E1_TIPO IN " + FormatIn(cTipos,"/")
Endif
If !Empty(MVPROVIS) .Or. !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .Or. !Empty(MVENVBCOR)	
	cQuery += "   AND E1_TIPO NOT IN " + FormatIn(MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVENVBCOR,"/")
Endif
cQuery += "   AND E1_SITUACA IN ('0','F','G') "
cQuery += "   AND SE1.D_E_L_E_T_ <> '*' "
cQuery += "   AND SA1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY "+ SqlOrder(SE1->(IndexKey()))

MemoWrite("C:\Temp\AIRBP\queries\F060QRCP1.txt",cQuery)

Return cQuery









