function feature = Mask2Feature(maskIn,mammoIn,mammoBM)

feature = zeros(size(maskIn,3),2);
% figure,subplot(2,4,1),imshow(mammoIn,[]);

for candidate = 1:size(maskIn,3)
    % Feature 1: Perimeter to Area Ratio
    candidateMask = maskIn(:,:,candidate);
%     subplot(2,4,candidate+1),imshow(candidateMask,[]);
    perimeter = bwperim(candidateMask);
    feature(candidate,1) = sum(perimeter(:))/sum(candidateMask(:));
    
    % Feature 2: contrast
    bgMask = imdilate(candidateMask,strel('disk',5)) & ~candidateMask & mammoBM;
    
    fg  = mammoIn(candidateMask==1);
    fgMI = sum(fg(:))./sum(candidateMask(:));
    
    bg = mammoIn(bgMask==1);
    bgMI = sum(bg(:))./sum(bgMask(:));
    
    feature(candidate,2) = (fgMI - bgMI)./(fgMI+bgMI);
end

end