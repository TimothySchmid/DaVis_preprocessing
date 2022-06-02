
% ======================================================================= %
%                                                                         %
%                     FILE SEPARATOR TOP VIEW / DEM                       %
%                                                                         %
%                               AUTHOR:                                   %
%                     Stefano Fabri & Timothy Schmid                      %
%                      timothy.schmid@geo.unibe.ch                        %
%                                                                         %
% ======================================================================= %

% Script separates Topview pictures and stereoscopic pictures, used for DEM
% and 3D PIV. The main folder must be coppied into "FILESEP". After click
% on "run" a window pops up, where the name of the imported folder must be
% typed in.


clear all;
close all;
clc;

% Dialog box

prompt = {'Enter folder name'};
dlgtitle = 'Folder name';
dims = [1 40];
definput = {'FOLDERNAME'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
foldername = answer{1,1};

% Set path
folderpath = [pwd '/' num2str(foldername)];
cd(folderpath)
files = dir('*.jpg');

% Make folders for topview and DEM pictures

mkdir TOPVIEW
mkdir DEM

% Load data with corresponding filenames

h      = waitbar(0);
n      = length(files);

istart = 1;
iend   = 10;
incr   = 10;

while n - iend >= 0
    for i=istart:iend
        perc = i/n;
%         eval(['load ' files(i).name ' -ascii']);
%         data{i}  = importdata(files(i).name);
        waitbar(perc,h,['Processing data: ', num2str(round(perc*100,1)),' %']);
        
        if mod(i,2) == 1
            movefile(files(i).name,'TOPVIEW')
        else
            movefile(files(i).name,'DEM')
        end
    end
    
    clearvars data
    
    istart = iend+1;
    iend   = iend+incr;
end

for i = istart:n
    perc = i/n;
%     eval(['load ' files(i).name ' -ascii']);
%     data{i}  = importdata(files(i).name);
    waitbar(perc,h,['Processing data: ', num2str(round(perc*100,1)),' %']);
    
    if mod(i,2) == 1
        movefile(files(i).name,'TOPVIEW')
    else
        movefile(files(i).name,'DEM')
    end
end

clearvars data    
close(h)

