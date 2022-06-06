#standard imports
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import time

#system imports
import os
import sys
import shutil
import csv
from IPython.display import clear_output

#image lib import
from PIL import Image
from skimage.transform import resize

def get_image_fnames(image_dir):
    
    images = [i for i in os.listdir(image_dir) if os.path.splitext(i)[1] == '.png']
    
    return images

def _iso_grass(image):
 
    mat = np.array(image.convert('RGB'))
    grass = ((1.8*mat[:,:,1]) >= (mat[:,:,2]+mat[:,:,1])).astype('int')
    return (grass)

def print_test_images(image_dir):
    images = get_image_fnames(image_dir)
    idx = np.random.randint(len(images))
    test_image = Image.open(os.path.join(image_dir, images[idx]))
    
    if len(images) == 0:
        print('ENSURE IMAGES ARE LOADED INTO SOURCE DIRECTORY BEFORE PROCEEDING')
    else:
        print('TEST IMAGE DISPLAY')
        fig, ax = plt.subplots(1,2, figsize= (10,10))
        ax[0].imshow(test_image)
        ax[1].imshow(_iso_grass(test_image))
    
def classify_images(image_dir, dest_folder, name_class_file):
    
    images = get_image_fnames(image_dir)
    num_classified = 0
    
    for n, i in enumerate(images):
        
        print("Image #:", n)
        print("Coordinates:", os.path.splitext(i)[0])
        image_path = os.path.join(image_dir, i)
        im = Image.open(image_path).convert('RGB')
        display(im)

        clss = input('Enter Classification: ')

        if clss == 'stop':
            clear_output()
            print('PROCESS STOPPED')
            break
        elif clss == '1':
            try:
                shutil.move(image_path, os.path.join(dest_folder, 'lawn/'))
                with open(name_class_file, 'a') as f:
                    f.write(f"{i},{clss}\n")
                    
                num_classified += 1
                
            except:
                continue
        else:
            try:
                shutil.move(image_path, os.path.join(dest_folder, 'no_lawn/'))
                with open(name_class_file, 'a') as f:
                    f.write(f"{i},0\n")
                    
                num_classified += 1
                
            except:
                continue
                
            
        clear_output()
        
    _write_num_classified(num_classified)
    
    return

def _write_num_classified(num):
    
    rel_path = 'data_write/center_coordinates.txt'
    path = os.path.abspath(os.path.join(os.getcwd(), rel_path))
    
    with open(path, "a") as file:
        file.write(f",{num}\n")
    
    
    