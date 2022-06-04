%channel_estimation.m
% for LS/DFT Channel Estimation with linear/spline interpolation

Nfft = 32; 
Ng = Nfft/8;  
Nbit = Nfft + Ng;
Nsym = 100;
Nps = 4;  % Pilot spacing 
Np = Nfft/Nps;  % Numbers of pilots and data per OFDM symbol
Nbps = 4; 
M = 2^Nbps;  % Number of bits per (modulated) symbol
norms = [1, sqrt(2), 0, sqrt(10), 0, sqrt(42)];  % BPSK, 4-QAM, 16-QAM, 64-QAM
SNRs = 0:5:30;
MSEs = zeros(length(SNRs), 6);
for i = 1:length(SNRs)
   SNR = SNRs(i); 
   MSE = zeros(1, 6); 
   nose = 0;
   for nsym = 1:Nsym
      
      % Tx----------------------------------------------------------------------
      Xp = 2*(randn(1,Np)>0)-1;  % Pilot sequence generation
      msgint = randi([0, M-1], 1, Nfft-Np);  % bit generation
      Data = qammod(msgint, M, 'gray')/norms(Nbps);  % modulated data
      ip = 0;    
      X = zeros(1, Nfft);
      pilot_loc = zeros(1, Np);  % pilot location
      for k=1:Nfft
         if mod(k,Nps)==1
            X(k) = Xp(ceil(k/Nps)); 
            pilot_loc(ceil(k/Nps)) = k; 
            ip = ip+1;
         else
             X(k) = Data(k-ip);
         end
      end
      x = ifft(X,Nfft);  % IFFT
      xt = [x(Nfft-Ng+1:Nfft), x];  % Add CP
      
      % Channel-----------------------------------------------------------------
      h = [(randn+1j*randn), (randn+1j*randn)/2];  % generates a (2-tap) channel
      H = fft(h, Nfft);
      channel_length = length(h); % True channel and its time-domain length
      H_power_dB = 10*log10(abs(H.*conj(H)));  % True channel power in dB
      y_channel = conv(xt, h);  % Channel path (convolution)
      %sig_pow = mean(y_channel.*conj(y_channel));
      yt = awgn(y_channel, SNR, 'measured');
      
      % Rx----------------------------------------------------------------------
      y = yt(Ng+1:Nbit);  % Remove CP
      Y = fft(y);  % FFT
      for m = 1:3
         if m == 1
             H_est = LS_CE(Y, Xp, pilot_loc, Nfft, Nps, 'linear'); 
             method = 'LS-linear'; % LS estimation with linear interpolation
         elseif m == 2
             H_est = LS_CE(Y, Xp, pilot_loc, Nfft, Nps, 'spline');
             method = 'LS-spline'; % LS estimation with spline interpolation
         else
             H_est = MMSE_CE(Y, Xp, pilot_loc, Nfft, Nps, h, SNR);
             method = 'MMSE'; % MMSE estimation
         end
         H_est_power_dB = 10*log10(abs(H_est.*conj(H_est)));
         h_est = ifft(H_est); 
         h_DFT = h_est(1:channel_length); 
         H_DFT = fft(h_DFT,Nfft); % DFT-based channel estimation
         H_DFT_power_dB = 10*log10(abs(H_DFT.*conj(H_DFT)));
         if nsym == 10000
           figure(1);
           subplot(310+m);
           plot(H_power_dB,'b','linewidth',1);
           grid on; hold on;
           plot(H_est_power_dB,'r:+','Markersize',4,'linewidth',1.3);
           plot(H_DFT_power_dB,'m--o','Markersize',4,'linewidth',1.3);
           title(method);
           xlabel('子载波编号'); 
           ylabel('信道系数功率[dB]');
           legend('True Channel', method, [method, ' with DFT'], 'Location', 'south');  
         end
         MSE(m) = MSE(m) + (H-H_est)*(H-H_est)';
         MSE(m+3) = MSE(m+3) + (H-H_DFT)*(H-H_DFT)';
      end
      Y_eq = Y./H_est;
      if nsym >= Nsym+10
          figure(2);
          subplot(121);
          hold on; grid on; box on;       
          axis([-1.5 1.5 -1.5 1.5]);
          title('信道补偿前');
          plot(Y,'.','Markersize',5);

          subplot(122);
          hold on; grid on; box on;
          axis([-1.5 1.5 -1.5 1.5]);    
          title('信道补偿后');
          plot(Y_eq,'.','Markersize',5);
      end
      ip = 0;
      Data_extracted = zeros(1, Nfft - Np);
      for k = 1:Nfft
         if mod(k,Nps)==1
             ip=ip+1;  
         else
             Data_extracted(k-ip) = Y_eq(k); 
         end
      end
      msg_detected = qamdemod(Data_extracted*norms(Nbps), M, 'gray');
      nose = nose + sum(msg_detected~=msgint);
   end
   MSEs(i,:) = MSE/(Nfft*Nsym);
end   
Number_of_symbol_errors = nose;
figure(3);
semilogy(SNRs, MSEs(:, 1), '-x', 'LineWidth', 1.5, 'MarkerSize', 5);
hold on; box on; grid on;
semilogy(SNRs, MSEs(:, 2), '-+', 'LineWidth', 1.5, 'MarkerSize', 5);
semilogy(SNRs, MSEs(:, 3), '-o', 'LineWidth', 1.5, 'MarkerSize', 5);
legend('LS-线性插值', 'LS-样条插值', 'MMSE');
xlabel('SNR [dB]');
ylabel('MSE');