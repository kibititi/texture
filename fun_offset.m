function [directions, offSets, offset_num] = fun_offset(Type,directions)
%--------------------------------------------------------------------------------
%此时为对应叠前数据的纹理统计方向，共计有六种方向
w1 = [0,1,0,0; 0,0,1,0; 0,1,1,0; 0,-1,1,0];%inine、xline、inline和xline的45°方向、inline和xline的135°方向
w2 = [1,0,0,0];%沿时间方向
w3 = [0,0,0,1];%沿道集方向
w4 = [0,0,0,0];%纹理自适应方向，这里初始化为0
switch Type.seismicData_type
    %叠前数据
    case 'pre'
        switch Type.offSets_type
            case 'Classical'
                offSets = cat(1,w1,w2,w3);  %叠前数据统计方向
            case 'Auto'
                offSets = cat(1,w1,w2,w3,w4);  %叠前数据统计方向+纹理自适应方向
        end
        %对于叠后数据
    case 'stack'
        directions=1;  %输入数据的方向个数
        switch Type.offSets_type
            case 'Classical'
                offSets = cat(1,w1,w2);  %叠前数据统计方向
            case 'Auto'
                offSets = cat(1,w1,w2,w4);  %叠前数据统计方向+纹理自适应方向
        end
end
clear w1 w2 w3;

%纹理统计方向数目
offset_num=size(offSets,1);
end