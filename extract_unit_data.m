%==========================================================================
%提取每个反射元的纹理属性
%调用方法
%eg.  [data,fr_loc] = extract_data(400,600,5,6,0)
%文件输入：
%六个方向的sgy数据
%每一个反射元所占的 xlinenum  inlineNum  time 的数量
%输入参数: data         待提取特征的数据体
%          xlineNum     每次读取数据的联络测线长度
%          time         每次读取数据的时间长度
%          inlineNum     每次要读取多少条主测线 (设为五条线)
%          directions   一共的方向数量
%          Ng           预先指定灰度级的大小
%输出：
%纹理特征体：提取出来的数据
%==========================================================================

%% 函数主体
function [texture_data] = extract_unit_data(Data,iter_num,FoldPath,offSets,Parameter,Type)
%% 文件内部参数
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

numHarFeature= Parameter.numHarFeature;        %纹理特征数量
% pointIndex = 0; %用于标记得到的属性向量的对应的点数(1~xlineNum*inlineNum)
% inlineNum=nums;

%% 纹理统计方向：(time,crossline,inlineNum,trace)
%--------------------------------------------------------------------------------
%此时为对应叠前数据的纹理统计方向，共计有六种方向
% w1 = [0,1,0,0; 0,0,1,0; 0,1,1,0; 0,-1,1,0];%inine、xline、inline和xline的45°方向、inline和xline的135°方向
% w2 = [1,0,0,0];%沿时间方向
% w3 = [0,0,0,1];%沿道集方向
% offSets = cat(1,w1,w2,w3);  %方向
% clear w1 w2 w3;
%
offset_num=size(offSets,1);%纹理统计方向
% %--------------------------------------------------------------------------------
% %当为叠后纹理属性时，共计有五种方向，没有W3方向
%% 初始化纹理特征矩阵
%这里为什么是78：
%因为使用了13个纹理特征，一共有6个方向   13*6 = 78
% featureMatrix = zeros(78, xlineNum*inlineNum);
%% 提取叠前纹理特征
%说明：如果是五条线的话，inline方向是不用循环的
%防止越界操作
% time=time-nums+1;
inlineNum=1;
xlineNum=xlineNum-nums+1;

%12.07将featureMatrix拿到顶部上来
%featureMatrix的大小为 inlineNum*xlineNum*time，纹理统计方向*纹理数量
featureMatrix = zeros(inlineNum*xlineNum*time,  offset_num*numHarFeature);


%加载所有的层位置信息  layer_total:  inline线段号；xline线段号；time

