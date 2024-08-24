function outputdata = fun_omega(inputdata)
%����ʹ��ʱƵ��ʾ��������˲ʱƵ��
%   inputdata �������ݣ�������˹ƽ����ϣ�����ر任�����ά��������
%   outputdata ������ݣ�ʹ��ʱƵ��ʾ��������õ���˲ʱƵ��

[x,y,z]=size(inputdata);
outputdata=zeros(x,y,z);
l =floor(z/2);
f = 1:l;
% h=waitbar(0,'stft');
for a=1:x
    for j=1:y
        data_text = inputdata(a,j,:);
        data_text = permute(data_text,[3 1 2]);
        
        data_tfr= tfrstft(data_text);
% fun_omega �е����˺���tfrstft�����ڴ�Сѡ���ں���tfrstft�У�ѡ������Ϊ
% T = 1/f ������f��ʾ�����źŵ���ҪƵ�ʣ�һ��Ϊ30hz��
% h = T/��t�����Ц�t��ʾ�������ڣ���������Ϊ0.0002s
        data_tfr = data_tfr';
        data_tfr =data_tfr(:,1:l);
        pz = abs(data_tfr).^2;
        for i = 1:z
           outputdata(a,j,i) = sum(f.*pz(i,:))/sum(pz(i,:));
        end
    end
%     waitbar(a/x,h)
    if(mod(a,200)==1)
        fprintf("��Ǽ��㣬�����%d ��....\n",a);
    end
end
% delete(h);
% clear h;
%���ڵĹ�һ����17��ʾ��ʱ����Ҷ�仯�Ĵ��ڣ�17��
%z��ʾ�������ݵĴ���
outputdata=17/z.*outputdata;
end

