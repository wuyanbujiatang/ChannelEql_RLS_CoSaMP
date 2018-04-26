function [w,xEst,am_xEst,ee] = DFE_RLS( FrontOrder,BackOrder,dfeSend,dfeRecv,train_code_num )
%EQ 此处显示有关此函数的摘要
%   此处显示详细说明
% DealyOrder = floor(FrontOrder/2);
DealyOrder = 0;
N = length(dfeSend);%训练序列的长度
FrontCoeff = 0j*zeros(FrontOrder,1);%前馈滤波器的系数
BackCoeff= 0j*zeros(BackOrder,1);%后馈滤波器的系数
yFront = 0j*zeros(FrontOrder,1);%前向观测向量（由采样点或输入码元组成）
yBack = 0j*zeros(BackOrder,1);%后向观测向量（判决反馈均衡之后的反馈向量）
r = 0.998;%Kalman_RLS算法的遗忘因子
p = (1000+1000j)*eye(FrontOrder+BackOrder);%Kalman_RLS算法的协方差矩阵的逆
ee = zeros(N-FrontOrder+1,1);%训练过程中的误差信号存储空间，可用来观察训练过程
xEst = zeros(N-FrontOrder+1,1);%判决反馈均衡后的（判决）信号存储空间
am_xEst = zeros(N-FrontOrder+1,1);%判决反馈均衡后的（未判决）信号存储空间
for nn=1:1:N %训练过程
% for nn=1:1:N+FrontOrder-1 %训练过程
%     if nn<=N
    %更新前向观测向量
    for i=1:FrontOrder-1
        yFront(FrontOrder-i+1)=yFront(FrontOrder-i);
    end
    yFront(1) = dfeRecv(nn);
%     else
%         %更新前向观测向量
%         for i=1:FrontOrder-1
%             yFront(FrontOrder-i+1)=yFront(FrontOrder-i);
%         end
%         yFront(1) = 0+0j;
%     end
    if nn-FrontOrder>=0
        %前向和后向滤波
        sumFilter=([FrontCoeff;BackCoeff])'*[yFront;yBack];
        e = dfeSend(nn-FrontOrder+1+DealyOrder)-sumFilter;%计算误差
        if(nn<=train_code_num)
            %Kalman_RLS算法的计算过程
            k = p*[yFront;yBack]/(r+([yFront;yBack])'*p*[yFront;yBack]);
            p = (p-k*([yFront;yBack])'*p)/r; 
            Wd = k*conj(e);
            FrontCoeff = FrontCoeff+Wd(1:length(FrontCoeff));%更新前馈滤波器系数
            BackCoeff = BackCoeff+Wd(length(FrontCoeff)+1:length(Wd));%更新后馈滤波器系数
            am_xEst(nn-FrontOrder+1+DealyOrder) = sumFilter;
            sumFilter = dfeSend(nn-FrontOrder+1+DealyOrder);
        else
            am_xEst(nn-FrontOrder+1+DealyOrder) = sumFilter;
            %判决
            if real(sumFilter)>=0
                sumFilter_real = 1;
            else
                sumFilter_real = -1;
            end
            if imag(sumFilter)>=0
                sumFilter_imag = 1;
            else
                sumFilter_imag = -1;
            end
            sumFilter = sumFilter_real + 1j*sumFilter_imag;
        end
        xEst(nn-FrontOrder+1+DealyOrder) = sumFilter;
        %存储误差信号
        ee(nn-FrontOrder+1) = abs(e);
        %更新后向观测向量
        for i=1:BackOrder-1
            yBack(BackOrder-i+1)=yBack(BackOrder-i);
        end
        yBack(1) = sumFilter;
    end
end
w = ([FrontCoeff;BackCoeff])';
end

