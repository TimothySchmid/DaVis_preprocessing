%
%--------------------------------------------------------------------------
% FILE NAME:
%   helper_file.m
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
EXP.experiment_name     = 'EXP_1002';

% ======================================================================= %

% SET PATHS TO FUNCTIONS 
% ----------------------------------------------------------------------- %

    path_main = pwd;
    parent_path = pwd;
    addpath(parent_path)
    experiment_dir = [path_main '/' EXP.experiment_name];
    cleaned_files_dir = [path_main '/' EXP.experiment_name '_cleaned_data'];
    
    cd(cleaned_files_dir)
    files = dir('*.mat');
    files(strncmp({files.name}, '.', 1)) = [];
    n = length(files);
    
% LOAD SCALES
% ----------------------------------------------------------------------- %

    load(files(1).name);
    
  % x direction:
    x_slope  = vc_struc.Frames{1}.Scales.X.Slope;
    x_offset = vc_struc.Frames{1}.Scales.X.Offset;
    x_unit   = vc_struc.Frames{1}.Scales.X.Unit;
    
  % y direction:
    y_slope  = vc_struc.Frames{1}.Scales.Y.Slope;
    y_offset = vc_struc.Frames{1}.Scales.Y.Offset;
    y_unit   = vc_struc.Frames{1}.Scales.Y.Unit;

  % z direction:
    z_slope  = vc_struc.Frames{1}.Scales.Z.Slope;
    z_offset = vc_struc.Frames{1}.Scales.Z.Offset;
    z_unit   = vc_struc.Frames{1}.Scales.Z.Unit;
    
  % intensity:
    h_slope  = vc_struc.Frames{1}.Scales.I.Slope;
    h_offset = vc_struc.Frames{1}.Scales.I.Offset;
    h_unit   = vc_struc.Frames{1}.Scales.I.Unit;
    
% LOCATE DISPLACEMENT COMPONENTS
% ----------------------------------------------------------------------- %

% search for correct places
loc_u = fct_find_location(vc_struc,'U0');
loc_v = fct_find_location(vc_struc,'V0');

% check if it is a stereo set
is_stereo = sum(ismember(vc_struc.Frames{1}.ComponentNames,'W0'));
if is_stereo
    loc_w = fct_find_location(vc_struc,'W0');
end

loc_h = fct_find_location(vc_struc,'TS:Height');
loc_m = fct_find_location(vc_struc,'MASK');


    

