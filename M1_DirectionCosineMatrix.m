%���ڷ������Ҿ����������̬�������ENU����ϵ��

function [ ] = M1_DirectionCosineMatrix( )
clc;clear;
close all;
addpath(genpath('Utils'));

%������
Weie = [0;0;7.292115e-5];%������ת���ٶ�
deltaT = 10e-3*2;%�������ݲ�������

%��ʼ��
dataPath = '../Data/';%�����ļ���ŵ�ַ
fidOut = fopen([dataPath,'INS.txt'],'r');%�ߵ���������1.�ṩ����ĳ�ʼ״̬��2.��������ͼʱ��Ϊ�ο�ֵ��
initOut = fscanf(fidOut,'%e',[13,1]);
psi_0 = degree2radian(initOut(11));%ƫ���Ǧ�
theta_0 = degree2radian(initOut(12));%�����Ǧ�
gamma_0 = degree2radian(initOut(13));%����Ǧ�
lambda_0 = degree2radian(initOut(2));%���Ȧ�
L_0 = degree2radian(initOut(3));%γ��L
num = 0;

%��ʼ����
Tnb_0 = T_N_B(psi_0,theta_0,gamma_0);%�������Ҿ���
Cne_0 = C_N_E(lambda_0, L_0);%λ�þ���
Wnie_0 = Cne_0*Weie;
Wnen_0 = [0;0;0];%����������

%�����ʼWbib_0������Wbnb_0
fidIn = fopen([dataPath,'IMU.txt'],'r');%��������Ĵ���������
imu_0 = fscanf(fidIn,'%e',[7,1]);
Wbib_0 = [imu_0(5);imu_0(6);imu_0(7)];%����������

Wnin_0 = Wnie_0 + Wnen_0;
Wbnb_0 = Wbib_0 - Tnb_0'*Wnin_0;

%��̬����
Tnb = Tnb_0;
plotIndex = 1;
figure;
while(fseek(fidIn,2,0) == 0)
    %����δ����
    fseek(fidIn,-2,0);
    
    %��IMU������Wbnb
    imu = fscanf(fidIn,'%e',[7,1]);
    Wbib = [imu(5);imu(6);imu(7)];
    
    Wnin = Wnie_0 + Wnen_0;
    Wbnb = Wbib - Tnb'*Wnin;
    num = num + 1;
    
    if(num ~= 1)
        %�Ѷ�ȡ����0������1������2
        %����Tnb
        Tnb = R_K_4_DirectionCosineMatrix(deltaT,Tnb,Wbnb_0,Wbnb_1,Wbnb);
        
        %������
        Tnb = Orthogonalization_Tnb(Tnb);
        
        %����psi, theta, gamma
        [psi,theta,gamma] = AnttitudeAngle_Tnb(Tnb);
        
        Wbnb_0 = Wbnb;
        num = 0;
        %��ͼ
        if(mod(plotIndex*2,100) == 0)%ÿ50����������Ӧ1����׼������
            ins = fscanf(fidOut,'%e',[13,1]);
            psi_s = degree2radian(ins(11));
            theta_s = degree2radian(ins(12));
            gamma_s = degree2radian(ins(13));
            
            subplot(2,2,1)
            plot(plotIndex*deltaT,psi_s,'m*',plotIndex*deltaT,psi,'b.')
            title('ƫ���ǽ�����')
            xlabel('t/s')
            ylabel('��/rad')
            legend('��׼','���','Location','northwest')
            hold on;
            subplot(2,2,2)
            plot(plotIndex*deltaT,theta_s,'m*',plotIndex*deltaT,theta,'b.')
            title('�����ǽ�����')
            xlabel('t/s')
            ylabel('��/rad')
            legend('��׼','���','Location','southeast')
            hold on;
            subplot(2,2,3)
            plot(plotIndex*deltaT,gamma_s,'m*',plotIndex*deltaT,gamma,'b.')
            title('����ǽ�����')
            xlabel('t/s')
            ylabel('��/rad')
            legend('��׼','���','Location','southwest')
            hold on;
            subplot(2,2,4)
            plot(plotIndex*deltaT,psi_s - psi,'m.',plotIndex*deltaT,theta_s - theta,'b.',plotIndex*deltaT,gamma_s - gamma,'c.')
            title('���������')
            xlabel('t/s')
            ylabel('��/rad')
            legend('��','��','��','Location','northwest')
            hold on;
            drawnow;
        end
        plotIndex = plotIndex + 1;
    else
        %�Ѷ�ȡ����0������1
        Wbnb_1 = Wbnb;
    end
end

fclose(fidIn);
fclose(fidOut);
disp('���ڷ������Ҿ������̬���������');
end
