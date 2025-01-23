function [R] = RotMat(theta_vec)

theta_x = theta_vec(1);
theta_y = theta_vec(2);
theta_z = theta_vec(3);

% Orientation
Rx = [1 0 0; 0 cos(theta_x) -sin(theta_x); 0 sin(theta_x) cos(theta_x)];
Ry = [cos(theta_y) 0 sin(theta_y); 0 1 0 ; -sin(theta_y) 0 cos(theta_y)];
Rz = [cos(theta_z) -sin(theta_z) 0; sin(theta_z) cos(theta_z) 0; 0 0 1];

R = Rz*Ry*Rx ;

end
