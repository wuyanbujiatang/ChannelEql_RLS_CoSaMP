function [ w,xEst,am_xEst,ee ] = DFE_CoSaMP( FrontOrder,BackOrder,dfeSend,dfeRecv,train_code_num )
%DFE_COSAMP �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
N = length(dfeSend);%ѵ�����еĳ���
FrontCoeff = 0j*zeros(FrontOrder,1);%ǰ���˲�����ϵ��
BackCoeff= 0j*zeros(BackOrder,1);%�����˲�����ϵ��
yFront = 0j*zeros(FrontOrder,1);%ǰ��۲��������ɲ������������Ԫ��ɣ�
yBack = 0j*zeros(BackOrder,1);%����۲��������о���������֮��ķ���������
r = 0.998;%Kalman_RLS�㷨����������
Ryy = (0j)*eye(FrontOrder+BackOrder);
Rdy = (0j)*zeros(FrontOrder+BackOrder,1);
ee = zeros(N-FrontOrder-BackOrder+1,1);%ѵ�������е�����źŴ洢�ռ䣬�������۲�ѵ������
xEst = zeros(N-FrontOrder+1,1);%�о����������ģ��о����źŴ洢�ռ�
am_xEst = zeros(N-FrontOrder+1,1);%�о����������ģ�δ�о����źŴ洢�ռ�
S = 6;
w = [FrontCoeff;BackCoeff];
for nn=FrontOrder+BackOrder:1:N %ѵ������
    %����ǰ��۲�����
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
        xEst(nn-FrontOrder+1) = sumFilter;
    else
        %���º���۲�����
        for i=1:BackOrder-1
            yBack(BackOrder-i+1)=yBack(BackOrder-i);
        end
        yBack(1) = sumFilter;
        sumFilter=w'*[yFront;yBack];
        am_xEst(nn-FrontOrder+1) = sumFilter;
        ee(nn-FrontOrder-BackOrder+1) = abs(dfeSend(nn-FrontOrder+1)-sumFilter);
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
        xEst(nn-FrontOrder+1) = sumFilter;
    end
end
end
