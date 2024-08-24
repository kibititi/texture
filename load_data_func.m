%==========================================================================
%��ȡÿ������Ԫ���������ԣ����ϳ�һ���������
%�������˵����
%   time                %ʱ�䷽�򳤶�
%   xlineNum            %������߳���
%   inlineNum           %�����ߵĳ���
%   directions          %��������
%   textNum             %������������
%   nums                %һ�ζ�ȡinline����


%�����ļ�˵����
%   ���mat�ļ�
%�����
    %�����������mat�ļ�
%==========================================================================
function []=load_data_func(time,xlineNum,inlineNum,directions,textNum)
    
    iter_nums=inlineNum-4;      %��������
    inlineNum = inlineNum-4;    %������ά�������ߵĳ���
    xlineNum=xlineNum-4;        %������ά��������ߵĳ���
    time=time-4;                %����ʱ��ĳ���

    %===============================================
    %       һ���Ը�ֵ��������ڴ����
    %       ����forѭ���������
    %       ���ڶ���forѭ�������Ӳ��в������ӿ촦��
    %===============================================
    for iter_dir=1:directions
        %��ʼ������
        dr = zeros(xlineNum,inlineNum,time,textNum);
        %һ�������ϴ���Ŀ�ʼʱ��
        start_time = clock;
        for iter_num = 1:iter_nums
           %���ص�·��
           loadpath=strcat('I:\matlab\12_23data\','Iter_',int2str(iter_num),'.mat');
           %����ļ��Ƿ����
           if(isfile(loadpath)== 1)
               %�����ļ�
               load(loadpath)
           else
               %��ʾ�ļ�������
               fprintf("������Iter_%d.mat�ļ���",iter_num);
           end

           for time_data=1:time
              for xlineNum_data=1:xlineNum
                %ע��˴���loc_dataҪ��Ӧextract_unit_data��˳�򣬲�Ȼ����
                loc_data = xlineNum*(time_data-1)+xlineNum_data;
                %iter_dir*5-4:iter_dir*5��ʾ��Ӧdir������
                dr(iter_num,xlineNum_data,time_data,:) = text_data(loc_data ,iter_dir*5-4:iter_dir*5);
              end
           end 
        end
        
        %һ�������ϴ�����ɵĽ���ʱ��
        end_time = clock;
        %��ʾ
        fprintf("Total_Iter:%d is completed, costing %f s\n",iter_dir,etime(end_time,start_time));
        %����·��
        savepath=strcat('I:\matlab\12_23mergedata\','Dir_Of_',int2str(iter_dir),'.mat');

        save(savepath,'dr')
        %��clear�����ڴ��ֹ�ڴ����
        clear dr
    end

end




