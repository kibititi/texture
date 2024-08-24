%=================================================================================
%���ܣ�����ĳ����Ԫ��4D��ǰ����Ԫ�ĻҶȹ����������ȡ���������ĳ���
%���÷���
%eg. [featureVector, coocMat] = extractPreTexture(data, 'direction', [1,0,0,0; 0,1,0,0; 0,0,0,1])
%���룺
%data����ǰ4ά������Ԫ�;������(time*xline*inline*gather,numLevels,HarFeature)
%numLevels HarFeature�ֱ��ǻҶȼ���������������
%�����
%featureVector���÷���Ԫ��������������
%coocMat��      �Ҷȹ�������
%=================================================================================

%

%

%1��������
function [featureVector,coocMat] = extractPreTexture(varargin)
%�ɱ��������varargin��һ��Ԫ�����飬���ú���ʱ������������Բ�ͬ���С����������������������С

data = varargin{1}; %����,��ǰ����ά������

%Ĭ�ϲ�������-------------------------------
%Wu
% numLevels = 128;  %�Ҷȼ�
% numHarFeature = 13; %���������ĸ���

%Zou---->Ҫ�ĳɴ�Ԫ������ȡ����(δ���)
%����һ��δ��ɵľ������·��������������ĵ���
numLevels = (varargin{5});  %�Ҷȼ�
numHarFeature = (varargin{4}); %���������ĸ���
textures=(varargin{6});%��������������

offSet = int8(varargin{3});     %����ͳ�Ʒ���
noDirections = size(offSet,1);  %����ͳ�Ʒ��������

coocMat = zeros(numLevels, numLevels, noDirections); %3-D����ÿһ�������Ӧһ����ά�Ҷȹ�������12.12�ģ�
% featureVector = zeros(1, noDirections*numHarFeature); %����õ�����������������1�У���������Ϊ �������*ÿ�������������

tempVec = zeros(1,0);    %Empty matrix: 1-by-0

%����Ҷȹ�������coocMat����������harMat
[harMat, coocMat(:,:,:)] = graycooc4d(data, numLevels, numHarFeature, offSet,textures);

% harMat��ά����:6x13 �������forѭ����6x13�ľ��󻯳���1x78

%ʹÿ����ά���ݼ���������һ����
%organizing the data so each cube's data is on a row
temphar = zeros(1,0);
for clicks =1:size(harMat,1)
    temphar = cat(2,temphar,harMat(clicks,:));
end

%����featureVector���ɵ�ά���� 1x78
featureVector = cat(2,tempVec,temphar);

return


%2���������������ͻҶȹ�������
function [harMat,coMat] = graycooc4d(data,numLevels,numHarFeature, offSet,textures)

%**************������ʼ��/����**********************
noDirections = size(offSet,1);  %����ĸ���

%����Ҷȹ�������coocMat
coMat = zeros(numLevels,numLevels,noDirections); %�����������õ��ĻҶȹ����������塱������ά�Ƕ�Ӧ�ķ������

%**************************Beginning analysis*************************
[D1, D2, D3, D4] = size(data); %���ݵĸ��������ά��

for directionOrder =1:noDirections
    for d1 = 1:D1
        for d2 = 1:D2
            for d3 = 1:D3
                for d4 = 1:D4
                    %��ǰλ�ûҶ�
                    currentGraylevel = data(d1,d2,d3,d4);
                    %offSet(directionOrder,1:4)������һ�У�������һ������

                    %һ�в���  =>   һ������
                    %��һλ��
                    d1Next = d1 + offSet(directionOrder,1);
                    d2Next = d2 + offSet(directionOrder,2);
                    d3Next = d3 + offSet(directionOrder,3);
                    d4Next = d4 + offSet(directionOrder,4);
                    %�ж���һλ���Ƿ�Խ��
                    if d1Next<=D1 && d2Next<=D2 && d3Next<=D3 && d4Next<=D4
                        if d1Next>0 && d2Next>0 && d3Next>0 && d4Next>0
                            nextGraylevel = data(d1Next,d2Next,d3Next,d4Next);
                            coMat(currentGraylevel, nextGraylevel, directionOrder) = ...
                                coMat(currentGraylevel, nextGraylevel, directionOrder) + 1;
                        end
                    end
                end
            end
        end
    end
end


%���ݻҶȹ����������塱��ȡÿ���������������.  һ����6������
harMat = harFeatures(coMat,numHarFeature,textures);

return


%3��������������
function [harMat]= harFeatures(coMat, numHarFeature,textures)

% hasfeature1=clock;

%�Ҷȼ�
numLevels = size(coMat,1); %number of graylevels

%��ʼ��������������
harMat = zeros(numHarFeature,size(coMat,3));


%�ȳ�ʼ�������÷ŵ�ѭ����ȥÿ��Ҫ����
% z_var = 1:numLevels;

