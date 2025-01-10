function [value] = BinaryConversion_2_10_int(bin2_10)
value = 0;
len = length(bin2_10);
for i=1:len
    value = value + bin2_10(i)*(2^(len-i));
end