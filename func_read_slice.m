function [data_slice_3d] = func_read_slice(data3d,layer_data,up_time_number,down_time_number)
%func_read_slice 用于按照slice_data表示的顺序选择三维地震数据中的一部分
%   data3d：地震数据，顺序为time*xline*inline
%   slice_data：层位数据，顺序为xline，inline，time
%   up_time_number：向上取的毫秒数，对应点数/2
%   up_time_number：向下取的毫秒数，对应点数/2
%   
datasize=size(data3d);
data_slice_3d=zeros(datasize);
%毫秒数/2转化为点数，2ms为采样率，可修改
up_time_number=round(up_time_number/2);
down_time_number=round(down_time_number/2);
layer_data=[layer_data(:,1)-layer_data(1,1)+1,layer_data(:,2)-layer_data(1,2)+1,layer_data(:,3)];
for i=1:datasize(2)%inline
    for j=1:datasize(3)%xline
        time=layer_data((j-1)*datasize(2)+i,3);
        temp=data3d(time-up_time_number:time+down_time_number,i,j);
        data_slice_3d(time-up_time_number:time+down_time_number,i,j)=temp;
    end
end

end
