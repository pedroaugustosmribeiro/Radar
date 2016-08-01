a$=''
xlon=0.
ylat=0.
estacao=''
close,10
openr,10,'coordenadas_pluv_saisp.dat'
while eof(10) eq 0 do begin
   readf,10,estacao
   readf,10,format='(2f12.6)',ylat,xlon


   file_pluv = findfile('Out/' + estacao + '.dat',count=p1)
   
   print,estacao,p1
   if p1 gt 0 then begin
      

      kont=0L
      close,1
      openr,1,file_pluv
      while eof(1) eq 0 do begin
         readf,1,format='(i4,4(1x,i2),f7.2)',ano,mes,dia,hora,minuto,chuva

         if kont eq 0 then begin
            jul0 = julday(mes,dia,ano)
            nminutos = 365L*24L*6L   ; numero de 10 minutos de intervalos ; 1ano
            rain = fltarr(nminutos)
            inst = fltarr(nminutos)
            flag = intarr(365) ; se temos observacao no dia
            kont=1
         endif 

         jul1 = julday(mes,dia,ano) - jul0
         flag(jul1) = 1

         iminu = jul1*24L*6L + hora*6L + minuto/10
         
         rain(iminu) = chuva


         ;print,format='(i4,4(1x,i2),f7.2,2i6)',ano,mes,dia,hora,minuto,chuva,iminu,jul1
      endwhile 
      close,1

;1000660
      if max(rain) gt 0 then begin
         

         pos_dia = where(flag eq 1,pdias)
         nminutos = (pos_dia(pdias-1)+1)*24L*6L
         print,"Numero de Dias = ",pos_dia(pdias-1)+1

         for i=0L,nminutos-2L do begin

            dia = i/(24L*6L)
            hora = (i -dia*24*6L)/6
            minuto = (i - dia*24L*6L  - hora*6L)*10

            caldat,(dia+jul0),mes,dia1,ano

            yymmdd$ = string(ano,format='(i4)') + "-" + string(mes,format='(i02)') + "-" + string(dia1,format='(i02)')
            fileout = 'Instantaneo_Novo/' + yymmdd$ + '_' + estacao + '.dat'
            

            if i gt 0 then begin
               if hora eq 10 and minuto eq 10 and rain(i-1) gt 0 then rain(i-1) = 0. ; zera para tirar a chuva
               inst(i) = rain(i)-rain(i-1)
            endif else begin
               inst(i) = rain(i)
            endelse

            

            close,1
            openw,1,fileout,/append
            printf,1,format='(i4,4(1x,i02),f7.2)',ano,mes,dia1,hora,minuto,inst(i)
            close,1

               
         endfor
         close,1
         
      endif

 
        
   endif
 
endwhile



close,10


end


