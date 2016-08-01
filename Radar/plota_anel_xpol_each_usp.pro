@load_nav_polar_novimet.pro


rmax = 50.

device,decompose=0
read_png,'tab_reflectibity2.png',img,red,green,blue
tvlct,red,green,blue

load_nav_polar_novimet,xpol_lon,xpol_lat
nbin = (rmax/0.075) - 1
print,nbin
xpol_lon = xpol_lon(*,0:nbin)
xpol_lat = xpol_lat(*,0:nbin)

load_nav_polar_usp_each,xpolar_pelletron,ypolar_pelletron,$
                        xpolar_each,ypolar_each

lon_each = xpolar_each(0,0)
lat_each = ypolar_each(0,0)

lon_usp = xpolar_pelletron(0,0)
lat_usp = ypolar_pelletron(0,0)

lon_xpol = xpol_lon(0,0)
lat_xpol = xpol_lat(0,0)

lonc = (lon_xpol + lon_usp + lon_each)/3.
latc = (lat_xpol + lat_usp + lat_each)/3.




dx=0.5
dy = 0.4
lon0 = -46.946592-dx
lon1 = -46.289584+dx
lat0 = -23.755570-dy
lat1 = -23.288351+dy-0.2
   
dx_win = 1491/3
dy_win = 1154/3


window,0, xsize=dx_win,ysize=dy_win
!P.MULTI=[0,1,1]
map_set,0,0,limit=[lat0,lon0,lat1,lon1],position=[0,0,1,1],/noborder,/mercator,/isotropic
plota_rmsp
plots,xpolar_pelletron(*,239),ypolar_pelletron(*,239),psym=3,color=61
plots,xpolar_each(*,239),ypolar_each(*,239),psym=3,color=61
plots,xpol_lon(*,nbin),xpol_lat(*,nbin),color=61
map_continents,/hires,color=61

plots,lonc,latc,psym=1,color=50,symsize=3
raio = 40.
x1 = fltarr(361)
y1 = fltarr(361)
for teta=0,360 do begin
   RAIO1=RAIO/6371.
   RESUL = LL_ARC_DISTANCE([LONC,LATC],RAIO1,TETA,/DEGREE)
   X1(TETA) = RESUL(0)
   Y1(TETA) = RESUL(1)
ENDFOR
PLOTS,X1,Y1,COLOR=20,LINESTYLE=2

   

end 
