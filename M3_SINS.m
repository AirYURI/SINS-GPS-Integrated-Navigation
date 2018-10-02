%����ʽ���Ե���ϵͳ�������ENU����ϵ��

function [ ] = M3_SINS( )
clc;clear;
close all;
addpath(genpath('Utils'));

%������ֵ
Weie = [0;0;7.292115e-5];
%Re = 6378137;f = 1/298.257;g0 = 9.7803;
deltaT = 10e-3;
k1 = 3.828;%�߶�ͨ����������ϵͳ������Ref�����Ե�������P123.��
k2 = 3.2804;

%INS����ֵ
dataPath = '../Data/';
fidOut = fopen([dataPath,'INS.txt'],'r');
initOut = fscanf(fidOut,'%e',[13,1]);
lambda_0 = degree2radian(initOut(2));
L_0 = degree2radian(initOut(3));
H_0 = initOut(4);
Vn_0 = [initOut(5);initOut(6);initOut(7)];
psi_0 = degree2radian(initOut(11));
theta_0 = degree2radian(initOut(12));
gamma_0 = degree2radian(initOut(13));
num = 0;

%��ʼ����
Tnb_0 = T_N_B(psi_0,theta_0,gamma_0);
Q_0 = Q_AnttitudeAngle(psi_0,theta_0,gamma_0);
Cne_0 = C_N_E(lambda_0, L_0);

%����Wnen_0
Wnen_0 = W_N_E_N(Vn_0(1),Vn_0(2),L_0,H_0);
Wnin_0 = Cne_0*Weie + Wnen_0;
g_0 = G_H(H_0);

%IMU��Wbib_0��Fb_0������Wbnb_0��d_Vn_0
fidIn = fopen([dataPath,'IMU.txt'],'r');
imu_0 = fscanf(fidIn,'%e',[7,1]);
Wbib_0 = [imu_0(5);imu_0(6);imu_0(7)];
Wbnb_0 = Wbib_0 - Tnb_0'*Wnin_0;
Fb_0 = [imu_0(2);imu_0(3);imu_0(4)];
d_Vn_0 = d_V_N(Tnb_0,Fb_0,Wnen_0,Cne_0,Vn_0,g_0);
%HIGH��Hc_0
fidHc = fopen([dataPath,'HIGH.txt'],'r');
high_0 = fscanf(fidHc,'%e',[3,1]);
Hc_0 = high_0(3);

