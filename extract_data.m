%==========================================================================
%���ܣ���ȥ����ͷ�;�ͷ��sgy�ļ�����ȡ����
%���÷���
%eg.  [data,fr_loc] = extract_data(400,600,5,6,0)
%�ļ����룺
    %���������sgy����
    %ÿһ������Ԫ��ռ�� xlinenum  inlinenum  time ������
    %�������: xlinenum      ÿ�ζ�ȡ���ݵ�������߳��� 
    %          time         ÿ�ζ�ȡ���ݵ�ʱ�䳤��
    %          inline       ÿ��Ҫ��ȡ������������ (��Ϊ������)
    %          directions   һ���ķ�������
    %          loc       ������ļ�ָ��λ��
%�����
    %data����ȡ����������
    %fr_loc:�ļ����ڵ�λ��
%==========================================================================

function [data] = extract_data(parameter,directions,loc,FoldPath)
%12.07ȡ��
% %��ȡֵ���ֽڴ�д
% data_byte=4;

%�����ļ���������

filecomname = '.sgy';

%��ʼ��
data=zeros(parameter.time*parameter.xlineNum*parameter.nums,directions);

for i=1:directions
    
    %����sgy���ļ���
    filename = strcat(FoldPath.DataPath,num2str(30*i),filecomname);  
    %% ��д������ȡ����    
    %��ȡ�ļ����
    fr = fopen(filename);
        
    %�ƶ�ָ�뵽main����Ҫ�����ļ�ָ��
    fseek(fr,loc,'bof');
            temp= fread(fr,parameter.time*parameter.xlineNum*parameter.nums,'single');
            data(:,i)= temp;   
%     data_cur=fread(fr,time*xlinenum*nums,'float');
    %���� �����ܳ����Ĳ�Ӧ���ǶԵ�
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
    %�ر��ļ�
    fclose(fr); 
end

return

