   function [] = cellTrackingMDCK4
%particle tracking 
% load tif stack -> find weighted centroids -> simpletrack -> find the
% average displacement and subtract -> simpletrack -> collect displacements
% make averages make displacement maps etc
clear
            warning('off','all')
croproi = [50,50,950,950];
       tic 
names = dir;
j = 1;
par_idx = 1;
v_idx = 1;
d = dir;

disk2 = strel('disk',1);
%tpv data for measuring shape
[code dirMatrix deltaI] = generatethreepixelclasses;
G = fspecial('gaussian', [5 5], 2);

clear tracks2
tracks2 = {};
len =length(imfinfo('outline.tif'));
image = {};

i = 1;        
        
        
mr2(:,1) = 1:len+1;
mr2(:,2) = 0;
mr2(:,3) = 0;
i=1;
s=0;
u=0;

%load segmented images
for k = 1:len
            mask{k} = im2bw(imread('outline.tif',k));
            cc{k} = bwconncomp(mask{k},4);
end


%%
%track once and subtract the average displacement to account for stage
%drift
for k = 1:len
                
        %collect centroids and other info for all the cells
       props0{i}{k} = regionprops(cc{k},'Centroid','PixelIdxList','Area','Perimeter');

       
       if k>1
           if length(props0{i}{k}) < length(props0{i}{k-1})/2
               length(props0{i}{k})
               length(props0{i}{k-1})
               len = k-1; 
               break
           end
       end
       
        for m = 1:length(props0{1,i}{1,k})
        props02{1,i}{1,k}(m,1:2) = props0{1,i}{1,k}(m).Centroid;
        props02{1,i}{1,k}(m,3) =  k;
        props02{1,i}{1,k}(m,4) = m;
        end
        
end     
         clear a0 a1
         a_idx = 1;
        %use simple tracker to generate trajectories
        [ tracks0, adjacency_tracks0 ] = simpletracker(props02{1,i},'MaxLinkingDistance',30,'MaxGapClosing',1);

        %remove short trajectories
        all_points0 = vertcat( props02{1,i}{:} );
        for track = 1:length(adjacency_tracks0)
            
           if length(adjacency_tracks0{track}) < 5
                for u = 1:length(adjacency_tracks0{track})
                   k0 = all_points0(adjacency_tracks0{track}(u),3);
                   m0 = all_points0(adjacency_tracks0{track}(u),4);
                end
                adjacency_tracks0{track} = [];
                tracks0{track} = [];
            end
        end
        
        %collect displacement measurements
        for t = 1:length(adjacency_tracks0)
            if ~isempty(adjacency_tracks0{t})

                for pi = 1:length(adjacency_tracks0{t})-1

                    for pf = pi+1:length(adjacency_tracks0{t})
                    dt = all_points0(adjacency_tracks0{t}(pf),3)-all_points0(adjacency_tracks0{t}(pi),3);
                    dx = all_points0(adjacency_tracks0{t}(pf),1)-all_points0(adjacency_tracks0{t}(pi),1);
                    dy = all_points0(adjacency_tracks0{t}(pf),2)-all_points0(adjacency_tracks0{t}(pi),2);
                    
                    if dt == 1
                       a0(a_idx,1) =  all_points0(adjacency_tracks0{t}(pi),3);
                       a0(a_idx,2) = dx;
                       a0(a_idx,3) = dy;
                       a_idx = a_idx+1;
                    elseif dt == -1
                       a0(a_idx,1) =  all_points0(adjacency_tracks0{t}(pf),3);
                       a0(a_idx,2) = -dx;
                       a0(a_idx,3) = -dy;
                       a_idx = a_idx+1;
                        
                        
                    end
                    end
                    
                    
                 end
              


            end
        end
  
              a1 = zeros(len,3);  
              
        for z = 1:length(a0) % average dx and dy for the frame
                    a1(a0(z,1),1) = a1(a0(z,1),1)+a0(z,2);
                    a1(a0(z,1),2) = a1(a0(z,1),2)+a0(z,3);
                    a1(a0(z,1),3) = a1(a0(z,1),3)+1;
        end
                    a1(:,1) = a1(:,1)./a1(:,3);
                    a1(:,2) = a1(:,2)./a1(:,3);
                    
                        for  b = 1:length(a1)
                       a2(b,1) = sum(a1(1:b,1));
                       a2(b,2) = sum(a1(1:b,2));
                        end
                
                        
                    
