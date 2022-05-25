#standard imports
import numpy as np
import matplotlib.pyplot as plt
import time

#system imports
import os

#image lib import
from PIL import Image
from skimage.transform import resize

def read_flatten_image(image):
    im = Image.open(image)
    im_rgb = im.convert('RGB')
    arr_200 = resize(np.array(im_rgb), (200,200,3))
    r = arr_200[:,:,0].flatten()
    g = arr_200[:,:,1].flatten()
    b = arr_200[:,:,2].flatten()
    return np.dstack([r,g,b])

def get_classes(name_class_file):
    with open(name_class_file) as f:
        l = f.read().splitlines()
    names = [i[:-2] for i in l]
    classes = [int(i[-1]) for i in l]
    print(f'Returned {len(names)} items to each list')
    return(names, classes)
    
    
def load_gmaps_images(image_folder, image_names):
    data = []
    start = time.time()
    for file_name in image_names:
        data.append(read_flatten_image(f'classified_images/{file_name}'))
    end = time.time()
    print(f'{len(image_names)} images loaded in {end-start:.4f} seconds.')
    
    return(data)


def display_image(index, list_of_photos):
    '''plots the image'''
    return plt.imshow(list_of_photos[index].reshape(200,200,3))

def get_photo_array(index, list_of_photos):
    '''returns the vector for the RGB converted photo'''
    return np.array(list_of_photos[index].reshape(200,200,3))