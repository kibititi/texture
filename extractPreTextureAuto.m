%=================================================================================
%功能：计算某反射元的4D叠前纹理元的灰度共生矩阵和提取纹理特征的程序
%调用方法
%eg. [featureVector, coocMat] = extractPreTexture(data, 'direction', [1,0,0,0; 0,1,0,0; 0,0,0,1])
%输入：
%data：叠前4维地震体元和具体参数(time*xline*inline*gather,numLevels,HarFeature)
%numLevels HarFeature分别是灰度级和纹理特征参数
%输出：
%featureVector：该反射元的纹理属性向量
%coocMat：      灰度共生矩阵
%=================================================================================

%

%

%1、主程序
function [featureVector,coocMat] = extractPreTextureAuto(varargin)
%可变参数输入varargin是一个元胞数组，调用函数时，输入参数可以不同其大小可以随着输入参数而变大或变小

data = varargin{1}; %数据,叠前的四维体数据

%默认参数设置-------------------------------
%Wu
% numLevels = 128;  %灰度级
% numHarFeature = 13; %纹理特征的个数
%Zou---->要改成从元胞中提取出来(未完成)
%还有一个未完成的就是最下方纹理特征个数的调整
numHarFeature = (varargin{4}); %纹理特征的个数
numLevels = (varargin{5});  %灰度级
angle_center=varargin{6};%数据，水平方位角数据
textures=varargin{7}; %纹理特征的类型

offSets = int8(varargin{3});     %纹理统计方向
noDirections = size(offSets,1);  %纹理统计方向的数量

coocMat = zeros(numLevels, numLevels, noDirections); %3-D矩阵，每一个方向对应一个二维灰度共生矩阵（12.12改）
% featureVector = zeros(1, noDirections*numHarFeature); %计算得的纹理特征向量，仅1行，其中列数为 方向个数*每个方向的特征数

tempVec = zeros(1,0);    %Empty matrix: 1-by-0

%当中心点高斯和为0 45 135 90 时，统计方向与原始方向一致
%计算灰度共生矩阵coocMat和纹理特征harMat
[harMat, coocMat(:,:,:)] = graycooc4d(data, numLevels, numHarFeature, offSets,angle_center,textures);
%使每个多维数据集的数据在一行上
%organizing the data so each cube's data is on a row
temphar = zeros(1,0);
for clicks =1:size(harMat,1)
    temphar = cat(2,temphar,harMat(clicks,:));
end

%这里featureVector生成的维度是 1x78
featureVector = cat(2,tempVec,temphar);

return
%2.1、计算统计方向自适应的纹理特征和灰度共生矩阵
function [harMat,coMat] = graycooc4d(data,numLevels,numHarFeature, offSets,angle_center,textures)

%**************变量初始化/声明**********************
noDirections = size(offSets,1);  %方向的个数

% offSet(1:4,:)=offSet(1:4,:).*2;
[D1, D2, D3, D4] = size(data); %数据的各个方向的维度
%计算灰度共生矩阵coocMat
coMat = zeros(numLevels,numLevels,noDirections); %各个方向计算得到的灰度共生“矩阵体”，第三维是对应的方向序号
%% ceilData 数值全相等，不进行纹理统计，直接给comat赋值为0
m = min(min(min(min(data)))); %该4D纹理元中的最小值
M = max(max(max(max(data)))); %该4D纹理元中的最大值
if m~=M
    %% 数据插值
    Ng=numLevels;%灰度级
    switch angle_center

        case 0 %0->对应角度
            offSets(noDirections,:)=offSets(2,:);%1
%             m = min(min(min(min(data)))); %该4D纹理元中的最小值
%             M = max(max(max(max(data)))); %该4D纹理元中的最大值
            data = round( ((Ng-1)*data + M - m*Ng)/(M-m) ); %对ceilData进行线性放缩处理(规范化到1~Ng)
            coMat = Texture_analyise_classical(noDirections, D1, D2, D3, D4, data, offSets, coMat);

        case 0.7854%45
            offSets(noDirections,:)=offSets(4,:);%3
%             m = min(min(min(min(data)))); %该4D纹理元中的最小值
%             M = max(max(max(max(data)))); %该4D纹理元中的最大值
            data = round( ((Ng-1)*data + M - m*Ng)/(M-m) ); %对ceilData进行线性放缩处理(规范化到1~Ng)
            coMat = Texture_analyise_classical(noDirections, D1, D2, D3, D4, data, offSets, coMat);

        case 1.5708%±90
            offSets(noDirections,:)=offSets(1,:);%2
