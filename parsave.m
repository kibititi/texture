%==========================================================================
%��һ������
%���÷���
%eg.  [file] = norm_data(data)
%�ļ����룺
    %�������  dir          ����·��          
    %�������: data         ��������
%�ļ�������
%
%
%�����
    %�ļ�
%==========================================================================

function [output] = parsave(dir,data,k,i,j,iter_num)
    %ÿ��timeѭ��Ҫ����ı�����
    var_name=strcat('Iter_',int2str(iter_num),'_',int2str(k),'_',int2str(i),'_',int2str(j));


    file_name=strcat('.\datas\','Iter_',int2str(iter_num),'.mat');

    
    %��������ڸ��ļ���Ӧ���ȴ���
    if exist(file_name,'file')==0
        save(dir,'var_name');
    end
    
    %ִ�и�ֵ
    express=strcat(var_name,'=','data',';');
    eval(express);
    %��ʾ���
    fprintf('���浽�ļ���%s\n',var_name);
    %����
    save(dir, strcat('Iter_',int2str(iter_num),'_',int2str(k),'_',int2str(i),'_',int2str(j)),'-append')

    output="sccess";
end

