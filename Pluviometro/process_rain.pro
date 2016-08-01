xlon=0.
ylat=0.
file1='coordenadas_pluv_saisp.dat' ;station info file
file2='rain.dat' ;from pre-process_rain.sh
estacao_tmp=0l
estacao_str={asema:0l,lat:0.0,lon:0.0} ;structure defined by station_code (asema)
;latitude and longitude
estacao=replicate(estacao_str,fix(file_lines(file1)/2.))

;the loop below populates the station structure with data from the
;info file
close,1
openr,1,file1
i=0
while ~eof(1) do begin
   readf,1,estacao_tmp
   estacao[i].asema=estacao_tmp
   readf,1,format='(2(f12.6,x))',ylat,xlon
   estacao[i].lat=ylat
   estacao[i].lon=xlon
   i++
endwhile
close,1

dl=file_lines(file2) ;number of data lines
;definition of the precipitation data structure
rain_structure={rain_data,asema:0L,ano:0,mes:0,dia:0,hora:0,min:0,rain:0.0}
temp=replicate(rain_structure,dl)

;the block below populates the prec data struc with pre-processed data
;from disk
close,2
openr,2,file2
readf,2,temp,format='(i0,1x,i4,4i2,1x,f)'
close,2

rain_structure=create_struct('time',0d,'inst',0.0,rain_structure)
rain= replicate(rain_structure,dl)
Struct_Assign, temp, rain
rain.time=julday(rain.mes,rain.ano,rain.dia,rain.hora,rain.min)

;the for loop calculates the 10min accumulated precipitation for each
;data item
;Atention is paid to the reset at 10:00am every calendar day
for i=0,n_elements(estacao)-1 do begin
   est_tmp=where(rain.asema eq estacao[i].asema,est_count)
   if est_count gt 0 then begin
      hora10s=where((rain.asema eq estacao[i].asema)$
                    and (rain.hora eq 10)$
                    and (rain.min eq 10)) ;looks for 10:10am's (time-step after
;the daily reset
      hora10=where((rain.asema eq estacao[i].asema) and (rain.hora ne 10))
      rain[hora10].inst=rain[hora10].rain-rain[hora10-1].rain
      rain[hora10[0]].inst=.0 ;sets the first time-step to 0 (not posible to calculate)
      rain[hora10s].inst=rain[hora10s].rain ;set 10:10am's to it's own value,
;as the gauge was reset at 10:00am
   endif
endfor
;save the structures in compressed idl save file format
save,estacao,rain,/compress,filename='pluviometros.idl'
end
