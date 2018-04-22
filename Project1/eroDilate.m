function retImg=eroDilate(image,radius)
% Function to erode and dilate the image using a disk element of radius r
SE3 = strel('disk', radius);
retImg=imdilate(imerode(image,SE3),SE3);
end
