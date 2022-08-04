#!/usr/bin/env python
# coding: utf-8

# # Google Earth Engine Panel Data Creation

# ## Initialize

# In[1]:


# !pip install geemap
#!pip install ee


# In[2]:


# !pip install uszipcode


# In[33]:


#GEE specific
import ee
import geemap
import math

#plotting and functions
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import itertools
from time import time

# Postgres
import psycopg2

# Zip code info
from uszipcode import SearchEngine


# In[4]:


#Initialize Google Earth Engine
#ee.Authenticate() #just needed the 1st time
ee.Initialize()


# In[5]:


# Check if geemap is working as intended - plot the leaflet map
Map = geemap.Map()


# ## Load Feature Collection - Shapefiles

# In[6]:


#Data loads

#loads feature collection data from Google Earth Engine - We can also upload other feature collections
counties = ee.FeatureCollection("TIGER/2018/Counties")

#filter LA County
la_county = counties.filter(ee.Filter.eq('NAME', 'Los Angeles'))
sc_county = counties.filter(ee.Filter.eq('NAME', 'Santa Clara'))


# In[7]:


la_county, sc_county


# In[8]:


#Income Data
la_county_income = ee.FeatureCollection("projects/california-lawn-detection/assets/lacountyincome-final")


# ## Load NAIP Imagery

# In[9]:


def apply_3bands(image, band):
    i_8_bit = image.select(band).toUint8()
    square = ee.Kernel.square(**{'radius': 4})
    entropy = i_8_bit.entropy(square)
    glcm = i_8_bit.glcmTexture(**{'size': 4})
    contrast = glcm.select(str(band)+'_contrast')
    
    # Create a list of weights for a 9x9 kernel.
    list = [1, 1, 1, 1, 1, 1, 1, 1, 1]
    # The center of the kernel is zero.
    centerList = [1, 1, 1, 1, 0, 1, 1, 1, 1]
    # Assemble a list of lists: the 9x9 kernel weights as a 2-D matrix.
    lists = [list, list, list, list, centerList, list, list, list, list]
    # Create the kernel from the weights.
    # Non-zero weights represent the spatial neighborhood.
    kernel = ee.Kernel.fixed(9, 9, lists, -4, -4, False)
    neighs = i_8_bit.neighborhoodToBands(kernel)
    gearys = i_8_bit.subtract(neighs).pow(2).reduce(ee.Reducer.sum()).divide(math.pow(9, 2))
    image = image.addBands(entropy.rename(str(band)+'_Entropy')).addBands(contrast.rename(str(band)+'_Contrast')).addBands(gearys.rename(str(band)+'_Gearys'))   
    return image

def add_neighborhood_bands(image):
    bands = ['R', 'G', 'B', 'N']
    for band in bands:
        image = apply_3bands(image, band)
    return image
    
def add_NDVI(image):
    image = image.addBands(image.normalizedDifference(['N','R']).rename('NDVI'))
    return image
     


# In[10]:


def get_images(param_dict):
    source_image_collection = param_dict['source_image_collection']
    years = param_dict['years']
    counties = param_dict['counties']

    image_names = []
    images = []

    combos = list(itertools.product(years, counties.keys()))
    for i in combos:
        year = str(i[0])
        county = i[1]

        image_name = str(i[0])+'_'+i[1]
        image_names.append(image_name)

        image = ee.ImageCollection(source_image_collection)                                .filterDate(f'{year}-01-01', f'{year}-12-31')                                .select(['R','G','B','N'])                                .median().clip(counties[county])
        images.append(image)
        images_with_3band = list(map(add_neighborhood_bands, images))
        images_with_NDVI = list(map(add_NDVI, images_with_3band))
    return dict(zip(image_names, images_with_NDVI))

    
    


# ## Load Labeled Data

# In[11]:


## Loading feature collections from Google Earth Engine

