from fastapi import APIRouter
import json

from mod.eeImage import get_images
from mod.eeModel import clf, BANDS
from mod.eeArea import area_calculation, get_areas
import ee

router1 = APIRouter() #ROUTER PREFIX = /polygon_areas
router2 = APIRouter()

params = {
        'source_image_collection' : 'USDA/NAIP/DOQQ',
        'years' : [2020]
         }

images = get_images(params)

rf_model = clf
bands = BANDS
training_image_classified = images['2020_la_county'].select(bands).classify(rf_model)



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

    # zipcode = str(zipcode)

    areas = get_areas(training_image_classified, zipcode)

    return areas
