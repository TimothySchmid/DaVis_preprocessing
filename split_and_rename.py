#!/usr/bin/env python3

# IMPORT PACKAGES
# =========================================================================== #

import os
import glob
import shutil

from tqdm import tqdm
from tkinter import Tk
from tkinter import filedialog


# DEFINITIONS
# =========================================================================== #

def mkdir_check(directory):
    """ Checks if subfolders exists and, if so, continues.
    If not, subfolders will be created"""
    if not os.path.isdir(directory):
        os.makedirs(directory)
       
        
def split_files(files, folder_dir):
    """ Takes split file lists and moves files into subfolders"""
    print("Split file list... \n")
    for f in tqdm(files):
        shutil.move(f, folder_dir)
        
        
def rename_files(file_list, dic_wild_card, path_name, name_input):
    """ Rename files and append wild_card"""
    print("Renaming files... \n")
    for index, file in tqdm(enumerate(file_list)):
        txt_add = name_input
        num = str(index)
        num = num.zfill(4)
        name_now = num + "_" + txt_add + "_" + dic_wild_card
        
        os.rename(os.path.join(path_name, file),
                  os.path.join(path_name, ''.join([name_now, '.JPG'])))
        
def copy_files_to_davis(camera_list, src_end, davis_dest):
    """ Copy needed files into defined DaVis folders"""
    for camera_name in camera_list:
        src_dir = os.path.join(path_experiment, camera_name, src_end)
        
        for filename in tqdm(os.listdir(src_dir)):
            if filename.endswith('.JPG'):
                shutil.copy( src_dir + filename, davis_dest)
        
        
# CHOOSE DIRECTORY AND SETUP DIRECTORIES
# =========================================================================== #

root = Tk()                                    # initialise GUI
root.withdraw()                                # hide main window
path_experiment = filedialog.askdirectory()    # chose folder path
root.destroy()                                 # destroy GUI

# path_experiment = '/Users/timothyschmid/Desktop/EXP_xxx'

os.chdir(path_experiment)

path_davis_experiment = os.path.join(path_experiment, 'davis_experiment')
path_davis_calibration = os.path.join(path_experiment, 'davis_calibration')

mkdir_check(path_davis_experiment)
mkdir_check(path_davis_calibration)


# GET ALL SUBFOLDERS (DOOR, TOP, WINDOW)
# =========================================================================== #

camera_list = ['Door', 'Top', 'Window']
folder_list = ['calibration', 'experiment', 'shade', 'silicone']


# ... AND RENAME
# =========================================================================== #

for camera_name in camera_list:
    path_camera = os.path.join(path_experiment, camera_name)
    dic_wild_card = camera_name
    
    for sub_folder_name in folder_list:
        path_sub_folder = os.path.join(path_camera, sub_folder_name)
        
    
        os.chdir(path_sub_folder)
        cwd = os.getcwd()
        
        if os.path.basename(os.getcwd()) == 'experiment':
            
            dir_double = "double"
            dir_single = "single"

            path_double = os.path.join(path_sub_folder, dir_double)
            path_single = os.path.join(path_sub_folder, dir_single)

            mkdir_check(path_double)
            mkdir_check(path_single)
        
            # SEPARATE DOUBLE AND SINGLE LIGHT SOURCE FILES
            # =============================================================== #

            file_list = sorted(filter(os.path.isfile, glob.glob('*.JPG')))
            
            file_list_1 = file_list[::2]
            file_list_2 = file_list[1::2]

            split_files(file_list[::2], path_single)
            split_files(file_list[1::2], path_double)
            
            rename_files(file_list[::2], dic_wild_card, path_single, 'single')
            rename_files(file_list[1::2], dic_wild_card, path_double, 'double')
            
        file_list = sorted(filter(os.path.isfile, glob.glob('*.JPG')))
        
        name_input = sub_folder_name
        rename_files(file_list, dic_wild_card, cwd, name_input)
        
        
# COPY DOUBLE LIGHT SOURCE FILES INTO DAVIS DIRECTORIES
# =========================================================================== #

camera_list = ['Door', 'Window'] # could be extended with topview to get 3 cams.

copy_files_to_davis(camera_list, 'experiment/double/', path_davis_experiment)
copy_files_to_davis(camera_list, 'calibration/', path_davis_calibration)

print("\n \n")
print("---------------------------------------------------------------------")
print("successfully split images, renamed files and copied into DaVis folder")
print("---------------------------------------------------------------------")
