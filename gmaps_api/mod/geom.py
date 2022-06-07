from fastapi import APIRouter

from area import area
import json

#create API router to feed into main.py
router2 = APIRouter()


# @router2.get("/folder={folder_name}&file={filename}")
@router2.get("/{json_data}")
async def get_area(json_data):
    '''
    returns the area of the coordinate space in the target json file

    in: json data with coordinates under ['path']['Md'] item
    out: area of polygon defined in json data (square meters), plus number of vertices

    router extension: /polygon
    e.g. base_url/polygon/{data}
    '''

    coords = json.loads(json_data)['path']['Md']
    coord_list = [[]]

    #append all coordinates to coordinate list, with first and last points being the same
    start = coords[0]
    coord_list[0].append([start['lat'], start['lng']])

    #iteratively append all coordinates from json data
    for i in range(1, len(coords)):
        point = coords[i]
        coord_list[0].append([point['lat'], point['lng']])

    #close polygon by appending starting coordinate as last coordinate
    coord_list[0].append([start['lat'], start['lng']])

    #calculate and return area
    obj = {'type':'Polygon','coordinates':coord_list}
    return ({
            'square_meters': area(obj),
            'polygon_shape': len(coords)
             })
