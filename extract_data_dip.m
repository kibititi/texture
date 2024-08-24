function [data] = extract_data_dip(parameter,loc,filename)
%初始化
% data=zeros(time*xlineNum*nums);
    %% 自写函数读取数据    
    %获取文件句柄
    fr = fopen(filename);       
    %移动指针到main迭代要到的文件指针
    fseek(fr,loc,'bof');
            temp= fread(fr,parameter.time*parameter.xlineNum*parameter.nums,'single');
            data= temp;   
    fclose(fr); 
end