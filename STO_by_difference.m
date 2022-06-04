%% 利用差值的基于 CP 的时域 STO 估计

function [STO_est, Mag] = STO_by_difference(y, Nfft, Ng, com_delay)

Nbit = Nfft + Ng;
minimum = 100;
STO_est = 0;
if nargin < 4
    com_delay = Nbit/2;
end
Mag = zeros(1,Nbit);
for n = 1:Nbit
    nn = n + com_delay + (0:Ng-1);
    tmp0 = abs(y(nn)) - abs(y(nn+Nfft));
    Mag(n) = tmp0 * tmp0';
    if Mag(n) < minimum
        minimum = Mag(n);
        STO_est = Nbit - com_delay - (n-1);
    end
end

end