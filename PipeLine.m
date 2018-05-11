function [mammoMaskOut,mammoDS,mammoFH] = PipeLine(mammoIn)

% Preprocessing
mammoIn = mat2gray(mammoIn);

% Down Sample the Original High Resolution Mammogram for Speed Up
mammoDS = imresize(mammoIn, 0.1);
mammoMaskOut = zeros(size(mammoDS,1),size(mammoDS,2),0);

% Logarithmic intensity range expansion
mammoRE = mat2gray(log(1 + mammoDS));

% Otsu's Binarization
mammoBinary = imbinarize(mammoRE);

% Find the Largest Connected Component, Remove Tags
CC = bwconncomp(mammoBinary,8);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
mammoBM = zeros(size(mammoBinary));
mammoBM(CC.PixelIdxList{idx}) = 1;

% Morphological Closing to Remove Spurious Detail
mammoSmoothBD = imclose(mammoBM,strel('disk',20));
mammoFH = imfill(mammoSmoothBD,'holes');
mammoBreastMask = imdilate(mammoFH,strel('disk',20));

% Remove Background in Mammogram
mammoBR = mammoDS;
mammoBR(~mammoBreastMask) = 0;

% Keep Peaks
SE = strel('disk',50);
mammoTopHat = imtophat(mammoBR,SE);

% Remove Calc
SE = strel('disk',2);
mammoTopHat = imopen(mammoTopHat,SE);
mammoCalMask = (mammoTopHat > 0.45);
mammoTopHat(mammoCalMask) = 0.45;

% Remove Muscle
peakMask = imclearborder(imbinarize(mammoTopHat,max(mammoTopHat(:))/2));

% Remove small peaks
CC = bwconncomp(peakMask);
numPixels = cellfun(@numel,CC.PixelIdxList);
x = find(numPixels > 100);
if isempty(x)
%     figure,
%     subplot(2,4,1),imshow(mammoRE);
%     subplot(2,4,2),imshow(mammoBR);
%     subplot(2,4,3),imshow(mammoTopHat);
%     subplot(2,4,4),imshow(mammoBR); hold on
%     subplot(2,4,4),visboundaries(peakMask);
    return;
end
%%

for object = x
    objectMask = zeros(size(peakMask));
    objectMask(CC.PixelIdxList{object}) = 1;
    massMask = activecontour(mammoTopHat,objectMask,'Chan-Vese','SmoothFactor',2,'ContractionBias',0.5);
    
    if sum(massMask(:)) > 200
        mammoMaskOut = cat(3,mammoMaskOut,massMask);
%         figure,
%         subplot(2,4,1),imshow(mammoRE);
%         subplot(2,4,2),imshow(mammoBR);
%         subplot(2,4,3),imshow(mammoTopHat);
%         subplot(2,4,4),imshow(mammoBR); hold on
%         subplot(2,4,4),visboundaries(peakMask);
%         
%         bd = bwboundaries(massMask);
%         subplot(2,4,5),imshow(mammoBR); hold on
%         subplot(2,4,5),visboundaries(bd)
    else
%         figure,
%         subplot(2,4,1),imshow(mammoRE);
%         subplot(2,4,2),imshow(mammoBR);
%         subplot(2,4,3),imshow(mammoTopHat);
%         subplot(2,4,4),imshow(mammoBR); hold on
%         subplot(2,4,4),visboundaries(peakMask);
        continue;
    end
end


end