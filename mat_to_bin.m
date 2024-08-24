%===============================================
%       功能：将mat数据文件转换为原始bin文件
%       注意：一次性赋值多个变量可能内存崩溃
%===============================================
function []=mat_to_bin()
    %注意：Dir_2_1,mat数据有问题需要重新调整

    textures={'Energy','Entropy','Corre','Contrast','Homo'};
    for i=3:6
        for j=1:5
            fprintf('Current %d dir %d texture',i,j)
            %加载数据
            loadpath=strcat("F:\科研\数据\纹理属性数据\整体叠前数据输出数据（带倾角）352-1351\",'Dir_Of_',int2str(i),textures(j),'.mat');  %需要改
            load(loadpath)

            %各个方向上的维度
            [M,N,T]=size(dr);

            T=1345;     % Iter文件个数
            
            
            filename = strcat("F:\科研\数据\纹理属性数据\整体叠前数据输出数据（带倾角）352-1351\sgy文件\",textures(j),'_dir-',int2str(i),'.sgy');
            filename=filename{1};
            %打开的文件地址
            file=fopen(filename,'wb');


            %write到二进制文件中
            for kk=1:T
            tic
               for jj=1:N

                  for ii=1:M
                    %写入能量上的信息
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



