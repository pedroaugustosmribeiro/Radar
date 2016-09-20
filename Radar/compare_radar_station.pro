;pro compare_radar_station
  if !version.os_family eq 'Windows' then cd,'G:\Pedro Augusto\Meteorologia USP\Google Cloud\Iniciação Científica\Radar\Radar'
  ;device,decomposed=0
  list_radar_file='./MVOL/'+file_basename(file_search('./MVOL/*.gz'))
  file_pluv='../Pluviometro/pluviometros.idl'
  restore,filename=file_pluv
  lixo=99999.
  close,4
  openw,4,'./out.txt'
  printf,4,'est.cod. r(km) Theta lat lon dia hora min seg dado R(mm/10min) Z(dbZ) Zdr(dbZr) Kdp(o/km) Vr(m/s) Rhv',format='(a)'

for f=0,n_elements(list_radar_file)-1 do begin ;loop em cada arquivo de radar

  file_radar=list_radar_file[f]
  radar=rsl_anyformat_to_radar(file_radar,/quiet)

  print,file_radar
;  ano = radar.h.year
;  mes = radar.h.month
;  dia = radar.h.day
;  hora = radar.h.hour
;  minuto = radar.h.minute
;  segundo = radar.h.sec
  reads,(file_basename(file_radar,'.gz')),ano,mes,dia,hora,minuto,segundo,format='(3x,6(2i2))
  ano=2000+ano
  print,dia,hora,minuto,segundo

  time_radar=julday(mes,dia,ano,hora,minuto)
  lat_radar = float(radar.h.latd) + float(radar.h.latm)/60. + float(radar.h.lats)/3600.
  lon_radar = float(radar.h.lond) + float(radar.h.lonm)/60. + float(radar.h.lons)/3600.
  voldz=rsl_get_volume(radar,'dz')
  volvr=rsl_get_volume(radar,'vr')
  voldr=rsl_get_volume(radar,'dr')
  volrhv=rsl_get_volume(radar,'rh')
  volkdp=rsl_get_volume(radar,'kd')

  binres=(voldz.sweep[0].ray.h.GATE_SIZE)[0,0,0]/1000.
  azimute=voldz.sweep[0].ray.h.azimuth

  for i=0,n_elements(estacao)-1 do begin ;loop itera em cada estacao pluviometrica

     lat=estacao[i].lat ;pegando coordenadas da estacao pluviometrica
     lon=estacao[i].lon
     r=map_2points(lon,lat,lon_radar,lat_radar,/meters,radius=a)/1000.
     theta=((map_2points(lon_radar,lat_radar,lon,lat))[1]+360) mod 360

     if r le 60.075 then begin ;definindo raio maximo dos dados do radar

        azim=(rsl_get_ray(voldz,0.,theta)).h.ray_num
        gtpos=(r/binres)-0.5
        dz2=mean(voldz.sweep[0].ray[azim-1:azim+1].range[gtpos-1:gtpos+1])
        vr2=mean(volvr.sweep[0].ray[azim-1:azim+1].range[gtpos-1:gtpos+1])
        dzdr2=mean(voldr.sweep[0].ray[azim-1:azim+1].range[gtpos-1:gtpos+1])
        rhv2=mean(volrhv.sweep[0].ray[azim-1:azim+1].range[gtpos-1:gtpos+1])
        kdp2=mean(volkdp.sweep[0].ray[azim-1:azim+1].range[gtpos-1:gtpos+1])
        ;if ((dz2 ge 0) and (dzdr2 ge -2 ) and (dzdr2 le 6) and (vr2 gt -50 ) and (rhv2 ge 0.8)) then begin ;filtrando dados do radar
           if n_elements(first) eq 0 then begin
              dz=dz2
              vr=vr2
              dzdr=dzdr2
              rhv=rhv2
              kdp=kdp2
              ;rain_loc=rain_pos
              time_loc=time_radar
              first=0
              print,first
           endif else begin
              dz=[dz,dz2]
              vr=[vr,vr2]
              dzdr=[dzdr,dzdr2]
              rhv=[rhv,rhv2]
              kdp=[kdp,kdp2]
              ;rain_loc=[rain_loc,rain_pos]
              time_loc=[time_loc,time_radar]
           endelse
           rain_pos=where((rain.codigo eq estacao[i].codigo) and (rain.time eq time_radar))
           if rain_pos ne -1 then begin
              printf,4,estacao[i].codigo,r,theta,lat,lon,dia,hora,minuto,segundo,$
              rain[rain_pos].dado,rain[rain_pos].inst,dz2,dzdr2,kdp2,vr2,rhv2,$
              format='(i,1x,15(f,1x),f)'
           endif else begin
              printf,4,estacao[i].codigo,r,theta,lat,lon,dia,hora,minuto,segundo,$
              lixo,lixo,dz2,dzdr2,kdp2,vr2,rhv2,$
              format='(i,1x,15(f,1x),f)'
           endelse
        ;endif
     endif
  endfor
  print,f*100./n_elements(list_radar_file),format='(f5.2," %")'
endfor
save,dz,vr,dzdr,rhv,kdp,time_loc,/compress,filename='r-z_relation.idl'
close,4
end
