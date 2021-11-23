function Dev = fct_correct_height(H0)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
x_vec = linspace(0, size(H0,1), size(H0,1));
y_vec = linspace(0, size(H0,2), size(H0,2));

[X_temp, Y_temp] = ndgrid(x_vec, y_vec);

% Calculate plane through first surface
A = [ones(numel(X_temp),1), X_temp(:), Y_temp(:)];
M = A\H0(:);
Dev = reshape(A*M,size(X_temp,1),size(X_temp,2));
end

