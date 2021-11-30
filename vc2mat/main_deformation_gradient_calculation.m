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
mkdir deformation_gradients

path_incr_mat   = [experiment_dir '/incr_mat_disp'];
path_def_grads  = [experiment_dir '/deformation_gradients'];


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


% SETUP PHYSICAL/NUMERICAL GRID
% ----------------------------------------------------------------------- %
% physical model lengths
  Lx = xcoords(end) - xcoords(1);
  Ly = ycoords(end) - ycoords(1);

% grid
  [X, Y] = ndgrid(xcoords, ycoords);

% # nodes
  nx    = length(xcoords);
  ny    = length(ycoords);
  n_tot = nx * ny;

% # elements
  nelx    = nx - 1;
  nely    = ny - 1;
  el_tot  = nelx * nely;

% # nodes and pts per element
  n_per_el   = 4;
  pts_per_el = 1;

  
% GLOBAL TO LOCAL INDEXING
% ----------------------------------------------------------------------- %       
% 2D grid with node numbers 
  NoN   = reshape(1:n_tot, nx, ny);

% Numbering scheme... relates nodes to elements
%
%   4        3
%    o------o
%    |      |
%    |      |
%    o------o
%   1        2
    
  EL_N = [reshape(NoN(1:nx-1,1:ny-1),1,el_tot);
          reshape(NoN(2:nx  ,1:ny-1),1,el_tot);
          reshape(NoN(2:nx  ,2:ny  ),1,el_tot);
          reshape(NoN(1:nx-1,2:ny  ),1,el_tot)];
    
% points for "numerical" integration at the centroid
  pts = [ 0 ;...   % int.pts coordinate in s-direction
          0 ];     % int.pts coordinate in t-direction

% initialize shape functions and derivatives
  N    = zeros(pts_per_el,n_per_el);   % shape functions
  dNds = zeros(2,n_per_el,pts_per_el); % spatial derivatives of shape functions

    for ipts = 1:pts_per_el
       s  = pts(1,ipts);
       t = pts(2,ipts);

       N(ipts,:) =   1/4*[(1-s)*(1-t),...
                          (1+s)*(1-t),...
                          (1+s)*(1+t),...
                          (1-s)*(1+t)];

      dNds = 1/4*[t-1 1-t 1+t -1-t];
      dNdt = 1/4*[s-1 s-1 1+s  1-s];
    end

% centroid point for coordinates and displacements
  COORD_MID = zeros(2,el_tot);
  DISP_MID  = zeros(3,el_tot);

  
% CALCULATION LOOP
% ----------------------------------------------------------------------- % 
tStart = tic;

fct_print_statement_start
fct_print_statement('material')
fct_print_statement('H')

for iRead = progress(1:n) % time loop ----------------------------------- %
    
  % load displacement data
    loadvar_name = files(iRead).name;
    loadvar = ([path_incr_mat '/' loadvar_name]);
    load(loadvar);
    clearvars loadvar
    
    X(is_valid==0) = NaN;
    Y(is_valid==0) = NaN;
    
    X_now = X;
    Y_now = Y;
    
  % Global coordinates node-wise
    COORD = [reshape(X_now, 1, n_tot) ;...
             reshape(Y_now, 1, n_tot)];
    
    U_now = Du;
    V_now = Dv;
    W_now = Dw;
    
  % displacements node-wise
    DISP  = [reshape(U_now,1,n_tot);...
             reshape(V_now,1,n_tot);...
             reshape(W_now,1,n_tot)];
         
  % initialise displacement and deformation gradient tensors
    disp_grad = zeros(4,el_tot);
    def_grad  = zeros(4,el_tot);
    
