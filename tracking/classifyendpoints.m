function [endpointslist] = classifyendpoints(m1)

  endpoints = bwmorph(m1, 'endpoints');
  [rowsEP, colsEP] = find(endpoints(31:end-30,31:end-30));
  
  rowsEP = rowsEP+30;
  colsEP = colsEP+30;
  
  %      1  2  3
  %      4  5  6
  %      7  8  9
  for i = 1:length(rowsEP)
      
       m0 = [m1(rowsEP(i)-1,colsEP(i)-1),m1(rowsEP(i)-1,colsEP(i)), m1(rowsEP(i)-1,colsEP(i)+1),...
           m1(rowsEP(i),colsEP(i)-1),0,m1(rowsEP(i),colsEP(i)+1),...
           m1(rowsEP(i)+1,colsEP(i)-1),m1(rowsEP(i)+1,colsEP(i)),m1(rowsEP(i)+1,colsEP(i)+1)];
       
       [~,type] = max(m0);
              
         
      
      
      endpointslist(i,1) = rowsEP(i);
      endpointslist(i,2) = colsEP(i);
      endpointslist(i,3) = type;
  end
  
  
  
      
    
    
end