water_1 = ee.FeatureCollection("projects/california-lawn-detection/assets/water_torrance_0610")
water_2 = ee.FeatureCollection("projects/california-lawn-detection/assets/water_torrance_0701_400")
vegetation_trees = ee.FeatureCollection("projects/california-lawn-detection/assets/trees_torrance")
vegetation_grass = ee.FeatureCollection("projects/california-lawn-detection/assets/grass_torrance").limit(400)
turf_1 = ee.FeatureCollection("projects/california-lawn-detection/assets/turf_torrance1")
turf_2 = ee.FeatureCollection("projects/california-lawn-detection/assets/turf_torrance2")
impervious_1 = ee.FeatureCollection("projects/california-lawn-detection/assets/impervious_torrance1").limit(35)
impervious_2 = ee.FeatureCollection("projects/california-lawn-detection/assets/impervious_torrance2").limit(35)
soil = ee.FeatureCollection("projects/california-lawn-detection/assets/soil_reduced_070222")

water = water_1.merge(water_2)
turf = turf_1.merge(turf_2)
impervious= impervious_1.merge(impervious_2)


# In[12]:


def conditional_water(feat):
    return ee.Algorithms.If(ee.Number(feat.get('landcover')).eq(1),feat.set({'landcover': 0}),feat)

def conditional_trees(feat):
    return ee.Algorithms.If(ee.Number(feat.get('landcover')).eq(2),feat.set({'landcover': 1}),feat)

def conditional_grass(feat):
    return ee.Algorithms.If(ee.Number(feat.get('landcover')).eq(3),feat.set({'landcover': 2}),feat)

def conditional_turf(feat):
    return ee.Algorithms.If(ee.Number(feat.get('landcover')).eq(4),feat.set({'landcover': 3}),feat)

def conditional_impervious(feat):
    return ee.Algorithms.If(ee.Number(feat.get('landcover')).eq(6),feat.set({'landcover': 4}),feat)

def conditional_soil(feat):
    return ee.Algorithms.If(ee.Number(feat.get('landcover')).eq(7),feat.set({'landcover': 5}),feat)

water_tr = water.map(conditional_water)
trees_tr = vegetation_trees.map(conditional_trees)
grass_tr = vegetation_grass.map(conditional_grass)
turf_tr = turf.map(conditional_turf)
impervious_tr = impervious.map(conditional_impervious)
soil_tr = soil.map(conditional_soil)

LABELED_SET = water_tr.merge(trees_tr).merge(grass_tr).merge(turf_tr).merge(impervious_tr).merge(soil_tr)


# In[13]:


water_test = ee.FeatureCollection("projects/california-lawn-detection/assets/water_test")
vegetation_trees_test = ee.FeatureCollection("projects/california-lawn-detection/assets/trees_test")
vegetation_grass_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/grass_test")
turf_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/turf_test")
impervious_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/impervious_reduced_test")
soil_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/soil_reduced_070222")

TEST_SET = water_test.merge(vegetation_trees_test).merge(vegetation_grass_test).merge(turf_test).merge(impervious_test).merge(soil_test)


# ## Build Training Set

# In[14]:


training_image_params = {
        'source_image_collection' : 'USDA/NAIP/DOQQ',
        'years' : [2020],
        'counties': {'la_county': la_county}
         }

TRAINING_IMAGE = get_images(training_image_params)['2020_la_county']


# In[15]:


Map.addLayer(TRAINING_IMAGE, {}, 'TRAINING_IMAGE')


# In[16]:


# Overlay the points on the imagery to get training.
LABEL = 'landcover'
BANDS = ['R', 
         'G', 
         'B', 
         'N', 
         'NDVI',
         'N_Entropy', 
         'N_Contrast', 
         'N_Gearys']

train_data = TRAINING_IMAGE.select(BANDS).sampleRegions(**{
  'collection': LABELED_SET,
  'properties': [LABEL],
  'scale': 1
})

test_data = TRAINING_IMAGE.select(BANDS).sampleRegions(**{
  'collection': TEST_SET,
  'properties': [LABEL],
  'scale': 1
})


# In[17]:


# print("Training Set Size in Pixels", train_data.aggregate_count('R').getInfo())


# In[18]:


