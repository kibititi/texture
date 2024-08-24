%==========================================================================
%提取每个反射元的纹理属性，整合成一个大的数据
%输入参数说明：
%   time                %时间方向长度
%   xlineNum            %联络测线长度
%   inlineNum           %主测线的长度
%   directions          %方向数量
%   textNum             %纹理特征数量
%   nums                %一次读取inline长度


%读入文件说明：
%   存的mat文件
%输出：
    %特征数据体的mat文件
%==========================================================================
function []=load_data_func(time,xlineNum,inlineNum,directions,textNum)
    
    iter_nums=inlineNum-4;      %迭代次数
    inlineNum = inlineNum-4;    %最终三维体主测线的长度
    xlineNum=xlineNum-4;        %最终三维体联络测线的长度
    time=time-4;                %最终时间的长度

    %===============================================
    %       一次性赋值多个变量内存崩溃
    %       采用for循环逐个处理
    %       可在二级for循环中增加并行操作，加快处理
    %===============================================
    for iter_dir=1:directions
        %初始化变量
        dr = zeros(xlineNum,inlineNum,time,textNum);
        %一个方向上处理的开始时间
        start_time = clock;
        for iter_num = 1:iter_nums
           %加载的路径
           loadpath=strcat('I:\matlab\12_23data\','Iter_',int2str(iter_num),'.mat');
           %检查文件是否存在
           if(isfile(loadpath)== 1)
               %加载文件
               load(loadpath)
           else
               %提示文件不存在
               fprintf("不存在Iter_%d.mat文件夹",iter_num);
           end

           for time_data=1:time
              for xlineNum_data=1:xlineNum
                %注意此处的loc_data要对应extract_unit_data的顺序，不然出错
                loc_data = xlineNum*(time_data-1)+xlineNum_data;
                %iter_dir*5-4:iter_dir*5表示对应dir的序列
                dr(iter_num,xlineNum_data,time_data,:) = text_data(loc_data ,iter_dir*5-4:iter_dir*5);
              end
           end 
        end
        
        %一个方向上处理完成的结束时间
        end_time = clock;
        %提示
        fprintf("Total_Iter:%d is completed, costing %f s\n",iter_dir,etime(end_time,start_time));
        %保存路径
        savepath=strcat('I:\matlab\12_23mergedata\','Dir_Of_',int2str(iter_dir),'.mat');

        save(savepath,'dr')
        %再clear变量内存防止内存崩溃
        clear dr
    end

end




