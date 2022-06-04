%% 插入 GI

function y = guard_interval(Ng, Nfft, NgType, ofdmSym)

% Ng：保护间隔长度，以采样点为单位
% Nfft：fft 点数
% NgType：保护间隔类型，1 为 CP，2 为 ZP
% ofdmSym：插入 GI 前的 OFDM 符号，以采样点为单位

if NgType == 1
    y = [ofdmSym(Nfft-Ng+1:Nfft), ofdmSym(1:Nfft)];
elseif NgType == 2
    y = [zeros(1,Ng), ofdmSym(1:Nfft)];
end

end