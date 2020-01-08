function d = dFunc(region, state) 
global density cp;
d = density*cp*region.x;
end