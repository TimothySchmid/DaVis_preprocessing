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
EXP.experiment_name     = 'EXP_xxx';

% Show control plot ('yes') or not ('no') --> no is faster for saving
EXP.check_plot          = 'no';

% threshold value for outlier detection (default = 1)
EXP.outlier.threshmed   = 1;

% estimated measurement noise level for outlier detection (default = 1)
EXP.outlier.eps         = 1;

% neighborhood radius for outlier detection: 1 = 3x3, 2 = 5x5 etc.
EXP.outlier.neighbour   = 3;

% ======================================================================= %

% SET PATHS TO FUNCTIONS 
% ----------------------------------------------------------------------- %

    path_main = pwd;
    parent_path = pwd;
    addpath(parent_path)
    addpath([parent_path, '/readimx-v2.1.8-osx'])
    % addpath([parent_path, '/readimx-v2.1.9'])
    experiment_dir = [path_main '/' EXP.experiment_name];

    cd(parent_path)
    mkdir([EXP.experiment_name, '_cleaned_data'])
    path_cleaned_data = [parent_path '/' EXP.experiment_name '_cleaned_data'];
    
    cd(experiment_dir)
    files = dir('*.vc7');
    files(strncmp({files.name}, '.', 1)) = [];
    n = length(files);

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
    
  % get needed components
    U0 = vc_struc.Frames{1}.Components{1}.Planes{:};
    V0 = vc_struc.Frames{1}.Components{2}.Planes{:};
    W0 = vc_struc.Frames{1}.Components{5}.Planes{:};
    H0 = vc_struc.Frames{1}.Components{6}.Planes{:};
    
    is_valid = vc_struc.Frames{1}.Components{9}.Planes{:};
    
  % Define conservative mask based on is_valid
    U_temp = fct_extract_data(U0, is_valid);
    V_temp = fct_extract_data(V0, is_valid);
    W_temp = fct_extract_data(W0, is_valid);
    H_temp = fct_extract_data(H0, is_valid);
    
  % Clean extracted buffers   
    [H_temp, U_temp, V_temp, Wtemp_] = fct_clean_raw_data(H_temp,...
        U_temp, V_temp, W_temp, EXP);
    
  % Get height correction
    if iRead == 1
        Dev = fct_correct_height(H_temp);
        Dev = fct_reassign_values(Dev, is_valid);
    end
    
  % Reassign cleaned output to original buffer size
    U = fct_reassign_values(U_temp, is_valid);
    V = fct_reassign_values(V_temp, is_valid);
    W = fct_reassign_values(W_temp, is_valid);
    H = fct_reassign_values(H_temp, is_valid) - Dev;

  % control_plot
  fct_check_plot(EXP, H0, H, iRead)
    
  % Write new data back to .mat structure
    vc_struc.Frames{1}.Components{1}.Planes = U;
    vc_struc.Frames{1}.Components{2}.Planes = V;
    vc_struc.Frames{1}.Components{5}.Planes = W;
    vc_struc.Frames{1}.Components{6}.Planes = H;
    
  % Write new data as vc structure
    savevar	= [path_cleaned_data '/B' num2str(iRead,'%5.5d')];
    save(savevar, 'vc_struc')
    clearvars savevar vc_struc
end

fun_print_statement_finished(tStart)
cd ..
