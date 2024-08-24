function [p, q] = fun_computeCurvature(ceilData)
    % 获取数据大小
    [time, xline, inline,direction] = size(ceilData);
    % 初始化倾角数据
    p = zeros(time, xline, inline,direction);
    q = zeros(time, xline, inline,direction);
p1 = 4;  %对梯度矩阵进行平滑的各向异性高斯核的标准差
p2 = 2;
p3 = 2;
delta1 = 2;  %对数据进行高斯平滑的高斯核的标准差
delta2 = 1;
delta3 = 1;
    %进行希尔伯特变化
    for dir=1:direction
        seismicData=ceilData(:,:,:,dir);
        [p_temp,q_temp] = Func_GST_anisotropy(seismicData,p1,p2,p3,delta1,delta2,delta3,1,1,1);
        TF= isinf(p_temp);
        p_temp(TF) = 0;
        TF= isinf(q_temp);
        q_temp(TF) = 0;     
        p_temp=medfilt3(p_temp);
        q_temp=medfilt3(q_temp);
        p(:,:,:,dir)=p_temp;
        q(:,:,:,dir)=q_temp;
    end
    nanf=isnan(p);
    p(nanf) = 0;

    nanf=isnan(q);
    q(nanf) = 0;
end



