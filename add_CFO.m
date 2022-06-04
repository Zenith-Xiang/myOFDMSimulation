%% 施加 CFO

function y_CFO = add_CFO(y, CFO, Nfft)

% y_CFO: 施加 CFO 之后的信号
% y: 接收信号
% CFO: 整数 CFO + 小数 CFO
% Nfft: fft 点数

n = 0:length(y)-1;
y_CFO = y.*exp(1j*2*pi*CFO*n/Nfft);

end