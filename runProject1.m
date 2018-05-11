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

% No suspected mass detected, both mask is zero, return healthy.
if size(estmaskleftDS,3) == 0 && size(estmaskrightDS,3) == 0
    estmaskleft = zeros(size(mammoimgleft));
    estmaskright = zeros(size(mammoimgright));
    estdiag = [0,0];
    return
    
    % Left Mammogram Has No Suspect Mass, Must Be The Right Mammogram
elseif size(estmaskleftDS,3) == 0
    feature = Mask2Feature(estmaskrightDS,mammorightDS,mammorightBM);
    indicator = 2;
    % Right Mammogram Has No Suspect Mass, Must Be The Left Mammogram
elseif size(estmaskrightDS,3) == 0
    feature = Mask2Feature(estmaskleftDS,mammoleftDS,mammoleftBM);
    indicator = 1;
    % Combine Suspect Masses from Both Mammogram
else
    leftfeature = Mask2Feature(estmaskleftDS,mammoleftDS,mammoleftBM);
    rightfeature = Mask2Feature(estmaskrightDS,mammorightDS,mammorightBM);
    feature = cat(1,leftfeature,rightfeature);
    indicator = 3;
end

%% For Training

% if exist('features.mat','file')
%     load('features.mat','features');
%     features = cat(1,features,feature);
%     save('features.mat','features');
% else
%     features = feature;
%     save('features.mat','features');
% end
%
% return;

%% For Testing
% normalize features
load('coeff.mat','coeff');
load('features.mat','features')
features = cat(1,features,feature);
for i = 1:size(features,2)
    cA3 = features(:,i);
    cA3=reshape(zscore(cA3(:)),size(cA3,1),size(cA3,2));
    features(:,i) = cA3;
end
feature = features(29:end,:);

% project onto principle components
feature = feature * coeff;
feature = feature(:,1:7);

% load('model_tree.mat','tree');
load('model_knn.mat','knn');
[label,score,~] = predict(knn,feature);

if all(label == 0)
    estmaskleft = zeros(size(mammoimgleft));
    estmaskright = zeros(size(mammoimgright));
    estdiag = [0,0];
    return
elseif ~any(label == 1)
    indice = find(label == 0);
    score(indice,:) = 0;
    [~,maskIndex] = max(score(:));
    [maskRow,~] = ind2sub([size(score,1),size(score,2)],maskIndex);
    diag = 2;
elseif ~any(label == 2)
    indice = find(label == 0);
    score(indice,:) = 0;
    [~,maskIndex] = max(score(:));
    [maskRow,~] = ind2sub([size(score,1),size(score,2)],maskIndex);
    diag = 1;
else
    indice = find(label~=0);
    score(indice,:) = 0;
    [~,maskIndex] = max(score(:));
    [maskRow,~] = ind2sub([size(score,1),size(score,2)],maskIndex);
    diag = label(maskIndex);
end

if indicator == 3
    if maskRow > size(estmaskleftDS,3)
        indicator =2;
        maskRow = maskRow - size(estmaskleftDS,3);
    else
        indicator = 1;
    end
end

if indicator == 1
    estdiag = [diag,0];
    
    estmaskright = zeros(size(mammoimgright));
    
    estmaskleftDS = squeeze(estmaskleftDS(:,:,maskRow));
    estmaskleftUS = imresize(estmaskleftDS(:,:,1), 10);
    estmaskleft(1:min(size(estmaskleftUS,1),size(estmaskleft,1)),1:min(size(estmaskleftUS,2),size(estmaskleft,2))) = ...
        estmaskleftUS(1:min(size(estmaskleftUS,1),size(estmaskleft,1)),1:min(size(estmaskleftUS,2),size(estmaskleft,2)));
    
elseif indicator == 2
    estdiag = [0,diag];
    estmaskleft = zeros(size(mammoimgleft));
    
    estmaskrightDS = squeeze(estmaskrightDS(:,:,maskRow));
    estmaskrightUS = imresize(estmaskrightDS(:,:,1), 10);
    estmaskright(1:min(size(estmaskrightUS,1),size(estmaskright,1)),1:min(size(estmaskrightUS,2),size(estmaskright,2))) = ...
        estmaskrightUS(1:min(size(estmaskrightUS,1),size(estmaskright,1)),1:min(size(estmaskrightUS,2),size(estmaskright,2)));
    
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



