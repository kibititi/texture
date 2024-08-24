function [] = fun_mat_to_sgy(FoldPath,Parameter,Type,offset_num)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明
%mat2sgy
%用于将mat数据转存为带卷头文件、道头文件的sgy数据
%函数调用时内存占用较大，这里需要清楚工作区以减少内存占用，确保正常运行
clear all；clc；
filecomname = '.sgy';
textures=Parameter.textures;
seismicData_type=Type.seismicData_type;
Texture_type=Type.Texture_type;
time=Parameter.time;
inlineNum=Parameter.inlineNum;
xlineNum=Parameter.xlineNum;
nums=Parameter.nums;
[~,SegyTraceHeaders,SegyHeader]=ReadSegy(FoldPath.sesimic_data_filename);
% save(savefilename,'SegyTraceHeaders')
%创建文件夹 \sgy有道头
mkdir(strjoin(cellstr(strcat(FoldPath.OutputPath,'\sgy有道头'))));
%%
for i=1:offset_num
     fprintf('写入进度：%d/%d\n',i,offset_num)
    for j=1:Parameter.numHarFeature
            %加载数据
            loadpath= strjoin(cellstr(strcat(FoldPath.OutputPath,'Dir_Of_',int2str(i),textures(j),'.mat')));  
            load(loadpath)
            %temp与原地震数据相同大小
            temp=zeros(time,xlineNum,inlineNum);
            %将计算得到的数据赋值到temp的中心，左右各缺少(nums-1)/2道，用0补齐
            temp(:,(nums-1)/2+1:xlineNum-(nums-1)/2,:)=dr;
            clear dr

            temp=reshape(temp,[time,xlineNum*inlineNum]);
            %打开的文件地址
            filename = strjoin(cellstr(strcat(FoldPath.OutputPath,"sgy有道头\",seismicData_type,'_',Texture_type,'_',textures(j),'_dir-',int2str(i),filecomname)));
            %使用封装函数写入数据
            WriteSegyStructure(filename,SegyHeader,SegyTraceHeaders,temp);
            clear temp
    end
end
disp("有到头的标准sgy文件写入完成.");
end