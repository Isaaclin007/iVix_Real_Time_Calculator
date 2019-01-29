function vix_data=cboe_vix_cal(option_list,current_date)
%% ����������CBOE VIX INDEXָ��
%   ʱ�䣺2018.2.26
    min_date=option_list.call_a.(current_date){1,12};
    sec_date=option_list.call_b.(current_date){1,12};
    
    %% �������ֻ���ĸ���Ȩ����vixָ��
    %   ��һ������������մ��ڵ���30����Ȼ��
    %   �ڶ��������������С�ڵ���5����Ȼ���ҵڶ������մ��ڵ���30����Ȼ��
    if (min_date>=30) || (min_date<=5 && sec_date>=30)
        disp('������ѡ�����·ݺ�Լ����vixָ��')
        if min_date>=30
            target_type='_a';
        else
            target_type='_b';
        end
        sample_info.type=target_type;
        sample_info.class=2;
        vix_data=vix_index(sample_info,option_list,current_date);
    else
        disp('������ѡ�����·ݺ�Լ����vixָ��')
        if (min_date>5 && min_date<30)
            target_type_1='_a';
            target_type_2='_b';
        else
            target_type_1='_b';
            target_type_2='_c';
        end
        sample_info.type_1=target_type_1;
        sample_info.type_2=target_type_2;
        sample_info.class=1;
        vix_data=vix_index(sample_info,option_list,current_date);
    end
end

function vix_data=vix_index(sample_info,option_list,current_date)
    if sample_info.class==1
        %% ����ѡ�����·�����ʱ
        vix_comp_1=vix_cal(sample_info.type_1,option_list,current_date);
        remain_time_1=(option_list.(['call' sample_info.type_1]).(current_date){1,12}-1)*24*60;
        remain_time_1=double(remain_time_1);
        time_ratio_1=remain_time_1/(365*24*60);
        vix_comp_2=vix_cal(sample_info.type_2,option_list,current_date);
        remain_time_2=(option_list.(['call' sample_info.type_2]).(current_date){1,12}-1)*24*60;
        remain_time_2=double(remain_time_2);
        time_ratio_2=remain_time_2/(365*24*60);
        weight=(remain_time_2-30*24*60)/(remain_time_2-remain_time_1);
        vix_data=100*sqrt(time_ratio_1*vix_comp_1^2*weight+time_ratio_2*vix_comp_2^2*(1-weight))*sqrt(365/30);
    elseif sample_info.class==2
        %% ����ѡ�����·�����ʱ
        vix_data=100*vix_cal(sample_info.type,option_list,current_date);
    end
end

function vix_data=vix_cal(target_type,option_list,current_date)
    %% ����ĳ���ض��·��µ�sigma
    % step1������call��put��priceѡ��۲���С�Ĳο�ִ�м۸�
    call_info=option_list.(['call' target_type]).(current_date);
    put_info=option_list.(['put' target_type]).(current_date);
    call_info=cell2table(call_info);
    put_info=cell2table(put_info);
    call_put_balance=abs(call_info{:,16}-put_info{:,16});
    % �����ֻ���Զ�ڼ۸�
    [~,loc]=min(call_put_balance);
    ref_K=call_info{loc,7};
    ref_call=call_info{loc,16};
    ref_put=put_info{loc,16};
    remain_time=(double(call_info{1,12})-1)/365;
    risk_free_rate=0.03;
    F0=exp(risk_free_rate*remain_time)*(ref_call-ref_put)+ref_K;
    if sum(call_info{:,7}<=F0)==0
        K0=min(call_info{:,7});
    else
        K0=max(call_info{call_info{:,7}<=F0,7});
    end
    % step2��ɸѡ����Ҫ�������
	insample_call=call_info(call_info{:,7}>=K0,:);
    insample_put=put_info(put_info{:,7}<=K0,:);
    % step3������VIX�ı�Ҫ����
    if size(insample_call,1)>1
        [~,loc]=sort(insample_call.call_info7);
        insample_call=insample_call(loc,:);
        delta_K=zeros(size(insample_call,1),1);
        sigma_comp=zeros(size(insample_call,1),1);
        for iloop=1:size(insample_call,1)
            if iloop==1
                delta_K(iloop)=insample_call{iloop+1,7}-insample_call{iloop,7};
            elseif iloop==size(insample_call,1)
                delta_K(iloop)=insample_call{iloop,7}-insample_call{iloop-1,7};
            else
                delta_K(iloop)=(insample_call{iloop+1,7}-insample_call{iloop-1,7})/2;
            end
            sigma_comp(iloop)=delta_K(iloop)/(insample_call{iloop,7}^2)*exp(risk_free_rate*remain_time)*insample_call{iloop,16};
        end
        insample_call.delta_K=delta_K;
        insample_call.sigma_comp=sigma_comp;
    elseif size(insample_call,1)==1
        insample_call.sigma_comp=0;
    end
    
    if size(insample_put,1)>1
        [~,loc]=sort(insample_put.put_info7);
        insample_put=insample_put(loc,:);
        delta_K=zeros(size(insample_put,1),1);
        sigma_comp=zeros(size(insample_put,1),1);
        for iloop=1:size(insample_put,1)
            if iloop==1
                delta_K(iloop)=insample_put{iloop+1,7}-insample_put{iloop,7};
            elseif iloop==size(insample_put,1)
                delta_K(iloop)=insample_put{iloop,7}-insample_put{iloop-1,7};
            else
                delta_K(iloop)=(insample_put{iloop+1,7}-insample_put{iloop-1,7})/2;
            end
            sigma_comp(iloop)=delta_K(iloop)/(insample_put{iloop,7}^2)*exp(risk_free_rate*remain_time)*insample_put{iloop,16};
        end
        insample_put.delta_K=delta_K;
        insample_put.sigma_comp=sigma_comp;
    elseif size(insample_put,1)==1
        insample_put.sigma_comp=0;
    end
    
    sigma_2=(2/remain_time)*(sum(insample_call.sigma_comp)+sum(insample_put.sigma_comp))-(1/remain_time)*((F0/K0-1)^2);
    vix_data=sqrt(sigma_2);
end