function [ver2_temp] = BinaryConversion_2_10_1(ver2_temp_bin,bit_len)
ver2_temp = 0;
for j = 0:bit_len-1
    ver2_temp = ver2_temp + ver2_temp_bin(bit_len-j)*2^j;
end