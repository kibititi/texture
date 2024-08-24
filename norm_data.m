%==========================================================================
%归一化方法
%调用方法
%eg.  [normed_data] = norm_data(featureMatrix,xlineNum,inlineNum)
%文件输入：
    %输入参数: data         特征矩阵
    %          xlineNum     每次读取数据的联络测线长度 
    %          time         每次读取数据的时间长度
    %          inlineNum     每次要读取多少条主测线 (设为五条线)
    %          directions   一共的方向数量
    %          Ng           预先指定灰度级的大小
%文件参数：
%
%
%输出：
    %纹理特征体：提取出来的数据
%==========================================================================


function [normed_data] = norm_data(featureMatrix,directions,textures)

    mA = min(featureMatrix, [], 2);         %每一行的最小值  65*1
    MA = max(featureMatrix, [], 2);         %每一行的最大值  65*1

    %featureMatrix的维度是(65，601*501=301101)
%     normed_data(:,:,:,:) = normed_data(:,:,:,:)/mean(normed_data(:));
    normed_data = (featureMatrix - repmat(mA, [1,directions*textures]))./repmat(MA-mA, [1,directions*textures]);
        
    
end

