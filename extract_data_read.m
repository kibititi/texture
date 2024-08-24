%==========================================================================
%功能：从去掉道头和卷头的sgy文件中提取数据
%调用方法
%eg.  [data,fr_loc] = extract_data(400,600,5,6,0)
%文件输入：
    %六个方向的sgy数据
    %每一个反射元所占的 xlinenum  inlinenum  time 的数量
    %输入参数: xlinenum      每次读取数据的联络测线长度 
    %          time         每次读取数据的时间长度
    %          inline       每次要读取多少条主测线 (设为五条线)
    %          directions   一共的方向数量
    %          loc       保存的文件指针位置
%输出：
    %data：提取出来的数据
    %fr_loc:文件所在的位置
%==========================================================================

function [data] = extract_data_read(time,xlineNum,nums,directions,loc)
%12.07取消
% %读取值的字节大写
% data_byte=4;

%定义文件参数名字

filecomname = '.sgy';

%初始化
data=zeros(time*xlineNum*nums,directions);

for i=1:directions
    
    %各个sgy的文件名  
    filename = strcat('F:\学习23\研一科研\纹理属性\数据\',num2str(30*i),filecomname);  
        
    %获取文件句柄
    fr = fopen(filename);
        
    %移动指针到main迭代要到的文件指针
    fseek(fr,loc,'bof');
    
    %读取反射元数据,每次读取五条inline数据 这个生成的数据不对哦 wrong
%     data(:,:,i) = fread(fr,[time xlinenum*nums],'float');
      temp= fread(fr,time*xlineNum*nums,'float');
    data(:,i)= temp;

   
%     data_cur=fread(fr,time*xlinenum*nums,'float');
    %测试 下面跑出来的才应该是对的
%     [x,y,z]=meshgrid(1:xlineNum,1:nums,1:time);
%     fseek(fr,0,'bof');
%     for inline=1:nums
%        for xline=1:xlineNum
%           for t=1:time
%           loc_data=(inline-1)*xlineNum*time+(xline-1)*time+t;
%           data2(inline,xline,time-t+1)=data(loc_data,i); %fread(fr,1,'float');
%           end
%        end
%     end
    %关闭文件
    fclose(fr);
end

return

