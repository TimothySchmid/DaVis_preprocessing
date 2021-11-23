### vc2mat2vc

Loads .vc7 DaVis files (LaVisison) into MATLAB for processing and writes new data back into new .vc7 files

For incremental 3D displacement fields and height data.
Processing uses an outlier detection algorithm (Westerweel and Scarano, 2005) and replaces outliers by interpolation
(John D'Errico's magical inpaint_nan). Height data is corrected by using a 2D linear plane fit for the initial surface 
(assumes initial flat topography). After corrections, data is written back into .vc7 file (not working at the moment).
