function davis_var = fct_reassign_values(var_temp, is_valid)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% get mid point
s1 = round(size(is_valid,1)/2,0);
s2 = round(size(is_valid,2)/2,0);

% "draw" two profile lines through mid point (s1,s2)
p1 = is_valid(:, s2);
p2 = is_valid(s1, :);

% get start and end points
p1_start = find(p1, 1, 'first'); p1_end = find(p1, 1, 'last');
p2_start = find(p2, 1, 'first'); p2_end = find(p2, 1, 'last');

boundaries = [p1_start, p1_end;...
              p2_start, p2_end];
          
davis_var = zeros(size(is_valid));
davis_var(boundaries(1,1):boundaries(1,2), boundaries(2,1):boundaries(2,2)) = var_temp;

end