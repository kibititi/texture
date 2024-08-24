function output = Gauss_filter_3d(input,ksize,sigma)
%������ά�������ݵĸ�˹�˲�
%   ����ά����������t�����Ͼ���������ƽ��
% �Ա��ά��˹�˲�������image����Ҫ�˲���ͼ��ksize�Ƕ�ά��˹�˲���ģ��ߴ磬sigma�Ƿ���
%���ȹ�����˹��
% ����ͼ������λ��
k=floor((ksize-1)/2);
% �ȳ�ʼ��
gauss_kernel = zeros(ksize,ksize);
% ���ɶ�ά��ɢ��˹����ˣ��ߴ�Ϊksize��ksize��
for i=1:ksize
    for j=1:ksize
        % ����ά��˹������ɢ��
        gauss_kernel(i,j) = exp(-((i-k-1)^2+(j-k-1)^2)/(2*sigma.^2))/(2*pi*sigma.^2);
    end
end
%��һ��
temp=sum(sum(gauss_kernel));
gauss_kernel=gauss_kernel./temp;
%��ʼ��������ݣ����������ݴ�С��ͬ

[mx,my,mz]=size(input);
z=zeros(mx,my,mz);
%replicate:ͼ���Сͨ����ֵ��߽��ֵ����չ
%symmetric ͼ���Сͨ��������ı߽���о���ӳ����չ

    
h=waitbar(0,'��z���и�˹ƽ��');
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

