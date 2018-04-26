% function [ h,response_codes ] = channel( anticausal_order,causal_order,S_sparse,SNR,src_codes )
% %CHANNEL 此处显示有关此函数的摘要
% %   此处显示详细说明
% h_sparse=exp(1j*2*pi*rand(S_sparse,1));
% sparse_pos = randperm(anticausal_order+causal_order);
% sparse_pos = sparse_pos(1:S_sparse)';
% h = 0j*zeros(anticausal_order+causal_order,1);
% h(sparse_pos) = h_sparse;
% response_codes = conv(conj(h),src_codes);
% response_codes = response_codes(anticausal_order+1:end);
% [response_codes,~] = noisegen(response_codes,SNR);
% end
function [ response_codes ] = channel( anticausal_order,causal_order,SNR,src_codes )
%CHANNEL 此处显示有关此函数的摘要
%   此处显示详细说明;
h_front = 0j*zeros(anticausal_order,1);
h_back = 0j*zeros(causal_order,1);
h_front(anticausal_order) = 0.2+0j;
h_back(causal_order) = 0.7+0j;
h_back(1) = 1+0j;
h_back(5) = 0.02+0j;
h_back(20) = 0.2+0.5j;
h_back(50) = 0.5-0.5j;
% response_codes = filter(conj(h_back),1,src_codes);
response_codes = filter(conj(h_back),1,src_codes)+conj(h_front(anticausal_order))*[src_codes(anticausal_order+1:end);0j*zeros(anticausal_order,1)];
[response_codes,~] = noisegen(response_codes,SNR);
end

function [Y,NOISE] = noisegen(X,SNR)
NOISE = wgn( length(X),1,0,'complex');
NOISE = NOISE - mean(NOISE);
signal_power = 1/length(X)*(X*X');
noise_var = signal_power/(10^(SNR/10));
NOISE = sqrt(noise_var)/std(NOISE)*NOISE;
Y = X + NOISE; 
end

