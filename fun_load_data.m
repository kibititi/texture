%==========================================================================
%��ȡÿ������Ԫ����������
%�����ļ�˵����
%   ���mat�ļ�
%�����
    %�����������mat�ļ�
%==========================================================================



function []=fun_load_data(Parameter,FoldPath,offset_num)
nums=Parameter.nums;
inlineNum=Parameter.inlineNum;
xlineNum=Parameter.xlineNum;
time=Parameter.time;
iter_nums=Parameter.iter_nums;
    %inlineNum = 351;
%     directions=1;
    %����������˳��
    textNum = Parameter.numHarFeature;                %���������
%     offset_num=6;               %�������Ե�ͳ�Ʒ���
    xlineNum=xlineNum-nums+1;        %������ά��������ߵĳ���
    textures=Parameter.textures;
    %ע��˳����Ҫ��
    % E:\ѧϰ23\��һ����\��������\����\matlab_m\extractPreTexture.m
    %�е���������������˳�򱣳�һ��
    %===============================================
    %       һ���Ը�ֵ��������ڴ����
    %===============================================
    
    
    
    for text=1:textNum     % 1-5��ĳһ���������� 
        for iter_dir = 1:offset_num          % w����  
            start_time = clock;
            
            %��ʼ������
           dr = zeros(time,xlineNum,inlineNum);
%�޸Ĳ���
            for iter_num = 1:iter_nums   %iter_nums,Ҳ���ǣ�inlineNum-4      % 1512��ʾIter�ļ��ĸ���
               loadpath=strcat(FoldPath.OutputPath,'Iter_',int2str(iter_num),'.mat');
               %����ļ��Ƿ����
               if(isfile(loadpath)== 1)
                    load(loadpath)
               else
                   fprintf('������Iter_%d.mat�ļ���',iter_num);
               end

               % ���˳��  1.xline  2.time
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
            %����·��
%             temp=strjoin(cellstr(textures(text)));
            savepath=strjoin(cellstr(strcat(FoldPath.OutputPath,'Dir_Of_',num2str(iter_dir),textures(text),'.mat')));
%             loadpath=strcat(FoldPath.OutputPath,'Iter_',int2str(iter_num),'.mat');
            save(savepath,'dr')
            %clear�����ڴ�
            clear dr
        end
    end
end



