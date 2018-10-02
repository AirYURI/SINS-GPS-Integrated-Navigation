function [ Cne ] = C_N_E( lambda, L )
%�ɾ���lambda��γ��L��������λ�þ���Cne

S_lambda = sin(lambda);
S_L = sin(L);
C_lambda = cos(lambda);
C_L = cos(L);

Cne = [-S_lambda C_lambda 0;...
    -S_L*C_lambda -S_L*S_lambda C_L;...
    C_L*C_lambda C_L*S_lambda S_L];
end
