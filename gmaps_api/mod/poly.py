from fastapi import APIRouter

from area import area
import json
from shapely.geometry import Point
from shapely.geometry.polygon import Polygon
import itertools
import numpy as np

#create API router to feed into main.py
router2 = APIRouter() #ROUTER PREFIX = /polygon

def get_area(json_data):
    '''
    returns the area of the coordinate space in the target json file

    in: json data with coordinates under ['path']['Md'] item
    out: area of polygon defined in json data (square meters), plus number of vertices

    router extension: /polygon
    e.g. base_url/polygon/{data}
    '''

    coords = json.loads(json_data)['path']['Md']

    coord_list = [[list(i.values()) for i in coords]]
    coord_list[0].append(coord_list[0][0])

    #calculate and return area
    obj = {'type':'Polygon','coordinates':coord_list}
    sqm = area(obj)
    return sqm


def get_dict(json_data):
    '''convert json data from frontend to useable python dictionary'''
    return json.loads(json_data)

def polygon_vertices(data):
    '''
    in: json data with value corresponding to ['path']['Md'] being a set of polygon vertices
    out: stacked list of latitude, longitude coordinates
    '''
    coords = get_dict(data)['path']['Md']
    coord_list = [list(i.values()) for i in coords]
    return coord_list

def rect_corners(vertices):
    '''
    Get the square around the inputted polygon vertices. only works for NW quadrant e.g. United States
    In: coordinate list from polygon_vertices function
    Out: corner gps coordinates of the minimum rectangular area containing the original polygon
    '''
    north = max([i[0] for i in vertices])
    south = min([i[0] for i in vertices])
    east = max([i[1] for i in vertices])
    west = min([i[1] for i in vertices])

    extrema = [[north,south], [east,west]]
    corners = sorted(list(itertools.product(*extrema)), key = lambda x :(x[0], x[1]))
    square_verts = {'sw': corners[0], 'se': corners[1],'nw':corners[2],'ne':corners[3]}
    return(square_verts)

def get_coord_list(coord_dict, dim = 4):
    '''
    In: dictionary of 4 coordinates of square polygon (from rect_corners function)
    out: list of tuples of evenly distributed gps coordinates within the square
    '''
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

def within(point, bounds):
    '''
    in: a single point (point) and a dictionary of corners: se, sw, ne, nw (bounds)
    out: Boolean value of whether or not the single point is inside the bounds

    '''
    bounds = list(bounds.values())
    point = Point(point)
    polygon = Polygon(bounds)
    return polygon.contains(point)

@router2.get("/{json_data}")
async def get_sample(json_data):
    meters = get_area(json_data)
    poly_verts = polygon_vertices(json_data)
    square_verts = rect_corners(poly_verts)
    lst = get_coord_list(square_verts)

    return {
            'original_polygon':poly_verts,
            'square_polygon': square_verts,
            'area': meters,
            'distributed_coordinates':lst
           }
