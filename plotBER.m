% 运行 OFDM_basci.m 把 dat 文件都存好之后，再运行该文件画图

EbN0dB = 0:1:30;
M = 2^4;
ber_AWGN = ber_QAM(EbN0dB, M, 'AWGN');
ber_Rayleigh = ber_QAM(EbN0dB, M, 'Rayleigh');

semilogy(EbN0dB, ber_AWGN, 'r:','LineWidth',2);
hold on; grid on; box on;
semilogy(EbN0dB, ber_Rayleigh, 'r-','LineWidth',2);

AWGN0 = load('OFDM_BER_AWGN_CP_GL0.dat');
AWGN3 = load('OFDM_BER_AWGN_CP_GL3.dat');
AWGN15 = load('OFDM_BER_AWGN_CP_GL15.dat');

semilogy(AWGN0(:,1), AWGN0(:,2), '--o','LineWidth',1,'Color','#77AC30');
semilogy(AWGN3(:,1), AWGN3(:,2), 'm--^','LineWidth',1);
semilogy(AWGN15(:,1), AWGN15(:,2), 'b--s','LineWidth',1);

RL0 = load('OFDM_BER_RL_CP_GL0.dat');
RL3 = load('OFDM_BER_RL_CP_GL3.dat');
RL15 = load('OFDM_BER_RL_CP_GL15.dat');

semilogy(RL0(:,1), RL0(:,2), '--o','LineWidth',1,'Color','#77AC30');
semilogy(RL3(:,1), RL3(:,2), 'm--^','LineWidth',1);
semilogy(RL15(:,1), RL15(:,2), 'b--s','LineWidth',1);

legend('AWGN 理论', 'Rayleigh 理论', '保护间隔：0', '保护间隔：3', '保护间隔：15');
xlabel('Eb/N0(dB)');
ylabel('BER');
axis([-inf, inf, 1e-5, 1]);