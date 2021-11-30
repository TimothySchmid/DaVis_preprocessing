function [slope, offset, varargout] = fct_get_scaling(vc_struc_init, var_str)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

Cell1     = struct2cell(vc_struc_init.Frames{1}.Scales);
Cell2     = struct2cell(vc_struc_init.Frames{1}.Grids);

location1 = find(ismember(fields(vc_struc_init.Frames{1}.Scales), var_str));
location2 = find(ismember(fields(vc_struc_init.Frames{1}.Grids) , var_str));

slope = Cell1{location1}.Slope;
offset = Cell1{location1}.Offset;

if location2 > 0
    varargout{1}   = Cell2{location2};
end

end

