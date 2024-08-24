%===============================================
%       功能：将两个mat数据文件同时转换为原始bin文件
%       注意：一次性赋值多个变量可能内存崩溃
%===============================================
function [outdata]=fun_2_file_mat2bin(matdata1,matdata2,filename1,filename2)
%各个方向上的维度
[M,N,T]=size(matdata1);
file1=fopen(filename1,'wb');
file2=fopen(filename2,'wb');
%write到二进制文件中
for kk=1:T
    for jj=1:N
        for ii=1:M
            %写入能量上的信息
            fwrite(file1,matdata1(ii,jj,kk),'float32');
            fwrite(file2,matdata2(ii,jj,kk),'float32');
        end
    end
    if(mod(kk,100)==1||kk==0)
        fprintf('数据写入进度:%d/%d\n',kk,T)
    end
end
fclose(file1);
fclose(file2);
outdata='数据写入完成';
end