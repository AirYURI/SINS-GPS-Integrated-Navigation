function [ g ] = G_H( H )
%�ɸ߶�H�����������ٶ�g

Re = 6378137;
g0 = 9.7803;

g = g0*(1 - 2*H/Re);
end
