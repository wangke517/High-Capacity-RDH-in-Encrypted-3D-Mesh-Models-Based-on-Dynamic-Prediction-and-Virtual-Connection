function vertex1 = meshGenerate(ver_bin, bit_len)

ver2_int = [];
for i = 1:length(ver_bin)/bit_len
    ver2_temp_bin = ver_bin((i-1)*bit_len+1: i*bit_len);
    ver2_temp = 0;
    for j = 0:bit_len-1
        ver2_temp = ver2_temp + ver2_temp_bin(bit_len-j)*2^j;
    end
    ver2_int = [ver2_int; ver2_temp];
end

vertex1 = uint32([]);
for i = 1:length(ver_bin)/bit_len/3
    vertex1(i, 1) = ver2_int(3*(i-1)+1);
    vertex1(i, 2) = ver2_int(3*(i-1)+2);
    vertex1(i, 3) = ver2_int(3*(i-1)+3);
end

end