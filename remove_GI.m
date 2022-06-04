%% 去除 GI

function y = remove_GI(Ng, Lsym, ofdmSym)

% Ng：保护间隔长度，以采样点为单位
% Lsym：OFDM 符号总长度
% ofdmSym：插入 GI 后的 OFDM 符号，以采样点为单位

if Ng ~= 0
    y = ofdmSym(Ng+1:Lsym);
%     if NgType == 1
%         y = ofdmSym(Ng+1:Lsym);
%     elseif NgType == 2
%         y = ofdmSym(1:Lsym-Ng) + [ofdmSym(Lsym-Ng+1:Lsym), zeros(1,Lsym-2*Ng)];
%     end
else
    y = ofdmSym;
end

end