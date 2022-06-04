function plot_ber(file_name, Nbps)
EbN0dB = 0:1:30;
M = 2^Nbps;
ber_AWGN = ber_QAM(EbN0dB, M, 'AWGN');
ber_Rayleigh = ber_QAM(EbN0dB, M, 'Rayleigh');
semilogy(EbN0dB, ber_AWGN, 'r:','LineWidth',1.5);
hold on; grid on; box on;
semilogy(EbN0dB, ber_Rayleigh, 'r-','LineWidth',1.5);
a = load(file_name);
semilogy(a(:,1), a(:,2), 'b--s','LineWidth',1.5);
legend('AWGN analytic', 'Rayleigh fading analytic', 'Simulation');
xlabel('EbN0[dB]');
ylabel('BER');
axis([a(1,1), a(end,1), 1e-5, 1]);
end