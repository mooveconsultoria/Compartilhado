#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO2     º Autor ³ AP6 IDE            º Data ³  27/10/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CTBNFSAI(nTipo)

Local aArea    := GetArea()
Local cTes     := ""
//Local cQry     := ""
Local vFrete   := 0
Local nCusNovo := 0
Local vPedagio := 0
Local nValIcms := 0
Local nqtddev  := 0
Local nQtd     := 0
Local nfrdev   := 0
Local npedev   := 0
Local cDoc     := ""
//Local nCUSFF1  := 0
//Local cTESCTF	 := SuperGetMv("MV_XCTF",.T.,0)
//Local cTESPDG	 := SuperGetMv("MV_XPDG",.T.,0)
Local vQryD1
Local vQryFr 
Local vQryD8                           
Local vQyD8
//Local nfD8
//Local vQD1  
//Local cLotectl
Local lLote 	:= .f.

Private nfdev := ""
                    

// chama a função para verificar se é devolução

dbSelectArea("SB8")
SB8->(dbSetOrder(5))
SB8->(dbSeek(xFilial("SB8")+SD2->D2_COD+SD2->D2_LOTECTL))

/// identificar de alguma maneira como a nota fiscal é classificada como devolução

cDoc := SB8->B8_DOC
                                         
// Busco a nota fiscal de entrada através do LoteCtl da nota fiscal de saída
vQryD1 := " SELECT SD1.D1_QUANT AS QUANT, SD1.D1_ITEM AS ITEM FROM "+RetSqlName("SD1")+" SD1 WHERE SD1.D1_FILIAL = '"+SD2->D2_FILIAL+"' AND SD1.D1_DOC = '"+cDoc+ "' AND SD1.D1_LOTECTL = '" + SB8->B8_LOTECTL + "'"
vQryD1 += " AND SD1.D_E_L_E_T_ <> '*'"
dbUseArea(.T.,"TOPCONN",TcGenQry(,,vQryD1),"vQRYD1",.T.,.T.)
vQryD1 := ChangeQuery(vQryD1) 
vQRYD1->(dbGoTop())                                                         
nQtd   := vQRYD1->QUANT


// Busco o nunseq da nota fiscal de entrada
vFrete := 0
vQryFr := " SELECT SD1.D1_NUMSEQ AS NUMSEQ FROM "+RetSqlName("SD1")+" SD1 WHERE SD1.D1_FILIAL = '"+SD2->D2_FILIAL+"' AND SD1.D1_DOC = '"+cDoc+ "'  AND SD1.D1_LOTECTL = '" + SB8->B8_LOTECTL + "'"
vQryFr += "  AND SD1.D_E_L_E_T_ <> '*'"
vQryFr := ChangeQuery(vQryFr)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,vQryFr),"vQRYFr",.T.,.T.)                                                                        
vQRYFr->(dbGoTop()) 

