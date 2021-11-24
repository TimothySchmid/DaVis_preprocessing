function M_new = fct_prepare_mask(M_raw)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    kernel = ones(10)/100;
    
    M_temp = imfill(M_raw, 'holes');
    M_temp = convn(double(M_temp), kernel, 'same');
    M_temp = imerode(M_temp, strel('square',10));
    M_new  = uint16(M_temp > 0.5);
end

