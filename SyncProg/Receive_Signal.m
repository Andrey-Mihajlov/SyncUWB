function s = Receive_Signal(Noise_signal_input, Q)
% ������������ ����� ������� (Signal) � ������� ��� (s)
% ����� �������, �� �� �������� ���������, � �������������, ��� ��������� 
% � Search_Impuls

    flag = 0;
    N=0;
    data_N = 10^4;
    
    Compare_signal = Comparator(Noise_signal_input,0);
    preamble_length = size(Compare_signal,1)*size(Compare_signal,2) - data_N*2 - N;
    count_impuls = 1;
    start_data = 0;
    arr_strt_impuls = zeros(1,10);
    count = 0;
    mode = 0;
    flag_impuls = 0;
    Flag_count = 0;
    size_of_signal = size(Noise_signal_input, 2);
    s = zeros(size(Compare_signal,1),size(Compare_signal,2));

%     Compare_signal = reshape(Compare_signal, 1, size(Compare_signal, 1)*size(Compare_signal, 2));
    Sum = [];
    Point = [];
    c = 1;
    for i = 1:size(Compare_signal,1)
        Sum(i) = 2*sum(Compare_signal(i,:))/size(Compare_signal,2);
        if Sum(i) >= 0.7
            Point(c) = i;
            c = c + 1;
        end
    end
    c = c - 1;
    signal1 = Comparator(Compare_signal(Point,:),1);
%     Compare_signal = reshape(Compare_signal, 1, size(Compare_signal, 1)*size(Compare_signal, 2));
%     Compare_signal = [Compare_signal zeros(1,N)];%+1� �����
    for x = 1:size(s, 1)*size(s, 2)-data_N
        if (flag == 0)&&(Flag_count <= preamble_length/20)
            if count < 3
                count=count+1;
                s(x) = Compare_signal(x);
            else if count == 3% ���������� ������ 4 ��� � ��������� �������� 3
                    count=0;
                    s(x) = 0;
                    [strt, flag, flag_impuls] = Search_Impuls(s, x, mode, 0);
                end
            end
        else if (flag == 0)&&(Flag_count > preamble_length/20) %����������� ���������
                mode = 1;
                s(x) = Compare_signal(x);
                [strt, flag, flag_impuls] = Search_Impuls(s, x, mode, flag_impuls);
                if start_data == 0%�������� ���������� ��������� � ����� ���������
                    for count_impuls = 4:10
                        if (arr_strt_impuls(count_impuls)-arr_strt_impuls(count_impuls - 1)) == 2*Q
                            if (arr_strt_impuls(count_impuls - 1)-arr_strt_impuls(count_impuls - 2)) == 2*Q
                                if (arr_strt_impuls(count_impuls - 2)-arr_strt_impuls(count_impuls - 3)) == 2*Q
                                    start_data = arr_strt_impuls(count_impuls);
                                    break;
                                end
                            end
                        end
                    end
                end
                % ������� ��������� ������ ������
                if (strt > size(Compare_signal, 2) - data_N-10 - N)&&(strt < size(Compare_signal, 2) - data_N - N)
                    if (mod((strt - start_data),Q) == 0)||(mod(strt,Q) == Point(1))
                        start_data = strt+Q;
                        else %if mod(round((strt - start_data)/Q)*Q,Q) == 0
                            start_data = start_data + round((strt - start_data)/Q)*Q+Q+1;
                        %end
                    end
                    s(1,size(Compare_signal, 2)+1 - data_N - N:end) = Receive_Data(Compare_signal,start_data,Q);%������ ������
                    break;
                else if (strt > size(Compare_signal, 2) - data_N-10 - N)&&(mod(strt,Q) == Point(1))
                        start_data = strt+Q;
                    end
                end
           % ��������� �������� � ��������
            else if flag == 1% ����� �������
                     if x == strt + Q% ���� ������� ������� �� ������� � ������ �������� Q
                        s(x) = Compare_signal(x); % ��������� �������
                     else if x == strt + Q + 1% ���������� ��������� �������
                             s(x) = Compare_signal(x);
                             Flag_count = Flag_count + 1;
                             flag = 0;
                             % ���������� � ������ ��������� �� �������
                             % ���������
                             if (Flag_count >  preamble_length/20-10)&&(Flag_count <=  preamble_length/20)
                                 arr_strt_impuls(count_impuls) = x-1;
                                 count_impuls = count_impuls + 1;
                             end
                         end
                     end
                     if mode == 1
                         flag = 0;
                     end
                end
            end
        end
    end



%     subplot(3,1,1);plot(Noise_signal_input, '-c'); xlabel('Noise_signal');
%     subplot(3,1,2);plot(Compare_signal, '-b'); xlabel('Signal');
%     subplot(3,1,3);plot(s, '-k'); xlabel('s');

%�� ����� Receive
%             if (strt > size(Compare_signal,1)*size(Compare_signal,2)-Q*N_data-Q)&&...
%                (strt < size(Compare_signal,1)*size(Compare_signal,2)-Q*N_data)
%                 if (mod((strt - start_data),Q) == 0)||(mod(strt,Q) == Point(1))
%                     start_data = strt+Q;
%                 else 
%                     if (strt > size(Compare_signal,1)*size(Compare_signal,2)-Q*N_data-Q/2)
%                         start_data = start_data + round((strt - start_data)/Q)*Q+1;
%                     else
%                         start_data = start_data + round((strt - start_data)/Q)*Q+Q+1;
%                     end
%                 end
%             else if (strt > size(Compare_signal,1)*size(Compare_signal,2)-Q*N_data-Q)&&(mod(strt,Q) == Point(1))
%                     if (strt > size(Compare_signal,1)*size(Compare_signal,2)-Q*N_data+Q)
%                         start_data = strt-Q;
%                     else
%                         start_data = strt;
%                     end
%                 else if (strt > size(Compare_signal,1)*size(Compare_signal,2)-Q*N_data-Q)&&(mod(strt,Q) == Point(2))
%                         if (strt > size(Compare_signal,1)*size(Compare_signal,2)-Q*N_data+Q)
%                             start_data = strt-Q-1;
%                         else
%                             start_data = strt-1;
%                         end
%                     else
%                         if (strt > size(Compare_signal,1)*size(Compare_signal,2)-Q*N_data-1)
%                             factor = strt - size(Compare_signal,1)*size(Compare_signal,2)+Q*N_data;
%                             factor = round(factor/Q);
%                             start_data = start_data + round((strt - start_data)/Q)*Q-factor*Q+1;
%                         else
%                             start_data = start_data + round((strt - start_data)/Q)*Q+1;
%                         end
%                     end
%                 end

end



