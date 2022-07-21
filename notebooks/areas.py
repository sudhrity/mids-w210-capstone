import json

from fastapi import APIRouter
import ee

from eeModel import training_image_classified
from eeArea import area_calculation, get_areas

router1 = APIRouter() #ROUTER PREFIX = /polygon_areas
router2 = APIRouter()

def get_coordinate_list(json_polygon):
    '''
    returns the area of the coordinate space in the target json file

    in: json data with coordinates under ['path']['Md'] item
    out: list of coordinates

    router extension: /polygon
    e.g. base_url/polygon/{data}
    '''

    coords = json.loads(json_polygon)['path']['Md']
    coord_list = [[float(i['lng']), float(i['lat'])] for i in coords]

    return coord_list


@router1.get("/{json_polygon}")
async def calc_polygon_area(json_polygon):
    coords = get_coordinate_list(json_polygon)

    poly = ee.Geometry.Polygon(coords)

    areas = get_areas(training_image_classified, poly)

    return areas


@router2.get("/{zipcode}")
async def calc_zip_area(zipcode):

    areas = get_areas(training_image_classified, zipcode)

    return areas
