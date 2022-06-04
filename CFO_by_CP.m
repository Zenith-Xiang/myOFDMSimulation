function CFO_est = CFO_by_CP(y, Nfft, Ng)
nn = 1:Ng;
CFO_est = angle(y(nn+Nfft)*y(nn)')/(2*pi);
end