function [vertex3,message] = vertRecovery(vertex2,face,Room_2,bit_len,sec_bin,n,EL_B,coding_selection)

[num_face, ~] = size(face);
[num_vert,~] =size(vertex2);
face = uint32(face);
Vert_num = uint32([]);
s_info = repmat(struct('id',[],'num',[],'ref',[],'status',[]),num_vert,1);

for j = 1:num_face
    v1 = face(j, 1);
    v2 = face(j, 2);
    v3 = face(j, 3);
    s_info(v1).ref = [s_info(v1).ref v2 v3];
    s_info(v2).ref = [s_info(v2).ref v1 v3];
    s_info(v3).ref = [s_info(v3).ref v1 v2];
end
noemb_id = [];
for i = 1:num_vert
    s_info(i).id =i;
    if size(s_info(i).ref,2) ~= 0 
        s_info(i).ref = unique(s_info(i).ref);
    end
    [~,num] = size(s_info(i).ref);
    Vert_num = [Vert_num num];
    s_info(i).num = num;
    s_info(i).status= 0;
    if num == 0
        noemb_id = [noemb_id i];
    end
end

[~,ind] = sort([s_info.id],'ascend');
Vert_num = sort(Vert_num, 'descend');
new_info = s_info(ind);

emb_vert = [];
noemb_vert = [];
ref_vert = [];
ref_vert_num = 0;
for i = 1:num_vert
    if new_info(i).num >= Vert_num(n) && ref_vert_num < n 
        ref_vert = [ref_vert new_info(i)];
        ref_vert_num = ref_vert_num + 1;
        new_info(i).status = 1;
    elseif new_info(i).num == 0
        noemb_vert = [noemb_vert new_info(i)];
        new_info(i).status = 1;
    else
        emb_vert = [emb_vert new_info(i)];
        new_info(i).status = 0;
    end
    new_info(i).ref = [];
    new_info(i).num = 0;
end
for i = 1:n
    [~,num] = size(ref_vert(i).ref);
    refs = ref_vert(i).ref;
    for j = 1:num
        new_info(new_info(refs(j)).id).num = new_info(new_info(refs(j)).id).num + 1;
        new_info(new_info(refs(j)).id).ref = [new_info(new_info(refs(j)).id).ref ref_vert(i).id];
    end
end

max_num = 0;
[~,emb_num] = size(emb_vert);
for i = 1:emb_num
    ver_num = new_info(emb_vert(i).id).num;
    if ver_num > max_num
        max_num = ver_num;
    end
end
emb_id = []; 
for i = 1:emb_num
   [~,num] = size(emb_vert);
   for j = 1:num
       ver_num = new_info(emb_vert(j).id).num;
       if ver_num == max_num
           emb_id = [emb_id emb_vert(j).id];
           refs = emb_vert(j).ref;
           [~,num1] = size(refs);
           for z = 1:num1
               if new_info(refs(z)).status == 0
                   new_info(refs(z)).ref = [new_info(refs(z)).ref emb_vert(j).id];
                   new_info(refs(z)).num = new_info(refs(z)).num + 1;
               end
           end
           new_info(emb_vert(j).id).status = 1;
           emb_vert = [emb_vert(1:j-1) emb_vert(j+1:num)];
           break;
       end
   end
   [~,num] = size(emb_vert);
   max_num = 0;
   for j = 1:num
       ver_num = new_info(emb_vert(j).id).num;
        if ver_num > max_num
            max_num = ver_num;
        end
   end
