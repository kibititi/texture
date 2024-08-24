function [slice] = fun_slice(data9z,data3d)
%用于在三维地震数据中根据层面数据确定层面位置
%   data9z 层面数据，二维，顺序为：inline*xline*time
%   data3d 三维地震数据，顺序为：inline*xline*time
%   输出clice 层面的二维数据
%   调用格式为：slice=ffind(data9z,data3d)

%确定输入的三维数据大小
[x,y,z]=size(data3d);
%初始化目标层面
slice=zeros(x,y);

%开始绘制层面
h=waitbar(0,'finding slice');
for i = 1:x
    for j=1:y
        time=data9z((i-1)*y+j,3);
        temp=data3d(i,j,time);
        slice(i,j)=temp;
    end
    waitbar(i/x*y,h)
end
delete(h);
end


