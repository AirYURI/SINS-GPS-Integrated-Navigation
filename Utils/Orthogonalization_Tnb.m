function [ Tnb_new ] = Orthogonalization_Tnb( Tnb )
%�������Ҿ���Tnb������

Tbn = Tnb';
for i=1:3
    Tbn = (Tbn + inv(Tbn'))/2;
end
Tnb_new = Tbn';
end
