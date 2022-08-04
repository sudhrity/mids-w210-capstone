import ee
from time import time


la_county_income_zipcode2 = ee.FeatureCollection("projects/california-lawn-detection/assets/income_zipcode2019")

la_county_income_zipcode = la_county_income_zipcode2.select(ee.List(['zipcode', '2019zipcod','shape_area']),
                                                            ee.List(['ZipCode', 'Median_Income','Area_sqft']))


def area_calculation(image, class_number, shape, pixel_scale = 20):

    if type(shape) == str:
        shape = la_county_income_zipcode.filter(ee.Filter.eq('ZipCode', shape))

    areaImage = image.eq(class_number).multiply(ee.Image.pixelArea())

    area = areaImage.reduceRegion(
        reducer = ee.Reducer.sum(),
        geometry = shape,
        scale = pixel_scale,
        maxPixels = 1e13)


    area_sq_m = area.getInfo().get('classification')

    area_sq_km = area_sq_m / 1e6

    return area_sq_km



def get_areas(imagery, polygon):

    dictionary = {}

    start = time()
    water_area = area_calculation(imagery, 0, polygon, 20)
    dictionary['water_area'] = water_area

    vegetation_trees_area = area_calculation(imagery, 1, polygon, 20)
    dictionary['tree_area'] = vegetation_trees_area

    vegetation_grass_area = area_calculation(imagery, 2, polygon, 20)
    dictionary['grass_area'] = vegetation_grass_area

    turf_area = area_calculation(imagery, 3, polygon, 20)
    dictionary['turf_area'] = turf_area

    impervious_area = area_calculation(imagery, 4, polygon, 20)
    dictionary['impervious_area'] = impervious_area

    soil_area = area_calculation(imagery, 5, polygon, 20)
    dictionary['soil_area'] = soil_area

    total_area = water_area + vegetation_trees_area + vegetation_grass_area + turf_area + impervious_area + soil_area
    dictionary['polygon_area'] = total_area

    end = time()

    dictionary['inference_time'] = end-start


    return(dictionary)
