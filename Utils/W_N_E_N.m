function [ Wnen ] = W_N_E_N( VnE, VnN, L, H )
%�ɶ����ٶ�VnE�������ٶ�VnN��γ��L�͸߶�H����Wnen��ENU����ϵ��

[RM,RN] = R_M_N(L);

Wnen = [-VnN/(RM + H);VnE/(RN + H);VnE/(RN + H)*tan(L)];
end
