function [ERR] = BER_Constellation(snr, modType, mod_size)

%% Theoretical BER --------------
switch modType
    case 'QAM',
        M = 2^mod_size ;
        
        % % Theoretical BER ---------        
        % % directly from matlab, see also http://www.mathworks.com/help/comm/ref/berawgn.html
        r_s_dB = 10*log10( snr/mod_size ) ;
        [BER, SER] = berawgn(r_s_dB,'qam',M) ;
        
        % % Use the following calculation, if your matlab version does not
        % % support berawgn.m
        % % Exact Bit Error Probability of M-QAM Modulation Over Flat Rayleigh Fading Channels
        %         r_s = 3/(2*(M-1))*snr ;
        %         BER = 0;
        %         for k = 1:log2(sqrt(M))
        %             Pek = 0;
        %             for i = 0:(1-2^(-k))*sqrt(M)-1
        %                 w = (-1)^(floor(i*2^(k-1)/sqrt(M)))*( 2^(k-1)-floor(i*2^(k-1)/sqrt(M)+1/2) );
        %                 Pek = Pek + 1/sqrt(M)*w *erfc((2*i+1)*sqrt(r_s)) ;
        %             end
        %             BER = BER + 1/log2(sqrt(M)) * Pek ;
        %         end
        
    case 'PSK',
        % Computation of the Exact Bit-Error Rate of Coherent M-ary PSK With Gray Code Bit Mapping
        % http://www.mathworks.com/help/comm/ref/berawgn.html
        % disp( 'Unsupport') ;
        M = 2^mod_size ;
        r_s_dB = 10*log10( snr/mod_size ) ;
        [BER, SER] = berawgn(r_s_dB,'psk',M,'nondiff') ;
        
    case 'Gaussian',
        BER = nan ;
        SER = nan ;
end

ERR.BER = BER ;
ERR.SER = SER ;


end