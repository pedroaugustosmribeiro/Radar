  a=!const.R_earth               ; Earth radius (in m)
  az=0.15;1.701e-2
  bz=0.39;0.714
  azzdr=6.701e-3
  bzdr=-3.43
  czzdr=0.93
  akdp=19.63;44
  bkdp=0.823;0.822\
if !version.os_family eq 'Windows' then cd,'C:\Users\hp\OneDrive - usp.br\Iniciação Científica\Radar\Radar'
restore,'../Pluviometro/pluviometros.idl'
nlines=file_lines('out.txt')

;r=dblarr(nlines)
;theta=dblarr(nlines)
;lat=dblarr(nlines)
;lon=dblarr(nlines)
;dia=dblarr(nlines)
;hora=dblarr(nlines)
;minu=dblarr(nlines)
;seg=dblarr(nlines)
;dz=dblarr(nlines)
;dzdr=dblarr(nlines)
;kdp=dblarr(nlines)
radar_str={codigo:0,r:0d,theta:0d,lat:0.,lon:0.,dia:0.,hora:0.,minuto:0.,$
segundo:0.,dado_pluv:0.,pluv:0.,dz:0.,dzdr:0.,kdp:0.,vr:0.,rhv:0.}
radar=replicate(radar_str,nlines-1)
header=''
close,2
openr,2,'out.txt'
readf,2,header
;print,header
for i=0,nlines-2 do begin
   readf,2,radar_str;,format='(i0,1x,16f)';format='(i,1x,16(f,1x))'
   radar[i]=radar_str
;   r[i]=tr
;   theta[i]=ttheta
;   lat[i]=tlat
;   lon[i]=tlon
;   dia[i]=d
;   hora[i]=h
;   minu[i]=m
;   seg[i]=s
;   dz[i]=tz
;   dzdr[i]=tdr
;   kdp[i]=tkdp
endfor
close,2
invalid_pluv=where(radar.pluv eq -99999.,ninvalid_pluv,complement=valid_pluv,ncomplement=nvalid_luv,/NULL)
radar[invalid_pluv].pluv=!VALUES.F_NAN
valid_radar=where(radar.dz ge 0 and radar.dzdr ge -2 and radar.dzdr le 6 and radar.vr gt -50 and radar.rhv ge 0.8,$
  nvalid_radar,complement=invalid_radar,ncomplement=ninvalid_radar,/NULL);] and radar.pluv ne -99999)]
z=10d^(radar.dz/10d)
zdr=10d^(radar.dzdr/10d)
rz=(az*z^bz)/30
rzzdr=(azzdr*(zdr^bzdr)*(z^czzdr))/30
;rkdp=akdp*(kdp^bkdp)
rkdp=(akdp*(abs(radar.kdp)^bkdp)*radar.kdp/abs(radar.kdp))/30
;stop
pluvs=dblarr(4,n_elements(radar))
chuva_pluv_acum=fltarr(n_elements(estacao))
for i=0,n_elements(estacao)-1 do begin
   rloc=where(radar.codigo eq estacao[i].codigo,/null)
   if rloc ne !NULL then chuva_pluv_acum[i]=total(radar[rloc].pluv,/nan)
;   if rloc[0] ne -1 then pluvs[*,i]=[total(radar[rloc].pluv),total(rz[rloc]),total(rzzdr[rloc]),total(rkdp[rloc])]
endfor
;graf=scatterplot(pluvs[0,*],pluvs[1,*])
;device,decomposed=0
;print,estacao[where(estacao.asema eq (rain.asema)[rain_loc[0]])]
;plot,dz,alog(rain[rain_loc].inst*6),psym=5,background=255,color=0,title='R vs Z'
;data=[[time_loc],[rain_loc],[rz],[rzzdr],[rkdp]]
;data=imsl_sortdata(data,2)
end