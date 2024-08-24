function [outputdata] = MatHilbert(inputdata)
%���ڶ���ά���ݽ���ϣ�����ر任
%   inputdata �������ά�������ݣ�˳��Ϊ  inline xline time
%   outputdata ������ݣ�inline xline time����ϣ�����ر任���������������

%ȷ�����롢������ݴ�С
[x,y,z]=size(inputdata);
outputdata=zeros(z,x*y);

%����������ת��Ϊ��ά����
inputdata=permute(inputdata,[3 1 2]);
inputdata=reshape(inputdata,[z x*y]);

% h=waitbar(0,'please wait');
for i = 1:x*y
    outputdata(:,i) =  hilbert(inputdata(:,i));
%     waitbar(i/x*y,h)
end
% delete(h);

outputdata=imag(outputdata); %ȡ����������

%�������ת��Ϊ��ά״̬
outputdata=reshape(outputdata,[z x y]);
outputdata=permute(outputdata,[2 3 1]);
end
