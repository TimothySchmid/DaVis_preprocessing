function val_out = fct_reassign_values(Dev, boundaries, H_temp)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% bring plane back in size
x_Dev = linspace(boundaries(1,1), boundaries(1,2), boundaries(1,2) - boundaries(1,1) + 1);
y_Dev = linspace(boundaries(2,1), boundaries(2,2), boundaries(2,2) - boundaries(2,1) + 1);

F = griddedInterpolant({x_Dev, y_Dev}, Dev);


x_Dev_ext = linspace(1, size(H_temp,1), size(H_temp,1));
y_Dev_ext = linspace(1, size(H_temp,2), size(H_temp,2));

Dev_ext = F({x_Dev_ext, y_Dev_ext});

val_out = Dev_ext;

end