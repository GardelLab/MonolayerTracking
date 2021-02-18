function [out,distout] = filtavg(in)
idx=ones(max(in(:,1)),1);
out = zeros(max(in(:,1)),7);
for i = 1:length(in)
    if in(i,5) < 10
      out(in(i,1),1) = out(in(i,1),1)+in(i,3);
      out(in(i,1),2) = out(in(i,1),2)+in(i,4);
      out(in(i,1),3) = out(in(i,1),3)+in(i,5);
      out(in(i,1),4) = out(in(i,1),4)+in(i,6);
      out(in(i,1),5) = out(in(i,1),5)+in(i,9);
      out(in(i,1),6) = out(in(i,1),6)+in(i,10);
    
      distout{in(i,1)}(idx(in(i,1)),:) = in(i,:);
      idx(in(i,1)) = idx(in(i,1))+1;

      out(in(i,1),7) = out(in(i,1),7)+1;
    end
end

                    out(:,1) = out(:,1)./out(:,7);
                    out(:,2) = out(:,2)./out(:,7);
                    out(:,3) = out(:,3)./out(:,7);
                    out(:,4) = out(:,4)./out(:,7);
                    out(:,5) = out(:,5)./out(:,7);
                    out(:,6) = out(:,6)./out(:,7);
end