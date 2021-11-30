%
%--------------------------------------------------------------------------
% FILE NAME:
%   material_displacement.m
%
% DESCRIPTION
%   Loads vc7 structure and takes data buffers for height, and displacement
%   components and corrects them by applying outlier detection,
%   interpolation and linear height correction. After Broerse et al. (2021)
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

% SET PATHS TO FUNCTIONS 
% ----------------------------------------------------------------------- %
parent_path = pwd;
addpath(parent_path)

experiment_dir = uigetdir('..');

cd(experiment_dir)
mkdir lag_mat_disp

path_incr_mat = [experiment_dir '/incr_mat_disp'];
path_lag_mat  = [experiment_dir '/lag_mat_disp'];

fct_print_statement_start


% LOAD EXPERIMENT INFO
% ----------------------------------------------------------------------- %
loadvar = ([experiment_dir, '/meta_data']);
load(loadvar);
clearvars loadvar

loadvar = ([experiment_dir, '/coordinate_system']);
load(loadvar);
clearvars loadvar


% SET PATHS TO FUNCTIONS 
% ----------------------------------------------------------------------- %
cd(path_incr_mat)
files = dir('*.mat');
files(strncmp({files.name}, '.', 1)) = [];
n = length(files);


% INITIAL TIME STEP t=0
% ----------------------------------------------------------------------- %
loadvar_name = files(1).name;
loadvar = ([path_incr_mat '/' loadvar_name]);
load(loadvar)
clearvars loadvar

% initialise grid and displacements (incr and cum)
  [X, Y] = ndgrid(xcoords, ycoords);
  [nx, ny] = size(X);
  ntot = nx * ny;
  
  H = zeros(size(X));   H(is_valid == 0) = NaN;
  
  U = zeros(size(X));   U(is_valid == 0) = NaN;
  V = zeros(size(X));   V(is_valid == 0) = NaN;
  W = zeros(size(X));   W(is_valid == 0) = NaN;
    
% assign first incremental displacements to structure D
  D.DU{1} = U;
  D.DV{1} = V;
  D.DW{1} = W;
  D.iv{1} = is_valid;
  
% INTERPOLATE DISPLACEMENTS FROM OFF GRID MARKERS ON EULERIAN GRID
% ----------------------------------------------------------------------- %
tStart = tic;
fct_print_statement('summation')

for iRead = progress(1:n)
    loadvar_name = files(iRead).name;
    loadvar = ([path_incr_mat '/' loadvar_name]);
    load(loadvar);
    clear loadvars
    
  % Assign incr. displacements to local var and set NaNs to 0 (for interp)
    U_now = Du;     U_now(is_valid==0) = 0;
    V_now = Dv;     V_now(is_valid==0) = 0;
    W_now = Dw;     W_now(is_valid==0) = 0;
    
  % rearange displacements and coordinates
    x_ra = double(reshape(X, ntot, 1));
    y_ra = double(reshape(Y, ntot, 1));
    
    u_ra = double(reshape(U_now, ntot, 1));
    v_ra = double(reshape(V_now, ntot, 1));
    w_ra = double(reshape(W_now, ntot, 1));
    
  % update rearanged coordinates
    x_ra_ud = x_ra + u_ra;
    y_ra_ud = y_ra + v_ra;
    
  % make scattered interpolant (if grid is fine enough 'linear' is ok)
    fu = scatteredInterpolant(x_ra_ud, y_ra_ud, u_ra);
    fv = scatteredInterpolant(x_ra_ud, y_ra_ud, v_ra);
    fw = scatteredInterpolant(x_ra_ud, y_ra_ud, w_ra);
    
  % interpolate on grid (nodes)
    UoN = fu(X, Y);
    VoN = fv(X, Y);
    WoN = fw(X, Y);
    
  % Cumulative displacement
    D.DU{iRead+1} = D.DU{iRead} + UoN;
    D.DV{iRead+1} = D.DV{iRead} + VoN;
    D.DW{iRead+1} = D.DW{iRead} + WoN;
    D.iv{iRead+1} = is_valid;
end
  

% SAVING ROUTINE
% ----------------------------------------------------------------------- % 
fct_print_statement('save')

cd(path_lag_mat)

for iRead = progress(1:n+1)
    DU = D.DU{iRead};
    DV = D.DV{iRead};
    DW = D.DW{iRead};
    
    savevar = [path_lag_mat '/B'...
        num2str(iRead-1, '%5.5d')];
    save(savevar, 'DU', 'DV', 'DW', 'is_valid')
end

fun_print_statement_finished(tStart)