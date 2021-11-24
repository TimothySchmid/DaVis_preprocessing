function [temporal_frame, boundaries] = fct_extract_data(davis_frame, is_valid)
%fct_extract_data ---------------------------------------------------------
%   extracts valid data from data frames U0, V0, W0 and H0 for further
%   processing
%
% INPUT
%   davis_frame --> frame extracted from davis vc structure
%   is_valid    --> data mask obtained from davis analysis
%
% OUTPUT
%   temporal_frame --> reduced data frame with valid elements for further
%   processing and cleaning etc.
% -------------------------------------------------------------------------

% get mid point
s1 = round(size(is_valid,1)/2,0);
s2 = round(size(is_valid,2)/2,0);

% "draw" two profile lines through mid point (s1,s2)
p1 = is_valid(:, s2);
p2 = is_valid(s1, :);

% get start and end points
p1_start = find(p1, 1, 'first'); p1_end = find(p1, 1, 'last');
p2_start = find(p2, 1, 'first'); p2_end = find(p2, 1, 'last');

% check for NaNs
temporal_frame = davis_frame(p1_start:p1_end, p2_start:p2_end);
gap = 0;

while isnan(mean(mean(temporal_frame)))
    
    boundaries = [p1_start + gap, p1_end - gap;...
        p2_start + gap, p2_end - gap];
    
    temporal_frame = davis_frame(boundaries(1,1):boundaries(1,2),...
        boundaries(2,1):boundaries(2,2));
    
    gap = gap + 1;
end
                         
end

