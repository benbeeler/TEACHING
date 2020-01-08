function c = cFunc(region, state)
global k
tt = state.u./1000;
k = 1./(7.5408 + 17.629.*tt + 3.6142.*tt.^2);
c = k.*region.x;
end