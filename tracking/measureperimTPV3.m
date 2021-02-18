function [perim,area,q] = measureperim(object,code,dirMatrix,deltaI)

%input object is a regionprops.Image of a given blob
%input code converts chaincode doublet into TPV classes - should be
%generated beforehand by generatethreepixelclasses
%input direction matrix from generate threepixelclasses

% convert dy,dx pairs to scalar indexes thinking to them (+1) as base-3 numbers
% according to: idx=3*(dy+1)+(dx+1)=3dy+dx+4 (adding 1 to have idx starting
% from 1)
% Then use a mapping array cm
%   --------------------------------------
%   | deltax | deltay | code | (base-3)+1 |
%   |-------------------------------------|
%   |    0   |   +1   |   2  |      8     | 
%   |    0   |   -1   |   6  |      2     | 
%   |   -1   |   +1   |   3  |      7     | 
%   |   -1   |   -1   |   5  |      1     | 
%   |   +1   |   +1   |   1  |      9     | 
%   |   +1   |   -1   |   7  |      3     | 
%   |   -1   |    0   |   4  |      4     |  
%   |   +1   |    0   |   0  |      6     | 
%   ---------------------------------------


areaclass(1:13) = [2,3,2,2,2,2,3/2,1,11/4,3,2,3/2,2];

chaincode([1 2 3 4 6 7 8 9])=[3 2 1 4 0 5 6 7];

%length of each class
ib = [sqrt(5),sqrt(5),sqrt(5),sqrt(5),2,3,3+sqrt(2),4,sqrt(2),2*sqrt(2),1+2*sqrt(2),2+sqrt(2),2+2*sqrt(2)];



area = sum(sum(bwmorph(object,'erode',1)));
perpoints = bwperim(object);

props = regionprops(perpoints,'PixelList');
try
perpixels = sort_coord_pixel(props(1).PixelList,'anti-clockwise');    
perpixels = vertcat(perpixels,perpixels(1,:));
  
catch
    try
    object = bwmorph(object,'open',1);
    perpoints = bwperim(object);
    props = regionprops(perpoints,'PixelList');
    perpixels = sort_coord_pixel(props(1).PixelList,'anti-clockwise');
    perpixels = vertcat(perpixels,perpixels(1,:));
    catch
        q=0;
        area=0;
        perim=0;
        return
    end
    
end
for i = 1:length(perpixels)-1
   if abs(perpixels(i,1) - perpixels(i+1,1))>1 || abs(perpixels(i,2) - perpixels(i+1,2))>1
    perpoints = bwperim(bwmorph(object,'open',1));
    props = regionprops(perpoints,'PixelList');
    perpixels = sort_coord_pixel(props(1).PixelList,'anti-clockwise');
    perpixels = vertcat(perpixels,perpixels(1,:));

       break
   end
end



if mod(length(perpixels)-1,2) == 0
    len = (length(perpixels)-1)/2;
    addperim = 0;

else
    
    len = (length(perpixels)-2)/2;
    %get the last chain code
    deltae = perpixels(end,:)-perpixels(end-1,:);
    idxe = 3*deltae(1,2)+deltae(1,1)+5;
    chaine = chaincode(idxe);
    if ismember(chaine,[1,3,5,7])
        addpere = sqrt(2);
        area = area+1/2;
    else
        addpere = 1;
        area = area+1;
    end
        
end 

%collect chain pairs
    for i = 1:len
        %len
        %length(perpixels)-1
    delta1 = perpixels((i*2),:)-perpixels((i*2)-1,:); 
    delta2 = perpixels((i*2)+1,:) - perpixels((i*2),:);
    
    idx1 = 3*delta1(1,2)+delta1(1,1)+5;
    idx2 = 3*delta2(1,2)+delta2(1,1)+5;

    chain3(i,1) = chaincode(idx1);
    chain3(i,2) = chaincode(idx2);

    
    n = floor(chain3(i,1)/2);
    
    codeind = find(code(:,1)==chain3(i,1) & code(:,2)==chain3(i,2));
    
    chain3(i,3) = code(codeind,3);
    chain3(i,4) = code(codeind,4);

    addper = ib(chain3(i,3));

    
    if i == 1
        perim = addper;
        continue
    end
    
    df = dirMatrix(1,chain3(i,3),n+1);
    do = dirMatrix(2,chain3(i-1,3),n+1);
    
    dn = mod(df-do+16,16)+1;
    
    deltaper = deltaI(chain3(i,4),dn);
    
    perim = perim + addper + deltaper;
    area = area+areaclass(chain3(i,3));
    end
    
    

try
q = perim/sqrt(area);
   
catch
   q = 0;
   area = 0;
   perim = 0;
end
    
    
    
    
end