pro load_nav_polar_novimet,rlon,rlat

nx = 361
ny = 801
rlon = fltarr(nx,ny)
rlat = fltarr(nx,ny)

close,1
openr,1,'navegacao_polar_noviment.dat'
readu,1,rlon
readu,1,rlat
close,1


end
