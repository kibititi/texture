%==========================================================================
%���ܣ��������������4D��ǰ����Ԫ�ĻҶȹ����������ȡ���������ĳ���
%���÷�����
%        1.extract_data func��   ��ȡsgy�ļ�����
%        2.handle_data func��    ������һ�׶ο��õ�����
%        3.extract_unit_data func�� ����Ҷȹ���������ȡ��������
%        4.normed func��         ��һ������
%���룺
%data��sgy�������ļ�
%�����
%featureVector���������������������
% ������ݵ��ǰ�����������ͳ�Ʒ��������ֵ����������n����������������
% ����1-6��Ӧ����������ͳ�Ʒ�������Ϊ��
%       ����1��xline����
%       ����2��inline����
%       ����3��inline������xline�����45��нǷ���
%       ����4��inline������xline�����135��нǷ���
%       ����5��time����
%       ����6����������offset��
%==========================================================================
%% �������ݲü����ȡ
%data_cut_23_10
%% ��λ���ݵĲü����ȡ
% layer_data_cut10_27
%% ------------------------------------------------- �����趨----------------------------------------------------------
%% ��ǰ���������ѡ��
%�������ݵ�����
% pre����ǰ��������
% stack�������������
Type.seismicData_type='pre';
%% ����ǡ�������ǲ���ѡ��
% ��������ͳ��ʱ�Ƿ�����
% WithDip�������
% NoDip���������
Type.Texture_type='WithDip';
%% ��������Ӧ
% ��������ͳ���Ƿ�ͳ�Ʒ�������Ӧ
%   Auto��ͳ������Ӧ����
%   Classical����ͳ������Ӧ����ʹ�ô�ͳ������ͳ�Ʒ���
Type.offSets_type='Auto';
%% �������·������
starttime=clock;%��ʼ��ʱ

%����������ݵĸ�ʽΪ����ͷ�ļ��Ĵ����ݶ�����sgy�ļ���˳��Ϊinline*xline*time
% FoldPath.DataPath='E:\����������������\Condata3d\ƽ������\';
FoldPath.DataPath='E:\����\qiulin\';

%������ݵ�·��:
FoldPath.OutputPath='E:\һ�ַ�������Ӧ����������ͳ�Ʒ���\����\����-��ǰ-ȫ��λ-�����-7-7-13\';

%�ж����·���Ƿ���ڣ��粻�������Զ�����
folder=FoldPath.OutputPath;
fun_folderexist(folder);

%��λ���ݵ�·��
%��λ���ݵ�˳���ǣ�inline��xline��time
FoldPath.LayerData=[FoldPath.DataPath 'layer_data.mat'];

%�������ݵ�·��,����˳��Ϊ��time xline inline
FoldPath.stackedData='E:\����\qiulin\stack_data.mat';

%��ǡ���λ�����ݾ�������ԭʼ����·����
%�������·����˳��Ϊinline*xline*time
FoldPath.pfilename=[FoldPath.DataPath 'p_all.sgy'];
FoldPath.qfilename=[FoldPath.DataPath 'q_all.sgy'];

%ƽ��Ƕȼ����һ��ֵ��˳��Ϊinline*xline*time
FoldPath.anglefilename=[FoldPath.DataPath 'angle.sgy'];

%�е�ͷ��ԭʼ�ļ�·��
%ֻ���ڽ��ṩ��ͷ����ͷ��Ϣ
%���巽��Ϊ��ԭʼ�����еĵ��������滻Ϊ����õ��������������ݣ��������fun_mat_to_sgy
FoldPath.sesimic_data_filename= strcat('E:\��������2051-1001\copy_inline7150-8500Xline7200-8200.sgy');
%% �趨�����ݵĲ���
%-----------------------------------���ݴ�С��������----------------------------------------------------------
%������ߵĳ���
Parameter.xlineNum = 551;   %2201;
%�����ߵĳ���
Parameter.inlineNum = 401;  %1601;   ------1351
%ʱ�䷽��Ĳ�������
Parameter.time = 201;
%(ÿ�ζ�ȡ����inline�ߣ�x�᷽��,�ܴ���Ϊ)
Parameter.nums=7;         %ÿ�ζ�ȡinline������
Parameter.iter_nums=Parameter.inlineNum - (Parameter.nums-1);   %���ļ��ĵ�������
%-------------------------------------�Ҷȼ���������----------------------------------------------------------
%�Ҷȼ��Ĵ�С 16 64
Parameter.Ng = 64;
%---------------------------------------��λ��ʱ���������---------------------------------------------------
%��λtime���ݵĿ�ʼ��ֵ
Parameter.layer_timestartnum=1050;
%xline���ݵĿ�ʼ�ߵ���
layer_data=load(FoldPath.LayerData);
layer_data=layer_data.layer_data;
Parameter.layer_xlinestartnum=layer_data(1,2);
% Parameter.layer_xlinestartnum=1;

