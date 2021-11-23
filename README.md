# DaVis_preprocessing

### Files

- batch_rename.py
- batch_split_images.py
- split_and_rename.py

Use split_and_rename.py to rename all files in all folders and split experiment data into files used for 
DIC (folder "double") and topviews (folder "single").

### Experiment foldername
Optional, but EXP_xxx is recommended

### Folder structure
Folder names must obey the following naming convention (case sensitive!):

- Door
    - calibration
    - experiment
    - shade
    - silicone

- Top
    - calibration
    - experiment
    - shade
    - silicone

- Window
    - calibration
    - experiment
    - shade
    - silicone


### vc2mat2vc

Loads .vc7 DaVis files (LaVisison) into MATLAB for processing and writes new data back into new .vc7 files

For incremental 3D displacement fields and height data.
Processing uses an outlier detection algorithm (Westerweel and Scarano, 2005) and replaces outliers by interpolation
(John D'Errico's magical inpaint_nans). Height data is corrected by using a 2D linear plane fit for the initial surface 
(assumes initial flat topography). After corrections, data is written back into .vc7 file (not working at the moment).

- Outlier detection: Westerweel and Scarano (2005)
- inpaint_nans: John D'Errico
- Progress bar class provided by J.-A. Adrian

LaVision's Matlab add on for DaVis is freely available for Windows and Mac OS https://www.lavision.de/de/downloads/software/matlab_add_ons.php
