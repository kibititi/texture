function fun_main_withdip_classical(Parameter, directions, FoldPath, offSets, Type)

%将结构体中的参数转化为局部参数，提高计算效率
time=Parameter.time;
xlineNum=Parameter.xlineNum;
% matlab较新版本不用这两行，直接使用parfor可自动开启并行运算
% core_number=10;            %想要调用的处理器个数
% parpool('local',core_number);
parfor iter_num=1:Parameter.iter_nums  %iter_nums
    %每次迭代的话，计算文件指针的位置
    iter_fr=time*xlineNum*4*(iter_num-1);
    fprintf("Iter:%d 开始数据准备.......",iter_num);
    %% --------模块一           =>         提取数据阶段  :  extract_data内部设置SGY路径
    %     fprintf("Iter:%d Moudle 1st is starting......\n",iter_num);
    tic
    %data维度为 "2D" -> (time*xlineNum*nums,  directions)，fr_loc为下次循环的起始位置
    [seismicdata] = extract_data(Parameter,directions,iter_fr,FoldPath);

    %读取倾角数据
    [p] = extract_data_dip(Parameter,iter_fr,FoldPath.pfilename);
    [q] = extract_data_dip(Parameter,iter_fr,FoldPath.qfilename);
    %存在数据缺失时执行此代码，用于使用最近的数据填充数据中的空缺
    % data = fillmissing(data,'nearest' );

    %% -------模块二           =>               处理数据

    %data维度为 "4D" -> (time, xlineNum, nums,directions)
    seismicdata = handle_data(seismicdata,Parameter,directions);
    %处理倾角数据
    p = handle_data(p,Parameter,1);
    q = handle_data(q,Parameter,1);
    %%  -------模块三           =>         计算纹理属性、提取特征
    fprintf("完成数据准备，开始计算\n");
    %输出handled_data维度为：(time,xlineNum,nums,directions)
    %                     [texture_data] = extract_unit_data_withdip(Data,iter_num,FoldPath,offSets,Parameter);
    [~] = extract_unit_data_withdip_classical(seismicdata,p,q,iter_num,FoldPath,offSets,Parameter,Type);
    %     fprintf("Iter:%d Moudle 3rd has completed......\n",iter_num);

    fprintf("\nIter:%d 完成计算，",iter_num);
    toc
end

end

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
function [texture_data] = extract_unit_data_withdip_classical(seismicdata,p,q,iter_num,FoldPath,offSets,Parameter,Type)
%% 文件内部参数
Texture_type=Type.Texture_type;
data=seismicdata;
xlineNum=Parameter.xlineNum;
time=Parameter.time;
nums=Parameter.nums;
Ng=Parameter.Ng;
layer_xlinestartnum=Parameter.layer_xlinestartnum;
layer_timestartnum=Parameter.layer_timestartnum;
time_window=Parameter.time_window;
LayerTimeNum_up=Parameter.LayerTimeNum_up;
LayerTimeNum_down=Parameter.LayerTimeNum_down;
sample_rate=Parameter.sample_rate;
numHarFeature= Parameter.numHarFeature;        %纹理特征数量
textures=Parameter.textures;%纹理特征的类型
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
        time_k=fix((k-layer_timestartnum)/sample_rate);
        % time_k=fix((k-layer_timestartnum));
        for i = 1:inlineNum
            for j = LayerxlineNum

                ceilData = data(time_k-time_window:time_k+time_window, j:j+nums-1, i:i+nums-1, :);

                %% 整体叠后倾角作为数据选取的标准
                %以中心点作为整体倾角导线的准则，p_ceilData、q_ceilData分别表示中心点倾角值

                p_ceilData=mean(p(time_k-1:time_k+1, j+(nums-1)/2, i+(nums-1)/2));
                q_ceilData=mean(q(time_k-1:time_k+1, j+(nums-1)/2, i+(nums-1)/2));
                ceilData=Func_select_data(ceilData,data,p_ceilData,q_ceilData,i,j,time_k,nums,time_window);
                %% 纹理属性计算单元
                m = min(min(min(min(ceilData)))); %该4D纹理元中的最小值
                M = max(max(max(max(ceilData)))); %该4D纹理元中的最大值

                ceilData = round( ((Ng-1)*ceilData + M - m*Ng)/(M-m) ); %对ceilData进行线性放缩处理(规范化到1~Ng)

                pointIndex = (i-1)*xlineNum+j+(time_k-1)*inlineNum*xlineNum;

                [featureVector, ~] = extractPreTexture(ceilData, 'direction', offSets,numHarFeature,Ng,textures);

                %纹理特征向量
                featureMatrix(pointIndex,:) = featureVector;
            end
        end
    end
    %% 归一化f(layer==1)
    fprintf('Iter %d 已完成：',iter_num)
end
if(mod(layer,200)==1)
    fprintf('  %d/%d',layer,xlineNum);
end
end
%纹理数据
%     featureMatrix=norm_data(featureMatrix,directions,numHarFeature);
%   正则化时内存小容易崩溃

%保存路径
savepath=strcat(FoldPath.OutputPath,'Iter_',int2str(iter_num),'.mat');
%保存数据
save(savepath,'featureMatrix');

texture_data=Texture_type;
end