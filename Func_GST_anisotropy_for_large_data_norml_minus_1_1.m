%% �Խϴ����ݼ���GST
% ���룺
%      input_data������ĵ�������
%      p1�����ݶȲ�ʸ�������ƽ��time(depth)ά�ȸ�˹�˵ı�׼������㣬��ȡ4
%      p2�����ݶȲ�ʸ�������ƽ��      xlineά�ȸ�˹�˵ı�׼������㣬��ȡ2
%      p3�����ݶȲ�ʸ�������ƽ��     inlineά�ȸ�˹�˵ı�׼������㣬��ȡ2
%      delta1�������ݽ��и�˹ƽ����time(depth)ά�ȸ�˹�˵ı�׼������㣬��ȡ2
%      delta2�������ݽ��и�˹ƽ����      xlineά�ȸ�˹�˵ı�׼������㣬��ȡ1
%      delta3�������ݽ��и�˹ƽ����     inlineά�ȸ�˹�˵ı�׼������㣬��ȡ1
%      d1_interval��time(depth)ά�ȵ�λ���ȣ������㣬��ȡ1
%      d2_interval��      xlineά�ȵ�λ���ȣ������㣬��ȡ1
%      d3_interval��     inlineά�ȵ�λ���ȣ������㣬��ȡ1
function [result_lambda_3] = Func_GST_anisotropy_for_large_data_norml_minus_1_1(input_data, p1,p2,p3,delta1,delta2,delta3,d1_interval,d2_interval,d3_interval)
t_max = max(max(max(input_data)));
t_min = min(min(min(input_data)));
t_max = max(abs(t_max),abs(t_min));
input_data = input_data/t_max; %0ֵ����

[d1,d2,d3] = size(input_data);
% result_lambda_1 = zeros(d1,d2,d3,3);
% result_lambda_2 = zeros(d1,d2,d3,3);
result_lambda_3 = zeros(d1,d2,d3,3);

% �ص������С
half_width_p = ceil(2*max([p1,p2,p3]));
half_width_delta = ceil(2*max([delta1,delta2,delta3]));
band_length = half_width_p + half_width_delta;
band_length = band_length+10;   %��΢����һ��

interval_d1 = 200;
interval_d2 = 200;
interval_d3 = 200;

disp('Start processing.....')
for index_d1 = 1:interval_d1:d1
    disp(['process d1��',num2str(index_d1),' / ',num2str(d1)]);
    for index_d2 = 1:interval_d2:d2
        disp(['   process d2��',num2str(index_d2),' / ',num2str(d2)]);
        for index_d3 = 1:interval_d3:d3
            disp(['      process d3��',num2str(index_d3),' / ',num2str(d3)]);
            t_d1_start = index_d1; t_d1_end = index_d1+interval_d1-1; t_d1_end = min(t_d1_end,d1);
            t_d2_start = index_d2; t_d2_end = index_d2+interval_d2-1; t_d2_end = min(t_d2_end,d2);
            t_d3_start = index_d3; t_d3_end = index_d3+interval_d3-1; t_d3_end = min(t_d3_end,d3);
            
            t_d1_start_expand = max(1,t_d1_start-band_length); t_d1_end_expand = min(d1,t_d1_end+band_length);
            t_d2_start_expand = max(1,t_d2_start-band_length); t_d2_end_expand = min(d2,t_d2_end+band_length);
            t_d3_start_expand = max(1,t_d3_start-band_length); t_d3_end_expand = min(d3,t_d3_end+band_length);
            
            t_d1 = t_d1_start - t_d1_start_expand + 1; t_length_1 = t_d1_end - t_d1_start + 1;
            t_d2 = t_d2_start - t_d2_start_expand + 1; t_length_2 = t_d2_end - t_d2_start + 1;
            t_d3 = t_d3_start - t_d3_start_expand + 1; t_length_3 = t_d3_end - t_d3_start + 1;
            
            t_data = input_data(t_d1_start_expand:t_d1_end_expand,t_d2_start_expand:t_d2_end_expand,t_d3_start_expand:t_d3_end_expand);
            %[t_result_lambda_1,t_result_lambda_2,t_result_lambda_3] = Func_GST_anisotropy(t_data, p1, p2, p3, delta1, delta2, delta3, d1_interval, d2_interval, d3_interval);
            [~,~,t_result_lambda_3] = Func_GST_anisotropy(t_data, p1, p2, p3, delta1, delta2, delta3, d1_interval, d2_interval, d3_interval);
%             result_lambda_1(t_d1_start:t_d1_end, t_d2_start:t_d2_end, t_d3_start:t_d3_end) = t_result_lambda_1(t_d1:t_d1+t_length_1-1, t_d2:t_d2+t_length_2-1, t_d3:t_d3+t_length_3-1);
%             result_lambda_2(t_d1_start:t_d1_end, t_d2_start:t_d2_end, t_d3_start:t_d3_end) = t_result_lambda_2(t_d1:t_d1+t_length_1-1, t_d2:t_d2+t_length_2-1, t_d3:t_d3+t_length_3-1);
            result_lambda_3(t_d1_start:t_d1_end, t_d2_start:t_d2_end, t_d3_start:t_d3_end,:) = t_result_lambda_3(t_d1:t_d1+t_length_1-1, t_d2:t_d2+t_length_2-1, t_d3:t_d3+t_length_3-1,:);
        end
    end
end

end