# print("Test Set Size in Pixels", test_data.aggregate_count('R').getInfo())


# ## Machine Learning Model

# In[19]:


clf = ee.Classifier.smileRandomForest(numberOfTrees = 230, minLeafPopulation = 50, bagFraction= 0.6)                   .train(train_data, LABEL, BANDS)
clf


# In[20]:


training_image_classified = TRAINING_IMAGE.select(BANDS)                                          .classify(clf)


# In[21]:


legend_keys = ['water', 'vegetation_trees', 'vegetation_grass', 'turf','impervious','soil']
legend_colors = ['#0B6AEF', '#097407', '#0CE708', '#8C46D2' ,' #A1A8AF','#D47911']

Map.addLayer(training_image_classified, {'min': 0, 'max': 5, 'palette': legend_colors}, 'Classification')


# In[22]:


training_image_classified.bandNames().getInfo()


# In[23]:


Map


# ## Binary Classification and Area Calculation

# In[71]:


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

    #area_sq_km = area_sq_m / 1e6

    return area_sq_m


# In[60]:


def ndvi_calculation(image, class_number, shape, ref_image, pixel_scale=5):
    
    if type(shape) == str:
        shape = la_county_income_zipcode.filter(ee.Filter.eq('ZipCode', shape))
        
    ndvi = ref_image.normalizedDifference(['N', 'R'])
    image_clipped = image.clip(shape)
    
    NDVI_for_class = ndvi.updateMask(image_clipped.select('classification').eq(class_number))
    
    reducer = ee.Reducer.mean()                        .combine(ee.Reducer.max(),sharedInputs=True)                        .combine(ee.Reducer.min(),sharedInputs=True)
    
    
    qty = NDVI_for_class.reduceRegion(
        reducer = reducer, 
        geometry = shape, 
        scale = pixel_scale, 
        maxPixels = 1e13)
    return qty


# ### Create Panel Data

# In[61]:


#import parcel shapes so we can clip by residential areas

la_parcel_shape_filtered = ee.FeatureCollection("projects/california-lawn-detection/assets/LA_County_Parcels_Shape")                             .filter(ee.Filter.eq('UseType', 'Residential'))
    
la_parcel_res = la_parcel_shape_filtered.select(ee.List(['AIN', 'SitusCity','SitusZIP','SitusFullA']), 
                                                ee.List(['AIN', 'City','ZipCode','FullAddress']))


# In[62]:


#import zipcode shapes so we can clip by zipcodes

la_county_income_zipcode2 = ee.FeatureCollection("projects/california-lawn-detection/assets/income_zipcode2019")
la_county_income_zipcode = la_county_income_zipcode2.select(ee.List(['zipcode', '2019zipcod','shape_area']), ee.List(['ZipCode', 'Median_Income','Area_sqft']))


# In[63]:


#
# function to run a select query and return rows in a pandas dataframe
# pandas puts all numeric values from postgres to float
# if it will fit in an integer, change it to integer
#

def my_select_query_pandas(query, rollback_before_flag, rollback_after_flag):
    "function to run a select query and return rows in a pandas dataframe"
    
    if rollback_before_flag:
        connection.rollback()
    
    df = pd.read_sql_query(query, connection)
    
    if rollback_after_flag:
        connection.rollback()
    
    # fix the float columns that really should be integers
    
    for column in df:
    
        if df[column].dtype == "float64":

            fraction_flag = False

            for value in df[column].values:
                
                if not np.isnan(value):
                    if value - math.floor(value) != 0:
                        fraction_flag = True

            if not fraction_flag:
                df[column] = df[column].astype('Int64')
    
    return(df)


# In[64]:


connection = psycopg2.connect(
    user = "postgres",
    password = "&j>n!_nL]k&wWdE>*TVds4P6",
    host = "3.239.228.42",
    port = "5432",
    database = "postgres"
)
cursor = connection.cursor()


# In[65]:


rollback_before_flag = True
rollback_after_flag = True

query = """

select zipcode 
from zipcode_detail
where county = 'Los Angeles County'
order by zipcode;

"""

