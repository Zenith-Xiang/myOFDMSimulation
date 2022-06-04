%% 施加 STO

function y_STO = add_STO(y, nSTO)

% y_STO: 施加 STO 之后的信号
% y: 接收信号
% nSTO: STO 对应的采样数

if nSTO >= 0
    y_STO = [y(nSTO+1:end), zeros(1,nSTO)];  % 估计点滞后于精确点
else
    y_STO = [zeros(1,-nSTO), y(1:end+nSTO)];  % 估计点提前于精确点
end

end