%% 
%track again and subtract the average again to refine the average
%displacement
for k = 1:len
    
    

            
       props00{i}{k} = regionprops(cc{k},'Centroid','PixelIdxList','Area','Perimeter');

                
        for m = 1:length(props00{1,i}{1,k})
        props002{1,i}{1,k}(m,1:2) = props00{1,i}{1,k}(m).Centroid;
        if k>1
        props002{1,i}{1,k}(m,1) = props002{1,i}{1,k}(m,1)-a2(k-1,1);
        props002{1,i}{1,k}(m,2) = props002{1,i}{1,k}(m,2)-a2(k-1,2);
        end
            props002{1,i}{1,k}(m,3) =  k;
        end
        
end     
         clear a0 a1
         a_idx = 1;
        [ tracks00, adjacency_tracks00 ] = simpletracker(props002{1,i},'Method','NearestNeighbor','MaxLinkingDistance',12,'MaxGapClosing',4);
        all_points00 = vertcat( props002{1,i}{:} );
        for track = 1:length(adjacency_tracks00)
            
           if length(adjacency_tracks00{track}) < 5
                adjacency_tracks00{track} = [];
                tracks00{track} = [];
            end
        end
        
        
        for t = 1:length(adjacency_tracks00)
            if ~isempty(adjacency_tracks00{t})

                for pi = 1:length(adjacency_tracks00{t})-1

                    for pf = pi+1
                    dt = 1;%all_points0(adjacency_tracks0{t}(pf),3)-all_points0(adjacency_tracks0{t}(pi),3);
                    dx = all_points00(adjacency_tracks00{t}(pf),1)-all_points00(adjacency_tracks00{t}(pi),1);
                    dy = all_points00(adjacency_tracks00{t}(pf),2)-all_points00(adjacency_tracks00{t}(pi),2);
                    
                    if dt == 1
                       a00(a_idx,1) = all_points00(adjacency_tracks00{t}(pi),3);
                       a00(a_idx,2) = dx;
                       a00(a_idx,3) = dy;
                       a_idx = a_idx+1;
                         
                         
                    end
                    end
                    
                    
                end
              


            end
        end
  
              a10 = zeros(len,3);  
              
        for z = 1:length(a00) % average dx and dy for the frame
                    a10(a00(z,1),1) = a10(a00(z,1),1)+a00(z,2);
                    a10(a00(z,1),2) = a10(a00(z,1),2)+a00(z,3);
                    a10(a00(z,1),3) = a10(a00(z,1),3)+1;
        end
                    a10(:,1) = a10(:,1)./a10(:,3);
                    a10(:,2) = a10(:,2)./a10(:,3);
                    
                        for  b = 1:length(a10)
                       a20(b,1) = sum(a10(1:b,1));
                       a20(b,2) = sum(a10(1:b,2));
                        end
                       