while vQRYFr->(!Eof())
	// Verifico se a nota fiscal é de devolução, buscando o SEQ original da entrada (FIFO)
	vQryD8 := " SELECT SD8.D8_TIPONF TIPONF, SD8.D8_DOC AS DOC, SD8.D8_TIPONF AS TIPO, SD8.D8_ITEM AS ITEM, SD8.D8_SEQ SEQ FROM "+RetSqlName("SD8")+" SD8 WHERE SD8.D8_FILIAL = '"+SD2->D2_FILIAL+"' AND SD8.D8_NUMSEQ = '"+vQRYFr->NUMSEQ+"' " 
	vQryD8 += " AND SD8.D_E_L_E_T_ <> '*'"
	vQryD8 := ChangeQuery(vQryD8)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,vQryD8),"vQryD8",.T.,.T.)
	vQryD8->(dbGoTop())                      
	
	If vQryD8->TIPONF == "D"
		lLote := .T.
                            
		// Se for devolução, faço uma busca nos dados originais, DOC + Custo + Frete + Pedágio
		// Ainda terá que criar um parâmetro para buscar as TES de frete e pedágio
		
		vQyD8 := " SELECT * FROM "+RetSqlName("SD8")+" SD8 WHERE SD8.D8_FILIAL = '"+SD2->D2_FILIAL+"' AND SD8.D8_SEQ = '"+vQryD8->SEQ+"' " 
		vQyD8 += " AND SD8.D_E_L_E_T_ <> '*'"
		vQyD8 := ChangeQuery(vQyD8)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,vQyD8),"vQyD8",.T.,.T.)
		vQyD8->(dbGoTop())                                     

  		While vQyD8->(!eof())
			If vQyD8->D8_TIPONF == "N"
				nfdev := vQyD8->D8_DOC
				nCusNovo := vQyD8->D8_CUSTO1 / vQyD8->D8_QUANT
				nqtddev := vQyD8->D8_QUANT
			ElseIf vQyD8->D8_TIPONF == "C" .AND. vQyD8->D8_CF == "281" //frete
				nfdev := vQyD8->D8_DOC
				nfrdev := vQyD8->D8_CUSTO1
			ElseIf vQyD8->D8_TIPONF == "C" .AND. vQyD8->D8_CF== "400"  //pedágio
				nfdev := vQyD8->D8_DOC
				npedev := vQyD8->D8_CUSTO1
   		 	Endif
			vQyD8->(dbSkip())
		Enddo
		vQyD8->(dbClosearea())

    Endif
    
	vQryD8->(dbclosearea())                  

	vQRYFr->(DbSkip())
Enddo        

vQryD1->(dbclosearea())
vQryFr->(dbclosearea())       
 

