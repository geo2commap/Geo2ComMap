function [BER] = Th_BER(H, noise_level, mod_size, ItMax) 

% H = 1/sqrt(2*3)* (randn(3,3) + 1j*randn(3,3)) ;

%% Modulation settong --------  
modType = 'QAM' ;
% mod_size = 8; % modulation size: 2 for QPSK, 4 for 16-QAM, 6 for 64-QAM

priorIn.modType = modType;
priorIn.mod_size = mod_size;

% noise_level = 10^(-20/10) ; 
% load('1024qammse.mat');



[Nr,Nt] = size(H);

v_b  = 1;
 
ItIdx = 1;
if nargin == 3, ItMax = 100; end  

old_v_b = inf ; 
toleranceErr = 10^(-10) ; 

while (norm(old_v_b-v_b)>toleranceErr)  && (v_b > 1e-10)
    
    old_v_b = v_b ; 
    
    v_a = 1/(1/(real(trace(inv(1/noise_level*(H'*H) + 1/v_b *eye(Nt))))/Nt) - 1/v_b) ;
%     v = mse_Constellation(1/sqrt(v_a), priorIn) ;
    
    switch mod_size 
        case 4
            v = mse_16QAM(1/sqrt(v_a)) ;       
        case 6
            v = mse_64QAM(1/sqrt(v_a)) ;
        case 8
            v = mse_256QAM(1/sqrt(v_a)) ; 
        case 10
            v = mse_1024QAM(1/sqrt(v_a)) ;

        otherwise
            disp('undfined QAM value')
    end 
    
    v_b = 1/(1/v-1/v_a) ;
    
    ItIdx = ItIdx + 1 ;
    if (ItIdx > ItMax), break, end 
    
end

MSE = v ; 

[ ERR ] = BER_Constellation(1/v_a, priorIn.modType, priorIn.mod_size) ;
BER = ERR.BER ;

end

function [v] = mse_16QAM(x)

x = log(x);

p1 =     -0.0553 ;
p2 =      0.6098 ;
p3 =      -2.777 ;
p4 =       6.024 ;
p5 =       -5.99 ;
p6 =      0.8736 ;
p7 =       1.575 ;
p8 =      -1.639 ;
p9 =     -0.8387 ;

v = exp(p1*x^8 + p2*x^7 + p3*x^6 + p4*x^5 + p5*x^4 + p6*x^3 + p7*x^2 + p8*x + p9) ;

end

function [v] = mse_64QAM(x)

x = log(x);

p1 =    -0.02757 ;
p2 =      0.3779 ;
p3 =      -2.174 ;
p4 =       6.538 ;
p5 =      -11.12 ;
p6 =       10.74 ;
p7 =      -5.738 ;
p8 =    -0.04935 ;
p9 =     -0.7653 ;

v = exp(p1*x^8 + p2*x^7 + p3*x^6 + p4*x^5 + p5*x^4 + p6*x^3 + p7*x^2 + p8*x + p9) ;

end

function [v] = mse_256QAM(x)

x = log(x);

p1 =   -0.004631 ;
p2 =     0.05762 ;
p3 =     -0.2915 ;
p4 =      0.6843 ;
p5 =     -0.6674 ;
p6 =       0.159 ;
p7 =     -0.2713 ;
p8 =      -1.138 ;
p9 =     -0.7334 ;

v = exp(p1*x^8 + p2*x^7 + p3*x^6 + p4*x^5 + p5*x^4 + p6*x^3 + p7*x^2 + p8*x + p9) ;

end

function [v] = mse_1024QAM(x)

p1 =  -4.238e-16 ;
p2 =   2.488e-13 ;
p3 =   -6.38e-11 ;
p4 =   9.373e-09 ;
p5 =  -8.684e-07 ;
p6 =   5.257e-05 ;
p7 =   -0.002078 ;
p8 =     0.05034 ;
p9 =     -0.7617 ;
p10 =    -0.4639 ;

v = exp(p1*x^9 + p2*x^8 + p3*x^7 + p4*x^6 + p5*x^5 + p6*x^4 + p7*x^3 + p8*x^2 + p9*x + p10);

end


