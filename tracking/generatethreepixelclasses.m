%generate 3 pixel chain code classes
function [code,dirMatrix,deltaI] = generatethreepixelclasses()
k=1;
for i = [0,1,2,3,4,5,6,7]
    for j = [0,1,2,3,4,5,6,7]
   code(k,1) = i;
   code(k,2) = j;
   k=k+1;
    end
end

for k = 1:length(code)
    n = floor(code(k,1)/2);
    isodd = mod(code(k,1),2);
    
    oneten = 2*n+1;
    twofive = 2*n;
    threenine = mod(2*n+7,8); 
    foursix = mod(2*n+2,8);
    seveneleven = mod(2*n+3,8);
    eighttwelve = mod(2*n+4,8);
    thirteen = mod(2*n+5,8);
    
    %find out which category the code belongs to
    switch code(k,2)
        case oneten
            if isodd
                code(k,3) = 10;
            else
                code(k,3) = 1;
            end
        case twofive
            if isodd
                code(k,3) = 2;
            else
                code(k,3) = 5;
            end
        case threenine
            if isodd
                code(k,3) = 9;
            else
                code(k,3) = 3;
            end
        case foursix
            if isodd 
                code(k,3) = 4;
            else
                code(k,3) = 6;
            end
        case seveneleven
            if isodd
                code(k,3) = 11;
            else
                code(k,3) = 7;
            end
        case eighttwelve
            if isodd
                code(k,3) = 12;
            else
                code(k,3) = 8;
            end
        case thirteen
            code(k,3) = 13;
    end

    %find out which class the category belongs to
     if ismember(code(k,3),[1,2])
         code(k,4) = 1;
     elseif ismember(code(k,3),[3,4])
         code(k,4) = 2;
     elseif ismember(code(k,3),[5,6,7,8])
         code(k,4) = 3;
     else
         code(k,4) = 4;
     end
         
         
         
         
end


for n = [0,1,2,3]
    dirMatrix(1,:,n+1) = [4*(4-n),4*(4-n),mod(18-4*n,16),mod(14-4*n,16),mod(17-4*n,16),mod(17-4*n,16),mod(17-4*n,16),mod(17-4*n,16),15-4*n,15-4*n,15-4*n,15-4*n,15-4*n];
    dirMatrix(2,:,n+1) = [4*(4-n),4*(4-n),mod(18-4*n,16),mod(14-4*n,16),mod(17-4*n,16),13-4*n,mod(27-4*n,16),mod(25-4*n,16),mod(19-4*n,16),15-4*n,mod(27-4*n,16),mod(25-4*n,16),mod(23-4*n,16)];
end

   deltaI(1,:)=[0,0,0,0,sqrt(2)-sqrt(5),1-sqrt(2),2-sqrt(5),0,2,2,2,2,1,1,1,1];
   deltaI(2,:)=[0,0,sqrt(2)-sqrt(5),sqrt(2)-sqrt(5),2-5,0,0,2,2,2,1,1,1,1,0,0];
   deltaI(3,:)=[0,-1,-1,2-sqrt(5),0,0,0,0,2,1,1,1,1,0,0,0];
   deltaI(4,:)=[0,0,0,sqrt(2)-sqrt(5),sqrt(5)-2*sqrt(2),2-sqrt(5),0,2,2,2,2,1,1,1,1,0];
   
   
end
    
    