If nTipo == "1" /// CUSTO DO PRODUTO - FRETE - PEDÁGIO

	dbSelectArea("SF4")
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
	cTes := SF4->F4_ESTOQUE

	if cTes == "S"

		If !lLote
			dbSelectArea("SB8")
			SB8->(dbSetOrder(5))
			SB8->(dbSeek(xFilial("SB8")+SD2->D2_COD+SD2->D2_LOTECTL))
			cDoc := SB8->B8_DOC
        Else 
			cDoc := nfDev
		Endif
    
   		// novo calculo do Frete:
   		cQryD2 := GetNextAlias()
			
        cQuery := " "
		cQuery := " SELECT DISTINCT D8_SEQ SEQ, D8_QUANT "
		cQuery += " FROM "+RetSqlName("SD2")+" D2 INNER JOIN "+RetSqlName("SD8")+" D8 "
		cQuery += " ON D2_DOC = D8_DOC AND D2_NUMSEQ = D8_NUMSEQ AND D2_ITEM = D8_ITEM "
		cQuery += " WHERE D2_FILIAL = '"+xFilial("SD2")+"' "
		cQuery += " AND D2_DOC = '"+SD2->D2_DOC+"' "
		cQuery += " AND D2_ITEM = '"+SD2->D2_ITEM+"'"
		cQuery += " AND D2.D_E_L_E_T_ = '' "
		cQuery += " AND D8.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQryD2,.F.,.T.)
        ///dbSelectArea(cQryD2)
        (cQryD2)->(dbGoTop())
        
   		vfrete := 0     
        nQtd := 0     
    	qtdloted8  := 0 
   	    
                        
	    While (cQRYD2)->(!eof())
	    	NSEQD8 := (cQryD2)->SEQ

			// Busca quantidade da entrada atavés do Lote da nota fiscal de saída
			// Query anterior a data 13/03, novo procedimento fifo
			cQryFr := " SELECT * "
			cQryFr += " FROM "+RetSqlName("SD8")
			cQryFr += " WHERE D8_SEQ = '" + (cQRYD2)->SEQ + "' "
			cQryFr += " AND D_E_L_E_T_ = '' "
			cQryFr := ChangeQuery(cQryFr)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryFr),"QRYFr",.T.,.T.)
			QRYFr->(dbGoTop())     
			while QRYFr->(!Eof())
                                                
				If QRYFr->D8_TIPONF == "N" .AND. QRYFr->D8_ORIGEM = 'SD1'
					nQtd += QRYFr->D8_QUANT
				ELSEIf QRYFr->D8_TIPONF == "C" .AND. (QRYFr->D8_CF == '281' .OR. QRYFr->D8_CF == '283' .OR. QRYFr->D8_CF == '284' .OR. QRYFr->D8_CF == '282')
					vFrete += QRYFr->D8_CUSTO1
					If QRYFr->D8_SEQ == NSEQD8 
						qtdloted8 += (cQryD2)->D8_QUANT
					Endif
				Endif
				
				QRYFr->(dbskip())
			enddo     
			QRYFr->(dbclosearea())
			(cQRYD2)->(dbskip())
		Enddo                

		if vfrete > 0 //QRY->FRETE > 0 .and. QRYD1->ITEM == QRY->ITEM
			vFrete := ( vfrete / nQtd ) * qtdloted8 /////SD2->D2_QUANT
		endif         
		
		(cQryD2)->(dbclosearea())     
   
   
		// Pedágio

		// Nova Query, procedimento fifo
		
		cQryD2 := GetNextAlias()
			
        cQuery := " "
		cQuery := " SELECT DISTINCT D8_SEQ SEQ, D8_QUANT "
		cQuery += " FROM "+RetSqlName("SD2")+" D2 INNER JOIN "+RetSqlName("SD8")+" D8 "
		cQuery += " ON D2_DOC = D8_DOC AND D2_NUMSEQ = D8_NUMSEQ AND D2_ITEM = D8_ITEM "
		cQuery += " WHERE D2_FILIAL = '"+xFilial("SD2")+"' "
		cQuery += " AND D2_DOC = '"+SD2->D2_DOC+"' "
		cQuery += " AND D2_ITEM = '"+SD2->D2_ITEM+"'"
		cQuery += " AND D2.D_E_L_E_T_ = '' "
		cQuery += " AND D8.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQryD2,.F.,.T.)
        ///dbSelectArea(cQryD2)
        (cQryD2)->(dbGoTop())
        
   		_vpedagio := 0
   		_qpedagio := 0     
   		qtdloted8  := 0 
                        
	    While (cQRYD2)->(!eof())
	    	NSEQD8 := (cQryD2)->SEQ

			// Busca quantidade da entrada atavés do Lote da nota fiscal de saída
			// Query anterior a data 13/03, novo procedimento fifo

			cQryFr := " SELECT * "
			cQryFr += " FROM "+RetSqlName("SD8")
			cQryFr += " WHERE D8_SEQ = '" + (cQRYD2)->SEQ + "' "
			cQryFr += " AND D_E_L_E_T_ = '' "
			cQryFr := ChangeQuery(cQryFr)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryFr),"QRYFr",.T.,.T.)
			QRYFr->(dbGoTop())     
			while QRYFr->(!Eof())
                                                
				If QRYFr->D8_TIPONF == "N" .AND. QRYFr->D8_ORIGEM = 'SD1'
					_qpedagio += QRYFr->D8_QUANT
				ELSEIf QRYFr->D8_TIPONF == "C" .AND. QRYFr->D8_CF = '400'
					_vpedagio += QRYFr->D8_CUSTO1
					If QRYFr->D8_SEQ == NSEQD8 
						qtdloted8 += (cQryD2)->D8_QUANT
					Endif
				Endif
				
				QRYFr->(dbskip())
			enddo     
			QRYFr->(dbclosearea())
			(cQRYD2)->(dbskip())
		Enddo                

		if _vpedagio > 0 //QRY->FRETE > 0 .and. QRYD1->ITEM == QRY->ITEM
			_vpedagio := ( _vpedagio / _qpedagio ) * qtdloted8 /////SD2->D2_QUANT
		endif         

		RestArea(aArea)
	
		IF !lLote //nCusNovo <= 0
			//Return(SD2->D2_CUSFF1-_vPedagio-vFrete)
			Return(SD2->D2_CUSFF1-_vPedagio-vFrete)
		Else                                
			Return((SD2->D2_QUANT*nCusNovo)-(((nfrdev/nqtddev)*SD2->D2_QUANT)+((npedev/nqtddev)*SD2->D2_QUANT))) /////-vPedagio-vFrete)
		Endif

	EndIf
	
