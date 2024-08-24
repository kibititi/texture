function fun_dip(Type, FoldPath)
%用于计算叠后数据的倾角
switch Type.Texture_type
    case 'WithDip'
        disp('......................................................................');
        disp('当前纹理属性元选取模式为：倾角导向模式');
        if exist(FoldPath.pfilename, 'file') == 2 && exist(FoldPath.qfilename, 'file') == 2
            disp('倾角数据存在');
        else
            disp('倾角数据不存在，计算倾角数据中......');

            %1.输入叠后地震数据，顺序为time xline inline
            stack_data=load(FoldPath.stackedData);
            stack_data=stack_data.stack_data;
            % % 2.对叠后数据计算倾角
            [p_all,q_all] = fun_curvature(stack_data);
            clear stack_data
            disp('倾角数据完成计算，开始写入倾角数据');
            [outdata]=fun_2_file_mat2bin(p_all,q_all,FoldPath.pfilename,FoldPath.qfilename);
            disp(outdata);
            clear  p_all q_all
        end
    case 'NoDip'
        disp('当前纹理属性元选取模式为：非倾角导向模式');
end
end