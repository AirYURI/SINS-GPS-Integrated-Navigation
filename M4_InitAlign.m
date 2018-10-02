%���Ե���ϵͳ�ĳ�ʼ��׼��ENU����ϵ������ʽ����������

function [ psi, theta, gamma ] = M4_InitAlign( )
clc;clear;
close all;
addpath(genpath('Utils'));

%������ֵ
Weie = [0;0;7.292115e-5];
g_unit = 9.7803;
deltaT = 10e-3;

%INS����ֵ
dataPath = '../Data/';
fidOut = fopen([dataPath,'INS.txt'],'r');
initOut = fscanf(fidOut,'%e',[13,1]);
lambda = degree2radian(initOut(2));
L = degree2radian(initOut(3));
H = initOut(4);
g = G_LH(L,H);
[RM,RN] = R_M_N(L);
Cne = C_N_E(lambda,L);

%IMU���������ڴֶ�׼����������ƽ�������������Ӱ�죩
fidIn = fopen([dataPath,'IMU.txt'],'r');
Wbib = [];
Fb = [];
for i = 1:2500
    imu = fscanf(fidIn,'%e',[7,1]);
    Wbib = [Wbib [imu(5);imu(6);imu(7)]]; %#ok<*AGROW>
    Fb = [Fb [imu(2);imu(3);imu(4)]];
end
Wbib = sum(Wbib,2)./size(Wbib,2);
Fb = sum(Fb,2)./size(Fb,2);

%[����]��Ԫ�������ԡ���װ��ʽ��ϵͳ�ṹ��Ԥ��ȷ��
Fb = -Fb;

%�ֶ�׼
Vn_T_inv = [0 0 1/(g*Weie(3)*cos(L));tan(L)/g 1/(Weie(3)*cos(L)) 0;-1/g 0 0];
Vb_T = [Fb(1) Fb(2) Fb(3);Wbib(1) Wbib(2) Wbib(3);...
    Fb(2)*Wbib(3) - Fb(3)*Wbib(2) Fb(3)*Wbib(1) - Fb(1)*Wbib(3) Fb(1)*Wbib(2) - Fb(2)*Wbib(1)];
Tnb = Vn_T_inv*Vb_T;

%Tnb = orth(Tnb);%Tnb = Normalization(Tnb,1);%Tnb = Orthogonalization_Schmidt(Tnb);
[psi,theta,gamma] = AnttitudeAngle_Tnb(Tnb);
Tnb = T_N_B(psi,theta,gamma);

%������
disp('�ֶ�׼�����');
disp(['�ף�',num2str(radian2degree(psi)),'��']);
disp(['�ȣ�',num2str(radian2degree(theta)),'��']);
disp(['�ã�',num2str(radian2degree(gamma)),'��']);

%IMU����������һ�������ֶ�׼����������ƽ�������������Ӱ�죩
Wbib = [];
Fb = [];
for i = 1:2500
    imu = fscanf(fidIn,'%e',[7,1]);
    Wbib = [Wbib [imu(5);imu(6);imu(7)]];
    Fb = [Fb [imu(2);imu(3);imu(4)]];
end
Wbib = sum(Wbib,2)./size(Wbib,2);
Fb = sum(Fb,2)./size(Fb,2);

Fb = -Fb;

%һ�������ֶ�׼
Fn = Tnb*Fb;
Wnib = Tnb*Wbib;
%phi = [Fn(2)/g;-Fn(1)/g;Wnib(1)/(Weie(3)*cos(L)) - Fn(1)*tan(L)/g];
phi = [-Fn(2)/g;Fn(1)/g;Wnib(1)/(Weie(3)*cos(L)) + Fn(1)*tan(L)/g];
Tnb = (eye(3,3) + OmegaMatrix(phi))*Tnb;

%������
[psi,theta,gamma] = AnttitudeAngle_Tnb(Tnb);
disp('һ�������ֶ�׼�����');
disp(['�ף�',num2str(radian2degree(psi)),'��']);
disp(['�ȣ�',num2str(radian2degree(theta)),'��']);
disp(['�ã�',num2str(radian2degree(gamma)),'��']);

anttitude_res = [psi theta gamma];

%����׼���������˲���
%������
V_delta = 0.01;
W_epsilon = degree2radian(0.5)/3600;
W_d = degree2radian(0.5)/3600;
F_delta = 1e-5*g_unit;
F_d = 1e-5*g_unit;
PHI = degree2radian(1);

%��ֵ��ʼ��
Xk = [0 0 0 0 0 0 0 0 0 0]';
PHIx_0 = Xk(3);
f_PHIx_0 = PHIx_0;
Pk = diag([V_delta V_delta PHI PHI PHI F_delta F_delta W_epsilon W_epsilon W_epsilon].^2);
Q = diag([F_d F_d W_d W_d W_d 0 0 0 0 0].^2);
R = diag([V_delta V_delta].^2);

