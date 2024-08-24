%函数参数说明：input_data：输入的三维地震数据,z*xline*inline
%               p1,p2,p3：对梯度矩阵进行平滑的各向异性高斯核的标准差
%   delta1,delta2,delta3：对数据进行高斯平滑的高斯核的标准差
%说明：高斯核函数：G(u,delta) = (2*pi*delta*delta)^(-3/2)*exp(-u^2/(2*delta*delta))
%function [result_lambda_1,result_lambda_2,result_lambda_3] = Func_GST_anisotropy(input_data, p1,p2,p3,delta1,delta2,delta3,d1_interval,d2_interval,d3_interval)
function [u,v,w] = Func_GST_anisotropy(input_data, p1,p2,p3,delta1,delta2,delta3,d1_interval,d2_interval,d3_interval)
G_p = Func_compute_Gaussian_kernal_anisotropy(p1,p2,p3);
G_delta = Func_compute_Gaussian_kernal_anisotropy(delta1,delta2,delta3);
G_p = Func_normal_3d_filter(G_p);
G_delta = Func_normal_3d_filter(G_delta);
data_size = size(input_data);

% filterred_data = Func_fast_conv3d(input_data, G_delta);
filterred_data = convn(input_data, G_delta,'same');  %使用matlab自带多维卷积
clear input_data
[gradient_filter_1,gradient_filter_2,gradient_filter_3] = Func_generate_gradient_filters();

% data_gradient_1 = Func_fast_conv3d(filterred_data,gradient_filter_1);
% data_gradient_2 = Func_fast_conv3d(filterred_data,gradient_filter_2);
% data_gradient_3 = Func_fast_conv3d(filterred_data,gradient_filter_3);
data_gradient_1 = convn(filterred_data,gradient_filter_1,'same');  %使用matlab自带多维卷积
data_gradient_2 = convn(filterred_data,gradient_filter_2,'same');  %使用matlab自带多维卷积
data_gradient_3 = convn(filterred_data,gradient_filter_3,'same');  %使用matlab自带多维卷积
clear filterred_data
%对不同维度的尺度进行处理
data_gradient_1 = data_gradient_1/d1_interval/32;
data_gradient_2 = data_gradient_2/d2_interval/32;
data_gradient_3 = data_gradient_3/d3_interval/32;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%思路
M_element_11 = data_gradient_1.*data_gradient_1;
M_element_12 = data_gradient_1.*data_gradient_2;
M_element_13 = data_gradient_1.*data_gradient_3;
clear data_gradient_1
M_element_22 = data_gradient_2.*data_gradient_2;
M_element_23 = data_gradient_2.*data_gradient_3;
clear data_gradient_2
M_element_33 = data_gradient_3.*data_gradient_3;
clear data_gradient_3

% M_element_11 = Func_fast_conv3d(M_element_11, G_p);
% M_element_12 = Func_fast_conv3d(M_element_12, G_p);
% M_element_13 = Func_fast_conv3d(M_element_13, G_p);
% M_element_22 = Func_fast_conv3d(M_element_22, G_p);
% M_element_23 = Func_fast_conv3d(M_element_23, G_p);
% M_element_33 = Func_fast_conv3d(M_element_33, G_p);
M_element_11 = convn(M_element_11, G_p,'same');  %使用matlab自带多维卷积
M_element_12 = convn(M_element_12, G_p,'same');  %使用matlab自带多维卷积
M_element_13 = convn(M_element_13, G_p,'same');  %使用matlab自带多维卷积
M_element_22 = convn(M_element_22, G_p,'same');  %使用matlab自带多维卷积
M_element_23 = convn(M_element_23, G_p,'same');  %使用matlab自带多维卷积
M_element_33 = convn(M_element_33, G_p,'same');  %使用matlab自带多维卷积

clear G_p G_delta

u = zeros([data_size,3]);
v = zeros([data_size,3]);
w = zeros([data_size,3]);


for index_1 = 1:1:data_size(1,1)
    for index_2 = 1:1:data_size(1,2)
        for index_3 = 1:1:data_size(1,3)
            t_element_11 = M_element_11(index_1,index_2,index_3);
            t_element_12 = M_element_12(index_1,index_2,index_3);
            t_element_13 = M_element_13(index_1,index_2,index_3);
            t_element_22 = M_element_22(index_1,index_2,index_3);
            t_element_23 = M_element_23(index_1,index_2,index_3);
            t_element_33 = M_element_33(index_1,index_2,index_3);
            
            t_matrix = [t_element_11, t_element_12, t_element_13;...
                        t_element_12, t_element_22, t_element_23;...
                        t_element_13, t_element_23, t_element_33];
            
                               % 计算特征值和特征向量
                    [V, D] = eig(t_matrix);
                    [~,ind] = sort(diag(D));
                    Vs = V(:,ind);
                    u(index_1,index_2,index_3,:)=normc(Vs(:, 3));
                    v(index_1,index_2,index_3,:)= normc(Vs(:, 2));
                    w(index_1,index_2,index_3,:)= normc(Vs(:, 1));
                    % 提取第一特征向量和对应的特征值
%                     [~, idx] = max(diag(D));
%                     u = V(:, idx);
%                     [~, idy] = min(diag(D));
%                     w= V(:, idy);
                    % 计算倾角
%                     p(index_1,index_2,index_3) = v1(1) / v1(3);
%                     q(index_1,index_2,index_3) = v1(2) / v1(3);    
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


