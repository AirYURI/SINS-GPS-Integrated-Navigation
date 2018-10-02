function [ RM, RN ] = R_M_N( L )
%��γ��L����������������ʰ뾶RM��î��Ȧ���ʰ뾶RN

Re = 6378137;
f = 1/298.257;

RM = Re*(1 - 2*f + 3*f*(sin(L))^2);
RN = Re*(1 + f*(sin(L))^2);
end
