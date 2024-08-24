function output = Gauss_filter_3d(input,ksize,sigma)
%用于三维地震数据的高斯滤波
%   对三维地震数据体t方向上均进行数据平滑
% 自编二维高斯滤波函数，image是需要滤波的图象，ksize是二维高斯滤波器模板尺寸，sigma是方差
%首先构建高斯核
% 计算图象中心位置
k=floor((ksize-1)/2);
% 先初始化
gauss_kernel = zeros(ksize,ksize);
% 生成二维离散高斯卷积核（尺寸为ksize×ksize）
for i=1:ksize
    for j=1:ksize
        % 将二维高斯函数离散化
        gauss_kernel(i,j) = exp(-((i-k-1)^2+(j-k-1)^2)/(2*sigma.^2))/(2*pi*sigma.^2);
    end
end
%归一化
temp=sum(sum(gauss_kernel));
gauss_kernel=gauss_kernel./temp;
%初始化输出数据，与输入数据大小相同

[mx,my,mz]=size(input);
z=zeros(mx,my,mz);
%replicate:图像大小通过赋值外边界的值来扩展
%symmetric 图像大小通过沿自身的边界进行镜像映射扩展

    
h=waitbar(0,'对z进行高斯平滑');
for i=1:mz
    temp = input(:,:,i);
    temp=medfilt2(temp,[3,3]);
    result=conv2(temp,gauss_kernel,'same');

    z(:,:,i)=result;
    waitbar(i/mz,h)
end
delete(h);
output=z;
end

