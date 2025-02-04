% Script for computing the BER for QAM modulation in ISI Channels with FDE
% 
close all;
clear all;

%% Simulation parameters
% On dÈcrit ci-aprËs les paramËtres gÈnÈraux de la simulation

%modulation parameters
M = 4; %Modulation order 
Nframe = 100;
Nfft=1024;
Ncp=8;
Ns=Nframe*(Nfft+Ncp);
N= log2(M)*Nframe*Nfft;

%Channel Parameters
Eb_N0_dB = [0:40]; % Eb/N0 values
%Multipath channel parameters
hc=[1 -0.9];
Lc=length(hc);%Channel length
H=fft(hc,Nfft);
%Preallocations
nErr_zffde=zeros(1,length(Eb_N0_dB));
nErr_mmsefde=zeros(1,length(Eb_N0_dB));


for ii = 1:length(Eb_N0_dB)

   %Message generation
   bits= randi([0 1],N,1);
   s = qammod(bits,M,'InputType','bit');
   sigs2=var(s);
   
   %Add CP
   smat=reshape(s,Nfft,Nframe);
   smatcp=[smat(end-Ncp+1:end,:);smat];
   scp=reshape(smatcp,1,(Nfft+Ncp)*Nframe);
   
    % Channel convolution: equivalent symbol based representation
   z = filter(hc,1,scp);  
   
   %Generating noise
   sig2b=10^(-Eb_N0_dB(ii)/10);
   
   %n = sqrt(sig2b)*randn(1,N+Lc-1); % white gaussian noise, 
   n = sqrt(sig2b/2)*randn(1,Ns)+1j*sqrt(sig2b/2)*randn(1,Ns); % white gaussian noise, 
   
    % Noise addition
   ycp = z + n; % additive white gaussian noise

   
  

   %remove CP
   ycp_matrice = reshape(ycp, Nfft + Ncp, Nframe); % Reshape pour séparer les CP
   y_no_cp = ycp_matrice(Ncp+1:end, :);           %  enlever CP 
   %y = reshape(y_no_cp, 1, Nfft * Nframe); % Reshape vector ligne
   
   %FDE
   wzf=1./H;
   Y=fft(y_no_cp,Nfft,1);
   s_filter = filter(1,H,Y);
   Yf= diag(wzf)*Y;
   s_zf=ifft(Yf,Nfft,1);
   bhat_zfeq = qamdemod(s_zf(:),M,'bin',OutputType='bit');
   
   %MMSE
   Wmmse = conj(H)./(abs(H).^2+sig2b/sigs2);
   Y_mmse = fft(y_no_cp,[],1);
   Y_mmse = fft(y_no_cp,Nfft,1);
   Yf_mmse= diag(Wmmse)*Y_mmse;
   xhat_mmse=ifft(Yf_mmse,[],1);
   bhat_mmseeq = qamdemod(xhat_mmse(:),M,'bin',OutputType='bit');
   
   nErr_zffde(1,ii) = size(find([bits(:)- bhat_zfeq(:)]),1);
   nErr_zffmmse(1,ii) = size(find([bits(:)- bhat_mmseeq(:)]),1);

   

end

dsp_H = pwelch(H);
   nexttile
    plot(10*log(dsp_H))
    xlabel('fréquence')
    ylabel('dsp')

simBer_zf = nErr_zffde/N; % simulated ber
simBer_mmse = nErr_zffmmse/N;
% plot

figure
semilogy(Eb_N0_dB,simBer_zf(1,:),'bs-','Linewidth',2);
hold on
semilogy(Eb_N0_dB,simBer_mmse(1,:),'rd-','Linewidth',2);
axis([0 70 10^-6 0.5])
grid on
legend('sim-zf-fde','sim-mmse-fde');
xlabel('Eb/No, dB');
ylabel('Bit Error Rate');
title('Bit error probability curve for QPSK in ISI with ZF and MMSE equalizers')




