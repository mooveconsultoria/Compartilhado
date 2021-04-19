#INCLUDE "Average.ch"

#define FO_READWRITE  2 
#define FO_EXCLUSIVE 16    // Exclusive use (other processes have no access)
#define BLOCK_READ 1024
#define TAB CHR(9)+CHR(9)+CHR(9)+CHR(9)
#define TA2 CHR(9)+CHR(9)+CHR(9)

*---------------------------*
User Function AtuMenuEEC()
*---------------------------*
Local hFile, hFile2
Local cBuffer    := ""
Local nSize      := 0
Local nInc 
Local cLine      := ""
Local aMenu      := {}
Local nLidos     := 0
Local cRet       := ""
Local aNewMenu      := ""

Private cModulo  := ""
Private cFile    := ""

Begin Sequence
   
   
   cModulo := "sigaeec" //Exportação

   /*
      Seleciona o arquivo de menu a ser alterado.
   */   
   cFile := cModulo + ".xnu"

   hFile := fOpen(cFile,FO_READWRITE+FO_EXCLUSIVE)
   
   IF fError() <> 0
      MsgStop("Não foi possível abrir o arquivo de menu.","Aviso")
      lRet := .F.
      Break
   Endif
    
   //Verifica o Tamaqnho total do arquivo
   nSize := fSeek(hFile,0,2)
   
   //Posiciona no Inicio do Arquivo
   FSeek(hFile,0)      
   
   Do While nLidos < nSize
      
      nLidos += LerLinha(hFile,@cLine,nSize)
    
      //cLine := StrTran(cLine,CHR(9),"")
      
      //cLine := StrTran(cLine,CHR(13),"")

      IF Empty(cLine)
         Loop
      Endif
      
      aAdd(aMenu,Alltrim(cLine)) 
   EndDo
   
   //Fecha arquivo
   FClose(hFile)
   
   //*** Naturezas - Após a opção "Normas" do menu "Tabelas"
   aNewMenu := {}
   AAdd(aNewMenu,TA2+'<MenuItem Status="Enable">')
   AAdd(aNewMenu,TAB + '<Title lang="pt">Naturezas</Title>')
   AAdd(aNewMenu,TAB + '<Function>EECAD100</Function>')
   AAdd(aNewMenu,TAB + '<Type>1</Type>')
   AAdd(aNewMenu,TAB + '<Tables>EYQ</Tables>')
   AAdd(aNewMenu,TAB + '<Access>xxxxxxxxxx</Access>')
   AAdd(aNewMenu,TAB + '<Module>29</Module>')
   AAdd(aNewMenu,TA2+'</MenuItem>')

   AddMenu(@aMenu,"<Function>EECAD100</Function>","<Function>EECAT180</Function>",aNewMenu,@cRet,"Naturezas")
   
   
   //*** Novas opções do menu 'Financeiro'
   //Câmbio III e IV - Após a opção "Câmbio" do menu "Financeiro"
   aNewMenu := {}
   AAdd(aNewMenu,TA2+'<MenuItem Status="Enable">')
   AAdd(aNewMenu,TAB + '<Title lang="pt">Cambio 3/4</Title>')
   AAdd(aNewMenu,TAB + '<Function>EECAF500</Function>')
   AAdd(aNewMenu,TAB + '<Type>1</Type>')
   AAdd(aNewMenu,TAB + '<Tables>EEQ</Tables>')
   AAdd(aNewMenu,TAB + '<Tables>EXG</Tables>')
   AAdd(aNewMenu,TAB + '<Access>xxxxxxxxxx</Access>')
   AAdd(aNewMenu,TAB + '<Module>29</Module>')
   AAdd(aNewMenu,TA2+'</MenuItem>')

   AddMenu(@aMenu,"<Function>EECAF500</Function>","<Function>EECAF200</Function>",aNewMenu,@cRet,"Cambio 3/4")

   //Movimentações - Após a opção "Câmbio III e IV" do menu "Financeiro"
   aNewMenu := {}
   AAdd(aNewMenu,TA2+'<MenuItem Status="Enable">')
   AAdd(aNewMenu,TAB + '<Title lang="pt">Movimentações</Title>')
   AAdd(aNewMenu,TAB + '<Function>EECAD101</Function>')
   AAdd(aNewMenu,TAB + '<Type>1</Type>')
   AAdd(aNewMenu,TAB + '<Tables>EYR</Tables>')
   AAdd(aNewMenu,TAB + '<Tables>EYQ</Tables>')
   AAdd(aNewMenu,TAB + '<Access>xxxxxxxxxx</Access>')
   AAdd(aNewMenu,TAB + '<Module>29</Module>')
   AAdd(aNewMenu,TA2+'</MenuItem>')

   AddMenu(@aMenu,"<Function>EECAD101</Function>","<Function>EECAF500</Function>",aNewMenu,@cRet,"Movimentações")

   //Internação de Recursos - Após a opção Movimentações
   aNewMenu := {}
   AAdd(aNewMenu,TA2+'<MenuItem Status="Enable">')
   AAdd(aNewMenu,'<Title lang="pt">Internação de Recursos</Title>')
   AAdd(aNewMenu,TAB + '<Function>EECAD103</Function>')
   AAdd(aNewMenu,TAB + '<Type>1</Type>')
   AAdd(aNewMenu,TAB + '<Tables>EYV</Tables>')
   AAdd(aNewMenu,TAB + '<Tables>EYR</Tables>')
   AAdd(aNewMenu,TAB + '<Access>xxxxxxxxxx</Access>')
   AAdd(aNewMenu,TAB + '<Module>29</Module>')
   AAdd(aNewMenu,TA2+'</MenuItem>')

   AddMenu(@aMenu,"<Function>EECAD103</Function>","<Function>EECAD101</Function>",aNewMenu,@cRet,"Internação de Recursos")
   
   //Câmbio Simultâneo - Após a opção Internação de Recursos
   aNewMenu := {}
   AAdd(aNewMenu,TA2+'<MenuItem Status="Enable">')
   AAdd(aNewMenu,TAB + '<Title lang="pt">Câmbio Simultâneo</Title>')
   AAdd(aNewMenu,TAB + '<Function>EECAD104</Function>')
   AAdd(aNewMenu,TAB + '<Type>1</Type>')
   AAdd(aNewMenu,TAB + '<Tables>EYV</Tables>')
   AAdd(aNewMenu,TAB + '<Tables>EYR</Tables>')
   AAdd(aNewMenu,TAB + '<Access>xxxxxxxxxx</Access>')
   AAdd(aNewMenu,TAB + '<Module>29</Module>')
   AAdd(aNewMenu,TA2+'</MenuItem>')

   AddMenu(@aMenu,"<Function>EECAD104</Function>","<Function>EECAD103</Function>",aNewMenu,@cRet,"Câmbio Simultâneo")

  //Follow up de recursos - Após a opção Câmbio Simultâneo
   aNewMenu := {}
   AAdd(aNewMenu,TA2+'<MenuItem Status="Enable">')
   AAdd(aNewMenu,TAB + '<Title lang="pt">Follow-up de Recursos</Title>')
   AAdd(aNewMenu,TAB + '<Function>EECAD105</Function>')
   AAdd(aNewMenu,TAB + '<Type>1</Type>')
   AAdd(aNewMenu,TAB + '<Tables>EYR</Tables>')
   AAdd(aNewMenu,TAB + '<Access>xxxxxxxxxx</Access>')
   AAdd(aNewMenu,TAB + '<Module>29</Module>')
   AAdd(aNewMenu,TA2+'</MenuItem>')
   
   AddMenu(@aMenu,"<Function>EECAD105</Function>","<Function>EECAD104</Function>",aNewMenu,@cRet,"Follow-up de Recursos")

   //***
  
   hFile2 := FCreate(cFile,0)
      
   //Renomeia o menu antigo
   FRename(cFile, cModulo + "_OLD.XNU")

   For nInc := 1 to Len(aMenu)
      cBuffer += aMenu[nInc] + ENTER
   Next    

   Fwrite(hFile2,cBuffer,Len(cBuffer))  

   fClose(hFile2)         
