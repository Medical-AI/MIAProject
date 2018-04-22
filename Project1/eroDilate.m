function retImg=eroDilate(image,radius)
% Erode then dilate the image given the radius of disk
% Input: image, radius
% Output: image
% Prasad Vagdargi
if radius>0
% Function to erode and dilate the image using a disk element of radius r
SE3 = strel('disk', radius);
retImg=imdilate(imerode(image,SE3),SE3);
else
    error('Radius should be greater than zero');
end
end
