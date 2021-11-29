%
%--------------------------------------------------------------------------
% FILE NAME:
%   conversion_vc2mat.m
%
% DESCRIPTION
%   Loads vc7 structure and takes data buffers for height, and displacement
%   components and corrects them by applying outlier detection,
%   interpolation and linear height correction. 
%
% INPUT:
%   - experiment_name --> gui select experiment main folder
%
%
% ASSUMPTIONS AND LIMITATIONS:
%   None
%
% For more information, see <a href="matlab: 
% web('https://www.geo.unibe.ch')">Institute of Geological Sciences UNIBE</a>.
%
%--------------------------------------------------------------------------

% Author: Timothy Schmid, MSc., geology
% Institute of Geological Sciences, University of Bern
% Baltzerstrasse 1, Office 207
% 3012 Bern, CH
% email address: timothy.schmid@geo.unibe.ch
% November 2021; Last revision: 22/11/2021 
% * initial implementation

close all;
clear;
clc

% INPUT PARAMETERS
% ======================================================================= %

% Define model name
experiment_dir = uigetdir('..');
[~, EXP.experiment_name, ~] = fileparts(experiment_dir);

% Show control plot ('yes') or not ('no') --> no is faster for saving
EXP.check_plot          = 'no';

% threshold value for outlier detection (default = 1)
EXP.outlier.threshmed   = 0.5;

% estimated measurement noise level for outlier detection (default = 1)
EXP.outlier.eps         = 1e-1;

% neighborhood radius for outlier detection: 1 = 3x3, 2 = 5x5 etc.
EXP.outlier.neighbour   = 5;

% ======================================================================= %


% SET PATHS TO FUNCTIONS 
% ----------------------------------------------------------------------- %
parent_path = pwd;
addpath(parent_path)

if isunix
    addpath([parent_path, '/readimx-v2.1.8-osx']) % Mac
else
    addpath([parent_path, '/readimx-v2.1.9'])     % Windows
end

cd(experiment_dir)
mkdir 'incr_mat_disp'
path_incr_mat_disp = [experiment_dir '/incr_mat_disp'];

cd([experiment_dir '/vc'])
files = dir('*.vc7');
files(strncmp({files.name}, '.', 1)) = [];
n = length(files);

    
% LOCATE DISPLACEMENT COMPONENTS
% ----------------------------------------------------------------------- %
vc_struc_init = readimx(files(1).name);

% search for correct places
loc_u = fct_find_location(vc_struc_init,'U0');
loc_v = fct_find_location(vc_struc_init,'V0');

% check if it is a stereo set
is_stereo = sum(ismember(vc_struc_init.Frames{1}.ComponentNames,'W0'));
if is_stereo
    loc_w = fct_find_location(vc_struc_init,'W0');
end

loc_h = fct_find_location(vc_struc_init,'TS:Height');
loc_m = fct_find_location(vc_struc_init,'TS:isValid');


% SCALING VALUES FOR COORDINATE SYSTEM
% ----------------------------------------------------------------------- %
[slope_x, offset_x, step_x] = fct_get_scaling(vc_struc_init, 'X');
[slope_y, offset_y, step_y] = fct_get_scaling(vc_struc_init, 'Y');
[slope_z, offset_z, step_z] = fct_get_scaling(vc_struc_init, 'Z');
[slope_i, offset_i ] = fct_get_scaling(vc_struc_init, 'I');


% ASSEMBLE COORDINATE SYSTEM
% ----------------------------------------------------------------------- %
dim = size(vc_struc_init.Frames{1}.Components{loc_u}.Planes{:});

xcoords = slope_x * (linspace(0, dim(1), dim(1)) * step_x) + offset_x;
ycoords = slope_y * (linspace(0, dim(2), dim(2)) * step_y) + offset_y;

% write experiment data and coordinates
savevar	= [experiment_dir '/coordinate_system'];
save(savevar, 'xcoords', 'ycoords', 'slope*', 'offset*', 'step*', '-v7.3')
  

% WRITE META DATA
% ----------------------------------------------------------------------- %
EXP = fct_write_metadata(vc_struc_init, EXP);
  
clearvars vc_struc_init slope_* offset_* *coords dim savevar step_*...
          is_stereo -except slope_i
  
      
% RUN THROUGH FILES
% ----------------------------------------------------------------------- %
tStart = tic;   

fct_print_statement_start
fct_print_statement('cleaning')

for iRead = progress(1:n)
    
  % get step
    cd([experiment_dir '/vc'])
    step_now = files(iRead).name;
    
  % get current .vc7 structure
    vc_struc = readimx(step_now);
    
  % get needed components
    U0 = vc_struc.Frames{1}.Components{loc_u}.Planes{:};
    V0 = vc_struc.Frames{1}.Components{loc_v}.Planes{:};
    W0 = vc_struc.Frames{1}.Components{loc_w}.Planes{:};
    H0 = vc_struc.Frames{1}.Components{loc_h}.Planes{:};
    
  % prepare mask
    M0 = logical(vc_struc.Frames{1}.Components{loc_m}.Planes{:});
    is_valid = fct_prepare_mask(M0);
    
  % Clean extracted buffers   
    [H_temp, U_temp, V_temp, W_temp] = fct_clean_raw_data(H0, U0, V0,...
        W0, EXP, is_valid);
    
  % Height correction
    if iRead == 1
        [correction_plane, boundaries] = fct_extract_data(H_temp, is_valid);
        [Dev, fit_vals]                = fct_correct_height(correction_plane);
         Dev_ext                       = fct_reassign_values(Dev, boundaries, H_temp);
         EXP.HeightCoefficients        = fit_vals;
         savevar = [experiment_dir '/meta_data'];
         save(savevar, 'EXP', '-v7.3')
    end
    
  % Scale new variables
    Du =  single(U_temp * slope_i);
    Dv =  single(V_temp * slope_i);
    Dw =  single(W_temp * slope_i);
    H  = single((H_temp - Dev_ext) * slope_i);

  % control_plot
    fct_check_plot(EXP, H0, H, iRead)
    
  % write new data as 7.3 .mat file (can be read as hdf5 in python)
    savevar	= [path_incr_mat_disp '/B' num2str(iRead,'%5.5d')];
    save(savevar, 'Du', 'Dv', 'Dw', 'H', 'is_valid', '-v7.3')
    cd([experiment_dir '/vc'])
    
  % clean up
    clearvars *0 vc_struc step_now *_temp Dev fit_vals Du Dv Dw H savevar...
                correction_plane boundaries is_valid
end

fun_print_statement_finished(tStart)