ElseIf nTipo == "2" /// FRETE

	dbSelectArea("SF4")
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
	cTes := SF4->F4_ESTOQUE

	if cTes == "S"

		// Verifica se tem lote de devolução, caso contrário busca o lote atual
		If !lLote //Empty(nfDev)
			dbSelectArea("SB8")
			SB8->(dbSetOrder(5))
			SB8->(dbSeek(xFilial("SB8")+SD2->D2_COD+SD2->D2_LOTECTL))
			cDoc := SB8->B8_DOC
  		Else 
			cDoc := nfDev
	 	Endif
                                                              
		// Busco o NUMseq através da nota fiscal original
		// ALTERAÇÃO QUERY EM 13/03
		//			cQryFr := " SELECT SD1.D1_NUMSEQ AS NUMSEQ FROM "+RetSqlName("SD1")+" SD1 WHERE SD1.D1_FILIAL = '"+SD2->D2_FILIAL+"' AND SD1.D1_NFORI = '"+cDoc+ "' AND SD1.D1_ITEM = '"+QRYD1->ITEM+"'"
		//			cQryFr += " AND SD1.D_E_L_E_T_ <> '*' "

		// NOVA QUERY

		// Nova Query, procedimento fifo
		
		cQryD2 := GetNextAlias()
			
        cQuery := " "
		cQuery := " SELECT DISTINCT D8_SEQ SEQ, D8_QUANT "
		cQuery += " FROM "+RetSqlName("SD2")+" D2 INNER JOIN "+RetSqlName("SD8")+" D8 "
		cQuery += " ON D2_DOC = D8_DOC AND D2_NUMSEQ = D8_NUMSEQ AND D2_ITEM = D8_ITEM "
		cQuery += " WHERE D2_FILIAL = '"+xFilial("SD2")+"' "
		cQuery += " AND D2_DOC = '"+SD2->D2_DOC+"' "
		cQuery += " AND D2_LOTECTL = '"+SD2->D2_LOTECTL+"'"
		cQuery += " AND D2_ITEM = '"+SD2->D2_ITEM+"'"
		cQuery += " AND D2.D_E_L_E_T_ = '' "
		cQuery += " AND D8.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQryD2,.F.,.T.)
        ///dbSelectArea(cQryD2)
        (cQryD2)->(dbGoTop())
        
   		_vfrete := 0
   		nQtd := 0     
   		qtdloted8  := 0
   		nqporlote := 0 
   		                
	    While (cQRYD2)->(!eof())
	    	NSEQD8 := (cQryD2)->SEQ
	    	nqporlote := (cQryD2)->D8_QUANT
			// Busca quantidade da entrada atavés do Lote da nota fiscal de saída
			// Query anterior a data 13/03, novo procedimento fifo
