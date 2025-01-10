function [label_Bin,num_label] = labelBinary(labelMap)

[~,col] = size(labelMap); 
label_Bin = zeros();
t = 0; 

for i=1:col
    label_Bin(t+1:t+6) = dec2bin(labelMap(i),6)-'0';
    t = t + 6;
end 
[~,num_label] = size(label_Bin);
