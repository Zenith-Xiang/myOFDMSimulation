NgType = 2;  % 保护间隔类型
if NgType == 1
    nt = 'CP';
elseif NgType == 2
    nt = 'ZP';
end

Ch = 1;  % 信道类型，Ch=0 为 AWGN，Ch=1 为 Rayleigh，
if Ch == 0
    chType = 'AWGN';
    Target_neb = 100;  % 目标错误比特数
else
    chType = 'RL';
    Target_neb = 500;
end
figure(Ch+1);
PowerdB = [0, -8, -17, -21, -25];  % 信道抽头功率
Power = 10.^(PowerdB/10);
Ntap = length(Power);  % 信道抽头数
Delay = [0, 3, 5, 6, 8];  % 信道时延，以采样点为单位
Lch = Delay(end) + 1;  % 信道长度

Nbps = 4;  % 1/2/4/6
M = 2^Nbps;  % 调制阶数，BPSK/QPSK/16-QAM/64-QAM
Nfft = 64;  % OFDM 有效数据符号长度
Ng = 16;  % GI 大小
Nbit = Nfft + Ng;  % OFDM 符号总长度
Nvc = Nfft/4;  % 虚拟载波个数
Nused = Nfft - Nvc;  % 实际使用的子载波数量，子载波总数等于 FFT 点数
EbN0 = 0:2:30;  % Eb/N0
N_iter = 1e5;  % 每一 Eb/N0 的迭代次数
Nsym = 3;  % 每一帧的符号数
sigPow = 0;  % 初始信号功率(dB)
file_name = ['OFDM_BER_', chType, '_', nt, '_GL', num2str(Ng), '.dat'];
fid = fopen(file_name, 'w+');
norms = [1, sqrt(2), 0, sqrt(10), 0, sqrt(42)];  % BPSK, 4-QAM, 16-QAM, 64-QAM
for i = 0:length(EbN0)
    Neb = 0;  % 错误比特数
    Ntb = 0;  % 总比特数
    for m = 1:N_iter
        % Tx------------------------------------------------------------
        X = randi([0, M-1], 1, Nused*Nsym);  % 为每一个符号里的每一个子载波都随机设置一个调制符号
        Xmod = qammod(X, M, 'gray')/norms(Nbps);  % 归一化 QAM 调制
        x_GI = zeros(1, Nsym*Nbit);  % 每一帧的总 bit 数（已算上了 GI）
        kk1 = 1:Nused/2;  % 前一半子载波
        kk2 = Nused/2+1:Nused;  % 后一半子载波
        kk3 = 1:Nfft;  % 控制循环的 FFT 位置
        kk4 = 1:Nbit;  % 控制循环的符号位置
        for k = 1:Nsym
            if Nvc == 0
                X_shift = [Xmod(kk2), Xmod(kk1)];  % 所有的子载波都使用
            else
                X_shift = [0, Xmod(kk2), zeros(1,Nvc-1), Xmod(kk1)];  % 使用部分子载波
            end
            x = ifft(X_shift);
            x_GI(kk4) = guard_interval(Ng, Nfft, NgType, x);
            kk1 = kk1 + Nused;
            kk2 = kk2 + Nused;
            kk3 = kk3 + Nfft;
            kk4 = kk4 + Nbit;
        end

        % Channel-------------------------------------------------------
        if Ch == 0  % AWGN 信道
            y = x_GI;
        else  % Rayleigh 信道
            channel = (randn(1,Ntap) + 1j*randn(1, Ntap)).*sqrt(Power/2);
            h = zeros(1,Lch);  % 信道脉冲响应
            h(Delay+1) = channel;
            y = conv(x_GI, h);
        end
        if i == 0  % 只测量信号功率
            y1 = y(1:Nsym*Nbit);
            sigPow = sigPow + y1*y1';
            continue;
        end
        
        % AWGN----------------------------------------------------------
        snr = EbN0(i) + 10*log10(Nbps*Nused/Nfft);  % 时域信噪比 snr 与频域信噪比 Eb/N0 的关系
        noise_mag = sqrt((10^(-snr/10))*sigPow/2);  % 噪声幅度
        y_GI = y + noise_mag*(randn(size(y)) + 1j*randn(size(y)));

        % Rx------------------------------------------------------------
        kk1 = 1:Nbit;
        kk2 = 1:Nfft;
        kk3 = 1:Nused;
        kk4 = (Nused/2+Nvc+1):Nfft;
        kk5 = (Nvc~=0) + (1:Nused/2);
        if Ch == 1
            H = fft([h, zeros(1,Nfft-Lch)]);  % 信道频率响应
            H_shift = zeros(1, Nused);
            H_shift(kk3) = [H(kk4), H(kk5)];
        end
        Y = zeros(1, Nfft*Nsym);
        Xmod_r = zeros(1,Nused*Nsym);
        for k = 1:Nsym
            Y(kk2) = fft(remove_GI(Ng, Nbit, y_GI(kk1)));
            Y_shift = [Y(kk4), Y(kk5)];
            if Ch == 0
                Xmod_r(kk3) = Y_shift;
            else
                Xmod_r(kk3) = Y_shift./H_shift;
            end
            kk1 = kk1 + Nbit;
            kk2 = kk2 + Nfft;
            kk3 = kk3 + Nused;
            kk4 = kk4 + Nfft;
            kk5 = kk5 + Nfft;
        end
        X_r = qamdemod(Xmod_r*norms(Nbps),M,'gray');
        Neb = Neb + sum(int2bit(X_r,Nbps)~=int2bit(X,Nbps), 'all');
        Ntb = Ntb + Nused*Nsym*Nbps;
        if Neb > Target_neb
            break;
        end
    end
    if i == 0
        sigPow = sigPow/Nbit/Nsym/N_iter;
    else
        Ber = Neb/Ntb;
%         fprintf('Eb/N0=%3d[dB], BER=%4d/%8d=%11.3e\n',EbN0(i), Neb, Ntb, Ber);
        fprintf(fid, '%d\t%.3e\n', EbN0(i), Ber);
        if Ber < 1e-6
            break;
        end
    end
end
if fid ~= 0
    fclose(fid);
end
disp('Simulation is finished');
plot_ber(file_name, Nbps);