/*
	Alterado por Fabiano Migoto m 23/03/2017, para teste da quantidade
	
			cQryD1 := " SELECT SD1.D1_QUANT AS QUANT, SD1.D1_ITEM AS ITEM FROM "+RetSqlName("SD1")+" SD1 WHERE SD1.D1_FILIAL = '"+SD2->D2_FILIAL+"' AND SD1.D1_DOC = '"+cDoc+ "' AND SD1.D1_LOTECTL = '" + SD2->D2_LOTECTL + "'"
 			cQryD1 += " AND SD1.D_E_L_E_T_ <> '*'"
			cQryD1 := ChangeQuery(cQryD1)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryD1),"QRYD1",.T.,.T.)

   			QRYD1->(dbGoTop())   
		
			nQtd 	:= 0
	
   			while QRYD1->(!Eof())
				nQtd   	+= QRYD1->QUANT
				QRYD1->(DbSkip())
			enddo                   
			
			QRYD1->(dbCloseaArea())
*/

			cQryFr := " SELECT * "
			cQryFr += " FROM "+RetSqlName("SD8")
			cQryFr += " WHERE D8_SEQ = '" + (cQRYD2)->SEQ + "' "
			cQryFr += " AND D_E_L_E_T_ = '' "
			cQryFr := ChangeQuery(cQryFr)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryFr),"QRYFr",.T.,.T.)
			QRYFr->(dbGoTop())     
			while QRYFr->(!Eof())
                                                
   				// Alteração do Bloco abaixo
				// busco o custo do frete se existir
				/*
				cQry := " SELECT SD8.D8_CUSTO1 AS FRETE, SD8.D8_ITEM AS ITEM FROM "+RetSqlName("SD8")+" SD8 WHERE SD8.D8_FILIAL = '"+SD2->D2_FILIAL+"' "
				cQry += " AND SD8.D8_NUMSEQ = '"+QRYFr->NUMSEQ+"' AND SD8.D8_QUANT = 0 AND SD8.D8_TIPONF = 'C' AND (SD8.D8_CF = '281' OR SD8.D8_CF = '282' OR SD8.D8_CF = '283' OR SD8.D8_CF = '284' OR SD8.D8_CF = '287' OR SD8.D8_CF = '288')"
				cQry += " AND SD8.D_E_L_E_T_ <> '*'"
				cQry := ChangeQuery(cQry)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRY",.T.,.T.)
				QRY->(dbGoTop())          
				While QRY->(!eof())
					_vfrete += QRY->FRETE
					QRY->(dbSkip())
				Enddo
				QRY->(dbclosearea())
				*/

				If QRYFr->D8_TIPONF == "N" .AND. QRYFr->D8_ORIGEM = 'SD1'
					nQtd += QRYFr->D8_QUANT
				ELSEIf QRYFr->D8_TIPONF == "C" .AND. (QRYFr->D8_CF == '281' .OR. QRYFr->D8_CF == '283' .OR. QRYFr->D8_CF == '284' .OR. QRYFr->D8_CF == '282')
					_vFrete += QRYFr->D8_CUSTO1
					If QRYFr->D8_SEQ == NSEQD8 
						qtdloted8 += nqporlote /////(cQryD2)->D8_QUANT
					Endif
				Endif
				
				QRYFr->(dbskip())
			enddo     
			QRYFr->(dbclosearea())
			(cQRYD2)->(dbskip())
		Enddo                

		if _vfrete > 0 //QRY->FRETE > 0 .and. QRYD1->ITEM == QRY->ITEM
			_vFrete := ( _vfrete / nQtd ) * qtdloted8  //SD2->D2_QUANT
		endif         
		
///		QRYD1->(dbclosearea())
		(cQryD2)->(dbclosearea())     
		RestArea(aArea)

		IF !lLote
			Return(_vFrete)
  		Else                                
			Return((nfrdev/nqtddev)*qtdloted8) /////SD2->D2_QUANT) /////-vPedagio-vFrete)
 		Endif

	Endif

ElseIf nTipo == "3" /// Pedágio

	dbSelectArea("SF4")
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
	cTes := SF4->F4_ESTOQUE

	if cTes == "S"
		dbSelectArea("SB8")
		SB8->(dbSetOrder(5))
		SB8->(dbSeek(xFilial("SB8")+SD2->D2_COD+SD2->D2_LOTECTL))
	///	cDoc := SB8->B8_DOC
		If !lLote //Empty(nfDev)
			cDoc := SB8->B8_DOC
		Else 
			cDoc := nfDev
		Endif



