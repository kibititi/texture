function [locationMatrix_new] = fun_revolveGrid(p_ceilData,q_ceilData,ceilData)
%fun_revolveGrid 用于将网格按照当前地层的倾角旋转
%   输入数据：
%   ceilData 表示每次提取的地震数据，大小为time*xline*num（inline）*direction
%   nums=5;         %每次读取inline的数量
%   q_ceilData ,  q_ceilData分别表示inline，xline方向的视倾角
%   i,j 当前点的位置,i表示inline，j表示xline
%   
%   输出数据;
%   locationMatrix_new 表示按照旋转后的网格
%-------------------------------------------------------------------
[T,X,Y,D]=size(ceilData);
%构建三维旋转矩阵
%ceilData大小为time*xline*num（inline）*direction,11*5*5*6
%绕inline方向旋转，只改变time和xline方向的坐标
%相当于绕z方向旋转，这里给出绕z轴旋转的旋转矩阵
% revolveMatrix=[cos(ang) -sin(ang) 0 ;sin(ang) cos(ang) 0; 0 0 1];
%旋转角度应当与当前计算的网格中心点的倾角保持一致
% [x_new,y_new,z_new]=revolveMatrix*[x,y,z];
%构建位置矩阵locationMatrix，其存贮顺序为 time，xline，inline，大小为time+xline+inline。
locationMatrix=zeros(X*Y*T,3,D);
first_T=(T-1)/2;
first_X=(X-1)/2;
first_Y=(Y-1)/2;
for direction_for=1:D
        i=1;
        for time_for=1:T
            for xline_for=1:X
                for inline_for=1:Y 
                    locationMatrix(i,1,direction_for)=-first_T+time_for-1;
                    locationMatrix(i,2,direction_for)=-first_X+xline_for-1;
                    locationMatrix(i,3,direction_for)=-first_Y+inline_for-1;
                    i=i+1;
                end
            end
        end
end
%对每个点的位置，坐标为time=locationMatrix(1:11)循环，xline=locationMatrix(12:16)，inline=locationMatrix(17:21)
%对不同方向分别计算
locationMatrix_new=zeros(X*Y*T,3,D);
    for direction_for=1:D
        %对单个方向上的每个位置矩阵locationMatrix分别计算每个位置对应的新坐标
        %由于绕inline方向旋转，角度选择为q
        ang=mean(mean(mean(q_ceilData(:,:,:,direction_for))));
        revolveMatrix=[cos(ang) -sin(ang) 0 ;sin(ang) cos(ang) 0; 0 0 1];
        for i=1:X*Y*T
            %对于ceilData中的第一个元素
            locationMatrix_new(i,:,direction_for)=revolveMatrix*locationMatrix(i,:,direction_for)';
%             locationMatrix_new(i,1,direction_for)=revolveMatrix*locationMatrix(i,:,direction_for)';
        end 
    end
end
%好像有个问题，按照旋转后的网格计算得到的纹理属性是否需要再旋转回去
%应该是不用，每次计算得到的纹理属性是当前网格的中心点（5道*6个方向），不需要储存的调整。