CFOs = 0.1:0.1:0.5;
SNRdBs = 0:3:30;
Nfft = 64;
Ng = Nfft/4;
Nbit = Nfft + Ng;
Nvc = 0;  % 虚拟载波个数
Nused = Nfft - Nvc;  % 实际使用的子载波数量，子载波总数等于 FFT 点数
Nbps = 2;
M = 2^Nbps;
norms = [1, sqrt(2), 0, sqrt(10), 0, sqrt(42)];  % BPSK, 4-QAM, 16-QAM, 64-QAM
N = Nfft;
com_delay = Nbit/2;
Nsym = 3;
MaxIter = 100;
LINESTYLE = ["o-", "d-", "^-", "p-", "x-"];

for i = 1:length(CFOs)
    CFO = CFOs(i);
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
        x_GI(kk4) = guard_interval(Ng, Nfft, 1, x);
        kk1 = kk1 + Nused;
        kk2 = kk2 + Nused;
        kk3 = kk3 + Nfft;
        kk4 = kk4 + Nbit;
    end

    y = x_GI;  % 无噪无损
    y_CFO = add_CFO(y, CFO, Nfft);
    MSE = zeros(1, length(SNRdBs));
    for j = 1:length(SNRdBs)
        SNRdB = SNRdBs(j);
        for iter = 1:MaxIter
            y_aw = awgn(y_CFO, SNRdB, 'measured');
            CFO_est = CFO_by_CP(y_aw, Nfft, Ng);
            MSE(j) = MSE(j) + (CFO_est - CFO)^2;
        end
    end
    MSE = MSE/MaxIter;

    semilogy(SNRdBs, MSE, LINESTYLE(i), 'LineWidth', 1.5);
    hold on; box on; grid on;
end
legend({'CFO$=0.1$', 'CFO$=0.2$', 'CFO$=0.3$', 'CFO$=0.4$', 'CFO$=0.5$'}, 'Interpreter', 'latex', 'FontSize', 14);
xlabel('SNR(dB)');
ylabel('Mean Squared Error');