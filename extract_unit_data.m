%==========================================================================
%��ȡÿ������Ԫ����������
%���÷���
%eg.  [data,fr_loc] = extract_data(400,600,5,6,0)
%�ļ����룺
%���������sgy����
%ÿһ������Ԫ��ռ�� xlinenum  inlineNum  time ������
%�������: data         ����ȡ������������
%          xlineNum     ÿ�ζ�ȡ���ݵ�������߳���
%          time         ÿ�ζ�ȡ���ݵ�ʱ�䳤��
%          inlineNum     ÿ��Ҫ��ȡ������������ (��Ϊ������)
%          directions   һ���ķ�������
%          Ng           Ԥ��ָ���Ҷȼ��Ĵ�С
%�����
%���������壺��ȡ����������
%==========================================================================

%% ��������
function [texture_data] = extract_unit_data(Data,iter_num,FoldPath,offSets,Parameter,Type)
%% �ļ��ڲ�����
Texture_type=Type.Texture_type;
data=Data.seismicdata;
p=Data.p;
q=Data.q;
xlineNum=Parameter.xlineNum;
time=Parameter.time;
nums=Parameter.nums;
Ng=Parameter.Ng;
layer_xlinestartnum=Parameter.layer_xlinestartnum;
layer_timestartnum=Parameter.layer_timestartnum;
time_window=Parameter.time_window;
LayerTimeNum_up=Parameter.LayerTimeNum_up;
LayerTimeNum_down=Parameter.LayerTimeNum_down;

numHarFeature= Parameter.numHarFeature;        %������������
% pointIndex = 0; %���ڱ�ǵõ������������Ķ�Ӧ�ĵ���(1~xlineNum*inlineNum)
% inlineNum=nums;

%% ����ͳ�Ʒ���(time,crossline,inlineNum,trace)
%--------------------------------------------------------------------------------
%��ʱΪ��Ӧ��ǰ���ݵ�����ͳ�Ʒ��򣬹��������ַ���
% w1 = [0,1,0,0; 0,0,1,0; 0,1,1,0; 0,-1,1,0];%inine��xline��inline��xline��45�㷽��inline��xline��135�㷽��
% w2 = [1,0,0,0];%��ʱ�䷽��
% w3 = [0,0,0,1];%�ص�������
% offSets = cat(1,w1,w2,w3);  %����
% clear w1 w2 w3;
%
offset_num=size(offSets,1);%����ͳ�Ʒ���
% %--------------------------------------------------------------------------------
% %��Ϊ������������ʱ�����������ַ���û��W3����
%% ��ʼ��������������
%����Ϊʲô��78��
%��Ϊʹ����13������������һ����6������   13*6 = 78
% featureMatrix = zeros(78, xlineNum*inlineNum);
%% ��ȡ��ǰ��������
%˵��������������ߵĻ���inline�����ǲ���ѭ����
%��ֹԽ�����
% time=time-nums+1;
inlineNum=1;
xlineNum=xlineNum-nums+1;

%12.07��featureMatrix�õ���������
%featureMatrix�Ĵ�СΪ inlineNum*xlineNum*time������ͳ�Ʒ���*��������
featureMatrix = zeros(inlineNum*xlineNum*time,  offset_num*numHarFeature);


%�������еĲ�λ����Ϣ  layer_total:  inline�߶κţ�xline�߶κţ�time