%%
%final tracking to make measurements
clear props0 props00
        for k = 1:len
            props{i}{k} = regionprops(cc{k},'Centroid','PixelIdxList','Image','MajorAxisLength','MinorAxisLength');
           
            
        
        for m = 1:length(props{1,i}{1,k})
        props2{1,i}{1,k}(m,1:2) = props{1,i}{1,k}(m).Centroid;
        if k>1
        props2{1,i}{1,k}(m,1) = props2{1,i}{1,k}(m,1)-a20(k-1,1)-a2(k-1,1);
        props2{1,i}{1,k}(m,2) = props2{1,i}{1,k}(m,2)-a20(k-1,2)-a2(k-1,2);
        end
        end
       
        try
        props3 = props2;
        catch
        continue
        end
        
        
            
            
        end
        for k = 1:len
        for m = 1:length(props{1,i}{1,k})  
        props3{1,i}{1,k}(m,3) = k;
        props3{1,i}{1,k}(m,4) = m;
        
        [~,area1,q1] = measureperimTPV3(props{1,i}{1,k}(m).Image,code,dirMatrix,deltaI);
        props3{1,i}{1,k}(m,5) = q1;
        props3{1,i}{1,k}(m,6) = area1;
        props3{1,i}{1,k}(m,7) = props{1,i}{1,k}(m).MajorAxisLength/props{1,i}{1,k}(m).MinorAxisLength;

        end
        end
        [ tracks{i} adjacency_tracks{i} ] = simpletracker(props2{1,i},'Method','NearestNeighbor','MaxLinkingDistance',30,'MaxGapClosing',4);
        all_points{i} = vertcat( props3{1,i}{:} );
        
        for track = 1:length(adjacency_tracks{i})
            if length(adjacency_tracks{i}{track}) < 5
                adjacency_tracks{i}{track} = [];
                tracks{i}{track} = [];
            end
        end
        t_idx = 1;
        par_idx = 1;
        for t = 1:length(adjacency_tracks{i})
            if ~isempty(adjacency_tracks{i}{t})
                p_idx = 1;
                
                    tracks2{t_idx} = zeros(len,5);
                    tracks2{t_idx}(:,4) = 1:len;
                    

                for pi = 1:length(adjacency_tracks{i}{t})-1
                    dt = 1;%all_points{i}(adjacency_tracks{i}{t}(pf),3) - all_points{i}(adjacency_tracks{i}{t}(pi),3);
                    dx = all_points{i}(adjacency_tracks{i}{t}(pi+1),1)-all_points{i}(adjacency_tracks{i}{t}(pi),1);
                    dy = all_points{i}(adjacency_tracks{i}{t}(pi+1),2)-all_points{i}(adjacency_tracks{i}{t}(pi),2);
                    dx2 = (dx)^2;
                    dy2 = (dy)^2;
                    
                    tracks2{t_idx}(dt,1) = tracks2{t_idx}(dt,1)+dx2;
                    tracks2{t_idx}(dt,2) = tracks2{t_idx}(dt,2)+dy2;
                    tracks2{t_idx}(dt,5) = tracks2{t_idx}(dt,5)+1;

                    %v0 stores all the single frame displacements and other
                    %info about the cell at that time point
                    if dt == 1
                       v0(v_idx,1) =  props3{1,i}{1,all_points{i}(adjacency_tracks{i}{t}(pi),3)}(all_points{i}(adjacency_tracks{i}{t}(pi),4),3);
                       v0(v_idx,2) =  props3{1,i}{1,all_points{i}(adjacency_tracks{i}{t}(pi),3)}(all_points{i}(adjacency_tracks{i}{t}(pi),4),4);

                       v0(v_idx,3) = dx;
                       v0(v_idx,4) = dy;
                       v0(v_idx,5) =  sqrt(dx2+dy2);
                       v0(v_idx,6) =  atan2d(dy,dx);
                       v0(v_idx,7) = all_points{i}(adjacency_tracks{i}{t}(pi),1);
                       v0(v_idx,8) = all_points{i}(adjacency_tracks{i}{t}(pi),2);

                        v0(v_idx,9) =           props3{1,i}{1,all_points{i}(adjacency_tracks{i}{t}(pi),3)}(all_points{i}(adjacency_tracks{i}{t}(pi),4),5);
                        v0(v_idx,10) =          props3{1,i}{1,all_points{i}(adjacency_tracks{i}{t}(pi),3)}(all_points{i}(adjacency_tracks{i}{t}(pi),4),6);
                        v0(v_idx,11) =          props3{1,i}{1,all_points{i}(adjacency_tracks{i}{t}(pi),3)}(all_points{i}(adjacency_tracks{i}{t}(pi),4),7);

                       v_idx = v_idx+1;
                     
                       
                    end
                end
                    tracks2{t_idx}(:,3) = (tracks2{t_idx}(:,1)+tracks2{t_idx}(:,2)).*(0.645)^2;

                    tracks2{t_idx}(:,3) = tracks2{t_idx}(:,3)./tracks2{t_idx}(:,5);
                    tracks2{t_idx}(:,1) = tracks2{t_idx}(:,1)./tracks2{t_idx}(:,5);
                    tracks2{t_idx}(:,2) = tracks2{t_idx}(:,2)./tracks2{t_idx}(:,5);

            t_idx = t_idx+1;
           
            end
           
        end
        
        
% r2 compiles mean squared displacement        
        r2{i}(:,1) = 1:len+1;
        r2{i}(:,2) = 0;
        r2{i}(:,3) = 0;
        r2{i}(:,4) = 0;
        r2{i}(:,5) = 0;
        r2{i}(:,6) = 0;
        r2{i}(:,7) = 0;
        

p_idx2 = 1;        
if ~isempty(tracks2)
        for n = 1:length(tracks2)
           for m = 1:length(tracks2{n})               
                   
               if ~isnan(tracks2{n}(m,3))
                r2{i}(tracks2{n}(m,4)+1,2) = r2{i}(tracks2{n}(m,4)+1,2)+tracks2{n}(m,3)*tracks2{n}(m,5);
                r2{i}(tracks2{n}(m,4)+1,3) = r2{i}(tracks2{n}(m,4)+1,3)+tracks2{n}(m,5); 
                r2{i}(tracks2{n}(m,4)+1,6) = r2{i}(tracks2{n}(m,4)+1,6)+tracks2{n}(m,1)*tracks2{n}(m,5);
                r2{i}(tracks2{n}(m,4)+1,7) = r2{i}(tracks2{n}(m,4)+1,7)+tracks2{n}(m,2)*tracks2{n}(m,5);
                        
                mr2(tracks2{n}(m,4)+1,2) = mr2(tracks2{n}(m,4)+1,2)+tracks2{n}(m,3)*tracks2{n}(m,5);
                mr2(tracks2{n}(m,4)+1,3) = mr2(tracks2{n}(m,4)+1,3)+tracks2{n}(m,5); 
               end
               
               
           end
             r2{i}(:,5) = r2{i}(:,2)./r2{i}(:,3);
             r2{i}(:,4) = r2{i}(:,1)*5;

           end
        
