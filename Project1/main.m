addpath('../../MIAData/MammoTraining');
raw=importdata('Project1List.xlsx');
% Get the labels
label=raw.data;

%% For manual testing, enter ID here
id=1002;
files=fetchID(id);
%% Processing for R
R.eq=histeq(files.R);
R.dImg=double(R.eq)./max(double(R.eq(:)));
R.dImg=eroDilate(R.dImg,10);
R.logMask=imbinarize(log(1+R.dImg));
R.mask=eroDilate(R.logMask,10);
imagesc(R.mask);
% Need to find active contour/edge here

L.dMap=bwdist(~L.mask);
%% Processing for L
L.eq=histeq(files.L);
L.dImg=double(L.eq)./max(double(L.eq(:)));
L.dImg=eroDilate(L.dImg,10);
L.logMask=imbinarize(log(1+L.dImg));
L.mask=eroDilate(L.logMask,10);
imagesc(L.mask);
% Need to find active contour/edge here

R.dMap=bwdist(~R.mask);