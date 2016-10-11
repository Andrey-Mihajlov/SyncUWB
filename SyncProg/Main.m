clear
close all
clc

N_zeros = 10^3;
L_preamble = 10^3;
N_Data = 10^3;
Q = 10;
N0 = 2;
N_SNR = 15;
Zeros_arr  = zeros(1, N_zeros);
Preamble_arr  = ones(1, L_preamble);
N_Average = 1000;
SNR_arr = [0:15];
Error_Prob = zeros(1,size(SNR_arr,2));
Noise_signal = zeros(1,31000);
Receive_Sig = zeros(1,31000);
c1 = 0;

for SNR = SNR_arr
    for i_Average = 1 : N_Average
        Data_sum = 0;
        Data_rec_sum = 0;
        Data = unidrnd(2, 1, N_Data)-1;%������ ��������� ������
%         Data1 = Data*2 - 1;
%         Data1 = [Data1; Data1];
%         Data1 = [Data1; zeros(Q - N0, size(Data1, 2))];
        Packet_tmp = [Zeros_arr Preamble_arr Data];%������ �����
        Packet = [Packet_tmp; Packet_tmp];%2 ������
        Packet1 = [Packet; zeros(Q - N0, size(Packet, 2))];% +8 ����� �����

%         Noise_signal = [];
        Noise_signal = awgn(Packet1,SNR-10*log10(Q)+10*log10(N0),'measured');
%         Data_rec = Comparator(Noise_signal(1:2,:),1);
%         Receive_Sig = [];
        Receive_Sig = Receive(Noise_signal, Q,N_Data,L_preamble);

        Receive_Data = Receive_Sig(:,2001:end);
        Data_rec = Comparator(Receive_Data(1:2,:),1);
% subplot(3,1,1);plot(Noise_signal, '-c'); xlabel('Noise_signal');
% subplot(3,1,2);plot(Receive_Sig, '-b'); xlabel('Signal');
% subplot(3,1,3);plot(Signal1, '-k'); xlabel('s');

%         Data_rec_tmp = Receive_Sig(((N_zeros + L_preamble)*Q + 1) : (N_zeros + L_preamble)*Q + N_Data*Q);%����� ������ �� 10� ���������
%         Data_rec_tmp2 = reshape(Data_rec_tmp, Q, N_Data);%����������� ������� � ���� 10 � 1000
%         Data_rec = Data_rec_tmp2(1, :);%������ ������ ������

        [~, Error_Prob_tmp] = biterr(Data,  Data_rec);

        Error_Prob(SNR == SNR_arr) = Error_Prob(SNR == SNR_arr) + Error_Prob_tmp;
    end
end
Error_Prob = Error_Prob/N_Average;
save data

% load data
figure

% subplot(3,1,1);
semilogy(SNR_arr, Error_Prob, '-k'); ylabel('Error_Prob');xlabel('SNR');
grid on
% subplot(3,1,2);semilogy(1:15, Error_Prob(2, :), '-b'); ylabel('L=100');
% subplot(3,1,3);semilogy(1:15, Error_Prob(3, :), '-c'); ylabel('L=1000');
