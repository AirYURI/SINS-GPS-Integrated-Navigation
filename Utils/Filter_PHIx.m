function [ Yk ] = Filter_PHIx( Xk_1, Xk, Yk_1 )
%��ˮƽ����PHIx����һ�׵�ͨ�˲���Ref��������.һ���µĹߵ�ϵͳ���������ٳ�ʼ��׼����[J].�������պ����ѧѧ��,1999(06):728-731.��

T = 10e-3;
Wdc = 0.001256;
Wac = tan(Wdc*T/2)*2/T;

Yk = Wac*T/2/(1 + Wac*T/2)*(Xk + Xk_1) + (1 - Wac*T/2)/(1 + Wac*T/2)*Yk_1;
end
