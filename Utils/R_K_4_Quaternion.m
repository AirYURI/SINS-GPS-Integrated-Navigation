function [ Q_new ] = R_K_4_Quaternion( deltaT, Q, Wbnb_0, Wbnb_1, Wbnb_2 )
%ʹ���ļ��Ľ�����-����������ⳣ΢�ַ��̳�ֵ�����һ����ֵ�⣨��Ԫ��΢�ַ��̣�
%����������deltaT����ֵQ�����ٶȣ�Wbnb_0,Wbnb_1,Wbnb_2

k_1 = omega_matrix(Wbnb_0)*Q./2;
k_2 = omega_matrix(Wbnb_1)*(Q + deltaT/2*k_1)./2;
k_3 = omega_matrix(Wbnb_1)*(Q + deltaT/2*k_2)./2;
k_4 = omega_matrix(Wbnb_2)*(Q + deltaT*k_3)./2;
Q_new = Q + deltaT/6*(k_1 + 2*k_2 + 2*k_3 + k_4);
end
