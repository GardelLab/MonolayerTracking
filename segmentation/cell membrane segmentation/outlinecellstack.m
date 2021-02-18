function [] = outlinecellstackc(file,last)
% function for segmenting image stacks calls outlinecells13t on each image and saves the output
%   Detailed explanation goes here
info1 = imfinfo(file);
tic

if last == 0
   last = length(info1);
end

for i = 1:last
    
    i1 =imread(file,i);
    
    %input parameters to outlinecells13t were previously optimized for
    %epithelial monolayers at 20x
    outline = uint8(outlineCells13t(i1,0.0281794154064827,4.50920575907323,40.3716047278053,0.966112308679992,0.985740407756296,1))*255;
 
    imwrite(outline,'outline15.tif','Writemode','append')
    
    
end


toc
end

