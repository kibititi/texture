%==========================================================================
%功能：将提取出来的数据加工
%调用方法
%eg.  [data] = extract_data(400,600,5,6,0)
%文件输入：
    %六个方向的sgy数据
    %每一个反射元所占的 xlinenum  inlinenum  time 的数量
    %输入参数:  data        待加工的数据
    %          xlinenum     每次读取数据的联络测线长度 
    %          time         每次读取数据的时间长度
    %          inline       每次要读取多少条主测线 
    %          directions   方向的数量
%输出：
    %handled_data：加工完成后的数据

%==========================================================================

function [handled_data] = handle_data(data,parameter,directions)

handled_data=zeros(parameter.time,parameter.xlineNum,parameter.nums,directions);        %初始化加工矩阵
%example：
%       s_data=data(:,:,1);             %取出来某一方向的数据
%       d_data=zeros(5,600,400);        %初始化加工矩阵
%       d_data(1,1,:)=s_data(:,1);      %令加工矩阵的z方向数据等于某一方向数据的列向量

%         tic
%         %小循环,x方向
%         for dir=1:directions
%             for i=1:nums
%                 %大循环,y方向
%                 for j=1:xlineNum
%                     index= (i-1)*xlineNum+j;
%                     handled_data(i,j,:,dir)=data(:,index,dir);
%                 end
%             end
%         end
%         toc

    %12.22发现extract_dataz中的错误
    %建议extract_data中直接读取成一列向量
    for dir=1:directions
      for inline=1:parameter.nums
          for xline=1:parameter.xlineNum
              for t=1:parameter.time
                  %原来的代码
%                 loc_data=(inline-1)*xlineNum*time+(xline-1)*time+t;
%                 handled_data(inline,xline,time-t+1,dir)= data(loc_data,dir);
    
             %改之后的代码   
                  loc_data=t+(xline-1)*parameter.time+(inline-1)*parameter.time*parameter.xlineNum;
                  handled_data(t,xline,inline,dir)=data(loc_data,dir);
             
              end
           end
       end
    end
    
end

%data的维度解释
%data维度为(time*xlineNum*nums,directions)，要化成下面的这种形式
%                                                                                                   
%                         %  ↗                                                                                                                                     
%                       % ↗ xline方向(y),大小：xlineNums                                                   
%                     %↗                                                               
%                   %                                                         
%                 % % % % % % % % % % % % % % % % %                                                                                    
%                 %          →→→→→→inline方向(x),大小：nums                                                  
%                ?%                                                              
%                ?%                                                                                
%      time方向  ?%                                                        
%      大小:time ?%                                                                                    
%                ?%                                                     

%
%sgy二进制文件是按先time，再xline最后inline方向来进行储存的
%因此
%可以利用公式
%三维数据体的任何一点(x,y,z)的数据在某个方向生成的列向量的位置为
% (x-1)*time*xlineNums+(y-1)*time+z  12.04书.
%


%12.05更新：将data的生成改为 (time,xlineNums*nums,directions)三维矩阵
%这样，该矩阵的列向量可以直接存放到三维矩阵的第三维度中
%因此，三维矩阵中列向量在data中第二维度的位置为：
%(x-1)*xlineNum+y
%example：
%       s_data=data(:,:,1);             %取出来某一方向的数据
%       d_data=zeros(5,600,400);        %初始化加工矩阵
%       d_data(1,1,:)=s_data(:,1);      %令加工矩阵的z方向数据等于某一方向数据的列向量
%       
