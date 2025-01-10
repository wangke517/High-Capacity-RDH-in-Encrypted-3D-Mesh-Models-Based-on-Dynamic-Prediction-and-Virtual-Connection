function [label_map,aux_len] = huffman_recover(ver_bin,num_vertemb,bit_len,EL_B)
huffman_rule = [];
label_map = [];
aux_len = 0;
code = {[0 1],[1 0],[0 0 1],[1 1 0],[0 0 0 1],[1 1 1 0],[0 0 0 0 1],[1 1 1 1 0],[0 0 0 0 0 1],[1 1 1 1 1 0],[0 0 0 0 0 0 1],[1 1 1 1 1 1 0],[0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 0],[0 0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 1 0],[0 0 0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 1 1 0],[0 0 0 0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 1 1 1 0],[0 0 0 0 0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 1 1 1 1 0],[0 0 0 0 0 0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 1 1 1 1 1 0],[0 0 0 0 0 0 0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 1 1 1 1 1 1 0],[0 0 0 0 0 0 0 0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 1 1 1 1 1 1 1 0],[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1],[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0]};
n = ceil(log2(bit_len-EL_B+2));
for i = 1:ceil(size(ver_bin,2)/n)
    aux_len = aux_len + n;
    bin = ver_bin((i-1)*n+1:i*n);
    dec = BinaryConversion_2_10_1(bin,n);
    if dec == 0
        ver_bin = ver_bin(i*n+1:length(ver_bin));
        break;
    end
    huffman_rule = [huffman_rule dec];
end
for i = 1:num_vertemb
    s_code = [];
    s_code = [s_code ver_bin(1)];
    for j = 2:length(ver_bin)
        s_code = [s_code ver_bin(j)];
        if ver_bin(1) == 1 && ver_bin(j) == 0
            ver_bin = ver_bin(j+1:length(ver_bin));
            break;
        end
        if ver_bin(1) == 0 && ver_bin(j) == 1
            ver_bin = ver_bin(j+1:length(ver_bin));
            break;
        end
    end
    aux_len = aux_len + length(s_code);
    for j = 1:size(code,2)
       if size(code{j},2)==size(s_code,2)
           if code{j} == s_code
               label_map = [label_map EL_B+huffman_rule(j)-1];
               break;
           end
       end
    end
end
end