% QZS_data=load('F:\学习23\研一科研\纹理属性\代码\QZS_xxx.mat');
% layer_total_data=QZS_data.QZS_data;
QZS_data=load(FoldPath.LayerData);
layer_total_data=QZS_data.layer_data;
%取出当前inline切面所对应的所有时间的点, 2201表示xline的数量
% layer_data = layer_total_data((iter_num-1)*2051+1:iter_num*2051,:);
layer_data = layer_total_data((iter_num-1)*(xlineNum+nums-1)+1:iter_num*(xlineNum+nums-1),:);
clear layer_total_data
switch Texture_type
    case 'WithDip'
        %注意都是向下取整
        for layer=1:xlineNum

            LayerTimeNum=layer_data(layer,3);

            k_for=LayerTimeNum-LayerTimeNum_up:1:LayerTimeNum+LayerTimeNum_down;  %60个ms  30个点数据
            %     k_for=LayerTimeNum-15:1:LayerTimeNum+50;     %30个ms  15个点数据
            %注意这里要减去1800----匹配数组操作，1800表示起始xline线段号
            LayerxlineNum=layer_data(layer,2)-layer_xlinestartnum+1;

            for k= k_for
                %计算k所对应的时间点 -2100再除以2[采样率]， 2100表示起始时间
                %time_k=fix((k-2100)/2);
                %层位数据已在主函数中修改，此处修改为fix（k）即可
                time_k=fix((k-layer_timestartnum)/2);
                % time_k=fix((k-layer_timestartnum));
                for i = 1:inlineNum
                    for j = LayerxlineNum
                        % 振幅规范化处理
                        %ceildata是选择的纹理属性计算网格，
                        % 目前的大小为：time*xline*inline*directions，11*5*5*6
                        %要实现倾角控制的纹理属性计算，倾角可以在这里计算
                        %只计算当前网格内的倾角
                        %网格要插值获取新点位的值
                        %size(data)=201        2201           5           6;
                        %size(ceilData)=11     5     5     6
                        %                 ceilData = data(time_k-1:time_k+1, j:j+nums-3, i:i+nums-3, :);
                        %使用上一行的3*3*3的地震数据是为了提高计算速度，平时应当使用下一行
                        %另外，在函数fun_revolveGrid中应当同步修改计算网格大小。
                        ceilData = data(time_k-time_window:time_k+time_window, j:j+nums-1, i:i+nums-1, :);
                        %数据中存在inf值，将inf值转化为NaN,并用周围值代替
                        %                 TF= isinf(ceilData);
                        %                 ceilData(TF) = NaN;
                        %                 ceilData= fillmissing(ceilData,'nearest' );
                        %% 整体叠后倾角作为数据选取的标准
                        %以中心点作为整体倾角导线的准则，p_ceilData、q_ceilData分别表示中心点倾角值

                        p_ceilData=mean(p(time_k-1:time_k+1, j+(nums-1)/2, i+(nums-1)/2));
                        q_ceilData=mean(q(time_k-1:time_k+1, j+(nums-1)/2, i+(nums-1)/2));
                        ceilData=Func_select_data(ceilData,data,p_ceilData,q_ceilData,i,j,time_k,nums,time_window);

                        %% 初步计算倾角，使用倾角扫描，希尔伯特变换的方法
                        %                 %7.17 现在的问题是：
                        %                 % 1.针对第一道，计算得到的倾角都是0
                        %%--------------------------------------------------------------------------------------------------
                        %方法一：插值计算，存在问题：计算速度慢
                        %                 %获得新的位置矩阵，locationMatrix_new，大小为point*3*direction，3表示time，xline，inline坐标
                        %                 [p_ceilData,q_ceilData] = fun_curvature(ceilData);
                        %                 [locationMatrix_new] = fun_revolveGrid(p_ceilData,q_ceilData,ceilData);
                        %
                        %                 locationMatrix_new=locationMatrix_new+[time_k,(j+j+nums-3)/2,(i+i+nums-3)/2];
                        %                 %按照新的位置矩阵重新读取ceilData数据
                        %                 ceilData_new = fun_reReadData(locationMatrix_new,data,ceilData);
                        %                 ceilData=ceilData_new;
                        %                 nanf=isnan(ceilData);
                        %                 ceilData(nanf) = 0;
                        %                 ceilData(nanf)=mean(mean(mean2(ceilData)));
                        %%--------------------------------------------------------------------------------------------------
                        %方法二：计算坐标，按照坐标的最近临近数据选取，计算速度快
                        % 目前的大小为：time*xline*inline*directions，11*5*5*6
                        % inline 方向+round（p），xline方向+round（q）
                        %                 [p_ceilData,q_ceilData] = fun_curvature(ceilData);
                        %                 ceilData=Func_select_data(ceilData,data,p_ceilData,q_ceilData,i,j,time_k,nums);
                        %% 根据扫描得到的倾角进行GST的构建和精确倾角扫描
                        %--------------------------------------------------------------------------------------------------
                        %方法一：插值计算，存在问题：计算速度慢
                        %                 [p, q] = fun_curvature(ceilData);
                        %                 [locationMatrix_new] = fun_revolveGrid(p,q,ceilData);
                        %                 locationMatrix_new=locationMatrix_new+[time_k,(j+j+nums-3)/2,(i+i+nums-3)/2];
                        %                 ceilData_new = fun_reReadData(locationMatrix_new,data,ceilData);
                        %                 ceilData=ceilData_new;
                        %                 nanf=isnan(ceilData);
                        %                 ceilData(nanf) = 0;
                        %                 ceilData(nanf)=mean(mean(mean2(ceilData)));
                        %%--------------------------------------------------------------------------------------------------
                        %方法二：计算坐标，按照坐标的最近临近数据选取，计算速度快
                        %                 [p, q] = fun_computeCurvature(ceilData);
                        %                 ceilData=Func_select_data(ceilData,data,p,q,i,j,time_k,nums);
                        %% 纹理属性计算单元
                        m = min(min(min(min(ceilData)))); %该4D纹理元中的最小值
                        M = max(max(max(max(ceilData)))); %该4D纹理元中的最大值

                        ceilData = round( ((Ng-1)*ceilData + M - m*Ng)/(M-m) ); %对ceilData进行线性放缩处理(规范化到1~Ng)

                        pointIndex = (i-1)*xlineNum+j+(time_k-1)*inlineNum*xlineNum;

                        [featureVector, ~] = extractPreTexture(ceilData, 'direction', offSets,numHarFeature,Ng);

                        %纹理特征向量
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

            k_for=LayerTimeNum-LayerTimeNum_up:1:LayerTimeNum+LayerTimeNum_down;  %60个ms  30个点数据
            %     k_for=LayerTimeNum-15:1:LayerTimeNum+50;     %30个ms  15个点数据
            %注意这里要减去1800----匹配数组操作，1800表示起始xline线段号
            LayerxlineNum=layer_data(layer,2)-layer_xlinestartnum+1;

            for k= k_for
                %计算k所对应的时间点 -2100再除以2[采样率]， 2100表示起始时间
                %time_k=fix((k-2100)/2);
                %层位数据已在主函数中修改，此处修改为fix（k）即可
                time_k=fix((k-layer_timestartnum)/2);
                % time_k=fix((k-layer_timestartnum));
                for i = 1:inlineNum
                    for j = LayerxlineNum                  
                        ceilData = data(time_k-time_window:time_k+time_window, j:j+nums-1, i:i+nums-1, :);             
                        %% 纹理属性计算单元
                        m = min(min(min(min(ceilData)))); %该4D纹理元中的最小值
                        M = max(max(max(max(ceilData)))); %该4D纹理元中的最大值

                        ceilData = round( ((Ng-1)*ceilData + M - m*Ng)/(M-m) ); %对ceilData进行线性放缩处理(规范化到1~Ng)

                        pointIndex = (i-1)*xlineNum+j+(time_k-1)*inlineNum*xlineNum;

                        [featureVector, ~] = extractPreTexture(ceilData, 'direction', offSets,numHarFeature,Ng);

                        %纹理特征向量
                        featureMatrix(pointIndex,:) = featureVector;
                    end
                end
            end
            if(mod(layer,300)==1)
                fprintf('Iter %d has finished %d th data...\n',iter_num,layer);
            end
        end
end

%% 归一化
%纹理数据
%     featureMatrix=norm_data(featureMatrix,directions,numHarFeature);
%   正则化时内存小容易崩溃

%保存路径
savepath=strcat(FoldPath.OutputPath,'Iter_',int2str(iter_num),'.mat');
%保存数据
save(savepath,'featureMatrix');

texture_data='success';
end