end

tracks3{i} = tracks2;



             mr2(:,5) = mr2(:,2)./mr2(:,3);
             mr2(:,4) = mr2(:,1)*5;

v1 = zeros(len,9);

for u = 1:len
   ma = imdilate(mask{u},disk2);
   totalarea(u) = sum(ma(:));
   v1(u,8) = totalarea(u);
end

%v1 stores frame averaged measurements

                    for i = 1:length(v0) % average dx and dy for the frame
                    v1(v0(i,1),1) = v1(v0(i,1),1)+v0(i,3);
                    v1(v0(i,1),2) = v1(v0(i,1),2)+v0(i,4);
                    v1(v0(i,1),3) = v1(v0(i,1),3)+v0(i,5);
                    v1(v0(i,1),4) = v1(v0(i,1),4)+v0(i,6);
                    v1(v0(i,1),5) = v1(v0(i,1),5)+v0(i,9);
                    v1(v0(i,1),6) = v1(v0(i,1),6)+v0(i,10);
                    v1(v0(i,1),7) = v1(v0(i,1),7)+v0(i,11);
                    

                    v1(v0(i,1),9) = v1(v0(i,1),9)+1;
                    end
                    v1(:,1) = v1(:,1)./v1(:,9);
                    v1(:,2) = v1(:,2)./v1(:,9);
                    v1(:,3) = v1(:,3)./v1(:,9);
                    v1(:,4) = v1(:,4)./v1(:,9);
                    v1(:,5) = v1(:,5)./v1(:,9);
                    v1(:,6) = v1(:,6)./v1(:,9);
                    v1(:,7) = v1(:,7)./v1(:,9);
                    v1(:,8) = v1(:,8)./v1(:,9);
     
                    %%
                    
%generate output images
                    
                    for k = 1:len
                   
                       maska{k} = zeros(size(mask{k}));
                    end

                    for i = 1:length(v0)
                         if v0(i,5)<4
                      
                       maska{v0(i,1)}(props{1}{v0(i,1)}(v0(i,2)).PixelIdxList) = v0(i,10); 
                         end
                       
                    end
                    for k = 1:len
                    
                       maska{k} = (maska{k}-500)./(2000).*64;
                      
                    end
                    
                    for k = 3:len-2
                    imwrite(uint8(frameAvg(maska{k-2},maska{k-1},maska{k},maska{k+1},maska{k+2})),magma(64),'aavgcolor20ma.tif','Writemode','append')
                    end

                    clear maska
                    for k = 1:len
                       maskp{k} = zeros(size(mask{k}));
                    end

                    for i = 1:length(v0)
                         if v0(i,5)<4
                       maskp{v0(i,1)}(props{1}{v0(i,1)}(v0(i,2)).PixelIdxList) = v0(i,9);
                         end
                       
                    end
                    for k = 1:len
                       maskp{k} = (maskp{k}-3.5)./((4.5-3.5)).*64;
                      
                    end
                    
                    for k = 3:len-2
                    imwrite(uint8(frameAvg(maskp{k-2},maskp{k-1},maskp{k},maskp{k+1},maskp{k+2})),magma(64),'pavgcolor20ma.tif','Writemode','append')
                    end

                    
                    clear maskp
                    

                    for k = 1:len
                       maskv{k} = zeros(size(mask{k}));
                    end

                    for i = 1:length(v0)
                         if v0(i,5)<4
                       maskv{v0(i,1)}(props{1}{v0(i,1)}(v0(i,2)).PixelIdxList) = v0(i,5);
                         end
                       
                    end
                    for k = 1:len
                       maskv{k} = (maskv{k})./((4)).*64;
                      
                    end
                    
                    for k = 3:len-2
                    imwrite(uint8(frameAvg(maskv{k-2},maskv{k-1},maskv{k},maskv{k+1},maskv{k+2})),magma(64),'vavgcolor20ma.tif','Writemode','append')
                    
                    end
                    clear maskv cc


                 for k = 1:len
                       maskf{k} = zeros(size(mask{k}));
                    end

                    for i = 1:length(v0)
                         if v0(i,5)<10
                       maskf{v0(i,1)}(props{1}{v0(i,1)}(v0(i,2)).PixelIdxList) = 1;
                         end
                       
                    end
                    maskf{k} = im2bw(maskf{k},0.0001);
                    
                    for k = 1:len
                    imwrite(uint8(maskf{k}),'outlinefinal.tif','Writemode','append')
      
                    end
toc
            warning('on','all')
            clear props maskf mask cc 
save('ws20ar2')

   end