for iel = 1:el_tot % element loop --------------------------------------- %
    
    crit_coord = ~isempty(find(isnan(COORD(:,EL_N(:,iel))),1));
    crit_disp  = ~isempty(find(isnan(DISP(:,EL_N(:,iel))),1));
    
    if crit_coord || crit_disp
        DU = NaN(2);
    else
      % get local coordinates
        Xl = COORD(1,EL_N(:,iel))';
        Yl = COORD(2,EL_N(:,iel))';
        
        Ul  = DISP(1,EL_N(:,iel))';
        Vl  = DISP(2,EL_N(:,iel))';
        Wl  = DISP(3,EL_N(:,iel))';
        
      % spatial derivative of displacement dU/dS
        dUdS = [ dNds * Ul dNdt * Ul ; ...
                 dNds * Vl dNdt * Vl];
        
      % spatial derivative of displacement dX/dS
        dXdS = [ dNds * Xl dNdt * Xl ; ...
                 dNds * Yl dNdt * Yl];
        
      % displacement gradient
        DU = dUdS/dXdS;
        
      % Displacement in the middle of the element
        DISP_MID(1,iel) = N*Ul;
        DISP_MID(2,iel) = N*Vl;
        DISP_MID(3,iel) = N*Wl;
        
      % centroid point coordinates
        COORD_MID(1,iel) = N*Xl;
        COORD_MID(2,iel) = N*Yl;
    end
  % assemble displacement gradient tensor
    disp_grad(1,iel) = DU(1,1);     % --> du/dx
    disp_grad(2,iel) = DU(1,2);     % --> du/dy
    disp_grad(3,iel) = DU(2,1);     % --> dv/dx
    disp_grad(4,iel) = DU(2,2);     % --> dv/dy
    
  % assemble incremental deformation gradient tensor
    def_grad(1,iel) = disp_grad(1,iel) + 1;
    def_grad(2,iel) = disp_grad(2,iel)    ;
    def_grad(3,iel) = disp_grad(3,iel)    ;
    def_grad(4,iel) = disp_grad(4,iel) + 1;
    
end % element loop ------------------------------------------------------ %

% reorder displacement and incremental deformation gradient tensors
  Cells.HIncrmt{iRead}(1,1,:,:) = reshape(disp_grad(1,:),nelx,nely);
  Cells.HIncrmt{iRead}(1,2,:,:) = reshape(disp_grad(2,:),nelx,nely);
  Cells.HIncrmt{iRead}(2,1,:,:) = reshape(disp_grad(3,:),nelx,nely);
  Cells.HIncrmt{iRead}(2,2,:,:) = reshape(disp_grad(4,:),nelx,nely);

  Cells.FIncrmt{iRead}(1,1,:,:) = reshape(def_grad(1,:),nelx,nely);
  Cells.FIncrmt{iRead}(1,2,:,:) = reshape(def_grad(2,:),nelx,nely);
  Cells.FIncrmt{iRead}(2,1,:,:) = reshape(def_grad(3,:),nelx,nely);
  Cells.FIncrmt{iRead}(2,2,:,:) = reshape(def_grad(4,:),nelx,nely);

% get mid points as grid
Xmid = reshape(COORD_MID(1,:),nelx,nely);
Ymid = reshape(COORD_MID(2,:),nelx,nely);
       
end % time loop --------------------------------------------------------- %


% CALCULATE CUMULATIVE GRADIENT TENSOR F
% ----------------------------------------------------------------------- % 
fct_print_statement('F')

for iRead = progress(1:n)
    if iRead == 1
        Cells.F{iRead} = Cells.FIncrmt{iRead};
    else
        for ix = 1:nelx
            for iy = 1:nely
                    Cells.F{iRead}(:,:,ix,iy) = ...
                    Cells.FIncrmt{iRead}(:,:,ix,iy) * ...
                    Cells.FIncrmt{iRead-1}(:,:,ix,iy);
            end
        end
    end
end


% SAVING ROUTINE
% ----------------------------------------------------------------------- % 
fct_print_statement('save')

cd(path_def_grads)

for iRead = progress(1:n)
    Fincr = Cells.FIncrmt{iRead};
    F     = Cells.F{iRead};
    
    savevar = [path_def_grads '/deformation_gradient_tensor_B'...
        num2str(iRead, '%5.5d')];
    save(savevar, 'Fincr', 'F', 'Xmid', 'Ymid')
end

fun_print_statement_finished(tStart)