%H��VnE��VnN��VnU���㣨d_Vn��������R-K����
%lambda��L��psi��theta��gamma���㣨d_Q,d_Cne�����ļ�R-K����
L = L_0;
H = H_0;
H_d = H_0;
Tnb = Tnb_0;
Wnen = Wnen_0;
Cne = Cne_0;
Vn = Vn_0;
VnU_d = Vn_0(3);
Q = Q_0;
d_VnU_d = d_Vn_0(3);
prog = 1;
anttitude_res = [];
location_res = [];
high_res = [];
speed_res = [];
while(fseek(fidIn,2,0) == 0)
    %����δ����
    fseek(fidIn,-2,0);
    
    g = G_H(H);
    
    %IMU��Wbib��Fb
    imu = fscanf(fidIn,'%e',[7,1]);
    Wbib = [imu(5);imu(6);imu(7)];
    Fb = [imu(2);imu(3);imu(4)];
    num = num + 1;
    
    d_Vn = d_V_N(Tnb,Fb,Wnen,Cne,Vn,g);
    Vn(1) = R_K_2(deltaT,Vn(1),d_Vn_0(1),d_Vn(1));
    Vn(2) = R_K_2(deltaT,Vn(2),d_Vn_0(2),d_Vn(2));
    Vn(3) = R_K_2(deltaT,Vn(3),d_Vn_0(3),d_Vn(3));
    H = R_K_2(deltaT,H,Vn_0(3),Vn(3));
    if(num == 4)
        %HIGH��Hc
        high = fscanf(fidHc,'%e',[3,1]);
        Hc = high(3);
        
        Vn(3) = R_K_2(deltaT*4,VnU_d,d_VnU_d - k2*(H_d - Hc_0),d_Vn(3) - k2*(H - Hc));
        H = R_K_2(deltaT*4,H_d,VnU_d - k1*(H_d - Hc_0),Vn(3) - k1*(H - Hc));
        num = 0;
        
        Hc_0 = Hc;
        VnU_d = Vn(3);
        H_d = H;
        d_VnU_d = d_Vn(3);
    end
    speed_res = [speed_res;Vn']; %#ok<*AGROW>
    high_res = [high_res;H];
    
    d_Vn_0 = d_Vn;
    Vn_0 = Vn;
    
    Wnen = W_N_E_N(Vn(1),Vn(2),L,H);
    Wnin = Cne*Weie + Wnen;
    Wbnb = Wbib - Tnb'*Wnin;
    
    if(mod(num,2) == 0)
        %�Ѷ�ȡ����0������1������2
        %����Q
        Q = R_K_4_Quaternion(deltaT*2,Q,Wbnb_0,Wbnb_1,Wbnb);
        Wbnb_0 = Wbnb;
        
        %��һ��
        Q = Normalization_Q(Q);
        
        %����Cne
        Cne = R_K_4_C_N_E(deltaT*2,Cne,Wnen_0,Wnen_1,Wnen);
        Wnen_0 = Wnen;
        
        %����Tnb
        Tnb = T_N_B_Quaternion(Q);
        
        %����psi��theta��gamma
        [psi,theta,gamma] = AnttitudeAngle_Tnb(Tnb);
        anttitude_res = [anttitude_res;[psi theta gamma]];
        
        %����lambda��L
        [lambda,L] = Location_Cne(Cne);
        location_res = [location_res;[lambda L]];
        
        disp(prog);
        prog = prog + 1;
    else
        %�Ѷ�ȡ����0������1
        Wnen_1 = Wnen;
        Wbnb_1 = Wbnb;
    end
end

%��ͼ
figure;
ins = fscanf(fidOut,'%e');
%���ݶ���
ins = reshape(ins,13,size(ins,1)/13)';
anttitude_base = degree2radian(ins(:,11:13));
location_base = [degree2radian(ins(:,2:3)) ins(:,4)];
speed_base = ins(:,5:7);
anttitude_res = anttitude_res(50:50:29950,:);
location_res = location_res(50:50:29950,:);
high_res = high_res(100:100:59900,:);
speed_res = speed_res(100:100:59900,:);
index = (1:599).*(deltaT*100);

subplot(3,4,1)
plot(index,anttitude_base(:,1),'m-',index,anttitude_res(:,1),'b-')
title('ƫ���ǽ�����')
xlabel('t/s')
ylabel('��/rad')
legend({'��׼','���'},'FontSize',8,'Location','best')
hold on;
subplot(3,4,2)
plot(index,anttitude_base(:,2),'m-',index,anttitude_res(:,2),'b-')
title('�����ǽ�����')
xlabel('t/s')
ylabel('��/rad')
legend({'��׼','���'},'FontSize',8,'Location','best')
hold on;
subplot(3,4,3)
plot(index,anttitude_base(:,3),'m-',index,anttitude_res(:,3),'b-')
title('����ǽ�����')
xlabel('t/s')
ylabel('��/rad')
legend({'��׼','���'},'FontSize',8,'Location','best')
hold on;
subplot(3,4,4)
plot(index,anttitude_base(:,1) - anttitude_res(:,1),'m-',index,anttitude_base(:,2) - anttitude_res(:,2),'b-',index,anttitude_base(:,3) - anttitude_res(:,3),'c-')
title('��̬���������')
xlabel('t/s')
ylabel('��/rad')
legend({'��','��','��'},'FontSize',8,'Location','best');

subplot(3,4,5)
plot(index,speed_base(:,1),'m-',index,speed_res(:,1),'b-')
title('�����ٶȽ�����')
xlabel('t/s')
ylabel('VE/(m/s)')
legend({'��׼','���'},'FontSize',8,'Location','best')
hold on;
subplot(3,4,6)
plot(index,speed_base(:,2),'m-',index,speed_res(:,2),'b-')
title('�����ٶȽ�����')
xlabel('t/s')
ylabel('VN/(m/s)')
legend({'��׼','���'},'FontSize',8,'Location','best')
hold on;
subplot(3,4,7)
plot(index,speed_base(:,3),'m-',index,speed_res(:,3),'b-')
title('�����ٶȽ�����')
xlabel('t/s')
ylabel('VU/(m/s)')
legend({'��׼','���'},'FontSize',8,'Location','best')
hold on;
subplot(3,4,8)
plot(index,speed_base(:,1) - speed_res(:,1),'m-',index,speed_base(:,2) - speed_res(:,2),'b-',index,speed_base(:,3) - speed_res(:,3),'c-')
title('�ٶȽ��������')
xlabel('t/s')
ylabel('��/(m/s)')
legend({'VE','VN','VU'},'FontSize',8,'Location','best');

subplot(3,4,9)
plot(index,location_base(:,1),'m-',index,location_res(:,1),'b-')
title('���Ƚ�����')
xlabel('t/s')
ylabel('��/rad')
legend({'��׼','���'},'FontSize',8,'Location','best')
hold on;
subplot(3,4,10)
plot(index,location_base(:,2),'m-',index,location_res(:,2),'b-')
title('γ�Ƚ�����')
xlabel('t/s')
ylabel('L/rad')
legend({'��׼','���'},'FontSize',8,'Location','best')
hold on;
subplot(3,4,11)
plot(index,location_base(:,3),'m-',index,high_res,'b-')
title('�߶Ƚ�����')
xlabel('t/s')
ylabel('H/m')
legend({'��׼','���'},'FontSize',8,'Location','best')
hold on;
subplot(3,4,12)
yyaxis left
plot(index,location_base(:,1) - location_res(:,1),index,location_base(:,2) - location_res(:,2))
ylabel('��/rad')
yyaxis right
plot(index,location_base(:,3) - high_res)
ylabel('��/m')
title('λ�ý��������','FontSize',10)
xlabel('t/s')
legend({'��','L','H'},'FontSize',8,'Location','northeast');

fclose(fidIn);
fclose(fidOut);
fclose(fidHc);
disp('�����ߵ����ݽ��������');
end
