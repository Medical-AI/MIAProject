function [mammoMaskOut] = PipeLine(mammoIn)

% Preprocessing
mammoIn = mat2gray(mammoIn);

% Down Sample the Original High Resolution Mammogram for Speed Up
mammoDS = imresize(mammoIn, 0.1);
mammoMaskOut = zeros(size(mammoDS));

% Histogram Equalization
% mammoHEQ=histeq(mammoDS);
% mammoHEQ=adapthisteq(mammoDS);

% Logarithmic intensity range expansion
mammoRE = log(1 + mammoDS);

% Otsu's Binarization
mammoBinary = imbinarize(mammoRE);

% Find the Largest Connected Component, Remove Tags
CC = bwconncomp(mammoBinary,8);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
mammoClean = zeros(size(mammoBinary));
mammoClean(CC.PixelIdxList{idx}) = 1;

% Morphological Closing to Remove Spurious Detail
mammoSmooth = imclose(mammoClean,strel('disk',20));

% Fill Holes in Mask
mammoFH = imfill(mammoSmooth,'holes');
mammoBreast = imdilate(mammoFH,strel('disk',20));

% Remove Background in Mammogram
mammoBR = mammoDS;
mammoBR(~mammoBreast) = 0;

%
strelSize=50;
SE = strel('disk',strelSize);
mammoPeak = imtophat(mammoBR,SE);
mammoBP = imbinarize(mammoPeak);
massMask= imfill(imclearborder(mammoBP,8),'holes');
massMaskClean = imopen(massMask,strel('disk',5));


% From the Seeds to Segmentation
seedMaskOut = RegionGrow(massMaskClean,mammoBR);

%%
% Remove Mass Based on Contrast
% CC = bwconncomp(seedMaskOut,8);
% numPixels = cellfun(@numel,CC.PixelIdxList);
% potentialMass = find(numPixels > 200);
% maxContrast = 0.05;
% for object = potentialMass
%
%     % pick a single object
%     objectMask = zeros(size(seedMaskOut));
%     objectMask(CC.PixelIdxList{object})=1;
%
%     % find the corresponding background
%     bgMask = imdilate(objectMask,strel('disk',5))-objectMask;
%
%     % compute the mean intensity of the current object
%     objectImage = mammoBR;
%     objectImage(~objectMask) = 0;
%     objectMean = sum(objectImage(:))/sum(objectMask(:));
%
%     % Compute the Mean Intensity of the Background
%     bgImage = mammoBR;
%     bgImage(~bgMask) = 0;
%     bgMean = sum(bgImage(:))/sum(bgMask(:));
%
%     if objectMean <= bgMean
%         seedMaskOut(objectMask) = 0;
%         continue;
%     end
%
%     % Otherwise, Compute the contrast
%     contrast = (objectMean - bgMean)/(objectMean + bgMean);
%
%     if contrast > maxContrast
%         maxContrast = contrast;
%         mammoMaskOut = zeros(size(mammoDS));
%         mammoMaskOut(CC.PixelIdxList{object}) = 1;
%     end
%
% end
%

%%
CC = bwconncomp(seedMaskOut,8);
numPixels = cellfun(@numel,CC.PixelIdxList);
potentialMass = find(numPixels > 200);

for object = potentialMass
    
    % pick a single object
    objectMask = zeros(size(seedMaskOut));
    objectMask(CC.PixelIdxList{object})=1;
    
    
    % feature1: length of skeleton/area
    objectSkel = bwmorph(objectMask,'skel',Inf);
    skelLength = sum(objectSkel(:));
    objectArea = sum(objectMask(:));
    disp(skelLength/objectArea);
    if skelLength/objectArea > 0.25
        continue;
    end
    
    % feature2: size of bounding box
    s  = regionprops(imopen(objectMask,strel('disk',1)),'Solidity');
    disp(s.Solidity)
    if s.Solidity < 0.8
        continue;
    end
    
    % compute the mean intensity of the current object
    objectImage = mammoBR;
    objectImage(~objectMask) = 0;
    objectMean = sum(objectImage(:))/sum(objectMask(:));
    
    % find the corresponding background
    bgMask = imdilate(objectMask,strel('disk',5))-objectMask;
        
    % Compute the Mean Intensity of the Background
    bgImage = mammoBR;
    bgImage(~bgMask) = 0;
    bgMean = sum(bgImage(:))/sum(bgMask(:));
    
    % feature4: contrast
    contrast = (objectMean - bgMean)/(objectMean + bgMean);
    
    if contrast < 0.06 || objectMean < 0.5
        continue;
    end
    
    mammoMaskOut = objectMask;
    % feature2: difference of intensity mean
    if objectMean - bgMean > 0.1 && objectMean > 0.6
        break;
    end
    
end
%%
figure,
subplot(2,4,1),imshow(mammoDS);
subplot(2,4,2),imshow(mammoBinary);
subplot(2,4,3),imshow(mammoBR);
subplot(2,4,4),imshow(mammoPeak);
subplot(2,4,5),imshow(mammoBP);
subplot(2,4,6),imshow(massMaskClean);
subplot(2,4,7),imshow(seedMaskOut);
subplot(2,4,8),imshow(mammoMaskOut);
end