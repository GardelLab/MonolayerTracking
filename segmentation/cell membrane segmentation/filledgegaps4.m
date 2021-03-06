% FILLEDGEGAPS  Fills small gaps in a binary edge map image
%
% Usage: bw2 = filledgegaps(bw, gapsize)
%
% Arguments:    bw - Binary edge image
%          gapsize - The edge gap size that you wish to be able to fill.
%                    Use the smallest value you can. (Odd values work best). 
%
% Returns:     bw2 - The binary edge image with gaps filled.
%
%
% Strategy: A binary circular blob of radius = gapsize/2 is placed at the end of
% every edge segment.  If the ends of two edge segments are in close proximity
% the circular blobs will overlap.  The image is then thinned.  Where circular
% blobs at end points overlap the thinning process will leave behind a line of
% pixels linking the two end points.  Where an end point is isolated the
% thinning process will erode the circular blob away so that the original edge
% segment is restored.
%
% Use the smallest gapsize value you can.  With large values all sorts of
% unwelcome linking can occur.
%
% The circular blobs are generated using the function CIRCULARSTRUCT which,
% unlike MATLAB's STREL, will accept real valued radius values.  Note that I
% suggest that you use an odd value for 'gapsize'.  This results in a radius
% value of the form x.5 being passed to CIRCULARSTRUCT which results in discrete
% approximation to a circle that seems to respond to thinning in a 'good'
% way. With integer radius values CIRCULARSTRUCT can produce circles that
% result in minor artifacts being generated by the thinning process.
%
% See also: FINDENDSJUNCTIONS, FINDISOLATEDPIXELS, CIRCULARSTRUCT, EDGELINK

% Copyright (c) 2013 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% PK May 2013

function bw = filledgegaps(bw, gapsize)
 gapsize = round(gapsize/2)*2;    

    [rows, cols] = size(bw);
    
    
   blob{1} = [[1,0,0];[0,1,0];[0,0,1]];  
   blob{2} = [[0,1,0];[0,1,0];[0,1,0]];  
   blob{3} = [[0,0,1];[0,1,0];[1,0,0]];  
   blob{4} = [[0,0,0];[1,1,1];[0,0,0]];  
   blob{6} = blob{4};
   blob{7} = blob{3};
   blob{8} = blob{2};
   blob{9} = blob{1};

    for i = [1:4,6:9]
    blob{i} = im2bw(imresize(blob{i},[gapsize+1,gapsize+1]),0.2);
    end
        
    
    % Get coordinates of end points and of isolated pixels
    endpoints = classifyendpoints(bw);
  
    

    % Place a circular blob at every endpoint and isolated pixel
    for n = 1:length(endpoints)
        

            bw(endpoints(n,1)-gapsize/2:endpoints(n,1)+gapsize/2, endpoints(n,2)-gapsize/2:endpoints(n,2)+gapsize/2) = ...
                bw(endpoints(n,1)-gapsize/2:endpoints(n,1)+gapsize/2, endpoints(n,2)-gapsize/2:endpoints(n,2)+gapsize/2) | blob{endpoints(n,3)};

    end
    
    
    
    bw = bwmorph(bw, 'thin', inf);  % Finally thin

    