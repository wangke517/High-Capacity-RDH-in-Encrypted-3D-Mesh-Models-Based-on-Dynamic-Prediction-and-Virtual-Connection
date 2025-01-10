function [label_map, aux_len] = arith_recover(ver_bin, num_vert)
compress_len_bin = ver_bin(1:ceil(log2(9*num_vert)));
compress_len = BinaryConversion_2_10_1(compress_len_bin, ceil(log2(9*num_vert)));
compress_bit = ver_bin(ceil(log2(9*num_vert))+1:ceil(log2(9*num_vert))+compress_len);
loc_Com = zeros(compress_len/8,1);
for n = 1:compress_len/8
    loc_Com(n,1) = BinaryConversion_2_10_int(compress_bit((n-1)*8+1:n*8));
end
cPos_x = arith07(loc_Com);
label_map = (cPos_x{1,1})';
aux_len = ceil(log2(9*num_vert)) + compress_len;
end

