% Prasad Vagdargi
% Main script for MIA project 1

addpath('../../MIAData/MammoTraining');
raw=importdata('Project1List.xlsx');
% Get the labels
label=raw.data;

%% For manual testing, enter ID here
id=1002;
files=fetchID(id);
%% Processing for R
% Use adaptive eq or histeq? Have to try to get good results
% R.eq=adapthisteq(files.R);
R.eq=histeq(files.R);

% Smoothen the image
R.filt=imgaussfilt(R.eq,2);

% EroDilate and then create log based mask
R.dImg=double(R.filt)./max(double(R.filt(:)));
R.dImg=eroDilate(R.dImg,10);

% Binarize logmask using otsu
R.logMask=imbinarize(log(1+R.dImg));

% And close contours to create continuous block
R.mask=eroDilate(R.logMask,10);
imagesc(R.mask);axis image;colormap gray;

% Use this centroid for active contour/segmentation?
% R.props=regionprops(R.mask,'Centroid');
% imshow(R.mask); hold on;
% scatter(R.props(1).Centroid(1),R.props(1).Centroid(2),'ro');

% Need to find active contour/edge here

R.dMap=bwdist(~R.mask);

%% Processing for L
L.eq=histeq(files.L);
L.dImg=double(L.eq)./max(double(L.eq(:)));
L.dImg=eroDilate(L.dImg,10);
L.logMask=imbinarize(log(1+L.dImg));
L.mask=eroDilate(L.logMask,10);
imagesc(L.mask);
% Need to find active contour/edge here

R.dMap=bwdist(~R.mask);
