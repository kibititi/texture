function [p_ceilData,q_ceilData] = fun_curvature(ceilData)
%   fun_curvature 用于初步计算ceildata中的11*5*5*6的地震数据块的曲率
%   使用倾角扫描的方式用于计算曲率
%   输入数据：ceilData，4D数据，大小为 time inline xline
%   输出数据：curvature_ceilData，4D数据，大小同ceilData
%   输出数据为当前ceildata的初步曲率结果
%-------------------------------------------------------------------------------

ceilData3d=ceilData;
clear ceilData
%  叠后数据的平均计算
%  ceilData3d=1/D.*ceilData3d;

%将数据顺序调整为：inline xline time
ceilData3d =  permute(ceilData3d,[2 3 1]);
%进行希尔伯特变化
ceilData3d_H=MatHilbert(ceilData3d);


%分方向求偏导
%Mat_Grad3d_conv进行差分求导，考虑到输入数据的大小选用3*3网格、5*5网格进行差分。
%具体差分网格选择在Mat_Grad3d_conv内部。
%当前使用的是3*3
[px,py,~] =  Mat_Grad3d_conv(ceilData3d);
[pxh,pyh,~] = Mat_Grad3d_conv(ceilData3d_H);
% 计算瞬时频率和kx、ky
% u=ceilData3d.^2+ceilData3d_H.^2;
% u(u<0.0001)=0;
% 将u中过小的值转为0，在计算omega、kxky中得到的inf转为0
%避免出现由于u值极小得到的omega、kx，ky的极大值
kx = (ceilData3d.*pxh - ceilData3d_H.*px)./(ceilData3d.^2+ceilData3d_H.^2);
% TF= isinf(kx);
% kx(TF) = 0;
% nanf=isnan(kx);
% kx(nanf) = 0;
clear TF px pxh

ky = (ceilData3d.*pyh - ceilData3d_H.*py)./(ceilData3d.^2+ceilData3d_H.^2);
% TF= isinf(ky);
% ky(TF) = 0;
% nanf=isnan(ky);
% ky(nanf) = 0;
clear TF py pyh
%fun_omega的输入数据顺序为：inline xline time
omeganew = fun_omega(ceilData3d);
p_temp=kx./omeganew;
q_temp=ky./omeganew;
clear kx ky omeganew nanf ceilData3d ceilData3d_H
%将数据顺序调整为：time inline xline
p_temp =  permute(p_temp,[3 1 2]);
q_temp =  permute(q_temp,[3 1 2]);
p_ceilData= p_temp;
clear p_temp
q_ceilData = q_temp;
clear  q_temp
nanf=isnan(p_ceilData);
p_ceilData(nanf) = 0;
clear TF
nanf=isnan(q_ceilData);
q_ceilData(nanf) = 0;
clear TF
p_ceilData=0.5.*p_ceilData;
q_ceilData=0.5.*q_ceilData;
q_ceilData=smoothdata(q_ceilData);
p_ceilData=smoothdata(p_ceilData);
end