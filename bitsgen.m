function [ out_codes ] = bitsgen( code_num )
%BITSGEN �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
%%%%%���������ݡ�%%%
bitstream_real=randi([0 1],code_num,1);
bitstream_imag=randi([0 1],code_num,1);
% out_codes = pskmod(bitstream,mod_order);
out_codes = (2*bitstream_real-1) + 1j*(2*bitstream_imag-1);
% out_codes = (2*bitstream_real-1);
end