/*
		cQryD1 := " SELECT SD1.D1_QUANT AS QUANT, SD1.D1_ITEM AS ITEM FROM "+RetSqlName("SD1")+" SD1 WHERE SD1.D1_FILIAL = '"+SD2->D2_FILIAL+"' AND SD1.D1_DOC = '"+cDoc+ "' AND SD1.D1_LOTECTL = '" + SB8->B8_LOTECTL + "'"
		//cQryD1 := " SELECT SD1.D1_QUANT AS QUANT, SD1.D1_ITEM AS ITEM FROM "+RetSqlName("SD1")+" SD1 WHERE SD1.D1_FILIAL = '"+SD2->D2_FILIAL+"' AND SD1.D1_DOC = '"+cDoc+ "'"
		cQryD1 += " AND SD1.D_E_L_E_T_ <> '*'"
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryD1),"QRYD1",.T.,.T.)
		cQryD1 := ChangeQuery(cQryD1)
		QRYD1->(dbGoTop())
		while QRYD1->(!Eof())
			nQtd     := QRYD1->QUANT
			vPedagio := 0
			cQryPe   := " SELECT SD1.D1_NUMSEQ AS NUMSEQ FROM "+RetSqlName("SD1")+" SD1 WHERE SD1.D1_FILIAL = '"+SD2->D2_FILIAL+"' AND SD1.D1_NFORI = '"+cDoc+ "'"
			cQryPe   += " AND SD1.D_E_L_E_T_ <> '*'"
			cQryPe   := ChangeQuery(cQryPe)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryPe),"QRYPe",.T.,.T.)
			QRYPe->(dbGoTop())
			while QRYPe->(!Eof())
				//cQry := " SELECT SD8.D8_CUSTO1 AS PEDAGIO, SD8.D8_ITEM AS ITEM FROM "+RetSqlName("SD8")+" SD8 WHERE SD8.D8_FILIAL = '"+SD2->D2_FILIAL+"' AND SD8.D8_NUMSEQ = '"+QRYPe->NUMSEQ+"' AND SD8.D8_QUANT = 0 AND SD8.D8_TIPONF = 'C' AND SD8.D8_CF = '400'"
				cQry := " SELECT SD8.D8_CUSTO1 AS PEDAGIO, SD8.D8_ITEM AS ITEM FROM "+RetSqlName("SD8")+" SD8 WHERE SD8.D8_FILIAL = '"+SD2->D2_FILIAL+"' AND SD8.D8_NUMSEQ = '"+QRYPe->NUMSEQ+"' AND SD8.D8_QUANT = 0 AND SD8.D8_TIPONF = 'C' AND SD8.D8_CF = '400'"
				cQry += " AND SD8.D_E_L_E_T_ <> '*'"
				cQry := ChangeQuery(cQry)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRY",.T.,.T.)
				QRY->(dbGoTop())      
				_pedagio := 0
				While QRY->(!eof())
					_pedagio += QRY->PEDAGIO
					QRY->(dbSkip())
				Enddo
				if _pedagio > 0 //QRY->PEDAGIO > 0 .and. QRYD1->ITEM == QRY->ITEM
					vPedagio := ( _pedagio / nQtd ) * SD2->D2_QUANT
				endif
				QRY->(dbclosearea())
				QRYPe->(dbskip())
			enddo
			QRYPe->(dbclosearea())
			QRYD1->(DbSkip())
		enddo
		QRYD1->(dbclosearea())
*/


		// Nova Query, procedimento fifo
		
		cQryD2 := GetNextAlias()
			
        cQuery := " "
		cQuery := " SELECT DISTINCT D8_SEQ SEQ, D8_QUANT "
		cQuery += " FROM "+RetSqlName("SD2")+" D2 INNER JOIN "+RetSqlName("SD8")+" D8 "
		cQuery += " ON D2_DOC = D8_DOC AND D2_NUMSEQ = D8_NUMSEQ AND D2_ITEM = D8_ITEM "
		cQuery += " WHERE D2_FILIAL = '"+xFilial("SD2")+"' "
		cQuery += " AND D2_DOC = '"+SD2->D2_DOC+"' "
		cQuery += " AND D2_LOTECTL = '"+SD2->D2_LOTECTL+"'"
		cQuery += " AND D2_ITEM = '"+SD2->D2_ITEM+"'"
		cQuery += " AND D2.D_E_L_E_T_ = '' "
		cQuery += " AND D8.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQryD2,.F.,.T.)
        ///dbSelectArea(cQryD2)
        (cQryD2)->(dbGoTop())
        
   		_vfrete := 0
   		nQtd := 0     
   		qtdloted8  := 0 
   		nqporlote := 0 
   		                        
	    While (cQRYD2)->(!eof())
	    	NSEQD8 := (cQryD2)->SEQ
	    	nqporlote := (cQryD2)->D8_QUANT 

			// Busca quantidade da entrada atavés do Lote da nota fiscal de saída
			// Query anterior a data 13/03, novo procedimento fifo

			cQryFr := " SELECT * "
			cQryFr += " FROM "+RetSqlName("SD8")
			cQryFr += " WHERE D8_SEQ = '" + (cQRYD2)->SEQ + "' "
			cQryFr += " AND D_E_L_E_T_ = '' "
			cQryFr := ChangeQuery(cQryFr)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryFr),"QRYFr",.T.,.T.)
			QRYFr->(dbGoTop())     
			while QRYFr->(!Eof())
                                                
				If QRYFr->D8_TIPONF == "N" .AND. QRYFr->D8_ORIGEM = 'SD1'
					nQtd += QRYFr->D8_QUANT
				ELSEIf QRYFr->D8_TIPONF == "C" .AND. QRYFr->D8_CF = '400'
					_vFrete += QRYFr->D8_CUSTO1
					If QRYFr->D8_SEQ == NSEQD8 
						qtdloted8 += nqporlote //(cQryD2)->D8_QUANT
					Endif
				Endif
				
				QRYFr->(dbskip())
			enddo     
			QRYFr->(dbclosearea())
			(cQRYD2)->(dbskip())
		Enddo                

		if _vfrete > 0 //QRY->FRETE > 0 .and. QRYD1->ITEM == QRY->ITEM
			_vFrete := ( _vfrete / nQtd ) * qtdloted8  ////SD2->D2_QUANT
		endif         
		
		vPedagio := _vFrete
		
		RestArea(aArea)

		IF !lLote //nCusNovo <= 0
			Return(vPedagio)
		Else                                
			Return((npedev/nqtddev)*qtdloted8) ////SD2->D2_QUANT)
		Endif

	Endif

