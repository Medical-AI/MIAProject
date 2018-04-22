function retImg=eroDilate(image,radius)
if radius>0
% Function to erode and dilate the image using a disk element of radius r
SE3 = strel('disk', radius);
retImg=imdilate(imerode(image,SE3),SE3);
else
    error('Radius should be greater than zero');
end
end
