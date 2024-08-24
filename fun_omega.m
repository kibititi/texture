function outputdata = fun_omega(inputdata)
%用于使用时频表示方法计算瞬时频率
%   inputdata 输入数据，经过高斯平滑和希尔伯特变换后的三维地震数据
%   outputdata 输出数据，使用时频表示方法计算得到的瞬时频率

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
% fun_omega 中调用了函数tfrstft，窗口大小选择在函数tfrstft中，选择依据为
% T = 1/f ，其中f表示地震信号的主要频率，一般为30hz，
% h = T/Δt，其中Δt表示采样周期，本数据中为0.0002s
        data_tfr = data_tfr';
        data_tfr =data_tfr(:,1:l);
        pz = abs(data_tfr).^2;
        for i = 1:z
           outputdata(a,j,i) = sum(f.*pz(i,:))/sum(pz(i,:));
        end
    end
%     waitbar(a/x,h)
    if(mod(a,200)==1)
        fprintf("倾角计算，已完成%d 道....\n",a);
    end
end
% delete(h);
% clear h;
%窗口的归一化，17表示短时傅里叶变化的窗口（17）
%z表示输入数据的窗口
outputdata=17/z.*outputdata;
end

