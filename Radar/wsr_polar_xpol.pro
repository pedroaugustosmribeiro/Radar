lon_radar = -46.6231
lat_radar = -23.6519


nx = 361
ny = 801
res = 75./1000.

lon_lat = [lon_radar,lat_radar]
rlon = fltarr(nx,ny)
rlat = fltarr(nx,ny)

raio=findgen(ny)*res + res/2.

for i=0,nx-1 do begin
    for j=0,ny-1 do begin
        dist1=raio(j)/6371.
        angle=i
        resul = ll_arc_distance(lon_lat,dist1,angle,/degrees)

        rlon(i,j) = resul(0)
        rlat(i,j) = resul(1)

   ENDFOR
ENDFOR


close,1
openw,1,'navegacao_polar_noviment.dat'
writeu,1,rlon
writeu,1,rlat
close,1


end
