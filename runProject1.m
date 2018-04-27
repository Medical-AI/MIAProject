function [estdiag, estmaskleft,estmaskright] = runProject1(mammoimgleft,mammoimgright)
% Inputs:   mammoimgleft  -     the mammogram of the left side (rowL x colL)
%                               where rowL and colL are the image
%                               dimensions.
%           mammoimgright -     the mammogram of the right side (rowR x colR)
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
[estmaskleftDS] = PipeLine(mammoimgleft);

% Pipeline for Right Mammogram
[estmaskrightDS]= PipeLine(mammoimgright);

if sum(estmaskleftDS(:)) > 0
    disp('left')
    estdiag = 1;
elseif sum(estmaskrightDS(:)) > 0
    disp('right')
    estdiag = 1;
else
    disp('healthy')
    estdiag = 0;
end
estmaskleftDS = imresize(estmaskleftDS, 10);
estmaskrightDS = imresize(estmaskrightDS, 10);
estmaskleft(:,:) = estmaskleftDS(1:min(size(estmaskleftDS,1),size(estmaskleft,1)),1:min(size(estmaskleftDS,2),size(estmaskleft,2)));
estmaskright(:,:) = estmaskrightDS(1:min(size(estmaskrightDS,1),size(estmaskright,1)),1:min(size(estmaskrightDS,2),size(estmaskright,2)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



