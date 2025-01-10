function [vertex_tran] = meshPrepro_re(m, vertex, k1, k2, k3)
magnify = 10^m;
vertex_tran = double(vertex)/magnify;
vertex_tran(:,1) = vertex_tran(:,1)*(10^k1);
vertex_tran(:,2) = vertex_tran(:,2)*(10^k2);
vertex_tran(:,3) = vertex_tran(:,3)*(10^k3);
end