N = 8;  % N 点 FFT
d = randi([0,N-1],[1,N]);
sigTx = qammod(d,N);
% sigTx = ones(1,M);

% 发射端模拟一个模拟信号
tA = 10^(-4);  % 模拟信号的时间最小单位
Tsym = 1;  % 码元周期
t = 0:tA:Tsym;
fn = 0:1/Tsym:(N-1)/Tsym;  % 子载波频率

Xk = ifft(sigTx)*N;

xt = zeros(N+1,length(t));  % QAM-OFDM 调制后的模拟信号，1:N 行为各子载波子身信号，N+1 行为总和信号
figure('Name','QAM-OFDM');
subplot(2,1,1);
box on; hold on; grid on;
for i = 1:N
    xt(i,:) = real(sigTx(i))*cos(2*pi*fn(i)*t)+imag(sigTx(i))*sin(2*pi*fn(i)*t);
    plot(t,xt(i,:),'LineWidth',1);
end

xt(N+1,:) = sum(xt(1:N,:));
subplot(2,1,2);
box on; hold on; grid on;
plot(t,xt(N+1,:),'LineWidth',1.5);

% 接收端对这个模拟信号采样
M = 2*N;  % 采样点数
ts = Tsym/M;  % 采样间隔
Yk = xt(N+1,1:ts/tA:M*ts/tA);
yl = fft(Yk);
sigRx = conj(yl(1:N))/N;

% OFDM 信号的功率谱
xdft = fft(xt(N+1,:));  % fft 后对应的频率是 0:Fs/N:Fs
xshift = fftshift(xdft);  % 注意，这里一定要shift，不然和下面的频率对不上
psdx = (tA/length(t)) * abs(xshift).^2;
freq = -1/tA/2:1/tA/length(t):1/tA/2-1/tA/length(t);  % 将频率变为正常的 -Fs/2:Fs/N:Fs/2

figure('Name','PSD')
plot(freq,10*log10(psdx),'LineWidth',1.5)
grid on;
title('Periodogram Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')
axis([fn(end)*-1.5,fn(end)*1.5,-150,10]);