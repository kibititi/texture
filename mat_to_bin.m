%===============================================
%       ���ܣ���mat�����ļ�ת��Ϊԭʼbin�ļ�
%       ע�⣺һ���Ը�ֵ������������ڴ����
%===============================================
function []=mat_to_bin()
    %ע�⣺Dir_2_1,mat������������Ҫ���µ���

    textures={'Energy','Entropy','Corre','Contrast','Homo'};
    for i=3:6
        for j=1:5
            fprintf('Current %d dir %d texture',i,j)
            %��������
            loadpath=strcat("F:\����\����\������������\�����ǰ����������ݣ�����ǣ�352-1351\",'Dir_Of_',int2str(i),textures(j),'.mat');  %��Ҫ��
            load(loadpath)

            %���������ϵ�ά��
            [M,N,T]=size(dr);

            T=1345;     % Iter�ļ�����
            
            
            filename = strcat("F:\����\����\������������\�����ǰ����������ݣ�����ǣ�352-1351\sgy�ļ�\",textures(j),'_dir-',int2str(i),'.sgy');
            filename=filename{1};
            %�򿪵��ļ���ַ
            file=fopen(filename,'wb');


            %write���������ļ���
            for kk=1:T
            tic
               for jj=1:N

                  for ii=1:M
                    %д�������ϵ���Ϣ
                    fwrite(file,dr(ii,jj,kk),'float32');
                  end
                  
               end
               toc
               fprintf('current kk equal:%d\n',kk)
            end

            fclose(file);

        end
    end
end



