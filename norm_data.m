%==========================================================================
%��һ������
%���÷���
%eg.  [normed_data] = norm_data(featureMatrix,xlineNum,inlineNum)
%�ļ����룺
    %�������: data         ��������
    %          xlineNum     ÿ�ζ�ȡ���ݵ�������߳��� 
    %          time         ÿ�ζ�ȡ���ݵ�ʱ�䳤��
    %          inlineNum     ÿ��Ҫ��ȡ������������ (��Ϊ������)
    %          directions   һ���ķ�������
    %          Ng           Ԥ��ָ���Ҷȼ��Ĵ�С
%�ļ�������
%
%
%�����
    %���������壺��ȡ����������
%==========================================================================


function [normed_data] = norm_data(featureMatrix,directions,textures)

    mA = min(featureMatrix, [], 2);         %ÿһ�е���Сֵ  65*1
    MA = max(featureMatrix, [], 2);         %ÿһ�е����ֵ  65*1

    %featureMatrix��ά����(65��601*501=301101)
%     normed_data(:,:,:,:) = normed_data(:,:,:,:)/mean(normed_data(:));
    normed_data = (featureMatrix - repmat(mA, [1,directions*textures]))./repmat(MA-mA, [1,directions*textures]);
        
    
end

