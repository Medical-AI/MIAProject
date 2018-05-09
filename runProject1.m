function [estdiag, estmaskleft,estmaskright] = runProject1(mammoimgleft,mammoimgright)
% Inputs:   mammoimgleft  -     the mammogram of the left side (rowL x colL)
%                               where rowL and colL are the image
%                               dimensions.
%           ma\

% mmoimgright -     the mammogram of the right side (rowR x colR)
%
% Outputs:  estdiag      -   the estimated diagnosis.  Should only have
%                            values of 0(healthy), 1(benigh), and 2(cancer).
%                            and be of size (1 x 2) (left, right).
%
%           estmaskleft  -   the output binary mask for the left side.
%                            Should only have values of zero or one.
%                            If the estdiag is 0, the mask should only have
%                            values of 0. Should be of size (rowL x colL).
%           estmaskright -   the output binary mask for the right side.
%                            Should only have values of zero or one.
%                            If the estdiag is 0, the mask should only have
%                            values of 0. Should be of size (rowR x colR).
%

% MAKE UP SOME BAD RESULTS FOR TESTING :)
estdiag = zeros(1,2);
estmaskleft = zeros(size(mammoimgleft));
estmaskright = zeros(size(mammoimgright));

%% PUT IN YOUR DIAGNOSIS AND SEGMENTATION CODE BELOW!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Pipeline for Left Mammogram
[estmaskleftDS,mammoleftDS,mammoleftBM] = PipeLine(mammoimgleft);

% Pipeline for Right Mammogram
[estmaskrightDS,mammorightDS,mammorightBM]= PipeLine(mammoimgright);

if size(estmaskleftDS,3) == 0 && size(estmaskrightDS,3) == 0
    estmaskleft = zeros(size(mammoimgleft));
    estmaskright = zeros(size(mammoimgright));
    estdiag = [0,0];
    return
elseif size(estmaskleftDS,3) == 0
    
    feature = Mask2Feature(estmaskrightDS,mammorightDS,mammorightBM);
    
elseif size(estmaskrightDS,3) == 0
    
    feature = Mask2Feature(estmaskleftDS,mammoleftDS,mammoleftBM);

else
    leftfeature = Mask2Feature(estmaskleftDS,mammoleftDS,mammoleftBM);
    rightfeature = Mask2Feature(estmaskrightDS,mammorightDS,mammorightBM);
    feature = cat(1,leftfeature,rightfeature);

end

%% For training
% if exist('totalfeature.mat','file')
%     clear totalfeature
%     load('totalfeature.mat','totalfeature');
%     totalfeature = cat(1,totalfeature,feature);
%     save('totalfeature.mat','totalfeature')
% elsedist(:,1) .* dist(:,1)
%     totalfeature =feature;
%     save('totalfeature.mat','totalfeature')
% end
% disp(totalfeature)

%%
load('totalfeature.mat');
gt = [0,0,1,1,0,1,0,0,1,0,0,1,0,0,0,0,0,0,0,1,2,2,2,2,2,0,2,2];
flag = 0;

for point = 1:size(feature,1)
    dist = totalfeature - repmat(feature(point,:),28,1);
    dist = dist(:,1) .* dist(:,1) + dist(:,2) .* dist(:,2);
    [~,indice] = min(dist);
    label = gt(indice);
    if label ~= 0
        
        flag = 1;
        if size(estmaskleftDS,3) == 0
            estmaskrightDS = estmaskrightDS(:,:,point);
            estmaskleftDS = zeros(size(mammoleftDS,1),size(mammoleftDS,2));
            estdiag = [0,label];
            break;
        elseif size(estmaskrightDS,3) == 0
            estmaskleftDS = estmaskleftDS(:,:,point);
            estmaskrightDS = zeros(size(mammoleftDS,1),size(mammoleftDS,2));
            estdiag = [label,0];
            break;
        else
            if point > size(estmaskleftDS,3)
                estmaskrightDS = estmaskrightDS(:,:,point-size(estmaskleftDS,3));
                estmaskleftDS = zeros(size(mammoleftDS,1),size(mammoleftDS,2));
                estdiag = [0,label];
            else
                estmaskrightDS = zeros(size(mammoleftDS,1),size(mammoleftDS,2));
                estmaskleftDS = estmaskleftDS(:,:,point);
                estdiag = [label,0];
            end
            break;
        end
    end
end

if flag == 0
    estmaskrightDS = zeros(size(mammoleftDS,1),size(mammoleftDS,2));
    estmaskleftDS = zeros(size(mammoleftDS,1),size(mammoleftDS,2));
    estdiag = 0;
end
% Generate features for each mask
estmaskleftUS = imresize(estmaskleftDS(:,:,1), 10);
estmaskleft(1:min(size(estmaskleftUS,1),size(estmaskleft,1)),1:min(size(estmaskleftUS,2),size(estmaskleft,2))) = ...
    estmaskleftUS(1:min(size(estmaskleftUS,1),size(estmaskleft,1)),1:min(size(estmaskleftUS,2),size(estmaskleft,2)));

estmaskrightUS = imresize(estmaskrightDS(:,:,1), 10);
estmaskright(1:min(size(estmaskrightUS,1),size(estmaskright,1)),1:min(size(estmaskrightUS,2),size(estmaskright,2))) = ...
    estmaskrightUS(1:min(size(estmaskrightUS,1),size(estmaskright,1)),1:min(size(estmaskrightUS,2),size(estmaskright,2)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