% z_x_var=repmat(z_var,numLevels,1);
% z_y_var=repmat(z_var',1,numLevels);

%test

% wu=0;
% zzz=0;

for directionOrder = 1:size(coMat,3) %directions

    %%%%%%%determining various p values
    %����41ҳ���������Ƚ�һ������ĻҶȹ��������������Ȼ������������ϵĻҶȹ����������
    %��ֵ���õ����Ǹ�Ԫ�ص�ͳ�Ƹ��ʡ�
    sum_spcific_direction = sum(sum(coMat(:,:,directionOrder))); %ĳ����ĻҶȹ�������ĺ�
    coMat(:,:,directionOrder)=coMat(:,:,directionOrder)./sum_spcific_direction;     %����Ԫ�ص�ͳ�Ƹ���


    mux=0;
    muy=0;

    for j=1:numLevels
        for i=1:numLevels
            mux =  mux+(i*(coMat(j,i,directionOrder)));
            muy =  muy+(j*(coMat(j,i,directionOrder)));
        end
    end

    %     mux = sum(sum(z_x_var.*(coMat(:,:,directionOrder))));
    %     muy = sum(sum(z_y_var.*(coMat(:,:,directionOrder))));


    %��������Բ���Ҫ���
    sigx=0;
    sigy=0;
    for j=1:numLevels
        for i=1:numLevels
            sigx = sigx+ (i-mux)^2*coMat(j,i,directionOrder);
            sigy = sigy+ (j-muy)^2*coMat(j,i,directionOrder);
        end
    end


    %����
    Energy =0;
    Entropy=0;
    Corre=0;
    Contrast=0;
    Homo=0;
    Variance=0;
    SumMean=0;
    Inertia=0;
    ClShade=0;
    ClTendency=0;
    InVariance=0;
    Dissimilarity = 0;  %(12.13 add)
    MaxProbability=0;

    %ѭ�����������Ҷȼ�
    for j=1:numLevels
        for i=1:numLevels

            %value����Pij
            value = coMat(j,i,directionOrder);

            Energy = Energy+ value^2;
            if(value~=0)
                Entropy = Entropy + (value * log10(value));
            end
            Corre = Corre+ ((i-mux)*(j-muy)*(value/(sigy*sigx)));
            Contrast = Contrast+ value*(abs(i-j))^2;
            Homo = Homo+ value/(1+abs(i-j));
            Variance = Variance + ((i - mux)^2)*value+((j-muy)^2)*value;
            SumMean = SumMean + (i+j)*(value);
            Inertia = Inertia+ (i-j)^2*(value);
            ClShade=ClShade+ ((i+j-mux-muy)^3)*(value);
            ClTendency = ClTendency+ (((i + j - mux - muy)^4) .* (value));
            if i~=j
                InVariance=InVariance+ value/(i-j)^2;
            end
            Dissimilarity = Dissimilarity + value*abs(i-j);
        end
    end

    MaxProbability=max(max(coMat(:,:,directionOrder)));
    %��ֵ
    % ���� textures �е�ÿ��������
    for i = 1:numel(textures)
        % ��ȡ������
        var_name = textures{i};

        % �������Ƿ����
        if exist(var_name, 'var') == 1
            % ����������ڣ����丳ֵ�� harMat ����
            harMat(i,directionOrder) = eval(var_name);
        else
            % ������������ڣ��������ʾ
            disp(['���� ' var_name ' ���Ǹ�������������֮һ������ƴд����Сд��']);
        end
    end
    %     harMat(1,directionOrder)=Energy;         %Energy
    %     harMat(2,directionOrder) = -Entropy;     %Entropy
    %     harMat(3,directionOrder)=Corre;           %Correlation
    %     harMat(4,directionOrder)=Contrast;           %Contrast
    %     harMat(5,directionOrder) = Homo;         %Homogeneity
    %
    %         harMat(6,directionOrder) = Variance/2;        %Variance
    %         harMat(7,directionOrder)=SumMean/2;         %Sum Mean
    %
    %         harMat(8,directionOrder)=Inertia;          %Inertia
    %
    %         harMat(9,directionOrder)=ClShade;          %Cluster Shade
    %         harMat(10,directionOrder) = ClTendency;         %Cluster Tendency
    %         harMat(11,directionOrder) = max(max(coMat(:,:,directionOrder))); %Max Probability
    %         harMat(12,directionOrder) = InVariance;       %Inverse Variance
    %         harMat(13,directionOrder) = Dissimilarity;        %Dissimilarity

    clear 'Energy' 'Entropy' 'Corre' 'Contrast' 'Homo';
    clear 'Variance' 'SumMean' 'Inertia' 'ClShade';
    clear 'ClTendency' 'InVariance' 'Dissimilarity' 'MaxProbability';

end


harMat = harMat';

% hasfeature2=clock;

% fprintf('Hasfeature Function computed feature cost %f \n',etime(hasfeature2,hasfeature1))


return
