a$=''
xlon=0.
ylat=0.
estacao=''
close,10
openr,10,'coordenadas_pluv_saisp.dat'
while eof(10) eq 0 do begin
   readf,10,estacao
   readf,10,format='(2f12.6)',ylat,xlon


   file_pluv = findfile('CSV/2016-06-04/_P' + estacao + '_*',count=p1)
   print,estacao,p1
   if p1 gt 0 then begin
      fileout = 'Out/' + estacao + '.dat'
      

      close,1
      openr,1,file_pluv(0)
      readf,1,a$
      lixo = strsplit(a$,',',/extrac)
      if n_elements(lixo) ge 3 then begin
         if strmid(lixo(2),1,3) eq 'PLU' then begin 
            
            close,2
            openw,2,fileout,/append

            while eof(1) eq 0 do begin
               readf,1,a$
               lixo = strsplit(a$,',',/extrac)
               n1 = n_elements(lixo)
               if n1 ge 3 then begin ; com chuva
                  ano    = fix(strmid(lixo(1),0,4))
                  mes    = fix(strmid(lixo(1),4,2))
                  dia    = fix(strmid(lixo(1),6,2))
                  hora   = fix(strmid(lixo(1),8,2))
                  minuto = fix(strmid(lixo(1),10,2))
                  chuva = float(lixo(2))
               endif else begin
                  ano    = fix(strmid(lixo(1),0,4))
                  mes    = fix(strmid(lixo(1),4,2))
                  dia    = fix(strmid(lixo(1),6,2))
                  hora   = fix(strmid(lixo(1),8,2))
                  minuto = fix(strmid(lixo(1),10,2))
                  chuva = 0.
               endelse
                                ;print,a$
               ;print,ano,mes,dia,hora,minuto,chuva
               printf,2,format='(i4,4(1x,i2),f7.2)',ano,mes,dia,hora,minuto,chuva
                                ;read,u
            endwhile 
            
         endif 
      endif
      close,1
      close,2
      
   endif 
endwhile



close,10


end
