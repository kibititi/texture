%==========================================================================
%���ܣ�����ȡ���������ݼӹ�
%���÷���
%eg.  [data] = extract_data(400,600,5,6,0)
%�ļ����룺
    %���������sgy����
    %ÿһ������Ԫ��ռ�� xlinenum  inlinenum  time ������
    %�������:  data        ���ӹ�������
    %          xlinenum     ÿ�ζ�ȡ���ݵ�������߳��� 
    %          time         ÿ�ζ�ȡ���ݵ�ʱ�䳤��
    %          inline       ÿ��Ҫ��ȡ������������ 
    %          directions   ���������
%�����
    %handled_data���ӹ���ɺ������

%==========================================================================

function [handled_data] = handle_data(data,parameter,directions)

handled_data=zeros(parameter.time,parameter.xlineNum,parameter.nums,directions);        %��ʼ���ӹ�����
%example��
%       s_data=data(:,:,1);             %ȡ����ĳһ���������
%       d_data=zeros(5,600,400);        %��ʼ���ӹ�����
%       d_data(1,1,:)=s_data(:,1);      %��ӹ������z�������ݵ���ĳһ�������ݵ�������

%         tic
%         %Сѭ��,x����
%         for dir=1:directions
%             for i=1:nums
%                 %��ѭ��,y����
%                 for j=1:xlineNum
%                     index= (i-1)*xlineNum+j;
%                     handled_data(i,j,:,dir)=data(:,index,dir);
%                 end
%             end
%         end
%         toc

    %12.22����extract_dataz�еĴ���
    %����extract_data��ֱ�Ӷ�ȡ��һ������
    for dir=1:directions
      for inline=1:parameter.nums
          for xline=1:parameter.xlineNum
              for t=1:parameter.time
                  %ԭ���Ĵ���
%                 loc_data=(inline-1)*xlineNum*time+(xline-1)*time+t;
%                 handled_data(inline,xline,time-t+1,dir)= data(loc_data,dir);
    
             %��֮��Ĵ���   
                  loc_data=t+(xline-1)*parameter.time+(inline-1)*parameter.time*parameter.xlineNum;
                  handled_data(t,xline,inline,dir)=data(loc_data,dir);
             
              end
           end
       end
    end
    
end

%data��ά�Ƚ���
%dataά��Ϊ(time*xlineNum*nums,directions)��Ҫ���������������ʽ
%                                                                                                   
%                         %  �J                                                                                                                                     
%                       % �J xline����(y),��С��xlineNums                                                   
%                     %�J                                                               
%                   %                                                         
%                 % % % % % % % % % % % % % % % % %                                                                                    
%                 %          ������������inline����(x),��С��nums                                                  
%                ?%                                                              
%                ?%                                                                                
%      time����  ?%                                                        
%      ��С:time ?%                                                                                    
%                ?%                                                     

%
%sgy�������ļ��ǰ���time����xline���inline���������д����
%���
%�������ù�ʽ
%��ά��������κ�һ��(x,y,z)��������ĳ���������ɵ���������λ��Ϊ
% (x-1)*time*xlineNums+(y-1)*time+z  12.04��.
%


%12.05���£���data�����ɸ�Ϊ (time,xlineNums*nums,directions)��ά����
%�������þ��������������ֱ�Ӵ�ŵ���ά����ĵ���ά����
%��ˣ���ά��������������data�еڶ�ά�ȵ�λ��Ϊ��
%(x-1)*xlineNum+y
%example��
%       s_data=data(:,:,1);             %ȡ����ĳһ���������
%       d_data=zeros(5,600,400);        %��ʼ���ӹ�����
%       d_data(1,1,:)=s_data(:,1);      %��ӹ������z�������ݵ���ĳһ�������ݵ�������
%       
