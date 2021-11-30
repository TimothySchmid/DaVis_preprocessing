#!/usr/bin/env python3

# IMPORT PACKAGES
# =========================================================================== #

import os
import glob

from tqdm import tqdm
from tkinter import Tk
from tkinter import filedialog


# DEFINITIONS
# =========================================================================== #

def rename_files(file_list, dic_wild_card, path_name, name_input):
    """ Rename files and append wild_card"""
    print("Renaming files...")
    for index, file in tqdm(enumerate(file_list)):
        txt_add = name_input
        num = str(index)
        num = num.zfill(4)
        name_now = num + "_" + txt_add + "_" + dic_wild_card
        print(name_now)
        
        os.rename(os.path.join(path_name, file),
                  os.path.join(path_name, ''.join([name_now, '.JPG'])))
        
        
# CHOOSE DIRECTORY
# =========================================================================== #

root = Tk()                                    # initialise GUI
root.withdraw()                                # hide main window
folder_experiment = filedialog.askdirectory()  # chose folder path
root.destroy()                                 # destroy GUI

os.chdir(folder_experiment)
os.chdir('..')
dic_wild_card = os.path.basename(os.getcwd())


# GET FILE LIST ...
# =========================================================================== #

os.chdir(folder_experiment)                    # change directory
file_list = sorted(filter(os.path.isfile, glob.glob('*.JPG')))


# ... AND RENAME
# =========================================================================== #

name_input = input("type in file names: \n")
rename_files(file_list, dic_wild_card, folder_experiment, name_input)
