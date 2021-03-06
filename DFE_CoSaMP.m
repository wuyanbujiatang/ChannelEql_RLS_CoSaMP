function [ w,xEst,am_xEst,ee ] = DFE_CoSaMP( FrontOrder,BackOrder,dfeSend,dfeRecv,train_code_num )
%DFE_COSAMP 此处显示有关此函数的摘要
%   此处显示详细说明
N = length(dfeSend);%训练序列的长度
FrontCoeff = 0j*zeros(FrontOrder,1);%前馈滤波器的系数
BackCoeff= 0j*zeros(BackOrder,1);%后馈滤波器的系数
yFront = 0j*zeros(FrontOrder,1);%前向观测向量（由采样点或输入码元组成）
yBack = 0j*zeros(BackOrder,1);%后向观测向量（判决反馈均衡之后的反馈向量）
r = 0.998;%Kalman_RLS算法的遗忘因子
Ryy = (0j)*eye(FrontOrder+BackOrder);
Rdy = (0j)*zeros(FrontOrder+BackOrder,1);
ee = zeros(N-FrontOrder-BackOrder+1,1);%训练过程中的误差信号存储空间，可用来观察训练过程
xEst = zeros(N-FrontOrder+1,1);%判决反馈均衡后的（判决）信号存储空间
am_xEst = zeros(N-FrontOrder+1,1);%判决反馈均衡后的（未判决）信号存储空间
S = 6;
w = [FrontCoeff;BackCoeff];
for nn=FrontOrder+BackOrder:1:N %训练过程
    %更新前向观测向量
    yFront = dfeRecv(nn:-1:nn-FrontOrder+1);
    if(nn<=train_code_num)
        yBack = dfeSend(nn-FrontOrder:-1:nn-FrontOrder-BackOrder+1);
        Ryy = r*Ryy + [yFront;yBack]*([yFront;yBack])';
        Rdy = r*Rdy + [yFront;yBack]*conj(dfeSend(nn-FrontOrder+1));
        gradient = Rdy - Ryy*w;
        [~,pos]=sort(abs(gradient));
        Ohm = pos(end:-1:end-2*S+1);
        if(nn==FrontOrder+BackOrder)
            total_Ohm = Ohm;
        else
            total_Ohm = union(Ohm,supp);
        end
        alpha = (gradient(total_Ohm)).'*gradient(total_Ohm)/((gradient(total_Ohm)).'*Ryy(total_Ohm,total_Ohm)*gradient(total_Ohm));
        w(total_Ohm) = w(total_Ohm) + alpha*gradient(total_Ohm);
        [~,pos]=sort(abs(w));
        supp = pos(end:-1:end-S+1);
        w(setdiff((1:1:FrontOrder+BackOrder),supp)) = 0;
        sumFilter=w'*[yFront;yBack];
        am_xEst(nn-FrontOrder+1) = sumFilter;
        ee(nn-FrontOrder-BackOrder+1) = abs(dfeSend(nn-FrontOrder+1)-sumFilter);
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
        xEst(nn-FrontOrder+1) = sumFilter;
    else
        %更新后向观测向量
        for i=1:BackOrder-1
            yBack(BackOrder-i+1)=yBack(BackOrder-i);
        end
        yBack(1) = sumFilter;
        sumFilter=w'*[yFront;yBack];
        am_xEst(nn-FrontOrder+1) = sumFilter;
        ee(nn-FrontOrder-BackOrder+1) = abs(dfeSend(nn-FrontOrder+1)-sumFilter);
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
        xEst(nn-FrontOrder+1) = sumFilter;
    end
end
end

