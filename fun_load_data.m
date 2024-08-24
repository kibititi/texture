%==========================================================================
%提取每个反射元的纹理属性
%读入文件说明：
%   存的mat文件
%输出：
    %特征数据体的mat文件
%==========================================================================



function []=fun_load_data(Parameter,FoldPath,offset_num)
nums=Parameter.nums;
inlineNum=Parameter.inlineNum;
xlineNum=Parameter.xlineNum;
time=Parameter.time;
iter_nums=Parameter.iter_nums;
    %inlineNum = 351;
%     directions=1;
    %纹理特征的顺序：
    textNum = Parameter.numHarFeature;                %纹理的数量
%     offset_num=6;               %纹理属性的统计方向
    xlineNum=xlineNum-nums+1;        %最终三维体联络测线的长度
    textures=Parameter.textures;
    %注意顺序，需要和
    % E:\学习23\研一科研\纹理属性\代码\matlab_m\extractPreTexture.m
    %中的纹理属性数量、顺序保持一致
    %===============================================
    %       一次性赋值多个变量内存崩溃
    %===============================================
    
    
    
    for text=1:textNum     % 1-5，某一个纹理属性 
        for iter_dir = 1:offset_num          % w方向  
            start_time = clock;
            
            %初始化变量
           dr = zeros(time,xlineNum,inlineNum);
%修改部分
            for iter_num = 1:iter_nums   %iter_nums,也就是：inlineNum-4      % 1512表示Iter文件的个数
               loadpath=strcat(FoldPath.OutputPath,'Iter_',int2str(iter_num),'.mat');
               %检查文件是否存在
               if(isfile(loadpath)== 1)
                    load(loadpath)
               else
                   fprintf('不存在Iter_%d.mat文件夹',iter_num);
               end

               % 存放顺序  1.xline  2.time
               for time_data=1:time
                  for xlineNum_data=1:xlineNum
                      loc_data = xlineNum*(time_data-1)+xlineNum_data;
                      dr(time_data,xlineNum_data,iter_num)=featureMatrix(loc_data ,  (iter_dir-1)*textNum+text);
                  end
               end 
                fprintf('%d is completed\n',iter_num);
            end
            end_time = clock;

            fprintf('Total_Iter:%d is completed, costing %f s\n',iter_dir,etime(end_time,start_time));
            %保存路径
%             temp=strjoin(cellstr(textures(text)));
            savepath=strjoin(cellstr(strcat(FoldPath.OutputPath,'Dir_Of_',num2str(iter_dir),textures(text),'.mat')));
%             loadpath=strcat(FoldPath.OutputPath,'Iter_',int2str(iter_num),'.mat');
            save(savepath,'dr')
            %clear变量内存
            clear dr
        end
    end
end



