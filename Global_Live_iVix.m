%% 0. ׼���趨
clc
clear all
addpath('0.Data\')
addpath('1.GUI\')
addpath('2.Pic\')
addpath('3.Protected\')
addpath('4.Temp\')
Protected_Config;
global cSetupPlatform

%% 1. ��ȡ��Ȩ�б�
Protected_Fetch_OptionList;

%% 2. �ϵ�����
Protected_Load_Today;

%% 2. ��ѭ��
disp('Main Loop Start')
while true
    dNow = datevec(now);
    nNow = dNow(4) * 100 + dNow(5);
    if (nNow >= 0930 && nNow<= 1130) || (nNow >= 1300 && nNow <= 1500)
        % 2.1 ��ȡʵʱ��Ȩ����
        Protected_Fetch_OptionMarketData;
        
        % 2.2 ����ʵʱivix
        Protected_Cal_Vix;

        % 2.3 GUI����
        try
            GUI_Fig;
        catch
            if cSetupPlatform.GUI.IsOpen
            else
                Protected_Save_Data;
            end
        end
        
    elseif nNow > 1500
        %% 3 ���̺�����ռ����ݽ���
        Protected_Save_Data;
        break
        
    else
        %% 4 �����Լ�������Ϣ
        if nNow ~= 1135
        else
            Protected_Save_Data;
            Protected_Send_Mail;
            pause(60)
        end
        
    end
end

%% 4. ���̺���㵱��vixָ��
Protected_Send_Mail;
