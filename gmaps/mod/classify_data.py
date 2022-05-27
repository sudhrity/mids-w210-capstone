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


def iso_grass(image):
 
    mat = np.array(image.convert('RGB'))
    grass = ((1.8*mat[:,:,1]) >= (mat[:,:,2]+mat[:,:,1])).astype('int')
    return (grass)

def print_test_images(source_directory):
    images = [i for i in os.listdir(source_directory) if i[-3:] == 'png'] 
    idx = np.random.randint(len(images))
    test_image = Image.open(f'source_images/{images[idx]}')
    
    if len(images) == 0:
        print('ENSURE IMAGES ARE LOADED INTO SOURCE DIRECTORY BEFORE PROCEEDING')
    else:
        print('TEST IMAGE DISPLAY')
        fig, ax = plt.subplots(1,2, figsize= (10,10))
        ax[0].imshow(test_image)
        ax[1].imshow(iso_grass(test_image))
    
def classify_images(image_source, destination_folder, name_class_file):
    
    images = [i for i in os.listdir(image_source) if i[-3:] == 'png']
    for i in images:
        im = Image.open(f'{image_source}/{i}').convert('RGB')
        display(im)

        clss = input('Enter Classification: ')

        if clss == 'stop':
            clear_output()
            print('PROCESS STOPPED')
            break
        elif clss == '1':
            try:
                shutil.move(f'./source_images/{i}', './classified_images/lawn/')
                with open(name_class_file, 'a') as f:
                    f.write(i+',1' + '\n')
            except:
                continue
        else:
            try:
                shutil.move(f'./source_images/{i}', './classified_images/no_lawn/')
                with open(name_class_file, 'a') as f:
                    f.write(i+',0' + '\n')
            except:
                continue
            
        clear_output()
    
    return
    