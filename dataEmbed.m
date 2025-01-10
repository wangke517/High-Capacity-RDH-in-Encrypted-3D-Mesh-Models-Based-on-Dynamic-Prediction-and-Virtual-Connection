function [vertex2,message] = dataEmbed(vertex1,Room_2,label_map,bit_len,vertemb,refer_id,EL_B,coding_selection,k_emb)
vertex2 = vertex1;
refer_id_bin = [];
[n,~] = size(vertex1);
Room_2 = double(Room_2);
len_sum = sum(label_map);
mess_total = [];

for i = 1:size(refer_id,2)
    refer_id_bin = [refer_id_bin BinaryConversion_10_2(refer_id(i),ceil(log2(n)))];
end

if coding_selection == 0
    cPos_x = cell(1,1);
    cPos_x{1} = label_map;
    loc_Com =  arith07(cPos_x);
    [compress_bit,compress_len] = dec_transform_bin(loc_Com, 8);
    compress_bit = double(compress_bit);
    compress_len_bin = BinaryConversion_10_2(compress_len, ceil(log2(9*n)));
    message = double(logical(pseudoGenerate(3*len_sum-compress_len-ceil(log2(9*n))-size(refer_id_bin,2), k_emb))');
    mess_total = [mess_total compress_len_bin compress_bit refer_id_bin message Room_2];
else
    [huffman_rule,encode_label_map] = huffman_define(label_map,bit_len,EL_B);
    message = double(logical(pseudoGenerate(3*len_sum-length(huffman_rule)-length(encode_label_map)-size(refer_id_bin,2), k_emb))');
    mess_total = [mess_total huffman_rule encode_label_map refer_id_bin message Room_2];
end
ver2_int = [];
for i = 1:length(mess_total)/bit_len
    ver2_temp_bin = mess_total((i-1)*bit_len+1: i*bit_len);
    ver2_temp = BinaryConversion_2_10_1(ver2_temp_bin,bit_len);
    ver2_int = [ver2_int; ver2_temp];
end
for i = 1:length(mess_total)/bit_len/3
    vertex2(vertemb(i), 1) = ver2_int(3*(i-1)+1);
    vertex2(vertemb(i), 2) = ver2_int(3*(i-1)+2);
    vertex2(vertemb(i), 3) = ver2_int(3*(i-1)+3);
end 
end

