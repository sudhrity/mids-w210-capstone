import googlemaps
from haversine import haversine, Unit, inverse_haversine, Direction
import itertools
import requests
import re
import math

def get_four_corners(center):
    '''
    in: gps coordinate
    out: a dictionary containing the gps coordinates of the 4 corners 
            of the square mile area around the input
    '''
    
    top = inverse_haversine(center, .5, Direction.NORTH, unit='mi')
    nw = inverse_haversine(top, .5, Direction.WEST, unit='mi')
    ne = inverse_haversine(nw, 1, Direction.EAST, unit='mi')
    se = inverse_haversine(ne, 1, Direction.SOUTH, unit='mi')
    sw = inverse_haversine(se, 1, Direction.WEST, unit='mi')
    
    dict_of_coords = {'se' : se,
                  'sw' : sw,
                  'nw' : nw,
                  'ne' : ne}
    
    return(dict_of_coords)

def get_coord_list(coord_dict, dim):
    se = coord_dict['se']
    sw = coord_dict['sw']
    nw = coord_dict['nw']
    ne = coord_dict['ne']
    
    delta_long = (se[1]- sw[1])/(dim-1)
    long_coords = [sw[1]]
    start = sw[1]
    for i in range(dim-1):
        start += delta_long
        long_coords.append(start)
        
    delta_lat = (nw[0] - sw[0])/(dim-1)
    
    lat_coords = [sw[0]]
    start = sw[0]
    for i in range(dim-1):
        start += delta_lat
        lat_coords.append(start)
        
    coords = [lat_coords, long_coords]
    coord_combos = list(itertools.product(*coords))
    
    return coord_combos

def extract_str_coord(coords):
    return (re.sub('[()\s]', '', str(coords)))



def produce_image(coordinate, target_folder,key, zoom =20, size =500):
    # base URL 
    BASE_URL = "https://maps.googleapis.com/maps/api/staticmap?"

    ################## PARAMETERS ########################
    # coordinates
    COORD = extract_str_coord(coordinate) #test image somewhere in LA with a lot of lawns
    
    API_KEY = key

    # zoom value
    ZOOM = zoom

    #pixels
    SIZE = size

    ######################################################

    # updating the URL
    URL = BASE_URL + "center=" + COORD + "&zoom=" + str(ZOOM) + f"&size={SIZE}x{SIZE}&key=" + API_KEY + "&maptype=satellite"

    # HTTP request
    response = requests.get(URL)

    # storing the response in a file (image)
    # with open(f'latest_{SIZE}_z{ZOOM}.png', 'wb') as file:
    with open(f'./{target_folder}/{COORD}.png', 'wb') as file:
       # writing data into the file
       file.write(response.content)

    print(f'URL RESPONSE: {response}.')
    if '200' in str(response):
        print('SUCCESS')
    if '400' in str(response):
        print('BAD REQUEST')
    
    return