zipcodes_df = my_select_query_pandas(query, rollback_before_flag, rollback_after_flag)

zipcode_list = zipcodes_df['zipcode'].values.tolist()


# In[80]:



sr = SearchEngine()

def insert_panel_zipcode(year, zipcode, water_area, tree_area, grass_area, turf_area, 
                        impervious_area, soil_area, total_area,
                        tree_ndvi_mean, tree_ndvi_max, tree_ndvi_min,
                        grass_ndvi_mean, grass_ndvi_max, grass_ndvi_min):

    connection.rollback()
    
    z = sr.by_zipcode(zipcode)
    city = z.major_city
    state = z.state_abbr
    #print("state", state)
    county = z.county
    median_income = z.median_household_income
    
    panel_zipcode_dict ={ 'item' : (state, 
                                    county, 
                                    zipcode, 
                                    city, 
                                    year, 
                                    round(total_area, 8),
                                    round(water_area, 8),
                                    round(grass_area, 8), 
                                    round(tree_area, 8),
                                    0.0, 
                                    round(impervious_area, 8), 
                                    round(soil_area, 8), 
                                    round(turf_area,  8),
                                    median_income, 
                                    0.0,
                                    tree_ndvi_mean, 
                                    tree_ndvi_max, 
                                    tree_ndvi_min,
                                    grass_ndvi_mean, 
                                    grass_ndvi_max, 
                                    grass_ndvi_min)
    }

    
    #print(panel_zipcode_dict)
    
    columns= panel_zipcode_dict.keys()
    
    for i in panel_zipcode_dict.values():
        
        query = '''

        INSERT INTO panel_zipcode (state, 
                                    county, 
                                    zipcode, 
                                    city_neighborhood, 
                                    year, 
                                    polygon_area, 
                                    water_area, 
                                    lawn_area, 
                                    tree_area, 
                                    pv_area, 
                                    impervious_area, 
                                    soil_area, 
                                    turf_area, 
                                    median_income, 
                                    water_usage,
                                    tree_ndvi_mean, 
                                    tree_ndvi_max, 
                                    tree_ndvi_min,
                                    grass_ndvi_mean, 
                                    grass_ndvi_max, 
                                    grass_ndvi_min)
            VALUES {}; '''.format(i)

        try:
            cursor.execute(query)
        
        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
    
        finally:
        
            if connection is not None:
                connection.commit()


# In[67]:


# from psycopg2.extras import execute_values

# zipcode = '90025'

# def delete_panel_zipcode(zipcode):

#     connection.rollback()
    
        
#     query = "DELETE FROM panel_zipcode WHERE zipcode IN ('90025')"

#     try:
#         execute_values(cursor, query)
#         connection.commit()
        
#     except (Exception, psycopg2.DatabaseError) as error:
#         print(error)

#     finally:

#         if connection is not None:
#             connection.commit()


# In[81]:


def run_inference(inference_params):
    
    #unpack inference parameter dictionary
    inference_images = get_images(inference_params)
    residential = inference_params['residential']
    zipcode_list = inference_params['zipcodes']
    ndvi = inference_params['ndvi']
    zipcode_shape = inference_params['zipcode_shape']
    residential_shape = inference_params['residential_shape']
    
    #add empty lists to data dictionary
    dictionary = {}

    base_keys = ['year','polygon','water_area','vegetation_trees_area', 
        'vegetation_grass_area', 'turf_area', 'impervious_area',
        'soil_area', 'total_area']
    
    ndvi_keys = ['tree_ndvi_mean', 'tree_ndvi_max','tree_ndvi_min',
       'grass_ndvi_mean', 'grass_ndvi_max','grass_ndvi_min']
    
    for i in base_keys:
        dictionary[i] = []
    if ndvi:
        for i in ndvi_keys:
            dictionary[i] = []
    
#     base_keys = ['year','polygon','water_area','vegetation_trees_area', 
#         'vegetation_grass_area', 'turf_area', 'impervious_area',
#         'soil_area', 'total_area']
    
