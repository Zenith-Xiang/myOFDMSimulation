nSTOs = [-20, -20, 20, 20];
CFOs = [0, 0.5, 0, 2.5];
SNRdB = 20;
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
Nsym = 100;
for i = 1:length(nSTOs)
    nSTO = nSTOs(i);
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
    y_CFO_STO = add_STO(y_CFO, -nSTO);

    y_aw = awgn(y_CFO_STO, SNRdB, 'measured');
    [STO_cor, mag_cor] = STO_by_correlation(y_aw, Nfft, Ng, com_delay);
    [STO_dif, mag_dif] = STO_by_difference(y_aw, Nfft, Ng, com_delay);

    [Mag_cor_max, ind_max] = max(mag_cor);
    nc = ind_max - 1 - com_delay;
    [Mag_dif_min, ind_min] = min(mag_dif);
    nd = ind_min - 1 - com_delay;
    nn = -Nbit/2 + (0:Nbit-1);
    subplot(220 + i);
    title(['STO $=', num2str(nSTO), '$, CFO $=', num2str(CFO), '$'], 'FontSize', 14, 'Interpreter', 'latex');
    xlabel('Sample');
    ylabel('Magnitude');
    hold on; grid on; box on;
    plot(nn, mag_cor, 'b-', 'LineWidth', 1.5);
    stem(nc, mag_cor(ind_max), 'b');
    plot(nn, mag_dif, 'r--', 'LineWidth', 1.5);
    stem(nd, mag_dif(ind_min), 'r');
    stem(nSTO, 0, 'k.', 'MarkerSize', 15);  % 真实值
    legend({'Corr.', 'Max', 'Diff.', 'Min', 'Theo.'});
end