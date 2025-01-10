function [label_map,vertemb,refer_id] = markEmbbed(vertex, face, bit_len, n)
[num_face, ~] = size(face);
[num_vert,~] =size(vertex);
face = uint32(face);
Vert_num = uint32([]);
s_info = repmat(struct('id',[],'num',[],'ref',[],'status',[]),num_vert,1);
% Find all other vertices to which each vertex is connected
for j = 1:num_face
    v1 = face(j, 1);
    v2 = face(j, 2);
    v3 = face(j, 3);
    s_info(v1).ref = [s_info(v1).ref v2 v3];
    s_info(v2).ref = [s_info(v2).ref v1 v3];
    s_info(v3).ref = [s_info(v3).ref v1 v2];
end
for i = 1:num_vert
    s_info(i).id =i;
    if size(s_info(i).ref,2) ~= 0 
        s_info(i).ref = unique(s_info(i).ref);
    end
    [~,num] = size(s_info(i).ref);
    Vert_num = [Vert_num num];
    s_info(i).num = num;
    s_info(i).status = 0;
end

% Sort ascending
[~,ind] = sort([s_info.id],'ascend');
Vert_num = sort(Vert_num, 'descend');
new_info = s_info(ind);

% Divide all vertices
emb_vert = [];
noemb_vert = [];
ref_vert = [];
all_ref_noemb = [];
ref_vert_num = 0;
for i = 1:num_vert
    if new_info(i).num >= Vert_num(n) && ref_vert_num < n 
        ref_vert = [ref_vert new_info(i)];
        ref_vert_num = ref_vert_num + 1;
        new_info(i).status = 1;
        all_ref_noemb = [all_ref_noemb i];
    % Independent Vertex
    elseif new_info(i).num == 0
        noemb_vert = [noemb_vert new_info(i)];
        new_info(i).status = 1;
    else
        emb_vert = [emb_vert new_info(i)];
        new_info(i).status = 0;
        all_ref_noemb = [all_ref_noemb i];
    end
    new_info(i).ref = [];
    new_info(i).num = 0;
end
% Process all reference vertices first
for i = 1:n
    [~,num] = size(ref_vert(i).ref);
    refs = ref_vert(i).ref;
    for j = 1:num
        new_info(new_info(refs(j)).id).num = new_info(new_info(refs(j)).id).num + 1;
        new_info(new_info(refs(j)).id).ref = [new_info(new_info(refs(j)).id).ref ref_vert(i).id];
    end
end
% Then process all independent vertices
[~,num] = size(noemb_vert);
min_distance = 999999999999999;
refer_id = [];
for i = 1:num
    [~,num1] = size(all_ref_noemb);
    x = vertex(noemb_vert(i).id,1);
    y = vertex(noemb_vert(i).id,2);
    z = vertex(noemb_vert(i).id,3);
    for j = 1:num1
        x_ref = vertex(all_ref_noemb(j),1);
        y_ref = vertex(all_ref_noemb(j),2);
        z_ref = vertex(all_ref_noemb(j),3);
        distance = (x-x_ref)^2 + (y-y_ref)^2 + (z-z_ref)^2;
        if distance < min_distance
            referId = all_ref_noemb(j);
            min_distance = distance;
        end
    end
    refer_id = [refer_id referId];
    min_distance = 999999999999999;
    all_ref_noemb = [all_ref_noemb noemb_vert(i).id];
end


% Select the vertex id that connects the most vertices
max_num = 0;
[~,emb_num] = size(emb_vert);
for i = 1:emb_num
    ver_num = new_info(emb_vert(i).id).num;
    if ver_num > max_num
        max_num = ver_num;
    end
end
% Process all embedded vertices
emb_id = []; % An array of ids constructed in the order they are embedded
for i = 1:emb_num
   [~,num] = size(emb_vert);
   for j = 1:num
       ver_num = new_info(emb_vert(j).id).num;
       if ver_num == max_num
           if max_num ~= 0
               emb_id = [emb_id emb_vert(j).id];
           end
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
   % Select the vertex id that connects the most vertices
   for j = 1:num
       ver_num = new_info(emb_vert(j).id).num;
        if ver_num > max_num
            max_num = ver_num;
        end
   end
end
vertemb = emb_id;
% Calculate and record prediction error
[~,count]= size(emb_id);
label_map = [];
for v = 1:count
    refer_vex = new_info(emb_id(v)).ref;
    refer_vex = unique(refer_vex);
    [~,refer_num] = size(refer_vex);
    refer1 = 0;
    refer2 = 0;
    refer3 = 0;
    for j = 1:refer_num
        refer1 = refer1 + vertex(refer_vex(j),1);
        refer2 = refer2 + vertex(refer_vex(j),2);
        refer3 = refer3 + vertex(refer_vex(j),3);
    end
    refer1_average = refer1/refer_num;
    refer2_average = refer2/refer_num;
    refer3_average = refer3/refer_num;
    bin1 = uint32(dec2binPN( vertex(emb_id(v),1), bit_len)');
    bin2 = uint32(dec2binPN( vertex(emb_id(v),2), bit_len)');
    bin3 = uint32(dec2binPN( vertex(emb_id(v),3), bit_len)');
    
    refer_bin1 = uint32(dec2binPN(refer1_average, bit_len)');
    refer_bin2 = uint32(dec2binPN(refer2_average, bit_len)');
    refer_bin3 = uint32(dec2binPN(refer3_average, bit_len)');
    t1=0;   
    t2=0;
    t3=0;
    for k1 = 1:bit_len
        if bin1(k1) == refer_bin1(k1)
            t1 = k1;
        else
            break;
        end
    end
    for k2 = 1:bit_len
        if bin2(k2) == refer_bin2(k2)
            t2 = k2;
        else
            break;
        end
    end
    for k3 = 1:bit_len
        if bin3(k3) == refer_bin3(k3)
            t3 = k3;
        else
            break;
        end
    end
    t0 = [t1 t2 t3];
    t = min(t0);
    label_map = [label_map t];
end

% Predictions for independent vertices
[~,num] = size(noemb_vert);
for v = 1:num
    vertemb = [vertemb noemb_vert(v).id];
    refer1 = vertex(refer_id(v),1);
    refer2 = vertex(refer_id(v),2);
    refer3 = vertex(refer_id(v),3);
    bin1 = uint32(dec2binPN( vertex(noemb_vert(v).id,1), bit_len)');
    bin2 = uint32(dec2binPN( vertex(noemb_vert(v).id,2), bit_len)');
    bin3 = uint32(dec2binPN( vertex(noemb_vert(v).id,3), bit_len)');
    
    refer_bin1 = uint32(dec2binPN(refer1, bit_len)');
    refer_bin2 = uint32(dec2binPN(refer2, bit_len)');
    refer_bin3 = uint32(dec2binPN(refer3, bit_len)');
    t1=0;   
    t2=0;
    t3=0;
    for k1 = 1:bit_len
        if bin1(k1) == refer_bin1(k1)
            t1 = k1;
        else
            break;
        end
    end
    for k2 = 1:bit_len
        if bin2(k2) == refer_bin2(k2)
            t2 = k2;
        else
            break;
        end
    end
    for k3 = 1:bit_len
        if bin3(k3) == refer_bin3(k3)
            t3 = k3;
        else
            break;
        end
    end
    t0 = [t1 t2 t3];
    t = min(t0);
    label_map = [label_map t];
end   
end