%             m = min(min(min(min(data)))); %该4D纹理元中的最小值
%             M = max(max(max(max(data)))); %该4D纹理元中的最大值
            data = round( ((Ng-1)*data + M - m*Ng)/(M-m) ); %对ceilData进行线性放缩处理(规范化到1~Ng)
            coMat = Texture_analyise_classical(noDirections, D1, D2, D3, D4, data, offSets, coMat);
        case -1.5708%±90
            offSets(noDirections,:)=offSets(1,:);%2
%             m = min(min(min(min(data)))); %该4D纹理元中的最小值
%             M = max(max(max(max(data)))); %该4D纹理元中的最大值
            data = round( ((Ng-1)*data + M - m*Ng)/(M-m) ); %对ceilData进行线性放缩处理(规范化到1~Ng)
            coMat = Texture_analyise_classical(noDirections, D1, D2, D3, D4, data, offSets, coMat);

        case -0.7854 %135
            offSets(noDirections,:)=offSets(3,:);%4
%             m = min(min(min(min(data)))); %该4D纹理元中的最小值
%             M = max(max(max(max(data)))); %该4D纹理元中的最大值
            data = round( ((Ng-1)*data + M - m*Ng)/(M-m) ); %对ceilData进行线性放缩处理(规范化到1~Ng)
            coMat = Texture_analyise_classical(noDirections, D1, D2, D3, D4, data, offSets, coMat);
            %-----------------------------------------------------------------------------------------

        case 0.4636% 26
            offSets(noDirections,:)=[0 -1 2 0];%[0 2 1 0]
            [D1, D2, D3, D4, data_fill] = fill_data(data);
%             m = min(min(min(min(data_fill)))); %该4D纹理元中的最小值
%             M = max(max(max(max(data_fill)))); %该4D纹理元中的最大值
            data_fill = round( ((Ng-1)*data_fill + M - m*Ng)/(M-m) ); %对ceilData进行线性放缩处理(规范化到1~Ng)
            coMat = Texture_analyise_auto(noDirections, D1, D2, D3, D4,  offSets, data_fill, coMat);

        case 1.1071%63
            offSets(noDirections,:)=[0 -2 1 0];%[0 1 2 0]
            [D1, D2, D3, D4, data_fill] = fill_data(data);
%             m = min(min(min(min(data_fill)))); %该4D纹理元中的最小值
%             M = max(max(max(max(data_fill)))); %该4D纹理元中的最大值
            data_fill = round( ((Ng-1)*data_fill + M - m*Ng)/(M-m) ); %对ceilData进行线性放缩处理(规范化到1~Ng)
            coMat = Texture_analyise_auto(noDirections, D1, D2, D3, D4,  offSets, data_fill, coMat);

        case -0.4636%-26
            offSets(noDirections,:)=[0 1 2 0];%[0 -2 1 0]
            [D1, D2, D3, D4, data_fill] = fill_data(data);
%             m = min(min(min(min(data_fill)))); %该4D纹理元中的最小值
%             M = max(max(max(max(data_fill)))); %该4D纹理元中的最大值
            data_fill = round( ((Ng-1)*data_fill + M - m*Ng)/(M-m) ); %对ceilData进行线性放缩处理(规范化到1~Ng)
            coMat = Texture_analyise_auto(noDirections, D1, D2, D3, D4, offSets, data_fill, coMat);

        case -1.1071%-63
            offSets(noDirections,:)=[0 2 1 0];%[0 -1 2 0]
            [D1, D2, D3, D4, data_fill] = fill_data(data);
%             m = min(min(min(min(data_fill)))); %该4D纹理元中的最小值
%             M = max(max(max(max(data_fill)))); %该4D纹理元中的最大值
            data_fill = round( ((Ng-1)*data_fill + M - m*Ng)/(M-m) ); %对ceilData进行线性放缩处理(规范化到1~Ng)
            coMat = Texture_analyise_auto(noDirections, D1, D2, D3, D4,  offSets, data_fill, coMat);
    end
end
%%**************************Beginning analysis*************************



%根据灰度共生“矩阵体”提取每个方向的纹理特征.  一共是6个方向
harMat = harFeatures(coMat,numHarFeature,textures);

return

%3、计算纹理特征
function [harMat]= harFeatures(coMat, numHarFeature,textures)

% hasfeature1=clock;

%灰度级
numLevels = size(coMat,1); %number of graylevels

