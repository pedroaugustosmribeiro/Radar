@rsl_anyformat_to_radar.pro
@load_nav_polar_novimet.pro

dir_data  = 'MVOL/'
dir_out = 'Out_XPOL/'

fileradar = findfile(dir_data + '*',count=p1)

for ff=0,p1-1 do begin

   file = fileradar(ff)
   
   print,file
      
   radar=rsl_anyformat_to_radar(file)

   ano = radar.h.year
   mes = radar.h.month
   dia = radar.h.day
   hora = radar.h.hour
   minuto = radar.h.minute
   segundo = radar.h.sec

   yymmdd$ = string(ano,format='(i04)') + '-' + string(mes,format='(i02)') + "-" + string(dia,format='(i02)')
   hh$ = string(hora,format='(i02)')
   mi$ = string(minuto,format='(i02)')

   print,ano,mes,dia,hora,minuto

   fileout = dir_out + '/xpol_' + $
             yymmdd$ + '_' + hh$ + mi$ +'.idl'

;header = radar.volume.sweep.ray.h
   variaveis=radar.volume.h.field_type 
   print,variaveis
;DZ DR PH RH VR SW (refletividade, zdr, phidp, rhohv,radial, largura)

   lat_radar = float(radar.h.latd) + float(radar.h.latm)/60. + float(radar.h.lats)/3600. 
   lon_radar = float(radar.h.lond) + float(radar.h.lonm)/60. + float(radar.h.lons)/3600. 
      
   
   volscan = radar.volume.sweep.ray.range
   azimute = radar.volume.sweep.ray.h.azimuth

   gatesize=radar.volume.sweep.ray.h.GATE_SIZE
   binres=float(gatesize(0,0,0))/1000.
   
   alt_radar = float(radar.h.height)/1000.
   angle = radar.volume.sweep.h.elev
   
   ngates = radar.volume.sweep.ray.h.nbins
   nbins=ngates(0,0,0)
   xradar = findgen(nbins)*binres
   
   nsweep = radar.volume.h.nsweeps
   
   nelev = nsweep(0)
   nazim = radar.volume.sweep.h.nrays ; elevacao x variavel
   
   volscan_dbz = fltarr(nazim(0,1)+1,nbins)
   volscan_vel = fltarr(nazim(0,2)+1,nbins)
   volscan_zdr = fltarr(nazim(0,4)+1,nbins)
   volscan_kdp = fltarr(nazim(0,5)+1,nbins)
   volscan_rhv = fltarr(nazim(0,6)+1,nbins)
   volscan_pdp = fltarr(nazim(0,7)+1,nbins)
   
   volscan_dbz_clean = fltarr(nazim(0,1)+1,nbins)
   volscan_vel_clean = fltarr(nazim(0,1)+1,nbins)


   for ii=0,nbins-1 do begin
      for jj=0,359 do begin 
         
         jpos = fix(azimute(jj,0,1))
         if jpos ge 0 and jpos lt 360 then volscan_dbz(jpos,ii) = volscan(ii,jpos,0,1)
         
         jpos = fix(azimute(jj,0,2))
         if jpos ge 0 and jpos lt 360 then volscan_vel(jpos,ii) = volscan(ii,jpos,0,2)
         
         jpos = fix(azimute(jj,0,4))
         if jpos ge 0 and jpos lt 360 then volscan_zdr(jpos,ii) = volscan(ii,jpos,0,4)
         
         jpos = fix(azimute(jj,0,5))
         if jpos ge 0 and jpos lt 360 then volscan_kdp(jpos,ii) = volscan(ii,jpos,0,5)
         
         jpos = fix(azimute(jj,0,6))
         if jpos ge 0 and jpos lt 360 then volscan_rhv(jpos,ii) = volscan(ii,jpos,0,6)
         
         jpos = fix(azimute(jj,0,7))
         if jpos ge 0 and jpos lt 360 then volscan_pdp(jpos,ii) = volscan(ii,jpos,0,7)
                    
      endfor
   endfor

   volscan_dbz(360,*) = volscan_dbz(0,*)

   pos_lixo = where(volscan_dbz ge   0 and volscan_vel gt -50 and $
                    volscan_rhv gt 0.8 and volscan_zdr ge -2  and volscan_zdr le 6,plixo)

   if plixo gt 0 then begin

      ii=0L
      while ii lt plixo do begin

         ipos = pos_lixo(ii) mod 361
         jpos = pos_lixo(ii)/361

         zeff = 10^(volscan_dbz(ipos,jpos)/10.)
         zdr =  10^(volscan_zdr(ipos,jpos)/10.)
         
         lixo_rain = 0.0067*(zeff^0.927)*(zdr^(-3.43))
         if lixo_rain ge 0.1 then begin
            volscan_dbz_clean(ipos,jpos) = volscan_dbz(ipos,jpos)
            volscan_vel_clean(ipos,jpos) = volscan_vel(ipos,jpos)
         endif 
         ii=ii+1L
      endwhile
   endif

   lixo = fltarr(361,600)
   lixo(*,*) = volscan_dbz_clean(*,0:599) ; gravando 45 km
   save,lixo,filename=fileout

endfor   



end 