End Sequence

If Empty(cRet)
   cRet := "Menu do módulo sigaeec atualizado." + ENTER
EndIf

Return cRet

*----------------------------------------*
Static Function LerLinha(hFile,cVar,nSize)
*----------------------------------------*
Local cBuffer := ""
Local cAux    := ""

Local nBytes  := BLOCK_READ
Local nEndLine:= 0
Local nPos    := 0

Begin Sequence
   
   While (nEndLine := At(CRLF,cAux)) == 0 .And. (nPos:=fSeek(hFile,0,1))<nSize
      IF nBytes > (nSize-nPos)
         nBytes := (nSize-nPos)
      Endif
      cBuffer := Space(nBytes)
      fRead(hFile,@cBuffer,nBytes)
      cAux += cBuffer
   Enddo
   
   IF nPos < nSize
      nVolta := (Len(cAux)+1) - nEndLine
      nVolta -= 2
      fSeek(hFile,-nVolta,1)
      cVar := Substr(cAux,1,nEndLine-1)
   ELSE
      cVar := cAux
   ENDIF
   
End Sequence

Return Len(cVar)+2 // +2 por causa do CRLF


*=====================================================================*
Static Function AddMenu(aMenu,cFunction,cFuncApos,aNewMenu,cRet,cDescr)
*=====================================================================*
Local nPos, i

Begin Sequence

   If aScan(aMenu,{|e| Upper(StrTran(e,CHR(9),"")) == Upper(cFunction)}) == 0
      nPos := aScan(aMenu,{|e| Upper(StrTran(e,CHR(9),"")) == Upper(cFuncApos)})
      If nPos > 0
         While nPos <= Len(aMenu) .And. !("</MENUITEM>" $ Upper(aMenu[nPos]))
            ++nPos
         EndDo
         For i := 1 To Len(aNewMenu)
            aAdd(aMenu, Nil)
            aIns(aMenu, nPos+i)
            aMenu[nPos+i] := aNewMenu[i]
         Next
      Else
         cRet += "Erro na inclusão da opção '"+AllTrim(cDescr)+"': "
         cRet += "A opção '"+cFuncApos+"' não foi encontrada no menu " + ENTER
      EndIf
   EndIf

End Sequence

Return 
