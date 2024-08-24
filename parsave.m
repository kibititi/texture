%==========================================================================
%归一化方法
%调用方法
%eg.  [file] = norm_data(data)
%文件输入：
    %输入参数  dir          保存路径          
    %输入参数: data         特征矩阵
%文件参数：
%
%
%输出：
    %文件
%==========================================================================

function [output] = parsave(dir,data,k,i,j,iter_num)
    %每次time循环要保存的变量名
    var_name=strcat('Iter_',int2str(iter_num),'_',int2str(k),'_',int2str(i),'_',int2str(j));


    file_name=strcat('.\datas\','Iter_',int2str(iter_num),'.mat');

    
    %如果不存在该文件，应该先创建
    if exist(file_name,'file')==0
        save(dir,'var_name');
    end
    
    %执行赋值
    express=strcat(var_name,'=','data',';');
    eval(express);
    %提示语句
    fprintf('保存到文件中%s\n',var_name);
    %保存
    save(dir, strcat('Iter_',int2str(iter_num),'_',int2str(k),'_',int2str(i),'_',int2str(j)),'-append')

    output="sccess";
end