ElseIf nTipo == "4" // Total credito

	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSeek(xFilial("SF4")+SD2->D2_TES)
	cTes := SF4->F4_ESTOQUE

	if cTes == "S"
		RestArea(aArea)
		Return(SD2->D2_CUSFF1)
	Endif

ElseIf nTipo == "5" // ICMS Retido

	dbSelectArea("SF4")
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
	cTes := SF4->F4_ESTOQUE

	if cTes == "S"
		dbSelectArea("SB8")
		SB8->(dbSetOrder(5))
		SB8->(dbSeek(xFilial("SB8")+SD2->D2_COD+SD2->D2_LOTECTL))

		If !lLote 
			cDoc := SB8->B8_DOC
		Else 
			cDoc := nfDev
		Endif

		nValIcms := 0
		nQtd     := 0

		cQryD1   := " SELECT SD1.D1_QUANT AS QUANT, SD1.D1_ICMSRET AS ICMSRET FROM "+RetSqlName("SD1")+" SD1 WHERE SD1.D1_FILIAL = '"+SD2->D2_FILIAL+"' AND SD1.D1_DOC = '"+cDoc+ "' AND SD1.D1_LOTECTL = '" + SB8->B8_LOTECTL + "'"
		cQryD1   += " AND SD1.D_E_L_E_T_ <> '*'"
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryD1),"QRYD1",.T.,.T.)
		cQryD1 := ChangeQuery(cQryD1)
		QRYD1->(dbGoTop())
		if QRYD1->(!Eof())
			nValIcms := (QRYD1->ICMSRET / QRYD1->QUANT) * SD2->D2_QUANT
		endif
		QRYD1->(dbclosearea())
		RestArea(aArea)
		Return(nValIcms)
	Endif

EndIf

Return nil
