function [ Tnb_new ] = R_K_4_DirectionCosineMatrix( deltaT, Tnb, Wbnb_0, Wbnb_1, Wbnb_2 )
%ʹ���ļ��Ľ�����-����������ⳣ΢�ַ��̳�ֵ�����һ����ֵ�⣨�������Ҿ���΢�ַ��̣�
%����������deltaT����ֵTnb�����ٶȣ�Wbnb_0,Wbnb_1,Wbnb_2

k_1 = Tnb*OmegaMatrix(Wbnb_0);
k_2 = (Tnb + deltaT/2*k_1)*OmegaMatrix(Wbnb_1);
k_3 = (Tnb + deltaT/2*k_2)*OmegaMatrix(Wbnb_1);
k_4 = (Tnb + deltaT*k_3)*OmegaMatrix(Wbnb_2);
Tnb_new = Tnb + deltaT/6*(k_1 + 2*k_2 + 2*k_3 + k_4);
end
