function [outputdata] = MatHilbert(inputdata)
%用于对三维数据进行希尔伯特变换
%   inputdata 输入的三维地震数据，顺序为  inline xline time
%   outputdata 输出数据，inline xline time经过希尔伯特变换后的虚数部分数据

%确定输入、输出数据大小
[x,y,z]=size(inputdata);
outputdata=zeros(z,x*y);

%将输入数据转换为二维数据
inputdata=permute(inputdata,[3 1 2]);
inputdata=reshape(inputdata,[z x*y]);

% h=waitbar(0,'please wait');
for i = 1:x*y
    outputdata(:,i) =  hilbert(inputdata(:,i));
%     waitbar(i/x*y,h)
end
% delete(h);

outputdata=imag(outputdata); %取虚数数部分

%输出数据转化为三维状态
outputdata=reshape(outputdata,[z x y]);
outputdata=permute(outputdata,[2 3 1]);
end