%函数功能：计算三维各向异性高斯核函数,half_width为2*delta,能达到95.44%
function G = Func_compute_Gaussian_kernal_anisotropy(delta1,delta2,delta3)
half_width1 = ceil(2*delta1);
half_width2 = ceil(2*delta2);
half_width3 = ceil(2*delta3);
width1 = 2*half_width1+1;
width2 = 2*half_width2+1;
width3 = 2*half_width3+1;
G = zeros(width1,width2,width3);
sigma1 = delta1*delta1;
sigma2 = delta2*delta2;
sigma3 = delta3*delta3;
for index_1 = 1:1:width1
    for index_2 = 1:1:width2
        for index_3 = 1:1:width3
            i = index_1-half_width1-1;
            j = index_2-half_width2-1;
            k = index_3-half_width3-1;
            G(index_1,index_2,index_3) = ((2*pi)^(-3/2) ) * ((sigma1*sigma2*sigma3)^(-1/2)) * exp(-0.5*(i*i/sigma1+j*j/sigma2+k*k/sigma3));
        end
    end
end      
end

function result = Func_fast_conv3d(input_data,kernal)
size_data = size(input_data);
size_kernal = size(kernal);
%判断输入是否满足条件：是否都为三维数据
if numel(size_data) ~= 3 || numel(size_kernal) ~= 3
    print('Wrong input for Func_conv3d!')
    return
end

t_indice_1 = (1:1:size_data(1,1))';
t_indice_1 = repmat(t_indice_1,1,size_data(1,2));
indice_1 = zeros(size_data);
for t_index = 1:1:size_data(1,3)
    indice_1(:,:,t_index) = t_indice_1;
end

t_indice_2 = (1:1:size_data(1,2))';
t_indice_2 = repmat(t_indice_2',size_data(1,1),1);
indice_2 = zeros(size_data);
for t_index = 1:1:size_data(1,3)
    indice_2(:,:,t_index) = t_indice_2;
end

t_indice_3 = ones(size_data(1,1),size_data(1,2));
indice_3 = zeros(size_data);
for t_index = 1:1:size_data(1,3)
    indice_3(:,:,t_index) = t_indice_3*t_index;
end

indice_1 = indice_1(:);
indice_2 = indice_2(:);
indice_3 = indice_3(:);
data_point_num = sum(size(indice_1))-1;

kernal_flatten = kernal(:);
data_expand = zeros(size_kernal(1,1)+size_data(1,1)-1,...
                    size_kernal(1,2)+size_data(1,2)-1,...
                    size_kernal(1,3)+size_data(1,3)-1);
t_1 = (size_kernal(1,1)-1)/2;
t_2 = (size_kernal(1,2)-1)/2;
t_3 = (size_kernal(1,3)-1)/2;
data_expand(t_1+1:t_1+size_data(1,1),t_2+1:t_2+size_data(1,2),t_3+1:t_3+size_data(1,3)) = input_data;


batch_size = 1000000;
count = ceil(data_point_num/batch_size);
result = zeros(size_data);
for count_index = 1:1:count
    start_num = batch_size*(count_index-1)+1;
    end_num = min(batch_size*count_index,data_point_num);
    
    t_data_expand_flatten = zeros(size_kernal(1,1)*size_kernal(1,2)*size_kernal(1,3),end_num-start_num+1);
    for i = start_num:1:end_num
        index_1 = round(indice_1(i,1));
        index_2 = round(indice_2(i,1));
        index_3 = round(indice_3(i,1));
        t_patch = data_expand(index_1:(index_1+size_kernal(1,1)-1),...
                              index_2:(index_2+size_kernal(1,2)-1),...
                              index_3:(index_3+size_kernal(1,3)-1));
        t_data_expand_flatten(:,i-start_num+1) = t_patch(:);
    end
    
    t_result_flatten = (kernal_flatten'*t_data_expand_flatten)';
    
    for i = start_num:end_num
        result(indice_1(i,1),indice_2(i,1),indice_3(i,1)) = t_result_flatten(i-start_num+1,1);
    end
end

end
%函数功能：得到三维的梯度算子,没有考虑系数
function [filter_1,filter_2, filter_3] = Func_generate_gradient_filters()
filter_1 = zeros(3,3,3);
filter_2 = zeros(3,3,3);
filter_3 = zeros(3,3,3);

filter_1(:,:,1) = [ -1, -2, -1;  0,  0,  0;  1,  2,  1];
filter_1(:,:,2) = [ -2, -4, -2;  0,  0,  0;  2,  4,  2];
filter_1(:,:,3) = [ -1, -2, -1;  0,  0,  0;  1,  2,  1];

filter_2(:,:,1) = [ -1,  0,  1; -2,  0,  2; -1,  0,  1];
filter_2(:,:,2) = [ -2,  0,  2; -4,  0,  4; -2,  0,  2];
filter_2(:,:,3) = [ -1,  0,  1; -2,  0,  2; -1,  0,  1];

filter_3(:,:,1) = [ -1, -2, -1; -2, -4, -2; -1, -2, -1];
filter_3(:,:,2) = [  0,  0,  0;  0,  0,  0;  0,  0,  0];
filter_3(:,:,3) = [  1,  2,  1;  2,  4,  2;  1,  2,  1];


end


%函数功能：对三维滤波器进行归一化
function result = Func_normal_3d_filter(input_data)
size_data = size(input_data);
%判断输入是否满足条件：是否都为三维数据
if numel(size_data) ~= 3
    print('Wrong input for Func_conv3d!')
    return
end

sum_value = sum(sum(sum(input_data)));

result = input_data/sum_value;
end