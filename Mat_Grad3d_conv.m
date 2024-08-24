function [px,py,pz] = Mat_Grad3d_conv(input)
% input ˳��Ϊ��inline xline time
% ���ڼ�����ά��ɢ���ݵ������ڲ��ݶȣ�ϵͳ�Դ��ݶ�Ϊ��������������֮����ݶ�
%ʹ���м�΢�֣���Եʹ��ǰ/����΢��
%ʹ��5*5�������
%���ݳ�ʼ��
[mx,my,mz]=size(input);
px = zeros(mx,my,mz);%��inline������
py = zeros(mx,my,mz);%��xline������
pz = zeros(mx,my,mz);%��time������

%�����������΢�ֵ�Ȩϵ������5*5��
Fx=1/60.*[1 1 1 1 1;-8 -8 -8 -8 -8;0 0 0 0 0;8 8 8 8 8;-1 -1 -1 -1 -1];
Fy=Fx';
Fz=60.*Fx.*Fy;
%�����������΢�ֵ�Ȩϵ������3*3��
% Fx=1/6.*[-1 -1 -1;0 0 0 ;1 1 1];
% Fy=Fx';
% Fz=9.*Fx.*Fy;
%����x�����΢��
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
%����y�����΢��
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
%����z�����΢��
% h=waitbar(0,'pz');
for i=1:mz
     temp = input(:,:,i);
    pz(:,:,i) = conv2(temp,Fz,'same');
%     waitbar(i/mz,h)
end 
% delete(h);
end

