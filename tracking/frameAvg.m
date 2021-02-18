function [imout] = frameAvg(im1,im2,im3,im4,im5)

sz = size(im1);

imout = zeros(sz);
bin1 = im1>0;
bin2 = im2>0;
bin3 = im3>0;
bin4 = im4>0;
bin5 = im5>0;

im1 = immultiply(im1,bin1);
im2 = immultiply(im2,bin2);
im3 = immultiply(im3,bin3);
im4 = immultiply(im4,bin4);
im5 = immultiply(im5,bin5);


mask = im2bw(bin2+bin3+bin4,0.001);


for i = 1:sz(1)
    for j = 1:sz(2)
        imout(i,j) = (im1(i,j)+im2(i,j)+im3(i,j)+im4(i,j)+im5(i,j))/(bin1(i,j)+bin2(i,j)+bin3(i,j)+bin4(i,j)+bin5(i,j));
        
    end
end


imout = immultiply(imout,mask);
end