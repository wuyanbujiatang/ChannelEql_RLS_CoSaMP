function [w,xEst,am_xEst,ee] = DFE_RLS( FrontOrder,BackOrder,dfeSend,dfeRecv,train_code_num )
%EQ �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
% DealyOrder = floor(FrontOrder/2);
DealyOrder = 0;
N = length(dfeSend);%ѵ�����еĳ���
FrontCoeff = 0j*zeros(FrontOrder,1);%ǰ���˲�����ϵ��
BackCoeff= 0j*zeros(BackOrder,1);%�����˲�����ϵ��
yFront = 0j*zeros(FrontOrder,1);%ǰ��۲��������ɲ������������Ԫ��ɣ�
yBack = 0j*zeros(BackOrder,1);%����۲��������о���������֮��ķ���������
r = 0.998;%Kalman_RLS�㷨����������
p = (1000+1000j)*eye(FrontOrder+BackOrder);%Kalman_RLS�㷨��Э����������
ee = zeros(N-FrontOrder+1,1);%ѵ�������е�����źŴ洢�ռ䣬�������۲�ѵ������
xEst = zeros(N-FrontOrder+1,1);%�о����������ģ��о����źŴ洢�ռ�
am_xEst = zeros(N-FrontOrder+1,1);%�о����������ģ�δ�о����źŴ洢�ռ�
for nn=1:1:N %ѵ������
% for nn=1:1:N+FrontOrder-1 %ѵ������
%     if nn<=N
    %����ǰ��۲�����
    for i=1:FrontOrder-1
        yFront(FrontOrder-i+1)=yFront(FrontOrder-i);
    end
    yFront(1) = dfeRecv(nn);
%     else
%         %����ǰ��۲�����
%         for i=1:FrontOrder-1
%             yFront(FrontOrder-i+1)=yFront(FrontOrder-i);
%         end
%         yFront(1) = 0+0j;
%     end
    if nn-FrontOrder>=0
        %ǰ��ͺ����˲�
        sumFilter=([FrontCoeff;BackCoeff])'*[yFront;yBack];
        e = dfeSend(nn-FrontOrder+1+DealyOrder)-sumFilter;%�������
        if(nn<=train_code_num)
            %Kalman_RLS�㷨�ļ������
            k = p*[yFront;yBack]/(r+([yFront;yBack])'*p*[yFront;yBack]);
            p = (p-k*([yFront;yBack])'*p)/r; 
            Wd = k*conj(e);
            FrontCoeff = FrontCoeff+Wd(1:length(FrontCoeff));%����ǰ���˲���ϵ��
            BackCoeff = BackCoeff+Wd(length(FrontCoeff)+1:length(Wd));%���º����˲���ϵ��
            am_xEst(nn-FrontOrder+1+DealyOrder) = sumFilter;
            sumFilter = dfeSend(nn-FrontOrder+1+DealyOrder);
        else
            am_xEst(nn-FrontOrder+1+DealyOrder) = sumFilter;
            %�о�
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
        %�洢����ź�
        ee(nn-FrontOrder+1) = abs(e);
        %���º���۲�����
        for i=1:BackOrder-1
            yBack(BackOrder-i+1)=yBack(BackOrder-i);
        end
        yBack(1) = sumFilter;
    end
end
w = ([FrontCoeff;BackCoeff])';
end

