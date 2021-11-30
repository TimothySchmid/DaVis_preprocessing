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
    print("Split file list...")
    for f in tqdm(files):
        shutil.move(f, folder_dir)
    
    
def rename_files(file_list, dic_wild_card, path_name):
    """ Rename files and append wild_card"""
    print("Renaming files...")
    for index, file in tqdm(enumerate(file_list)):
        txt_add = "_min_"
        num = str(index)
        num = num.zfill(4)
        name_now = num + txt_add + dic_wild_card
        
        os.rename(os.path.join(path_name, file),
                  os.path.join(path_name, ''.join([name_now, '.jpg'])))


# CHOOSE DIRECTORY
# =========================================================================== #

root = Tk()                                    # initialise GUI
root.withdraw()                                # hide main window
folder_experiment = filedialog.askdirectory()  # chose folder path
root.destroy()                                 # destroy GUI

# folder_experiment = "/Users/tschmid/Desktop/EXP_xxx/WINDOW/experiment"
os.chdir(folder_experiment)

os.chdir('..')
dic_wild_card = os.path.basename(os.getcwd())


# GET FILE LIST
# =========================================================================== #

os.chdir(folder_experiment)                    # change directory
file_list = sorted(filter(os.path.isfile, glob.glob('*.JPG')))


# MAKE DIRECTORIES FOR FILES
# =========================================================================== #
        
dir_dem = "DEM"
dir_top = "TOPVIEW"

path_dem = os.path.join(folder_experiment, dir_dem)
path_top = os.path.join(folder_experiment, dir_top)

mkdir_check(path_dem)
print("Directory '%s' created" % path_dem)

mkdir_check(path_top)
print("Directory '%s' created" % path_top)


# MOVE FILES...
# =========================================================================== #

file_list_1 = file_list[::2]
file_list_2 = file_list[1::2]

split_files(file_list_1, dir_top)
split_files(file_list_2, dir_dem)


# ... AND RENAME
# =========================================================================== #

os.chdir(path_top)
file_list_top = sorted(filter(os.path.isfile, glob.glob('*.JPG')))

rename_files(file_list_top, dic_wild_card, path_top)

os.chdir(path_dem)
file_list_dem = sorted(filter(os.path.isfile, glob.glob('*.JPG')))

rename_files(file_list_dem, dic_wild_card, path_dem)
