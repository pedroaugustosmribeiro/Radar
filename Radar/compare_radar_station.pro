;pro compare_radar_station
  if !version.os_family eq 'Windows' then cd,'G:\Pedro Augusto\Meteorologia USP\Google Cloud\Iniciação Científica\Radar\Radar'
  device,decomposed=0
  list_radar_file='./MVOL/'+file_basename(file_search('./MVOL/*.gz'))
  file_pluv='../Pluviometro/pluviometros.idl'
  restore,filename=file_pluv
  a=6378136.6                   ; Earth radius (in m)
  az=0.15;1.701e-2
  bz=0.39;0.714
  azzdr=6.701e-3
  bzdr=-3.43
  czzdr=0.93
  akdp=19.63;44
  bkdp=0.823;0.822\

  close,4
  openw,4,'./out.txt'
  printf,4,'r(km) Theta P(mm) R(mm/h) Z(dbZ) Zdr(dbZr) Kdp(o/km)'

  for f=0,n_elements(list_radar_file)-1 do begin

  file_radar=list_radar_file[f]
  radar=rsl_anyformat_to_radar(file_radar,/quiet)
  time_radar=julday(radar.h.month,radar.h.year,radar.h.day,radar.h.hour,radar.h.minute)
  lat_radar = float(radar.h.latd) + float(radar.h.latm)/60. + float(radar.h.lats)/3600.
  lon_radar = float(radar.h.lond) + float(radar.h.lonm)/60. + float(radar.h.lons)/3600.
  voldz=rsl_get_volume(radar,'dz')
  volvr=rsl_get_volume(radar,'vr')
  voldr=rsl_get_volume(radar,'dr')
  volrhv=rsl_get_volume(radar,'rh')
  volkdp=rsl_get_volume(radar,'kd')

  for i=0,n_elements(estacao)-1 do begin
     lat=estacao[i].lat
     lon=estacao[i].lon
     r=map_2points(lon,lat,lon_radar,lat_radar,/meters,radius=a)/1000.
     theta=((map_2points(lon_radar,lat_radar,lon,lat))[1]+360) mod 360
     if r le 60.075 then begin
        raydz=rsl_get_ray(voldz,0.,theta)
        rayvr=rsl_get_ray(volvr,0.,theta)
        raydr=rsl_get_ray(voldr,0.,theta)
        rayrhv=rsl_get_ray(volrhv,0.,theta)
        raykdp=rsl_get_ray(volkdp,0.,theta)
        binres=raydz.h.gate_size/1000.
        gtpos=(r/binres)-0.5
        dz2=raydz.range[gtpos]
        vr2=rayvr.range[gtpos]
        dzdr2=(raydr.range[gtpos])
        rhv2=rayrhv.range[gtpos]
        kdp2=raykdp.range[gtpos]
        time_ray=julday(raydz.h.month,raydz.h.year,raydz.h.day,raydz.h.hour,raydz.h.minute)
        rain_pos=where((rain.asema eq estacao[i].asema) and (rain.time eq time_ray))
        if ((dz2 ge 0) and (dzdr2 ge -2 ) and (dzdr2 le 6) and (vr2 gt -50 ) and (rhv2 ge 0.8) and (rain_pos ge 0)) then begin
           if n_elements(first) eq 0 then begin
              dz=raydz.range[gtpos]
              vr=rayvr.range[gtpos]
              dzdr=raydr.range[gtpos]
              rhv=rayrhv.range[gtpos]
              kdp=raykdp.range[gtpos]
              rain_loc=rain_pos
              first=0
           endif else begin
              dz=[dz,raydz.range[gtpos]]
              vr=[vr,rayvr.range[gtpos]]
              dzdr=[dzdr,(raydr.range[gtpos])]
              rhv=[rhv,rayrhv.range[gtpos]]
              kdp=[kdp,raykdp.range[gtpos]]
              rain_loc=[rain_loc,rain_pos]
           endelse
           printf,4,r,theta,rain[rain_pos].rain,rain[rain_pos].inst*6,raydz.range[gtpos],$
           raydr.range[gtpos],raykdp.range[gtpos],format='(6(f,1x),f)'
        endif
     endif
  endfor
  print,f*100./n_elements(list_radar_file),format='(f5.2," %")'
  endfor
  z=10d^(dz/10d)
  zdr=10d^(dzdr/10d)
  rz=az*z^bz
  rzzdr=azzdr*(zdr^bzdr)*(z^czzdr)
  rkdp=akdp*(kdp^bkdp)
  ;rkdp=akdp*(abs(kdp)^bkdp)*kdp/abs(kdp)
  close,4
end
