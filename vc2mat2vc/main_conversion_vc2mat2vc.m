%
%--------------------------------------------------------------------------
% FILE NAME:
%   conversion_vc2mat2vc.m
%
% DESCRIPTION
%   Loads vc7 structure and takes data buffers for height, and displacement
%   components and corrects them by applying outlier detection,
%   interpolation and linear height correction. 
%
% INPUT:
%   - experiment_name
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

cd(experiment_dir)
mkdir 'height_data'
path_height_data = [experiment_dir '/height_data'];

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


% RUN THROUGH FILES
% ----------------------------------------------------------------------- %

tStart = tic;

fct_print_statement_start
fct_print_statement_cleaning

for iRead = progress(1:n)
    
  % get step
    step_now = files(iRead).name;
    
  % get current .vc7 structure
    vc_struc = readimx(step_now);
    
  % get needed components as cell (don't touch this)
    U0 = vc_struc.Frames{1}.Components{loc_u}.Planes;
    V0 = vc_struc.Frames{1}.Components{loc_v}.Planes;
    W0 = vc_struc.Frames{1}.Components{loc_w}.Planes;
    H0 = vc_struc.Frames{1}.Components{loc_h}.Planes;
    
  % create local "working variables"
    U0loc = U0{:};  V0loc = V0{:};  W0loc = W0{:};  H0loc = H0{:};
    
    
  % prepare mask
    M0 = vc_struc.Frames{1}.Components{loc_m}.Planes;
    M0loc = logical(M0{:});
    is_valid = fct_prepare_mask(M0loc);
    
  % Clean extracted buffers   
    [H_temp, U_temp, V_temp, W_temp] = fct_clean_raw_data(H0loc, U0loc,...
        V0loc, W0loc, EXP, is_valid);
    
  % Height correction
    if iRead == 1
        [correction_plane, boundaries]  = fct_extract_data(H_temp, is_valid);
        Dev     = fct_correct_height(correction_plane);
        Dev_ext = fct_reassign_values(Dev, boundaries, H_temp);
    end
    
  % Reassign cleaned output to new variables and clean up
    U = {single(U_temp)};
    V = {single(V_temp)};
    W = {single(W_temp)};
    H = {single(H_temp - Dev_ext)};

  % control_plot
  fct_check_plot(EXP, V0loc, V, iRead)
    
  % Write new data back to .mat structure
    vc_struc.Frames{1}.Components{loc_u}.Planes = U;
    vc_struc.Frames{1}.Components{loc_v}.Planes = V;
    vc_struc.Frames{1}.Components{loc_w}.Planes = W;
    vc_struc.Frames{1}.Components{loc_h}.Planes = H;
    
  % Write new data as vc structure
    savevar	= [path_cleaned_data '/B' num2str(iRead,'%5.5d')];
    save(savevar, 'vc_struc')
    %writeimx(vc_struc, ['/B' num2str(iRead,'%5.5d') '.vc7'])
    clearvars savevar vc_struc
end

fun_print_statement_finished(tStart)
cd ..
