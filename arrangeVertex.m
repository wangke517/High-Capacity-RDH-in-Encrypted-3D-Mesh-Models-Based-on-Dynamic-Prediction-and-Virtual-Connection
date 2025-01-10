function [Room_1,Room_2] = arrangeVertex(vertex1,label_map,vertemb,bit_len)
    [~,count] = size(vertemb);
    Room_1 = [];
    Room_2 = [];
    for v = 1:count
        bin1 = uint32(dec2binPN(vertex1(vertemb(v),1), bit_len)');
        bin_1 = bin1(1:label_map(v));
        bin_1_1 = bin1(label_map(v)+1:end);
        bin2 = uint32(dec2binPN(vertex1(vertemb(v),2), bit_len)');
        bin_2= bin2(1:label_map(v));
        bin_2_2 = bin2(label_map(v)+1:end);
        bin3 = uint32(dec2binPN(vertex1(vertemb(v),3), bit_len)');
        bin_3 = bin3(1:label_map(v));
        bin_3_3 = bin3(label_map(v)+1:end);
        Room_1 = [Room_1 bin_1 bin_2 bin_3];  
        Room_2 = [Room_2 bin_1_1 bin_2_2 bin_3_3];
    end
end