%初始化纹理特征矩阵
harMat = zeros(numHarFeature,size(coMat,3));


%先初始化，不用放到循环中去每次要声明
% z_var = 1:numLevels;

% z_x_var=repmat(z_var,numLevels,1);
% z_y_var=repmat(z_var',1,numLevels);

%test

% wu=0;
% zzz=0;

for directionOrder = 1:size(coMat,3) %directions

    %%%%%%%determining various p values
    %论文41页，这里是先将一个方向的灰度共生矩阵加起来，然后用这个方向上的灰度共生矩阵除以
    %该值，得到的是该元素的统计概率。
    sum_spcific_direction = sum(sum(coMat(:,:,directionOrder))); %某方向的灰度共生矩阵的和
    coMat(:,:,directionOrder)=coMat(:,:,directionOrder)./sum_spcific_direction;     %计算元素的统计概率


    mux=0;
    muy=0;

    for j=1:numLevels
        for i=1:numLevels
            mux =  mux+(i*(coMat(j,i,directionOrder)));
            muy =  muy+(j*(coMat(j,i,directionOrder)));
        end
    end

    %     mux = sum(sum(z_x_var.*(coMat(:,:,directionOrder))));
    %     muy = sum(sum(z_y_var.*(coMat(:,:,directionOrder))));


    %计算相关性才需要这个
    sigx=0;
    sigy=0;
    for j=1:numLevels
        for i=1:numLevels
            sigx = sigx+ (i-mux)^2*coMat(j,i,directionOrder);
            sigy = sigy+ (j-muy)^2*coMat(j,i,directionOrder);
        end
    end

    %计算
    Energy =0;
    Entropy=0;
    Corre=0;
    Contrast=0;
    Homo=0;
    Variance=0;
    SumMean=0;
    Inertia=0;
    ClShade=0;
    ClTendency=0;
    InVariance=0;
    Dissimilarity = 0;  %(12.13 add)
    MaxProbability=0;

    %循环遍历两个灰度级
    for j=1:numLevels
        for i=1:numLevels

            %value即是Pij
            value = coMat(j,i,directionOrder);

            Energy = Energy+ value^2;
            if(value~=0)
                Entropy = Entropy + (value * log10(value));
            end
            Corre = Corre+ ((i-mux)*(j-muy)*(value/(sigy*sigx)));
            Contrast = Contrast+ value*(abs(i-j))^2;
            Homo = Homo+ value/(1+abs(i-j));
            Variance = Variance + ((i - mux)^2)*value+((j-muy)^2)*value;
            SumMean = SumMean + (i+j)*(value);
            Inertia = Inertia+ (i-j)^2*(value);
            ClShade=ClShade+ ((i+j-mux-muy)^3)*(value);
            ClTendency = ClTendency+ (((i + j - mux - muy)^4) .* (value));
            if i~=j
                InVariance=InVariance+ value/(i-j)^2;
            end
            Dissimilarity = Dissimilarity + value*abs(i-j);
        end
    end

    MaxProbability=max(max(coMat(:,:,directionOrder)));
    %赋值
    % 遍历 textures 中的每个变量名
    for i = 1:numel(textures)
        % 获取变量名
        var_name = textures{i};

        % 检查变量是否存在
        if exist(var_name, 'var') == 1
            % 如果变量存在，则将其赋值给 harMat 矩阵
            harMat(i,directionOrder) = eval(var_name);
        else
            % 如果变量不存在，则给出提示
            disp(['变量 ' var_name ' 不是给定的纹理属性之一，请检查拼写及大小写！']);
        end
    end
    %     harMat(1,directionOrder)=Energy;         %Energy
    %     harMat(2,directionOrder) = -Entropy;     %Entropy
    %     harMat(3,directionOrder)=Corre;           %Correlation
    %     harMat(4,directionOrder)=Contrast;           %Contrast
    %     harMat(5,directionOrder) = Homo;         %Homogeneity
    %
    %         harMat(6,directionOrder) = Variance/2;        %Variance
    %         harMat(7,directionOrder)=SumMean/2;         %Sum Mean
    %
    %         harMat(8,directionOrder)=Inertia;          %Inertia
    %
    %         harMat(9,directionOrder)=ClShade;          %Cluster Shade
    %         harMat(10,directionOrder) = ClTendency;         %Cluster Tendency
    %         harMat(11,directionOrder) = max(max(coMat(:,:,directionOrder))); %Max Probability
    %         harMat(12,directionOrder) = InVariance;       %Inverse Variance
    %         harMat(13,directionOrder) = Dissimilarity;        %Dissimilarity

    clear 'Energy' 'Entropy' 'Corre' 'Contrast' 'Homo';
    clear 'Variance' 'SumMean' 'Inertia' 'ClShade';
    clear 'ClTendency' 'InVariance' 'Dissimilarity' 'MaxProbability';

end


harMat = harMat';

% hasfeature2=clock;

% fprintf('Hasfeature Function computed feature cost %f \n',etime(hasfeature2,hasfeature1))


return
% 数据插值与填充
function [D1, D2, D3, D4, data_fill] = fill_data(data)
[D1, D2, D3, D4] = size(data); %数据的各个方向的维度
data_fill=zeros([D1 2*D2-1 2*D3-1 D4]);
%将原数据放在奇数行和奇数列上
for i=1:D2%xline
    for j=1:D3%inline
        data_fill(:,2*i-1,2*j-1,:)=data(:,i,j,:);
    end
end
for m=1:D4%道集方向
    for k=1:D1%time方向
        %在行上插值
        for i=2:2:2*D2-1
            data_fill(k,i,:,m)= 0.5*(data_fill(k,i-1,:,m)+data_fill(k,i+1,:,m));
        end
        for j=2:2:2*D3-1
            data_fill(k,:,j,m)= 0.5*(data_fill(k,:,j-1,m)+data_fill(k,:,j+1,m));
        end
    end
end


function coMat = Texture_analyise_auto(noDirections, D1, D2, D3, D4, offSets, data_fill, coMat)
%开始纹理分析
% 对offsets的前四行*2，当执行前四行时，自动跳过插值点，只分析原有数据点
% 最后一行（纹理统计方向7）才使用插值点
offSets(1:4,:)=offSets(1:4,:).*2;

for directionOrder =1:noDirections
    for d1 = 1:D1
        % 仅执行奇数xline和奇数inline，这样执行只统计了原有数据点，插值数据点不主动参与纹理分析
        % 插值数据点作为被动的纹理分析点，仅在自适应方向上
        for d2 = 1:2:D2
            for d3 = 1:2:D3
                for d4 = 1:D4
                    %当前位置灰度
                    currentGraylevel = data_fill(d1,d2,d3,d4);
                    %offSet(directionOrder,1:4)正好是一行，代表着一个方向

                    %一行操作  =>   一个方向
                    %下一位置
                    d1Next = d1 + offSets(directionOrder,1);
                    d2Next = d2 + offSets(directionOrder,2);
                    d3Next = d3 + offSets(directionOrder,3);
                    d4Next = d4 + offSets(directionOrder,4);
                    %判断下一位置是否越界
                    if d1Next<=D1 && d2Next<=D2 && d3Next<=D3 && d4Next<=D4
                        if d1Next>0 && d2Next>0 && d3Next>0 && d4Next>0
                            nextGraylevel = data_fill(d1Next,d2Next,d3Next,d4Next);
                            coMat(currentGraylevel, nextGraylevel, directionOrder) = ...
                                coMat(currentGraylevel, nextGraylevel, directionOrder) + 1;
                        end
                    end
                end
            end
        end
    end
end

function coMat = Texture_analyise_classical(noDirections, D1, D2, D3, D4, data, offSets, coMat)
%开始纹理分析
for directionOrder =1:noDirections
    for d1 = 1:D1
        for d2 = 1:D2
            for d3 = 1:D3
                for d4 = 1:D4
                    %当前位置灰度
                    currentGraylevel = data(d1,d2,d3,d4);
                    %offSet(directionOrder,1:4)正好是一行，代表着一个方向

                    %一行操作  =>   一个方向
                    %下一位置
                    d1Next = d1 + offSets(directionOrder,1);
                    d2Next = d2 + offSets(directionOrder,2);
                    d3Next = d3 + offSets(directionOrder,3);
                    d4Next = d4 + offSets(directionOrder,4);
                    %判断下一位置是否越界
                    if d1Next<=D1 && d2Next<=D2 && d3Next<=D3 && d4Next<=D4
                        if d1Next>0 && d2Next>0 && d3Next>0 && d4Next>0
                            nextGraylevel = data(d1Next,d2Next,d3Next,d4Next);
                            coMat(currentGraylevel, nextGraylevel, directionOrder) = ...
                                coMat(currentGraylevel, nextGraylevel, directionOrder) + 1;
                        end
                    end
                end
            end
        end
    end
end
