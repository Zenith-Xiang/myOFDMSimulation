%% 利用相关性的基于 CP 的时域 STO 估计

function [STO_est, Mag] = STO_by_correlation(y, Nfft, Ng, com_delay)

% STO_est: STO 的估计
% Mag: 相关函数的时变轨迹
% y: 包括 CP 的 OFDM 信号
% Ng: 保护间隔长度
% com_delay: 公共时延

Nbit = Nfft + Ng;
if nargin < 4
    com_delay = Nbit/2;
end
nn = 0:Ng-1;
yy = y(nn+com_delay)*y(nn+com_delay+Nfft)';
maximum = abs(yy);
Mag = zeros(1,Nbit);
for n = 1:Nbit
    n1 = n - 1;
    yy1 = y(n1+com_delay)*y(n1+com_delay+Nfft)';
    yy2 = y(n1+com_delay+Ng)*y(n1+com_delay+Nfft+Ng)';
    yy = yy - yy1 + yy2;
    Mag(n) = abs(yy);
    if (Mag(n) > maximum)
        maximum = Mag(n);
        STO_est = Nbit - com_delay - n1;
    end
end

end