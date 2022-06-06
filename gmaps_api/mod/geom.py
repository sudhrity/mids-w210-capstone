from fastapi import APIRouter

from area import area
import json

#create API router to feed into main.py
router2 = APIRouter()


@router2.get("/folder={folder_name}&file={filename}")
async def get_area(folder_name, filename):
    '''
    returns the area of the coordinate space in the target json file

    in: data folder name, file name
    out: area of polygon defined in json data (square meters)

    router extension: /geometry
    e.g. base_url/geometry/folder=json_data&file=poly5
    '''

    #look for data in target folder, create filepath
    filepath = folder_name + '/' + filename + '.json'

    #open file, load json data as dictionary
    with open(filepath) as j:
        data = json.load(j)

    #extract just coordinates from json data
    coords = data['path']['Md']
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
    return ({'sq_meters': str(area(obj))})
