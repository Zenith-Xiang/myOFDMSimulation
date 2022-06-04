NgType = 1;  % CP
Nbps = 2;  % 1/2/4/6，BPSK/QPSK/16-QAM/64-QAM
M = 2^Nbps;  % 调制阶数，BPSK/QPSK/16-QAM/64-QAM
Nfft = 64;  % OFDM 有效数据符号长度
Ng = 16;  % GI 大小
Nbit = Nfft + Ng;  % OFDM 符号总长度
Nvc = Nfft/4;  % 虚拟载波个数
Nused = Nfft - Nvc;  % 实际使用的子载波数量，子载波总数等于 FFT 点数
EbN0 = 0:2:30;  % Eb/N0
N_iter = 1e5;  % 每一 Eb/N0 的迭代次数
Nsym = 2;  % 每一帧的符号数
norms = [1, sqrt(2), 0, sqrt(10), 0, sqrt(42)];  % BPSK, 4-QAM, 16-QAM, 64-QAM

X = randi([0, M-1], 1, Nused*Nsym);
Xmod = qammod(X, M, 'gray');
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

figure(1);
subplot(2,2,1);
scatter(real(Xmod), imag(Xmod), 20, 'red', 'filled');
box on; axis equal;
axis([-1.5,1.5,-1.5,1.5]);
title('(a) $\delta=0$', 'FontSize', 14, 'Interpreter', 'latex');
xlabel('Real', 'FontSize', 12);
ylabel('Imaginary', 'FontSize', 12);

y = x_GI;  % 忽略信道和噪声的影响
nSTO = -10;
y_GI = add_STO(y, nSTO);
kk1 = 1:Nbit;
kk2 = 1:Nfft;
kk3 = 1:Nused;
kk4 = (Nused/2+Nvc+1):Nfft;
kk5 = (Nvc~=0) + (1:Nused/2);
Y = zeros(1, Nfft*Nsym);
Xmod_r = zeros(1,Nused*Nsym);
for k = 1:Nsym
    Y(kk2) = fft(remove_GI(Ng, Nbit, y_GI(kk1)));
    Y_shift = [Y(kk4), Y(kk5)];
    Xmod_r(kk3) = Y_shift;
    kk1 = kk1 + Nbit;
    kk2 = kk2 + Nfft;
    kk3 = kk3 + Nused;
    kk4 = kk4 + Nfft;
    kk5 = kk5 + Nfft;
end
subplot(2,2,2);
scatter(real(Xmod_r), imag(Xmod_r), 20, 'red', 'filled');
box on; axis equal;
axis([-1.5,1.5,-1.5,1.5]);
title(['(b) $\varepsilon=$ $', num2str(nSTO), '$'], 'FontSize', 14, 'Interpreter', 'latex');
xlabel('Real', 'FontSize', 12);
ylabel('Imaginary', 'FontSize', 12);

nSTO = -20;
y_GI = add_STO(y, nSTO);
kk1 = 1:Nbit;
kk2 = 1:Nfft;
kk3 = 1:Nused;
kk4 = (Nused/2+Nvc+1):Nfft;
kk5 = (Nvc~=0) + (1:Nused/2);
Y = zeros(1, Nfft*Nsym);
Xmod_r = zeros(1,Nused*Nsym);
for k = 1:Nsym
    Y(kk2) = fft(remove_GI(Ng, Nbit, y_GI(kk1)));
    Y_shift = [Y(kk4), Y(kk5)];
    Xmod_r(kk3) = Y_shift;
    kk1 = kk1 + Nbit;
    kk2 = kk2 + Nfft;
    kk3 = kk3 + Nused;
    kk4 = kk4 + Nfft;
    kk5 = kk5 + Nfft;
end
subplot(2,2,3);
scatter(real(Xmod_r), imag(Xmod_r), 20, 'red', 'filled');
box on; axis equal;
axis([-1.5,1.5,-1.5,1.5]);
title(['(c) $\varepsilon=$ $', num2str(nSTO), '$'], 'FontSize', 14, 'Interpreter', 'latex');
xlabel('Real', 'FontSize', 12);
ylabel('Imaginary', 'FontSize', 12);

nSTO = 20;
y_GI = add_STO(y, nSTO);
kk1 = 1:Nbit;
kk2 = 1:Nfft;
kk3 = 1:Nused;
kk4 = (Nused/2+Nvc+1):Nfft;
kk5 = (Nvc~=0) + (1:Nused/2);
Y = zeros(1, Nfft*Nsym);
Xmod_r = zeros(1,Nused*Nsym);
for k = 1:Nsym
    Y(kk2) = fft(remove_GI(Ng, Nbit, y_GI(kk1)));
    Y_shift = [Y(kk4), Y(kk5)];
    Xmod_r(kk3) = Y_shift;
    kk1 = kk1 + Nbit;
    kk2 = kk2 + Nfft;
    kk3 = kk3 + Nused;
    kk4 = kk4 + Nfft;
    kk5 = kk5 + Nfft;
end
subplot(2,2,4);
scatter(real(Xmod_r), imag(Xmod_r), 20, 'red', 'filled');
box on; axis equal;
axis([-1.5,1.5,-1.5,1.5]);
title(['(d) $\varepsilon=$ $', num2str(nSTO), '$'], 'FontSize', 14, 'Interpreter', 'latex');
xlabel('Real', 'FontSize', 12);
ylabel('Imaginary', 'FontSize', 12);