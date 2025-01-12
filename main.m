clear; clc; close all;
addpath(genpath(pwd));
m = 5; % Vertex information storage accuracy m
n = 4;
k_enc = 12345; % Encryption key
k_emb = 54321; % Data hiding key
coding_selection = 0; % Entropy coding selection : 0:Arithmetic Coding 1:Huffman Coding 

%% Read a 3D mesh file
tic;
name = "casting.off";
% [vertex, face] = read_ply("ply\" + name);
[vertex, face] = read_off("off\" + name);
vertex = vertex'; face = face'; % Comment out this line if you want to read the .PLY format 
vertex0 = vertex;
[num_vert,~] = size(vertex0);

%% Coordinate Transformation Process
magnify = 10^m;
% return 1.Processed integer coordinate values + 2.Non-negative coordinate values (Convenient comparison) + 3.length l in paper + 4.The number of unused bits in a binary coordinate value of length l + 5.The number of coordinate shifts
[vertex, vertex_tran, bit_len, EL_B, k1, k2, k3] =  meshPrepro(m, vertex0);

%% Dynamic Prediction、 Virtual Connection and Multi-MSB Prediction
% return 1.The set of embeddable bit lengths of vertices + 2.Embedding vertex sequences + 3.The sequence of vertices that are virtually connected
[label_map, vertemb, refer_id] = markEmbbed(vertex, face, bit_len, n);

%% Model Encryption
% return 1.The length of binary coordinates of all vertices + 2.Binary coordinates of all vertices（x,y,z,x,y,z...)
[meshlen, mesh_bin] = meshLength(vertex, bit_len);
% return 1.A fixed-length binary sequence randomly generated by an encryption key k_enc
sec_bin = logical(pseudoGenerate(meshlen, k_enc));
% return 1.Encrypted binary coordinate values
enc_bin = xor(mesh_bin, sec_bin);
% return 1.Encrypted integer coordinate value
vertex1 = meshGenerate(enc_bin, bit_len);

%% Entropy Coding、Auxiliary Information and Data Hiding
% return 1.Embeddable bit set + 2.Non-embeddable bit set
[Room_1, Room_2] = arrangeVertex(vertex1,label_map,vertemb,bit_len);
% return 1.Integer coordinate value after embedding data + 2.Embedded encrypted Data
[vertex2, message] = dataEmbed(vertex1,Room_2,label_map,bit_len,vertemb,refer_id,EL_B,coding_selection,k_emb);

%% Data Extraction and Model Recovery
% return 1.Recovered integer coordinate values + 2.Extracted encrypted data
[vertex3, extracted_message] = vertRecovery(vertex2,face,Room_2,bit_len,sec_bin,n,EL_B,coding_selection);
% Convert decimal coordinates to integer (Non-negative) coordinates
[vertex1_tran] = meshPrepro_re(m, vertex1, k1, k2, k3); % Encrypted
[vertex2_tran] = meshPrepro_re(m, vertex2, k1, k2, k3); % Marked
[vertex3_tran] = meshPrepro_re(m, vertex3, k1, k2, k3); % Restored
toc;

%% Experimental result
if message == extracted_message
    disp("The extracted data is correct!");
else
    disp("The extracted data is wrong!");
end

%Compute capacity
disp("The embedding capacity is "+ size(message,2)/num_vert  + " bpv");
% Compute HausdorffDist
hd = HausdorffDist(vertex_tran,vertex3_tran,1,0);
% Compute SNR
snr = meshSNR(vertex_tran,vertex3_tran);
fprintf('Hausdorff Distance is %e ; SNR is %f\n', hd, snr);

write_off("encrypted/" + name, vertex1_tran, face);
write_off("marked/" + name, vertex2_tran, face);
write_off("restored/" + name, vertex3_tran, face);
% write_ply(vertex1_tran, face, "encrypted/" + name);
% write_ply(vertex2_tran, face, "marked/" + name);
% write_ply(vertex3_tran, face, "restored/" + name);

