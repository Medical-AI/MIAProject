function feature = Mask2Feature(maskIn,mammoIn,mammoBM)

feature = zeros(size(maskIn,3),10);
% figure,subplot(2,4,1),imshow(mammoIn,[]);

for candidate = 1:size(maskIn,3)
    candidateMask = squeeze(maskIn(:,:,candidate));
    
    % Intensity Features
    % Feature 1: Average Intensity
    fg  = mammoIn(candidateMask==1);
    feature(candidate,1) = mean(fg);
    
    % Feature 2: Variance
    feature(candidate,2) = var(fg);
    
    % Feature 3: Skewness
    feature(candidate,3) = skewness(fg);
    
    % Feature 4: Kurtosis
    feature(candidate,4) = kurtosis(fg);
    
    % Feature 5: Contrast
    bgMask = imdilate(candidateMask,strel('disk',5)) & ~candidateMask & mammoBM;
    bg = mammoIn(bgMask==1);
    if sum(bg(:)) == 0
        feature(candidate,5) = 0;
    else
        feature(candidate,5) = (mean(fg) - mean(bg))./(mean(fg)+mean(bg));
    end
    
    % Shape Features
    stats = regionprops('struct',candidateMask,'Area','Centroid', ...
        'Perimeter','Solidity');
    
    % Feature 6: Area
    feature(candidate,6) = stats.Area;
    
    % Feature 7: Perimeter
    feature(candidate,7) = stats.Perimeter;
    
    % Feature 8: Solidity
    feature(candidate,8) = stats.Solidity;
    
    % Feature 9: Average Gradient
    [Gx, Gy] = imgradientxy(mammoIn, 'central');
    Gx(candidateMask == 0) = 0;
    Gy(candidateMask == 0) = 0;
    Gmag = Gx.^2 + Gy.^2;
    feature(candidate,9) = mean(Gmag(candidateMask == 1));
    
    % Feature 10: Spiculation
    [xc,yc] = meshgrid(1:size(mammoIn,2),1:size(mammoIn,1));
    xc = xc - stats.Centroid(1);
    yc = yc - stats.Centroid(2);
    xc(candidateMask == 0) = 0;
    yc(candidateMask == 0) = 0;
    Cdir = normalize(cat(3,xc,yc),3);
    Gdir = normalize(cat(3,Gx,Gy),3);
    angles = Cdir .* Gdir;
    feature(candidate,10) = mean(angles(candidateMask == 1));

end

end