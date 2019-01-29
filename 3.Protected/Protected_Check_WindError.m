% _Author : Frontal Xiang
%_Version: V 1.0.0
%_Describe: �ж�wind�Ƿ񱨴��׳�������ʾ
%_Update: 20171120 ��ɻ����������
%               20171228 �޸�warningΪdisp
%_Input: null
%_Output:null
%*******************************************************************
function [nIsError, sErrorMesg] = Protected_Check_WindError(nErrorID)
%% 0.ȫ�ֱ���
global cSetupPlatform

%% 1. �ȶ��Ƿ�������ݴ���
cErrorList = cSetupPlatform.Wind.ErrorList;
dLocated = [cErrorList{:, 1}] == nErrorID;

if ~sum(dLocated)
    cSetupPlatform.Wind.Status = '����';
    nIsError = false;
    sErrorMesg = [];
else
    sError = cErrorList{dLocated, 2};
    nIsError = true;
    cSetupPlatform.Wind.Status = ['Wind API Error, Error Code : ', num2str(nErrorID), ' ; ', sError];
    sErrorMesg = cSetupPlatform.Wind.Status;
end
end