%ϵͳ����
F = zeros(10,10);
F(1,2) = 2*Weie(3)*sin(L);
F(2,1) = -2*Weie(3)*sin(L);
F(3,4) = Weie(3)*sin(L);
F(3,5) = -Weie(3)*cos(L);
F(4,3) = -Weie(3)*sin(L);
F(5,3) = Weie(3)*cos(L);
F(1,4) = -g;
F(2,3) = g;
%F(3,2) = -1/RM;
%F(4,1) = 1/RN;
%F(5,1) = tan(L)/RN;
F(3,2) = -1/(RM + H);
F(4,1) = 1/(RN + H);
F(5,1) = tan(L)/(RN + H);
F(1:2,6:7) = Tnb(1:2,1:2);
F(3:5,8:10) = Tnb;

G = eye(10);

%������
Hk = zeros(2,10);
Hk(1,1) = 1;
Hk(2,2) = 1;

%����ʱ��ϵͳ��ɢ��
PHIk_k_1 = eye(10) + F.*deltaT + F^2.*(deltaT^2/2);%һ��ת����
GAMMAk_1 = deltaT.*(eye(10) + F.*(deltaT/2) + F^2.*(deltaT^2/6))*G;%ϵͳ����������

%������������ֵ
Vn = [0;0;0];%Zk
Fb = -Fb;
Wnen = W_N_E_N(Vn(1),Vn(2),L,H);
d_Vn_0 = d_V_N(Tnb,Fb,Wnen,Cne,Vn,g);

%err = 1;%epsilon = 1e-20;%phi_0 = [pi;pi];
prog = 1;
PHI_res = [];
%�����˲�
%while((prog <= 55000)&&(err > epsilon))
while((prog <= 55000))
    %��IMU���ݣ�������������
    imu = fscanf(fidIn,'%e',[7,1]);
    Fb = [imu(2);imu(3);imu(4)];
    
    d_Vn = d_V_N(Tnb,Fb,Wnen,Cne,Vn,g);
    
    Vn(1) = R_K_2(deltaT,Vn(1),d_Vn_0(1),d_Vn(1));
    Vn(2) = R_K_2(deltaT,Vn(2),d_Vn_0(2),d_Vn(2));
    
    d_Vn_0 = d_Vn;
    
    Wnen = W_N_E_N(Vn(1),Vn(2),L,H);
    
    %��ɢ�Ϳ������˲���������
    Pk_k_1 = PHIk_k_1*Pk*PHIk_k_1' + GAMMAk_1*Q*GAMMAk_1';
    Kk = Pk_k_1*Hk'/(Hk*Pk_k_1*Hk' + R);
    %Pk = inv(inv(Pk_k_1) + Hk'/R*Hk);
    Pk = (eye(10) - Kk*Hk)*Pk_k_1*(eye(10) - Kk*Hk)' + Kk*R*Kk';
    Xk_k_1 = PHIk_k_1*Xk;
    Xk = Xk_k_1 + Kk*(Vn(1:2,:) - Hk*Xk_k_1);
    
    %��ͨ�˲�
    f_PHIx = Filter_PHIx(PHIx_0,Xk(3),f_PHIx_0);
    %d_phi_x = F(3,:)*Xk;
    d_phi_x = (f_PHIx - f_PHIx_0)./deltaT;
    PHIx_0 = Xk(3);
    f_PHIx_0 = f_PHIx;
    
    %������̬��
    phi_z = (-d_phi_x + Xk(4)*Weie(3)*sin(L) - Xk(2)/RM)/(Weie(3)*cos(L));
    phi = [Xk(3:4);phi_z];
    Tnb_k = (eye(3,3) + OmegaMatrix(phi))*Tnb;
    [psi,theta,gamma] = AnttitudeAngle_Tnb(Tnb_k);
    anttitude_res = [anttitude_res;[psi theta gamma]];
    
    PHI_res = [PHI_res [Xk(3:5);phi_z]];
    
    %phi = phi(1:2);
    %err = max([RelativeError(phi_0(1),phi(1)) RelativeError(phi_0(2),phi(2))]);
    %phi_0 = phi;
    disp(prog);
    prog = prog + 1;
end

%��ͼ
figure;
anttitude_res = radian2degree(anttitude_res);
index = (0:size(anttitude_res,1) - 1).*deltaT;

PHI_res = radian2degree(PHI_res); %#ok<NASGU>

subplot(1,3,1)
plot(index,anttitude_res(:,1),'m-')
xlim([0 550])
title('ƫ���ǳ�ʼ��׼���')
xlabel('t/s')
ylabel('��/��')
hold on;
subplot(1,3,2)
plot(index,anttitude_res(:,2),'m-')
xlim([0 550])
title('�����ǳ�ʼ��׼���')
xlabel('t/s')
ylabel('��/��')
hold on;
subplot(1,3,3)
plot(index,anttitude_res(:,3),'m-')
xlim([0 550])
title('����ǳ�ʼ��׼���')
xlabel('t/s')
ylabel('��/��');

fclose(fidIn);
fclose(fidOut);
disp('���Ե���ϵͳ��ʼ��׼������');
end
