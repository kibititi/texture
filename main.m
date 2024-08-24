%==========================================================================
%功能：计算六个方向的4D叠前纹理元的灰度共生矩阵和提取纹理特征的程序
%调用方法：
%        1.extract_data func：   提取sgy文件数据
%        2.handle_data func：    处理下一阶段可用的数据
%        3.extract_unit_data func： 计算灰度共生矩阵并提取纹理特征
%        4.normed func：         归一化数据
%输入：
%data：sgy二进制文件
%输出：
%featureVector：数据体的纹理属性向量
% 输出数据的是按照纹理属性统计方向来区分的六个方向的n种纹理属性数据体
% 方向1-6对应的纹理属性统计方向依次为：
%       方向1：xline方向
%       方向2：inline方向
%       方向3：inline方向与xline方向的45°夹角方向
%       方向4：inline方向与xline方向的135°夹角方向
%       方向5：time方向
%       方向6：道集方向（offset）
%==========================================================================
%% 地震数据裁剪与读取
%data_cut_23_10
%% 层位数据的裁剪与读取
% layer_data_cut10_27
%% ------------------------------------------------- 参数设定----------------------------------------------------------
%% 叠前、叠后参数选择
%输入数据的类型
% pre：叠前地震数据
% stack：叠后地震数据
Type.seismicData_type='pre';
%% 带倾角、不带倾角参数选择
% 纹理属性统计时是否带倾角
% WithDip：带倾角
% NoDip：不带倾角
Type.Texture_type='WithDip';
%% 方向自适应
% 纹理属性统计是否统计方向自适应
%   Auto：统计自适应方向
%   Classical：不统计自适应方向，使用传统的纹理统计方向
Type.offSets_type='Auto';
%% 输入输出路径参数
starttime=clock;%开始计时

%输入地震数据的格式为：无头文件的纯数据二进制sgy文件，顺序为inline*xline*time
% FoldPath.DataPath='E:\神经网络与纹理属性\Condata3d\平层数据\';
FoldPath.DataPath='E:\数据\qiulin\';

%输出数据的路径:
FoldPath.OutputPath='E:\一种方向自适应的纹理属性统计方法\论文\秋林-叠前-全方位-带倾角-7-7-13\';

%判断输出路径是否存在，如不存在则自动创建
folder=FoldPath.OutputPath;
fun_folderexist(folder);

%层位数据的路径
%层位数据的顺序是：inline，xline，time
FoldPath.LayerData=[FoldPath.DataPath 'layer_data.mat'];

%叠后数据的路径,数据顺序为：time xline inline
FoldPath.stackedData='E:\数据\qiulin\stack_data.mat';

%倾角、方位角数据均保存在原始数据路径中
%倾角数据路径，顺序为inline*xline*time
FoldPath.pfilename=[FoldPath.DataPath 'p_all.sgy'];
FoldPath.qfilename=[FoldPath.DataPath 'q_all.sgy'];

%平面角度及其归一体值，顺序为inline*xline*time
FoldPath.anglefilename=[FoldPath.DataPath 'angle.sgy'];

%有道头的原始文件路径
%只用于将提供道头、卷头信息
%具体方法为将原始数据中的地震数据替换为计算得到的纹理属性数据，详见函数fun_mat_to_sgy
FoldPath.sesimic_data_filename= strcat('E:\纹理数据2051-1001\copy_inline7150-8500Xline7200-8200.sgy');
%% 设定宏数据的参数
%-----------------------------------数据大小参数设置----------------------------------------------------------
%联络测线的长度
Parameter.xlineNum = 551;   %2201;
%主测线的长度
Parameter.inlineNum = 401;  %1601;   ------1351
%时间方向的采样点数
Parameter.time = 201;
%(每次读取五条inline线，x轴方向,总次数为)
Parameter.nums=7;         %每次读取inline的数量
Parameter.iter_nums=Parameter.inlineNum - (Parameter.nums-1);   %总文件的迭代次数
%-------------------------------------灰度级参数设置----------------------------------------------------------
%灰度级的大小 16 64
Parameter.Ng = 64;
%---------------------------------------层位及时间参数设置---------------------------------------------------
%层位time数据的开始数值
Parameter.layer_timestartnum=1050;
%xline数据的开始线道号
layer_data=load(FoldPath.LayerData);
layer_data=layer_data.layer_data;
Parameter.layer_xlinestartnum=layer_data(1,2);
% Parameter.layer_xlinestartnum=1;

