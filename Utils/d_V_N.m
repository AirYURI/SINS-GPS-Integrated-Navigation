function [ d_Vn ] = d_V_N( Tnb, Fb, Wnen, Cne, Vn, g )
%�ɷ������Ҿ���Tnb������Fb�����ٶ�Wnen��λ�þ���Cne���ٶ�Vn���������ٶ�g����������ٶ�d_Vn

Weie = [0;0;7.292115e-5];

d_Vn = Tnb*Fb - (2.*OmegaMatrix(Cne*Weie) + OmegaMatrix(Wnen))*Vn - [0;0;g];
end
