clc
clear all
close all
%%
train_code_num = 500;
info_code_num = 5000;
code_num = train_code_num + info_code_num;
[ src_codes ] = bitsgen( code_num );
%%
anticausal_order = 20;
causal_order = 120;
SNR = 25;%dB
[ response_codes ] = channel( anticausal_order,causal_order,SNR,src_codes );
%%
FrontOrder = 50;
BackOrder = 150;
[w,xEst,am_xEst,ee] = DFE_CoSaMP( FrontOrder,BackOrder,src_codes,response_codes,train_code_num );
%%
len = length(xEst(train_code_num+1:end));
ber = length(find(src_codes(train_code_num+1:end-FrontOrder+1)~=xEst(train_code_num+1:end)))/len;
fprintf('ber=%f\n',ber)
%%
I = real(src_codes(train_code_num+1:end-FrontOrder+1));
Q = imag(src_codes(train_code_num+1:end-FrontOrder+1));
figure(1)
plot(I,Q,'ro')
axis([-2,2,-2,2])
I = real(response_codes(train_code_num+1:end-FrontOrder+1))/std(real(response_codes(train_code_num+1:end-FrontOrder+1)));
Q = imag(response_codes(train_code_num+1:end-FrontOrder+1))/std(imag(response_codes(train_code_num+1:end-FrontOrder+1)));
figure(2)
plot(I,Q,'ro')
axis([-4,4,-4,4])
I = real(am_xEst(train_code_num+1:end))/std(real(am_xEst(train_code_num+1:end)));
Q = imag(am_xEst(train_code_num+1:end))/std(imag(am_xEst(train_code_num+1:end)));
figure(3)
plot(I,Q,'ro')
axis([-2,2,-2,2])
figure(4)
stem(abs(w),'ro')
% axis([-1.5,1.5,-1.5,1.5])
figure(5)
plot(ee);