%时间方向上上下选取的点数，总窗口的长度是2*time_window+1
Parameter.time_window=6;
%采样率，单位ms，将时间转化为点数，
Parameter.sample_rate=1;
%总的分析时间窗口，只选取该范围内的地震数据统计纹理属性
%LayerTimeNum-LayerTimeNum_up:1:LayerTimeNum+LayerTimeNum_down
Parameter.LayerTimeNum_up=20;%目标层向上选取点数
Parameter.LayerTimeNum_down=20;%目标层向下选取点数

%需要计算的纹理数量及名称
Parameter.numHarFeature=13;        %纹理特征数量
Parameter.textures= {'Energy' ,'Entropy', 'Corre','Contrast' ,'Homo','Variance' ,'SumMean'   ,'Inertia' ,'ClShade','ClTendency','InVariance'  ,'Dissimilarity' ,'MaxProbability' };%,'Variance' ,'SumMean'   ,'Inertia' ,'ClShade','ClTendency','InVariance'  ,'Dissimilarity' ,'MaxProbability' };%对应的纹理特征名称
% {'Energy' ,'Entropy', 'Corre','Contrast' ,'Homo','Variance' ,'SumMean'   ,'Inertia' ,'ClShade','ClTendency','InVariance'  ,'Dissimilarity' ,'MaxProbability' };
%可供选择的纹理属性类型及名称，注意严格区分大小写
% Energy Entropy Corre Contrast Homo Variance SumMean Inertia ClShade
% ClTendency InVariance Dissimilarity MaxProbability
%共计13个
%% 纹理统计方向参数：(time,crossline,inlineNum,trace)
%叠前地震数据方位
directions=10;  %输入数据的方向个数，叠前根据实际情况给出，叠后默认为1，如需修改在fun_offset中修改
[directions, offSets, offset_num] = fun_offset(Type,directions);
%% 倾角计算模块
% 倾角计算，仅在需要时执行
fun_dip(Type, FoldPath);
%% 结构张量计算模块
% 水平方位角计算，仅在需要时执行
%gst各方向平滑因子调整在fun_horizontal_azimuth中
fun_horizontal_azimuth(Type, FoldPath);
%% ----------------------------------------------启动并行计算Computing data------------------------------
%并行运算模块在函数fun_main_*_* 中，默认直接开启parfor并行运算
fprintf(['......................................................................\n开始纹理属性统计......\n数据类型为：%s\n纹理属性元选取模式为：' ...
    '%s\n纹理属性统计方向为：%s\n' ...
    '......................................................................\n'], Type.seismicData_type, Type.Texture_type, Type.offSets_type);
%选择 纹理属性元选取模式
switch Type.Texture_type%选择是否开启倾角导向
    %倾角导向模式，沿倾角方向统计纹理
    case 'WithDip'
        %选择 纹理属性统计方向
        switch Type.offSets_type
            %传统纹理统计方向，叠后纹理五个方向，叠前纹理六个方向
            case 'Classical'
                fun_main_withdip_classical(Parameter, directions, FoldPath, offSets, Type);
                %自适应纹理统计方向，叠后纹理5+1，叠前纹理6+1
            case 'Auto'
                fun_main_withdip_auto(Parameter, directions, FoldPath, offSets, Type);
        end
        %非倾角导向模式，沿层位方向统计纹理
    case 'NoDip'
        switch Type.offSets_type
            case 'Classical'
                fun_main_nodip_classical(Parameter, directions, FoldPath, offSets, Type);
            case 'Auto'
                fun_main_nodip_auto(Parameter, directions, FoldPath, offSets, Type);
        end
end
%关闭并行运算
delete(gcp('nocreate'))
%% 模块四          =>          整合数据
fun_load_data(Parameter,FoldPath,offset_num);
%% 模块五          =>          输出二进制文件
% mat_to_bin();
%% 模块六          =>          输出有道头的标准sgy文件
% fun_mat_to_sgy(FoldPath,Parameter,Type,offset_num);
%% 发送邮件提醒自己
%输入参数starttime为项目开始时间
fun_send_mail(starttime,Type,Parameter);
%% 关闭电脑
% ! shutdown -s
% 代码showfigure用于查看纹理属性输出结果的沿层切片
% 代码showslicemain用于读取原始地震数据（无道头、卷头的segy文件）并根据层位数据绘制沿层切片