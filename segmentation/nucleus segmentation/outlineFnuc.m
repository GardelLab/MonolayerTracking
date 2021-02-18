function outlineFnucR(file,outname)

info1 = imfinfo(file);
for i = 1:length(info1)
    im = imread(file,i);
    


handles1.LPF=0.05; % Gaussian low-pass filter Full Width at Half Maximum (FWHM) (min:0 , max : 1)
handles1.Phase_strength=60.48;  % PST  kernel Phase Strength
handles1.Warp_strength=61.14;  % PST Kernel Warp Strength
[Edge1 PST_Kernel]= PST(im,handles1,0);
%otsu threshold the phase image
m1 = im2bw(Edge1+0.01,0);
m1 = imcomplement(m1);
m1 = m1 - bwareaopen(m1,500);

m1 = imopen(m1,strel('disk',3));


imwrite(m1,outname,'Writemode','append')

end

end