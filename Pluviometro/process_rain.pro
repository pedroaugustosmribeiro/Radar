;+
; :Author: Pedro Augusto
;-

;pro process_rain
  xlon=0.
  ylat=0.
  ;cd,'/mnt/c/Users/hp/OneDrive - usp.br/Iniciação Científica/Radar/Pluviometro/'
  if !version.os_family eq 'Windows' then cd,'C:\Users\hp\OneDrive - usp.br\Iniciação Científica\Radar\Pluviometro'
  file1='coordenadas_pluv_saisp.dat' ;station info file
  file2='rain.dat' ;from pre-process_rain.sh
  
  lon_radar=-46.6231;colocar
  lat_radar=-23.6519;
  
  estacao_tmp=0l
  estacao_str={codigo:0l,lat:0.0,lon:0.0,r_xpol:0.0,azimute_xpol:0.0} ;structure defined by station_code (codigo)
  ;latitude and longitude
  estacao=replicate(estacao_str,fix(file_lines(file1)/2.))
  
  ;the loop below populates the station structure with data from the
  ;info file
  close,1
  openr,1,file1
  i=0
  while ~eof(1) do begin
    readf,1,estacao_tmp
    estacao[i].codigo=estacao_tmp
    readf,1,format='(2(f12.6,x))',ylat,xlon
    estacao[i].lat=ylat
    estacao[i].lon=xlon
    r=map_2points(lon_radar,lat_radar,xlon,ylat,/meters)/1000.
    theta=((map_2points(lon_radar,lat_radar,xlon,ylat))[1]+360) mod 360
    estacao[i].r_xpol=r
    estacao[i].azimute_xpol=theta
    i++
  endwhile
  close,1
  
  dl=file_lines(file2) ;number of data lines
  ;definition of the precipitation data structure
  rain_structure={rain_data,codigo:0L,ano:0,mes:0,dia:0,hora:0,minuto:0,dado:0.0}
  temp=replicate(rain_structure,dl)
  
  ;the block below populates the prec data struc with pre-processed data
  ;from disk
  close,2
  openr,2,file2
  readf,2,temp,format='(i0,1x,i4,4i2,1x,f)'
  close,2
  
  rain_structure=create_struct('time',0d,'inst',0.0,'r_xpol',0d,'azimute_xpol',0d,'lat',0.0,'lon',0.0,rain_structure)
  rain= replicate(rain_structure,dl)
  Struct_Assign, temp, rain
  rain.time=julday(rain.mes,rain.dia,rain.ano,rain.hora,rain.minuto)
  for j=0l,n_elements(rain)-1 do rain[j].lat=estacao(where(estacao.codigo eq rain[j].codigo)).lat
  for j=0l,n_elements(rain)-1 do rain[j].lon=estacao(where(estacao.codigo eq rain[j].codigo)).lon
  for j=0l,n_elements(rain)-1 do rain[j].r_xpol=estacao(where(estacao.codigo eq rain[j].codigo)).r_xpol
  for j=0l,n_elements(rain)-1 do rain[j].azimute_xpol=estacao(where(estacao.codigo eq rain[j].codigo)).azimute_xpol
  ;the for loop calculates the 10min accumulated precipitation for each
  ;data item
  ;Atention is paid to the reset at 10:00am every calendar day
  for i=0,n_elements(estacao)-1 do begin
    est_tmp=where(rain.codigo eq estacao[i].codigo,est_count)
    if est_count gt 0 then begin
      hora10s=where((rain.codigo eq estacao[i].codigo)$
        and (rain.hora eq 10)$
        and (rain.minuto eq 10)) ;looks for 10:10am's (time-step after
      ;the daily reset
      hora10=where((rain.codigo eq estacao[i].codigo) and (rain.hora ne 10))
      rain[hora10].inst=rain[hora10].dado-rain[hora10-1].dado
      rain[hora10[0]].inst=.0 ;sets the first time-step to 0 (not posible to calculate)
      rain[hora10s].inst=rain[hora10s].dado ;set 10:10am's to it's own value,
      ;as the gauge was reset at 10:00am
    endif
  endfor
  ;save the structures in compressed idl save file format
  estacao=estacao(sort(estacao.codigo))
;  rain=rain(sort(rain.time))
  close,3
  openw,3,'rain.txt.gz',/compress
  printf,3,'datetime estacao_codigo dado Rg_mm_10min',format='(a)'
  foreach row,rain do printf,3,row.time,row.codigo,row.dado,row.inst,$
    format='(c(CYI4.2,"-",CMOI2.2,"-",CDI2.2,"T",CHI2.2,":",CMI2.2,"-03:00"),1x,i,1x,1(f,1x),f)'
  close,3
;  openw,3,'rain_grads.txt'
;  openw,4,'rain_grads.gra'
;  time_old=rain[0].time
;  ntime=1
;  flag=1
;  t_rel=0
;  foreach r,rain do begin
;    print,r.codigo,r.inst,r.time
;    if r.time ne time_old then begin
;      nlev=0
;      printf,3,r.codigo,r.lat,r.lon,t_rel,nlev,flag
;      writeu,4,string(r.codigo),r.lat,r.lon,fix(t_rel),fix(nlev),fix(flag)
;      time_old=r.time
;      ntime++
;    endif
;    nlev=1
;    printf,3,r.codigo,r.lat,r.lon,t_rel,nlev,flag
;    writeu,4,string(r.codigo),r.lat,r.lon,fix(t_rel),fix(nlev),fix(flag)
;    printf,3,r.inst
;    writeu,4,r.inst
;  endforeach
;  nlev=0
;  printf,3,r.codigo,r.lat,r.lon,t_rel,nlev,flag
;  close,3
;  close,4
;  save,estacao,rain,/compress,filename='pluviometros.idl'
  ;rainv=fltarr(345,360,42160)
end
