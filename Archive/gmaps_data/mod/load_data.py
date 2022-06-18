#standard imports
import numpy as np
import matplotlib.pyplot as plt
import time
import random

#system imports
import os

#image lib import
from PIL import Image
from skimage.transform import resize

      
def load_gmaps_data(main_images_dir, dimension):

    lawn_dir = 'lawn/'
    no_lawn_dir = 'no_lawn/'

    lawn_path = os.path.join(main_images_dir, lawn_dir)
    no_lawn_path = os.path.join(main_images_dir, no_lawn_dir)


    positive_data = []
    negative_data = []
    
    start = time.time()
    for i in os.listdir(no_lawn_path):
        if i[-3:] == 'png':
            im = Image.open(f'{no_lawn_path}/{i}').convert('RGB')
            im_resized = resize(np.array(im), (dimension,dimension,3))
            negative_data.append((im_resized,0))


    for i in os.listdir(lawn_path):
        if i[-3:] == 'png':
            im = Image.open(f'{lawn_path}/{i}').convert('RGB')
            im_resized = resize(np.array(im), (dimension,dimension,3))
            positive_data.append((im_resized,1))


    all_data = positive_data+negative_data
    random.shuffle(all_data)

    X = np.array([i[0] for i in all_data])
    y = np.array([i[1] for i in all_data])
    
    end = time.time()
    
    print(f'Loaded {X.shape[0]} images in {(end-start):.4f} seconds')
    print(f'Positive Images: {y.sum()}')
    print(f'Negative Images: {y.shape[0]-y.sum()}')
    print(f'Class Ratio: {y.mean():.4f}')
    
    return X, y


def display_image(data, index):
    '''plots the image'''
    return plt.imshow(data[index])
