;+
;This program extracts data from X-Band radar and saves it to ASCII file
; :Author: Pedro Augusto
;-
;pro compare_radar_station
if !version.os_family eq 'Windows' then cd,'C:\Users\hp\OneDrive - usp.br\Iniciação Científica\Radar\Radar'
;device,decomposed=0
list_radar_file='./MVOL/'+file_basename(file_search('./MVOL/SAO*'))
file_pluv='../Pluviometro/pluviometros.idl'
restore,filename=file_pluv
lixo=-32767.

dz=[]
vr=[]
dzdr=[]
rhv=[]
kdp=[]
rain_loc=[]
time_loc=[]

close,4
openw,4,'./radar.txt'
;printf,4,'est.cod. r(km) Theta lat lon dia hora min seg dado R(mm/10min) Z(dbZ) Zdr(dbZr) Kdp(o/km) Vr(m/s) Rhv',format='(a)'
printf,4,'datetime estacao_codigo r_km Theta height_km lat lon Z_dbZ Zdr_dbZr Kdp_o_km Vr_m_s Rhv',format='(a)'
;for f=0,n_elements(list_radar_file)-1 do begin ;loop em cada arquivo de radar
foreach file_radar, list_radar_file do begin

  ;  file_radar=list_radar_file[f]
  radar=rsl_anyformat_to_radar(file_radar,/quiet)
  
  ;  print,file_radar
  ;  ano = radar.h.year
  ;  mes = radar.h.month
  ;  dia = radar.h.day
  ;  hora = radar.h.hour
  ;  minuto = radar.h.minute
  ;  segundo = radar.h.sec
  reads,(file_basename(file_radar,'.gz')),ano,mes,dia,hora,minuto,segundo,format='(3x,6(2i2))
  if segundo lt 10 then begin
    ano=2000+ano
;    print,dia,hora,minuto,segundo
    
    time_radar=julday(mes,dia,ano,hora,minuto)
    latlon_radar=rsl_get_radar_latlon(radar)
    lat_radar = latlon_radar[0];float(radar.h.latd) + float(radar.h.latm)/60. + float(radar.h.lats)/3600.
    lon_radar = latlon_radar[1];float(radar.h.lond) + float(radar.h.lonm)/60. + float(radar.h.lons)/3600.
    voldz=rsl_get_volume(radar,'dz')
    volvr=rsl_get_volume(radar,'vr')
    voldr=rsl_get_volume(radar,'dr')
    volrhv=rsl_get_volume(radar,'rh')
    volkdp=rsl_get_volume(radar,'kd')
    
    binres=(voldz.sweep[0].ray.h.GATE_SIZE)[0,0,0]/1000.
    azimute=voldz.sweep[0].ray.h.azimuth
    elev=(rsl_get_ray(voldz,0.)).h.elev 
    
    print,time_radar,format='(c(CYI4.2,"-",CMOI2.2,"-",CDI2.2,"T",CHI2.2,":",CMI2.2))'
    ;    for i=0,n_elements(estacao)-1 do begin ;loop itera em cada estacao pluviometrica
    foreach est,estacao do begin
      ;      lat=estacao[i].lat ;pegando coordenadas da estacao pluviometrica
      ;      lon=estacao[i].lon
      lat=est.lat
      lon=est.lon
      r=map_2points(lon,lat,lon_radar,lat_radar,/meters)/1000.
      theta=((map_2points(lon_radar,lat_radar,lon,lat))[1]+360) mod 360
      
      if r le 60.075 then begin ;definindo raio maximo dos dados do radar
    
        azim=(rsl_get_ray(voldz,0.,theta)).h.ray_num
        rsl_get_slantr_and_h,r,elev,slant,height
        gtpos=(slant/binres)-0.5
        ;        dz2=mean(voldz.sweep[0].ray[azim-1:azim+1].range[gtpos-1:gtpos+1])
        ;        vr2=mean(volvr.sweep[0].ray[azim-1:azim+1].range[gtpos-1:gtpos+1])
        ;        dzdr2=mean(voldr.sweep[0].ray[azim-1:azim+1].range[gtpos-1:gtpos+1])
        ;        rhv2=mean(volrhv.sweep[0].ray[azim-1:azim+1].range[gtpos-1:gtpos+1])
        ;        kdp2=mean(volkdp.sweep[0].ray[azim-1:azim+1].range[gtpos-1:gtpos+1])
        dz2=voldz.sweep[0].ray[azim].range[gtpos]
        vr2=volvr.sweep[0].ray[azim].range[gtpos]
        dzdr2=voldr.sweep[0].ray[azim].range[gtpos]
        rhv2=volrhv.sweep[0].ray[azim].range[gtpos]
        kdp2=volkdp.sweep[0].ray[azim].range[gtpos]
        ;if ((dz2 ge 0) and (dzdr2 ge -2 ) and (dzdr2 le 6) and (vr2 gt -50 ) and (rhv2 ge 0.8)) then begin ;filtrando dados do radar
        ;        if n_elements(first) eq 0 then begin
        ;          dz=dz2
        ;          vr=vr2
        ;          dzdr=dzdr2
        ;          rhv=rhv2
        ;          kdp=kdp2
        ;          ;rain_loc=rain_pos
        ;          time_loc=time_radar
        ;          first=0
        ;          print,first
        ;        endif else begin
        dz=[dz,dz2]
        vr=[vr,vr2]
        dzdr=[dzdr,dzdr2]
        rhv=[rhv,rhv2]
        kdp=[kdp,kdp2]
        printf,4,time_radar,est.codigo,r,theta,height,lat,lon,dz2,dzdr2,kdp2,vr2,rhv2,$
          format='(c(CYI4.2,"-",CMOI2.2,"-",CDI2.2,"T",CHI2.2,":",CMI2.2,"+00:00"),1x,i,1x,9(f,1x),f)'
          
;        rain_pos=where((rain.codigo eq est.codigo) and (rain.time eq time_radar))
;        rain_loc=[rain_loc,rain_pos]
;        time_loc=[time_loc,time_radar]
;        ;              endelse
;        ;        rain_pos=where((rain.codigo eq estacao[i].codigo) and (rain.time eq time_radar))
;        if rain_pos ne -1 then begin
;          ;          printf,4,estacao[i].codigo,r,theta,lat,lon,dia,hora,minuto,segundo,$
;          printf,4,time_radar,est.codigo,r,theta,lat,lon,dia,hora,minuto,segundo,$
;            rain[rain_pos].dado,rain[rain_pos].inst,dz2,dzdr2,kdp2,vr2,rhv2,$
;            format='(c(CYI4.2,"-",cmoi2.2,"-",cdi2.2,"T",chi2.2,":",cmi2.2,"-03:00"),1x,i,1x,15(f,1x),f)'
;        endif else begin
;          ;          printf,4,estacao[i].codigo,r,theta,lat,lon,dia,hora,minuto,segundo,$
;          printf,4,time_radar,est.codigo,r,theta,lat,lon,dia,hora,minuto,segundo,$
;            lixo,lixo,dz2,dzdr2,kdp2,vr2,rhv2,$
;            format='(c(CYI4.2,"-",cmoi2.2,"-",cdi2.2,"T",chi2.2,":",cmi2.2,"-03:00"),1x,i,1x,15(f,1x),f)'
;        endelse
        ;endif
      endif
      ;    endfor
    endforeach
    ;    print,f*100./n_elements(list_radar_file),format='(f5.2," %")'
  endif
  ;endfor
endforeach
;save,dz,vr,dzdr,rhv,kdp,time_loc,rain_loc,/compress,filename='r-z_relation.idl'
close,4
end
