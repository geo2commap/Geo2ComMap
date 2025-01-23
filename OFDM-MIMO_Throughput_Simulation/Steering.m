function [A] = Steering(aoa, antPosition, IN)

% generate steering vector ---
% input: 
% a(:,1) theta: zenith angle
% a(:,2) phi: azimuth angle
% antPosition = [[x1 x2 x3 ... ];
%                [y1 y2 y3 ... ];
%                [z1 z2 z3 ... ];]
% outpot: steering vector
% 


theta = aoa(:,1) ; % zenith angle
phi = aoa(:,2) ;   % azimuth angle
u = [sin(theta).*cos(phi) sin(theta).*sin(phi) cos(theta)] ;

%% method 1
Delay =  u*antPosition;
if IN == 1  % 1: AoA, 0: AoD 
    Delay = -Delay ;
end

A = exp(-1j*pi*Delay) ;


end

