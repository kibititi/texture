function [ceilData_new] = Func_select_data(ceilData,data,p_ceilData,q_ceilData,i,j,time_k,nums,time_window)
%功能：用于计算坐标，按照坐标的最近临近数据选取，计算速度快
%无需插值
% ceilData_new 输出数据，大小与ceilData一致
% data总的地震数据
% p_ceilData inline方向的倾角
% q_ceilData xline方向的倾角
%%-------------------------------------------------------------------------------------------------
%数据初始化
datasize=size(ceilData);
ceilData_new=zeros(datasize);
%ceilData顺序：time，xine，inline，directions
%inline方向上的步长delta计算
% delta_inline=zeros(1,datasize(3));
% for sizefor=1:datasize(3)
%     delta_inline_temp=mean(mean(p_ceilData(:,:,sizefor)));
%     delta_inline(:,sizefor)=delta_inline_temp;
% end
delta_inline=tan(p_ceilData);
delta_inline(delta_inline>1)=1;
delta_inline(delta_inline<-1)=-1;
%用于确保中心点位置不变，左右方向相反的算子revolve_arrow
revolve_arrow=-(datasize(2)-1)/2:(datasize(2)-1)/2;
% revolve_arrow=[-3 -2 -1 0 1 2 3];
% revolve_arrow=zeros(size(delta_inline));
% revolve_arrow(1:(size(delta_inline,2)-1)/2)=1;
% revolve_arrow((size(delta_inline,2)+1)/2+1:(size(delta_inline,2)))=-1;
delta_inline=delta_inline.*revolve_arrow;
%xline 方向上的步长计算;
% delta_xline=zeros(1,datasize(2));
% for sizefor=1:datasize(2)
%     delta_xline_temp=mean(mean(q_ceilData(:,sizefor,:)));
%     delta_xline(:,sizefor)=delta_xline_temp;   
% end
delta_xline=tan(q_ceilData);
delta_xline(delta_xline>1)=1;
delta_xline(delta_xline<-1)=-1;
delta_xline=delta_xline.*revolve_arrow;
%按照步长选取数据
%ceilData = data(time_k-3:time_k+3, j:j+nums-1, i:i+nums-1, :);
delta=zeros(datasize(2),datasize(3));
%将每个点（inline，xline）的移动步长叠加出来
for deltafor=1:datasize(2)
    delta(deltafor,:)=delta_xline(deltafor)+delta_inline;
end
%将二维数组转化为一维向量，为后续选取数据少一个循环
delta=reshape(delta',[1 datasize(2)*datasize(3)]);
%数据取整
delta=round(delta);
%% 重新选取数据
%当步长值全为0时，输出数据与输入数据一致
if any(delta)*1==0
    ceilData_new=ceilData;
else
    %不全为0时，按照步长重新选取数据
    k=1;
    for xlinefor=j-j+1:j+nums-1-j+1
        for inlinefor=i-i+1:i+nums-1-i+1
            ceilData_new(:,xlinefor,inlinefor,:)=data(time_k-time_window-delta(k):time_k+time_window-delta(k),xlinefor-1+j,inlinefor-i+1,:);
            k=k+1;
        end
    end
end




