function [ceilData_new] = fun_reReadData(locationMatrix_new,data,ceilData)
%fun_reReadData 用于按照新的位置矩阵重新读取ceilData数据
%   输入数据：
%   data 地震数据，大小为size(data)=201        2201           5           6
%       顺序为time，xline，inline，direction
%   locationMatrix_new，按照地层倾角重新选定的计算网格，大小为point*3*direction，3表示time，xline，inline坐标
%   输出数据;
%   ceilData_new 表示按照新网格重新选取的地震数据，为配合原有代码，
%   其大小为11*5*5*6，顺序为time*xline*inline*directions
%-------------------------------------------------------------------
[point,L,D]=size(locationMatrix_new);
[T,X,Y,D]=size(ceilData);
ceilData_new=zeros(size(ceilData));
interpolated_value=zeros(point,1);
for i=1:D
    for j =1:point
        %选择点的位置
        time=locationMatrix_new(j,1,i);
        xline=locationMatrix_new(j,2,i);
        if (xline<1)
            xline=1;
        end
        if(xline>3)
            xline=3;
        end
        inline=locationMatrix_new(j,3,i); 
        % 使用 interp3 函数进行插值
        %对于 interp3 函数，目标点的输入参数顺序是 (Y, X, Z)，而不是 (X, Y, Z)。
        % 这是因为在 MATLAB 中，矩阵的索引方式是先行后列。
        interpolated_value(j) = interp3(data(:,:,:,i), xline, time, inline,'linear');
    end
%把Temp_ceilData_new中的数据转化为ceilData大小的数据
    j=1;
    for k=1:T
        for m=1:X
            for n=1:Y
                    ceilData_new(k,m,n,i)=interpolated_value(j);
                    j=j+1;
            end
        end
    end
end
% ceilData_new=reshape(ceilData_new,11,5,5,6);
fprintf('interp3 has finished\n');
toc
end