%ʱ�䷽��������ѡȡ�ĵ������ܴ��ڵĳ�����2*time_window+1
Parameter.time_window=6;
%�����ʣ���λms����ʱ��ת��Ϊ������
Parameter.sample_rate=1;
%�ܵķ���ʱ�䴰�ڣ�ֻѡȡ�÷�Χ�ڵĵ�������ͳ����������
%LayerTimeNum-LayerTimeNum_up:1:LayerTimeNum+LayerTimeNum_down
Parameter.LayerTimeNum_up=20;%Ŀ�������ѡȡ����
Parameter.LayerTimeNum_down=20;%Ŀ�������ѡȡ����

%��Ҫ�������������������
Parameter.numHarFeature=13;        %������������
Parameter.textures= {'Energy' ,'Entropy', 'Corre','Contrast' ,'Homo','Variance' ,'SumMean'   ,'Inertia' ,'ClShade','ClTendency','InVariance'  ,'Dissimilarity' ,'MaxProbability' };%,'Variance' ,'SumMean'   ,'Inertia' ,'ClShade','ClTendency','InVariance'  ,'Dissimilarity' ,'MaxProbability' };%��Ӧ��������������
% {'Energy' ,'Entropy', 'Corre','Contrast' ,'Homo','Variance' ,'SumMean'   ,'Inertia' ,'ClShade','ClTendency','InVariance'  ,'Dissimilarity' ,'MaxProbability' };
%�ɹ�ѡ��������������ͼ����ƣ�ע���ϸ����ִ�Сд
% Energy Entropy Corre Contrast Homo Variance SumMean Inertia ClShade
% ClTendency InVariance Dissimilarity MaxProbability
%����13��
%% ����ͳ�Ʒ��������(time,crossline,inlineNum,trace)
%��ǰ�������ݷ�λ
directions=10;  %�������ݵķ����������ǰ����ʵ���������������Ĭ��Ϊ1�������޸���fun_offset���޸�
[directions, offSets, offset_num] = fun_offset(Type,directions);
%% ��Ǽ���ģ��
% ��Ǽ��㣬������Ҫʱִ��
fun_dip(Type, FoldPath);
%% �ṹ��������ģ��
% ˮƽ��λ�Ǽ��㣬������Ҫʱִ��
%gst������ƽ�����ӵ�����fun_horizontal_azimuth��
fun_horizontal_azimuth(Type, FoldPath);
%% ----------------------------------------------�������м���Computing data------------------------------
%��������ģ���ں���fun_main_*_* �У�Ĭ��ֱ�ӿ���parfor��������
fprintf(['......................................................................\n��ʼ��������ͳ��......\n��������Ϊ��%s\n��������ԪѡȡģʽΪ��' ...
    '%s\n��������ͳ�Ʒ���Ϊ��%s\n' ...
    '......................................................................\n'], Type.seismicData_type, Type.Texture_type, Type.offSets_type);
%ѡ�� ��������Ԫѡȡģʽ
switch Type.Texture_type%ѡ���Ƿ�����ǵ���
    %��ǵ���ģʽ������Ƿ���ͳ������
    case 'WithDip'
        %ѡ�� ��������ͳ�Ʒ���
        switch Type.offSets_type
            %��ͳ����ͳ�Ʒ��򣬵�������������򣬵�ǰ������������
            case 'Classical'
                fun_main_withdip_classical(Parameter, directions, FoldPath, offSets, Type);
                %����Ӧ����ͳ�Ʒ��򣬵�������5+1����ǰ����6+1
            case 'Auto'
                fun_main_withdip_auto(Parameter, directions, FoldPath, offSets, Type);
        end
        %����ǵ���ģʽ���ز�λ����ͳ������
    case 'NoDip'
        switch Type.offSets_type
            case 'Classical'
                fun_main_nodip_classical(Parameter, directions, FoldPath, offSets, Type);
            case 'Auto'
                fun_main_nodip_auto(Parameter, directions, FoldPath, offSets, Type);
        end
end
%�رղ�������
delete(gcp('nocreate'))
%% ģ����          =>          ��������
fun_load_data(Parameter,FoldPath,offset_num);
%% ģ����          =>          ����������ļ�
% mat_to_bin();
%% ģ����          =>          ����е�ͷ�ı�׼sgy�ļ�
% fun_mat_to_sgy(FoldPath,Parameter,Type,offset_num);
%% �����ʼ������Լ�
%�������starttimeΪ��Ŀ��ʼʱ��
fun_send_mail(starttime,Type,Parameter);
%% �رյ���
% ! shutdown -s
% ����showfigure���ڲ鿴�����������������ز���Ƭ
% ����showslicemain���ڶ�ȡԭʼ�������ݣ��޵�ͷ����ͷ��segy�ļ��������ݲ�λ���ݻ����ز���Ƭ