function [rule,encode] = huffman_define(label_map,bit_len,EL_B)
frequency = zeros(1,bit_len-EL_B+1);
n = ceil(log2(bit_len-EL_B+2));
rule = [];
encode = [];
for i = 1:size(label_map,2)
    frequency(label_map(i)-EL_B+1) = frequency(label_map(i)-EL_B+1) + 1;
end
code = {[0 1],[1 0],[0 0 1],[1 1 0],[0 0 0 1],[1 1 1 0],[0 0 0 0 1],[1 1 1 1 0],[0 0 0 0 0 1],[1 1 1 1 1 0],[0 0 0 0 0 0 1],[1 1 1 1 1 1 0],[0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 0],[0 0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 1 0],[0 0 0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 1 1 0],[0 0 0 0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 1 1 1 0],[0 0 0 0 0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 1 1 1 1 0],[0 0 0 0 0 0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 1 1 1 1 1 0],[0 0 0 0 0 0 0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 1 1 1 1 1 1 0],[0 0 0 0 0 0 0 0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 1 1 1 1 1 1 1 0],[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0]};
[sorted_freqs, indices] = sort(frequency,'descend');

for i = 1:size(indices,2)
    if sorted_freqs(i) == 0
        rule = [rule BinaryConversion_10_2(0,n)];
        break;
    end
    bin = BinaryConversion_10_2(indices(i),n);
    rule = [rule bin];
    if i == size(indices,2)
        rule = [rule BinaryConversion_10_2(0,n)];
    end
end
for i = 1:size(label_map,2)
   index = label_map(i)-EL_B+1;
   for j = 1:size(indices,2)
       if index == indices(j)
           encode = [encode code{j}];
           break;
       end
   end
end