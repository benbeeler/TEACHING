function f = fFunc(region, state) 
global Q;
f = Q(region.y).*region.x;
end