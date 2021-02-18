function [map] = outlineCells10t(image,LPF,Phase,Warp,gthresh,defectfilt,dfilton)
%function for segmenting images with labeled membranes - optimized inputs
%for 20x mi star-gfp mdck cells on collagen gel -
%image,0.0281794154064827,4.50920575907323,40.3716047278053,0.966112308679992,0.985740407756296,1
 
%normalize the intensity values in the image
   i1 = mat2gray(image);
   
   
   m0 = zeros(size(i1));



  handles2.LPF=LPF; % Gaussian low-pass filter Full Width at Half Maximum (FWHM) (min:0 , max : 1)
  handles2.Phase_strength=Phase;  % PST  kernel Phase Strength
  handles2.Warp_strength=Warp;  % PST Kernel Warp Strength




% Thresholding parameters (for post processing)
handles1.Thresh_min=-1;      % minimum Threshold  (a number between 0 and -1)
handles1.Thresh_max=0.0019;  % maximum Threshold  (a number between 0 and 1)


%run pst segmentation
[Edge2 PST_Kernel]= PST(i1,handles2,0);

Edge2(Edge2>mean(Edge2(:))*10)=mean(Edge2(:));

% figure
% imhist(Edge2)
%threshold phase map
tEdge2 = mat2gray(Edge2);
m1 = im2bw(tEdge2,graythresh(tEdge2)/gthresh);

%complement to convert cells to edges and thin them to single pixel width
m10 = bwmorph(imcomplement(m1),'thin',Inf);

%remove small segments
m10 = bwareaopen(m10,20);

%close edge gaps each instance grows short edges
m11 = filledgegaps4(filledgegaps(m10,6), 20);
m11 = filledgegaps4(filledgegaps(m11,6), 10);
m11 = imdilate(filledgegaps(m11, 20),strel('disk',3));


 
% remove paths which are not closed
m12 = bwmorph(m11,'thin',Inf);
m13 = imdilate(m12,strel('disk',1));
m14 = bwmorph(m13,'majority',Inf);
m15 = bwmorph(m14,'thin',Inf);
m16 = imdilate(m15,strel('disk',1));
m17 = bwmorph(m16,'majority',Inf);
m18 = bwmorph(m17,'thin',Inf);

%complement back to cells
m19 = imcomplement(m18);

 
%remove small and large objects which are probably not single cells 
m20 = xor(bwareaopen(m19,500,4),bwareaopen(m19,7000,4));

% figure
% imshowpair(m19,m20)
% fda

%remove cells touching image boundary
m21 = imclearborder(m20,4);


m22 = m21;

%defect filter - find cells which have large intensity in 
%the center of the cell in the gfp image and remove them 
if dfilton == 1
    cc = bwconncomp(m21,4);
    props = regionprops(cc,tEdge2,'PixelValues','PixelIdxList');
    for i = 1:length(props)
        u = props(i).PixelValues<graythresh(props(i).PixelValues)*defectfilt;
        props(i).PixelIdxList =  props(i).PixelIdxList.*(-(u-1));
        m22(props(i).PixelIdxList(props(i).PixelIdxList>0)) = 0;
    end

    m22 = bwmorph(m22,'thin',Inf);
    m22 = immultiply(m22,imerode(m21,strel('disk',8)));
    m22 = bwareaopen(m22,4);

    props = regionprops(cc,m22,'MeanIntensity','PixelIdxList');
    m23 = m21;
    for i = 1:length(props)
    if props(i).MeanIntensity > 0
        m23(props(i).PixelIdxList)=0;

    end

    end
else
    m23 = m22;
end

map = m23;


 

   
   
end
