function [vertex, vertex_tran, bit_len, EL_B, k1, k2, k3] = meshPrepro(m, vertex0)
% mesh preporcessing
vertex = vertex0;
minx_vertex = min(vertex(:,1));
miny_vertex = min(vertex(:,2));
minz_vertex = min(vertex(:,3));
vertex(:,1) = vertex(:,1) - minx_vertex;
vertex(:,2) = vertex(:,2) - miny_vertex;
vertex(:,3) = vertex(:,3) - minz_vertex;
vertex_tran = vertex;
max_vertex = max(max(vertex));
k_array = 0;
while max_vertex >= 1 
    vertex = vertex/10;
    max_vertex = max(max(vertex));
    k_array = k_array + 1;
end 
k1 = k_array;
k2 = k_array;
k3 = k_array;
magnify = 10^m;
vertex = vertex * magnify;
if(m>=10)
    vertex = uint64(vertex); bit_len = 64;
elseif(m<=2)
    vertex = uint8(vertex); bit_len = 8;
elseif(m<=4)
    vertex = uint16(vertex); bit_len = 16;
else
    vertex = uint32(vertex); bit_len = 32;
end
if m == 1
    EL_B = 4;
elseif m == 2
    EL_B = 1;
elseif m == 3
    EL_B = 6;
elseif m == 4
    EL_B = 2;
elseif m == 5
    EL_B = 15;
elseif m == 6
    EL_B = 12;
elseif m == 7
    EL_B = 8;
elseif m == 8
    EL_B = 5;
elseif m == 9
    EL_B = 2;
else
    disp("The value of m exceeds 9"); % The current experiment only considers m < 10
end
end