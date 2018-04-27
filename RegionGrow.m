function seedMaskOut = RegionGrow(seedMaskIn,imageIn)


seedMaskOut = seedMaskIn;

for iterator = 1:50
    seedConverge = seedMaskOut;
    
    % Shrink Object
    CC = bwconncomp(seedMaskOut,8);
    for object = 1:CC.NumObjects
        
        % pick a single object
        objectMask = zeros(size(seedMaskIn));
        objectMask(CC.PixelIdxList{object})=1;
        
        % find the corresponding background
        bgMask = imdilate(objectMask,strel('disk',5))-objectMask;
        
        % find the one-pixel boundary points of the object
        objectBDMask = boundarymask(objectMask) & objectMask;
        [x,y] = find(objectBDMask);
        
        % compute the mean intensity of the current object
        objectImage = imageIn;
        objectImage(~objectMask) = 0;
        objectMean = sum(objectImage(:))/sum(objectMask(:));
        
        % Compute the Mean Intensity of the Background
        bgImage = imageIn;
        bgImage(~bgMask) = 0;
        bgMean = sum(bgImage(:))/sum(bgMask(:));
        
        if objectMean <= bgMean
            seedMaskOut(objectBDMask) = 0;
            continue;
        end
        
        for i = 1:length(x)
            if imageIn(x(i),y(i)) > objectMean
                seedMaskOut(x(i),y(i)) = 1;
            elseif imageIn(x(i),y(i)) < bgMean
                seedMaskOut(x(i),y(i)) = 0;
            elseif objectMean - imageIn(x(i),y(i)) < imageIn(x(i),y(i)) - bgMean
                seedMaskOut(x(i),y(i)) = 1;
            else
                seedMaskOut(x(i),y(i)) = 0;
            end
        end
    end
    
    % Expand Object
    CC = bwconncomp(seedMaskOut,8);
    for object = 1:CC.NumObjects
        
        % Pick a Single Object
        objectMask = zeros(size(seedMaskIn));
        objectMask(CC.PixelIdxList{object})=1;
        
        % Find the Corresponding Background
        bgMask = imdilate(objectMask,strel('disk',5))-objectMask;
        
        % Find the One-pixel Boundary Points of the Background
        bgBDMask = boundarymask(~objectMask) & bgMask;
        [x,y] = find(bgBDMask);
        
        % Compute the Mean Intensity of the Current Object
        objectImage = imageIn;
        objectImage(~objectMask) = 0;
        objectMean = sum(objectImage(:))/sum(objectMask(:));
        
        % Compute the Mean Intensity of the Background
        bgImage = imageIn;
        bgImage(~bgMask) = 0;
        bgMean = sum(bgImage(:))/sum(bgMask(:));
        
        if objectMean <= bgMean
            continue;
        end
        
        for i = 1:length(x)
            if imageIn(x(i),y(i)) > objectMean
                seedMaskOut(x(i),y(i)) = 1;
            elseif imageIn(x(i),y(i)) < bgMean
                seedMaskOut(x(i),y(i)) = 0;
            elseif objectMean - imageIn(x(i),y(i)) < imageIn(x(i),y(i)) - bgMean
                seedMaskOut(x(i),y(i)) = 1;
            else
                seedMaskOut(x(i),y(i)) = 0;
            end
        end
    end
    
    if seedConverge == seedMaskOut
%         disp(iterator)
        break;
    end
    
end
end