% QZS_data=load('F:\ѧϰ23\��һ����\��������\����\QZS_xxx.mat');
% layer_total_data=QZS_data.QZS_data;
QZS_data=load(FoldPath.LayerData);
layer_total_data=QZS_data.layer_data;
%ȡ����ǰinline��������Ӧ������ʱ��ĵ�, 2201��ʾxline������
% layer_data = layer_total_data((iter_num-1)*2051+1:iter_num*2051,:);
layer_data = layer_total_data((iter_num-1)*(xlineNum+nums-1)+1:iter_num*(xlineNum+nums-1),:);
clear layer_total_data
switch Texture_type
    case 'WithDip'
        %ע�ⶼ������ȡ��
        for layer=1:xlineNum

            LayerTimeNum=layer_data(layer,3);

            k_for=LayerTimeNum-LayerTimeNum_up:1:LayerTimeNum+LayerTimeNum_down;  %60��ms  30��������
            %     k_for=LayerTimeNum-15:1:LayerTimeNum+50;     %30��ms  15��������
            %ע������Ҫ��ȥ1800----ƥ�����������1800��ʾ��ʼxline�߶κ�
            LayerxlineNum=layer_data(layer,2)-layer_xlinestartnum+1;

            for k= k_for
                %����k����Ӧ��ʱ��� -2100�ٳ���2[������]�� 2100��ʾ��ʼʱ��
                %time_k=fix((k-2100)/2);
                %��λ�����������������޸ģ��˴��޸�Ϊfix��k������
                time_k=fix((k-layer_timestartnum)/2);
                % time_k=fix((k-layer_timestartnum));
                for i = 1:inlineNum
                    for j = LayerxlineNum
                        % ����淶������
                        %ceildata��ѡ����������Լ�������
                        % Ŀǰ�Ĵ�СΪ��time*xline*inline*directions��11*5*5*6
                        %Ҫʵ����ǿ��Ƶ��������Լ��㣬��ǿ������������
                        %ֻ���㵱ǰ�����ڵ����
                        %����Ҫ��ֵ��ȡ�µ�λ��ֵ
                        %size(data)=201        2201           5           6;
                        %size(ceilData)=11     5     5     6
                        %                 ceilData = data(time_k-1:time_k+1, j:j+nums-3, i:i+nums-3, :);
                        %ʹ����һ�е�3*3*3�ĵ���������Ϊ����߼����ٶȣ�ƽʱӦ��ʹ����һ��
                        %���⣬�ں���fun_revolveGrid��Ӧ��ͬ���޸ļ��������С��
                        ceilData = data(time_k-time_window:time_k+time_window, j:j+nums-1, i:i+nums-1, :);
                        %�����д���infֵ����infֵת��ΪNaN,������Χֵ����
                        %                 TF= isinf(ceilData);
                        %                 ceilData(TF) = NaN;
                        %                 ceilData= fillmissing(ceilData,'nearest' );
                        %% ������������Ϊ����ѡȡ�ı�׼
                        %�����ĵ���Ϊ������ǵ��ߵ�׼��p_ceilData��q_ceilData�ֱ��ʾ���ĵ����ֵ

                        p_ceilData=mean(p(time_k-1:time_k+1, j+(nums-1)/2, i+(nums-1)/2));
                        q_ceilData=mean(q(time_k-1:time_k+1, j+(nums-1)/2, i+(nums-1)/2));
                        ceilData=Func_select_data(ceilData,data,p_ceilData,q_ceilData,i,j,time_k,nums,time_window);

                        %% ����������ǣ�ʹ�����ɨ�裬ϣ�����ر任�ķ���
                        %                 %7.17 ���ڵ������ǣ�
                        %                 % 1.��Ե�һ��������õ�����Ƕ���0
                        %%--------------------------------------------------------------------------------------------------
                        %����һ����ֵ���㣬�������⣺�����ٶ���
                        %                 %����µ�λ�þ���locationMatrix_new����СΪpoint*3*direction��3��ʾtime��xline��inline����
                        %                 [p_ceilData,q_ceilData] = fun_curvature(ceilData);
                        %                 [locationMatrix_new] = fun_revolveGrid(p_ceilData,q_ceilData,ceilData);
                        %
                        %                 locationMatrix_new=locationMatrix_new+[time_k,(j+j+nums-3)/2,(i+i+nums-3)/2];
                        %                 %�����µ�λ�þ������¶�ȡceilData����
                        %                 ceilData_new = fun_reReadData(locationMatrix_new,data,ceilData);
                        %                 ceilData=ceilData_new;
                        %                 nanf=isnan(ceilData);
                        %                 ceilData(nanf) = 0;
                        %                 ceilData(nanf)=mean(mean(mean2(ceilData)));
                        %%--------------------------------------------------------------------------------------------------
                        %���������������꣬�������������ٽ�����ѡȡ�������ٶȿ�
                        % Ŀǰ�Ĵ�СΪ��time*xline*inline*directions��11*5*5*6
                        % inline ����+round��p����xline����+round��q��
                        %                 [p_ceilData,q_ceilData] = fun_curvature(ceilData);
                        %                 ceilData=Func_select_data(ceilData,data,p_ceilData,q_ceilData,i,j,time_k,nums);
                        %% ����ɨ��õ�����ǽ���GST�Ĺ����;�ȷ���ɨ��
                        %--------------------------------------------------------------------------------------------------
                        %����һ����ֵ���㣬�������⣺�����ٶ���
                        %                 [p, q] = fun_curvature(ceilData);
                        %                 [locationMatrix_new] = fun_revolveGrid(p,q,ceilData);
                        %                 locationMatrix_new=locationMatrix_new+[time_k,(j+j+nums-3)/2,(i+i+nums-3)/2];
                        %                 ceilData_new = fun_reReadData(locationMatrix_new,data,ceilData);
                        %                 ceilData=ceilData_new;
                        %                 nanf=isnan(ceilData);
                        %                 ceilData(nanf) = 0;
                        %                 ceilData(nanf)=mean(mean(mean2(ceilData)));
                        %%--------------------------------------------------------------------------------------------------
                        %���������������꣬�������������ٽ�����ѡȡ�������ٶȿ�
                        %                 [p, q] = fun_computeCurvature(ceilData);
                        %                 ceilData=Func_select_data(ceilData,data,p,q,i,j,time_k,nums);
                        %% �������Լ��㵥Ԫ
                        m = min(min(min(min(ceilData)))); %��4D����Ԫ�е���Сֵ
                        M = max(max(max(max(ceilData)))); %��4D����Ԫ�е����ֵ

                        ceilData = round( ((Ng-1)*ceilData + M - m*Ng)/(M-m) ); %��ceilData�������Է�������(�淶����1~Ng)

                        pointIndex = (i-1)*xlineNum+j+(time_k-1)*inlineNum*xlineNum;

                        [featureVector, ~] = extractPreTexture(ceilData, 'direction', offSets,numHarFeature,Ng);

                        %������������
                        featureMatrix(pointIndex,:) = featureVector;
                    end
                end
            end

            if(mod(layer,300)==1)
                fprintf('Iter %d has finished %d th data...\n',iter_num,layer);
            end
        end
    case 'NoDip'
        for layer=1:xlineNum

            LayerTimeNum=layer_data(layer,3);

            k_for=LayerTimeNum-LayerTimeNum_up:1:LayerTimeNum+LayerTimeNum_down;  %60��ms  30��������
            %     k_for=LayerTimeNum-15:1:LayerTimeNum+50;     %30��ms  15��������
            %ע������Ҫ��ȥ1800----ƥ�����������1800��ʾ��ʼxline�߶κ�
            LayerxlineNum=layer_data(layer,2)-layer_xlinestartnum+1;

            for k= k_for
                %����k����Ӧ��ʱ��� -2100�ٳ���2[������]�� 2100��ʾ��ʼʱ��
                %time_k=fix((k-2100)/2);
                %��λ�����������������޸ģ��˴��޸�Ϊfix��k������
                time_k=fix((k-layer_timestartnum)/2);
                % time_k=fix((k-layer_timestartnum));
                for i = 1:inlineNum
                    for j = LayerxlineNum                  
                        ceilData = data(time_k-time_window:time_k+time_window, j:j+nums-1, i:i+nums-1, :);             
                        %% �������Լ��㵥Ԫ
                        m = min(min(min(min(ceilData)))); %��4D����Ԫ�е���Сֵ
                        M = max(max(max(max(ceilData)))); %��4D����Ԫ�е����ֵ

                        ceilData = round( ((Ng-1)*ceilData + M - m*Ng)/(M-m) ); %��ceilData�������Է�������(�淶����1~Ng)

                        pointIndex = (i-1)*xlineNum+j+(time_k-1)*inlineNum*xlineNum;

                        [featureVector, ~] = extractPreTexture(ceilData, 'direction', offSets,numHarFeature,Ng);

                        %������������
                        featureMatrix(pointIndex,:) = featureVector;
                    end
                end
            end
            if(mod(layer,300)==1)
                fprintf('Iter %d has finished %d th data...\n',iter_num,layer);
            end
        end
end

%% ��һ��
%��������
%     featureMatrix=norm_data(featureMatrix,directions,numHarFeature);
%   ����ʱ�ڴ�С���ױ���

%����·��
savepath=strcat(FoldPath.OutputPath,'Iter_',int2str(iter_num),'.mat');
%��������
save(savepath,'featureMatrix');

texture_data='success';
end
