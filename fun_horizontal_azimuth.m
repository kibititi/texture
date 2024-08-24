function fun_horizontal_azimuth(Type, FoldPath)
%用于实现对xline-inline平面的水平方位角的计算
switch Type.offSets_type
    case 'Auto'
        disp('当前纹理属性统计方向为：传统方向+自适应方向');
        if exist(FoldPath.anglefilename, 'file') == 2
            disp('水平方位角数据存在');
        else
            disp('水平方位角数据不存在，计算水平方位角数据中......');
            %1.输入叠后地震数据，顺序为time xline inline
            stack_data=load(FoldPath.stackedData);
            stack_data=stack_data.stack_data;
            % % 2.对叠后数据计算水平方位角

            p1 = 4;  %对梯度矩阵进行平滑的各向异性高斯核的标准差
            p2 = 2;
            p3 = 2;
            delta1 = 2;  %对数据进行高斯平滑的高斯核的标准差
            delta2 = 1;
            delta3 = 1;
            %计算各方向的特征向量，uvw，针对较小数据
%             [~,~,w] = Func_GST_anisotropy(stack_data, p1,p2,p3,delta1,delta2,delta3,1,1,1);
%针对较大数据，使用局部计算方法
            [w] = Func_GST_anisotropy_for_large_data_norml_minus_1_1(stack_data, p1,p2,p3,delta1,delta2,delta3,1,1,1);
            clear stack_data
            %计算水平方向的角度
            angle=atan(w(:,:,:,3)./w(:,:,:,2));
            %将angle、angle_norm存为二进制文件
            disp('水平方位角数据完成计算，开始写入倾角数据');
            [outdata]=fun_1_file_mat2bin(angle,FoldPath.anglefilename);
            disp(outdata);
        end
    case 'Classical'
disp('当前纹理属性统计方向为：传统方向');
end
end