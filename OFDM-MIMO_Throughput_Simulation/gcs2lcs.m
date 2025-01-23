function [AoA_lcs] = gcs2lcs(AoA_gcs,arrayOrientation)
% 
% input :
%   AoA_gcs: global (zenith angle, azimuth angle)
%   arrayOrientation: [gamma; beta; alpha]  
% output:
%   AoA_lcs: local (zenith angle, azimuth angle)
%

% AoA_gcs = AoA_gcs/180*pi; % degree to radians 
% arrayOrientation = arrayOrientation/180*pi; % degree to radians 

rho = [sin(AoA_gcs(:,1)).*cos(AoA_gcs(:,2)), ...
       sin(AoA_gcs(:,1)).*sin(AoA_gcs(:,2)), ...
       cos(AoA_gcs(:,1)) ].';
R = RotMat(arrayOrientation);
cartesian_lcs = R'*rho ;

AoA_lcs(:,1) = acos(cartesian_lcs(3,:))';
AoA_lcs(:,2) = atan2(cartesian_lcs(2,:),cartesian_lcs(1,:))';
% AoA_lcs = AoA_lcs/pi*180; % radians to degree

end