function EXP = fct_write_metadata(vc_struc_init, EXP)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

size_cell = size(vc_struc_init.Frames{1}.Attributes,1);
for isize = 1: size_cell
    if strcmp(vc_struc_init.Frames{1}.Attributes{isize}.Name, 'InterrogationWindowSize')
        loc_int = isize;
        EXP.SearchWindow = sscanf(vc_struc_init.Frames{1}.Attributes{loc_int}.Value, '%d');
        
    elseif strcmp(vc_struc_init.Frames{1}.Attributes{isize}.Name, 'FrameDt')
        loc_Dt = isize;
        EXP.dt = sscanf(vc_struc_init.Frames{1}.Attributes{loc_Dt}.Value, '%d') * 1e-6;
    end
end

size_cell = size(vc_struc_init.Attributes,1);
for isize = 1:size_cell
    if strcmp(vc_struc_init.Attributes{isize}.Name, '_DaVisVersion')
        loc_vers = isize;
        EXP.DaVisVersion = (vc_struc_init.Attributes{loc_vers}.Value);
        
    elseif strcmp(vc_struc_init.Attributes{isize}.Name, '_Date')
        loc_date = isize;
        EXP.DaVisDate = (vc_struc_init.Attributes{loc_date}.Value);
    end
end

formatOut = 'dd.mm.yy';
EXP.ProcessingDate = datestr(now,formatOut);
end