#     ndvi_keys = ['tree_ndvi_mean', 'tree_ndvi_max','tree_ndvi_min',
#        'grass_ndvi_mean', 'grass_ndvi_max','grass_ndvi_min']
    
    #warning message about selected options
    if inference_params['residential']:
        print('CLIPPING AREA TO INCLUDE RESIDENTIAL AREAS ONLY')
    if inference_params['ndvi']:
        print('RUNNING INFERENCE INCLUDING NDVI CALCULATIONS')
    if inference_params['residential'] or inference_params['ndvi']:
        print('---------------------------------------------------------------------')
    

    #iterate through data, append to data dictionary 
    for i in zipcode_list:
        for j in list(inference_images.items()):
            image_name = j[0]
            im = j[1]
            if residential:
                im = im.clip(residential_shape)
            imagery = im.select(BANDS).classify(clf)
            name = j[0]

            start = time()
            polygon = zipcode_shape.filter(ee.Filter.eq('ZipCode', i))
            
            dictionary['year'].append(image_name[:4]) 
            dictionary['polygon'].append(i)

            water_area = area_calculation(imagery, 0, polygon, 20)
            dictionary['water_area'].append(water_area)

            vegetation_trees_area = area_calculation(imagery, 1, polygon, 20)
            dictionary['vegetation_trees_area'].append(vegetation_trees_area)

            vegetation_grass_area = area_calculation(imagery, 2, polygon, 20)
            dictionary['vegetation_grass_area'].append(vegetation_grass_area)

            turf_area = area_calculation(imagery, 3, polygon, 20)
            dictionary['turf_area'].append(turf_area)

            impervious_area = area_calculation(imagery, 4, polygon, 20)
            dictionary['impervious_area'].append(impervious_area)

            soil_area = area_calculation(imagery, 5, polygon, 20)
            dictionary['soil_area'].append(soil_area)

            total_area = water_area + vegetation_trees_area + vegetation_grass_area + turf_area + impervious_area + soil_area
            dictionary['total_area'].append(total_area)
            
            if ndvi:
                tree_ndvi_mean, tree_ndvi_max, tree_ndvi_min = ndvi_calculation(imagery, 1, polygon, ref_image = im).getInfo().values()
                dictionary['tree_ndvi_mean'].append(tree_ndvi_mean)
                dictionary['tree_ndvi_max'].append(tree_ndvi_max)
                dictionary['tree_ndvi_min'].append(tree_ndvi_min)

                grass_ndvi_mean, grass_ndvi_max, grass_ndvi_min = ndvi_calculation(imagery, 2, polygon, ref_image = im).getInfo().values()
                dictionary['grass_ndvi_mean'].append(grass_ndvi_mean)
                dictionary['grass_ndvi_max'].append(grass_ndvi_max)
                dictionary['grass_ndvi_min'].append(grass_ndvi_min)



            end = time()
            #print(f'Zip Code: {i}, Year: {j[0][:4]} ::: completed in {end-start} seconds.')
        
            insert_panel_zipcode(j[0][:4], i, water_area, vegetation_trees_area, vegetation_grass_area, 
                             turf_area, impervious_area, soil_area, total_area,
                            tree_ndvi_mean, tree_ndvi_max, tree_ndvi_min,
                            grass_ndvi_mean, grass_ndvi_max, grass_ndvi_min) 

    return dictionary
              
              


# In[82]:


inference_params = {
        'source_image_collection' : 'USDA/NAIP/DOQQ',
        'years' : [2010, 2012, 2014, 2016, 2018,2020],
#        'zipcodes': ['90802','90732'],
        'zipcodes': zipcode_list,
        'ndvi': True,
        'residential': False,
        'residential_shape': la_parcel_res, #don't adjust this line
        'counties': {'la_county': la_county}, #don't adjust this line
        'zipcode_shape' : la_county_income_zipcode #don't adjust
         }


# In[ ]:


dictionary = run_inference(inference_params)


# In[ ]:


df = pd.DataFrame(dictionary)
df

