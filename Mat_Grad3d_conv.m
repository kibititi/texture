function [px,py,pz] = Mat_Grad3d_conv(input)
% input 顺序为：inline xline time
% 用于计算三维离散数据的向量内部梯度，系统自带梯度为列向量与列向量之间的梯度
%使用中间微分，边缘使用前/后向微分
%使用5*5网格计算
%数据初始化
[mx,my,mz]=size(input);
px = zeros(mx,my,mz);%沿inline方向差分
py = zeros(mx,my,mz);%沿xline方向差分
pz = zeros(mx,my,mz);%沿time方向差分

%计算各个方向微分的权系数矩阵（5*5）
Fx=1/60.*[1 1 1 1 1;-8 -8 -8 -8 -8;0 0 0 0 0;8 8 8 8 8;-1 -1 -1 -1 -1];
Fy=Fx';
Fz=60.*Fx.*Fy;
%计算各个方向微分的权系数矩阵（3*3）
% Fx=1/6.*[-1 -1 -1;0 0 0 ;1 1 1];
% Fy=Fx';
% Fz=9.*Fx.*Fy;
%计算x方向的微分
% h=waitbar(0,'px');
for i=1:mx
    temp = input(i,:,:);
    temp=permute(temp,[2 3 1]);
    result = conv2(temp,Fx,'same');
    result=permute(result,[3 1 2]);
    px(i,:,:)=result;
%     waitbar(i/mx,h)
end 
% delete(h);
%计算y方向的微分
% h=waitbar(0,'py');
for i=1:my
    temp = input(:,i,:);
    temp=permute(temp,[1 3 2]);
    result = conv2(temp,Fy,'same');
    result=permute(result,[1 3 2]);
    py(:,i,:)=result;
%     waitbar(i/my,h)
end 
% delete(h);
%计算z方向的微分
% h=waitbar(0,'pz');
for i=1:mz
     temp = input(:,:,i);
    pz(:,:,i) = conv2(temp,Fz,'same');
%     waitbar(i/mz,h)
end 
% delete(h);
end

