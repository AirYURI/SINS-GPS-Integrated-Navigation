function [ F_new ] = R_K_2( deltaT, F, d_F_0, d_F )
%ʹ�ö�����������-����������ⳣ΢�ַ��̳�ֵ�����һ����ֵ�⣨�ദ���ã�
%����������deltaT����ֵF��΢�ֳ�ֵd_F_0��΢��d_F

F_new = F + deltaT/2*(d_F_0 + d_F);
end