end
Vertemb = emb_id;
%% 
ver_bin = [];
Vertemb = [Vertemb noemb_id]; 
[~, num_vertemb] = size(Vertemb); 
for m = 1:num_vertemb
    ver_1 = uint32(dec2binPN(vertex2(Vertemb(m),1), bit_len)');
    ver_2 = uint32(dec2binPN(vertex2(Vertemb(m),2), bit_len)');
    ver_3 = uint32(dec2binPN(vertex2(Vertemb(m),3), bit_len)');
    ver_bin = [ver_bin ver_1 ver_2 ver_3];
    ver_bin = double(ver_bin);
end
if coding_selection == 0
    [label_map, aux_len] = arith_recover(ver_bin, num_vert);
else
    [label_map, aux_len] = huffman_recover(ver_bin,num_vertemb,bit_len,EL_B);
end

refer_id_bin_len = ceil(log2(num_vert))*size(noemb_id,2);
refer_id_bin = ver_bin(aux_len+1:aux_len+refer_id_bin_len);
refer_id = [];
for i = 1:size(noemb_id,2)
    lindex = (i-1)*ceil(log2(num_vert))+1;
    rindex = i*ceil(log2(num_vert));
    id = BinaryConversion_2_10_int(refer_id_bin(lindex:rindex));
    refer_id = [refer_id id];
end

c = 3*sum(label_map)-aux_len-refer_id_bin_len;
message = ver_bin(aux_len+refer_id_bin_len+1:aux_len+refer_id_bin_len+c);
len_Room_1 = length(ver_bin)- length(Room_2);
Room_1 = ver_bin(1:len_Room_1);
g = 0;
v_emb = cell(3,num_vertemb);

for v = 1:num_vertemb
        mid_vert = Room_2(g+1:g+3*(bit_len-label_map(v)));
        v_emb{1,v} =[Room_1(1:label_map(v)) mid_vert(1:(bit_len-label_map(v)))];
        v_1 = BinaryConversion_2_10_1(v_emb{1,v},bit_len);
        v_emb{2,v} =[Room_1(label_map(v)+1:2*label_map(v)) mid_vert((bit_len-label_map(v))+1:2*(bit_len-label_map(v)))];
        v_2 = BinaryConversion_2_10_1(v_emb{2,v},bit_len);
        v_emb{3,v} =[Room_1(2*label_map(v)+1:3*label_map(v)) mid_vert(2*(bit_len-label_map(v))+1:3*(bit_len-label_map(v)))];
        v_3 = BinaryConversion_2_10_1(v_emb{3,v},bit_len);
        g = g + 3*(bit_len-label_map(v));
        vertex2(Vertemb(v),1) = v_1;
        vertex2(Vertemb(v),2) = v_2;
        vertex2(Vertemb(v),3) = v_3;  
end
[meshlen, nodec_bin] = meshLength(vertex2, bit_len);
dec_bin = double(xor(nodec_bin, sec_bin))';
ver2_int = [];
for u = 1:length(dec_bin)/bit_len
    ver2_temp_bin = dec_bin((u-1)*bit_len+1: u*bit_len);
    ver2_temp = BinaryConversion_2_10_1(ver2_temp_bin,bit_len);
    ver2_int = [ver2_int; ver2_temp];
end
v_em = cell(3,num_vertemb);
for o = 1:length(dec_bin)/bit_len/3
    vertex2(o, 1) = ver2_int(3*(o-1)+1);
    vertex2(o, 2) = ver2_int(3*(o-1)+2);
    vertex2(o, 3) = ver2_int(3*(o-1)+3);
end 
q = 0;
for v = 1:num_vertemb
        refer_vex = [];
        if v > num_vertemb-size(refer_id,2)
            refer_vex = [refer_vex refer_id(v-(num_vertemb-size(refer_id,2)))];
        else
            refer_vex = new_info(Vertemb(v)).ref;
        end
        refer_vex = unique(refer_vex);
        [~,refer_num] = size(refer_vex);
        refer1 = 0;
        refer2 = 0;
        refer3 = 0;
        for j = 1:refer_num
            refer1 = refer1 + vertex2(refer_vex(j),1);
            refer2 = refer2 + vertex2(refer_vex(j),2);
            refer3 = refer3 + vertex2(refer_vex(j),3);
        end
        refer1_average = refer1/refer_num;
        refer2_average = refer2/refer_num;
        refer3_average = refer3/refer_num;
        refer_bin1 = uint32(dec2binPN(refer1_average, bit_len)');
        refer_bin2 = uint32(dec2binPN(refer2_average, bit_len)');
        refer_bin3 = uint32(dec2binPN(refer3_average, bit_len)');
        
        refer_1 = refer_bin1(1:label_map(v));
        refer_2 = refer_bin2(1:label_map(v));
        refer_3 = refer_bin3(1:label_map(v));
        v_em{1,v} = uint32(dec2binPN(vertex2(Vertemb(v),1),bit_len)');
        v_em{1,v}(1:label_map(v)) = refer_1;
        v1 = BinaryConversion_2_10_1(v_em{1,v},bit_len);
        v_em{2,v} = uint32(dec2binPN(vertex2(Vertemb(v),2),bit_len)');
        v_em{2,v}(1:label_map(v)) = refer_2;
        v2 = BinaryConversion_2_10_1(v_em{2,v},bit_len);
        v_em{3,v} = uint32(dec2binPN(vertex2(Vertemb(v),3),bit_len)');
        v_em{3,v}(1:label_map(v)) = refer_3;
        v3 = BinaryConversion_2_10_1(v_em{3,v},bit_len);
         q = q + 3*(32-label_map(v));
        vertex2(Vertemb(v),1) = v1;
        vertex2(Vertemb(v),2) = v2;
        vertex2(Vertemb(v),3) = v3; 
end
        vertex3 = vertex2; 
end

