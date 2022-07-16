from enum import Enum

import ee
from eeImage import get_images

# Model variables
LABEL = 'landcover'
BANDS = ['R', 
         'G', 
         'B', 
         'N', 
         'NDVI',
         'N_Entropy', 
         'N_Contrast', 
         'N_Gearys']
CLASSES = ['water',
           'vegetation_trees',
           'vegetation_grass',
           'turf',
           'impervious',
           'soil']


# class ClassEnum(Enum):

#   '''
#   Enum class for mapping classes to new integers
#   '''

#   WATER = (1, 0)
#   TREES = (2, 1)
#   GRASS = (3, 2)
#   TURF = (4, 3)
#   IMPERVIOUS = (6, 4)
#   SOIL = (7, 5)

# def conditional_class(cls):
#     '''
#     Remaps class labels based on ClassEnum mapping
#     '''
#   def map_feature(feat):
#     mapper = ClassEnum[cls].value
#     return ee.Algorithms.If(ee.Number(feat.get('landcover')).eq(mapper[0]),feat.set({'landcover': mapper[1]}),feat)
#   return map_feature

def get_TF_classified_image(image, bands, tf_model, classes):
    
    '''
    Use a TF model hosted on Google AI Platform to classify an EE image.
    '''
    
    # Select bands from training image for classification
    selected_image = image.select(bands)

    # Get the predictions
    predictions = tf_model.predictImage(selected_image.float().toArray())
    classified_image = predictions.arrayArgmax().arrayGet([0]).rename('classification')
    
    return classified_image




ee.Initialize()

counties = ee.FeatureCollection("TIGER/2018/Counties")
la_county = counties.filter(ee.Filter.eq('NAME', 'Los Angeles'))

# PROJECT_DIR = 'projects/california-lawn-detection/assets/'


# # Create the labeled feature collection set for train data
# water_1 = ee.FeatureCollection(f"{PROJECT_DIR}water_torrance_0610")
# water_2 = ee.FeatureCollection(f"{PROJECT_DIR}water_torrance_0701_400")
# vegetation_trees = ee.FeatureCollection(f"{PROJECT_DIR}trees_torrance")
# vegetation_grass = ee.FeatureCollection(f"{PROJECT_DIR}grass_torrance").limit(400)
# turf_1 = ee.FeatureCollection(f"{PROJECT_DIR}turf_torrance1")
# turf_2 = ee.FeatureCollection(f"{PROJECT_DIR}turf_torrance2")
# impervious_1 = ee.FeatureCollection(f"{PROJECT_DIR}impervious_torrance1").limit(35)
# impervious_2 = ee.FeatureCollection(f"{PROJECT_DIR}impervious_torrance2").limit(35)
# soil = ee.FeatureCollection(f"{PROJECT_DIR}soil_reduced_070222")

# water = water_1.merge(water_2)
# turf = turf_1.merge(turf_2)
# impervious= impervious_1.merge(impervious_2)

# # Remap old labels to new labels per class
# water_tr = water.map(conditional_class('WATER'))
# trees_tr = vegetation_trees.map(conditional_class('TREES'))
# grass_tr = vegetation_grass.map(conditional_class('GRASS'))
# turf_tr = turf.map(conditional_class('TURF'))
# impervious_tr = impervious.map(conditional_class('IMPERVIOUS'))
# soil_tr = soil.map(conditional_class('SOIL'))

# LABELED_SET = water_tr.merge(trees_tr).merge(grass_tr).merge(turf_tr).merge(impervious_tr).merge(soil_tr)

# # Create the labeled feature collection set for test data
# water_test = ee.FeatureCollection("projects/california-lawn-detection/assets/water_test")
# vegetation_trees_test = ee.FeatureCollection("projects/california-lawn-detection/assets/trees_test")
# vegetation_grass_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/grass_test")
# turf_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/turf_test")
# impervious_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/impervious_reduced_test")
# soil_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/soil_reduced_070222")


# TEST_SET = water_test.merge(vegetation_trees_test).merge(vegetation_grass_test).merge(turf_test).merge(impervious_test).merge(soil_test)

# Generate training image
training_image_params = {
        'source_image_collection' : 'USDA/NAIP/DOQQ',
        'years' : [2020],
        'counties': {'lacounty': la_county}
         }

TRAINING_IMAGE = get_images(training_image_params)['2020_la_county']

# # Separate into train and test data using feature collection sets
# train_data = TRAINING_IMAGE.select(BANDS).sampleRegions(**{
#   'collection': LABELED_SET,
#   'properties': [LABEL],
#   'scale': 1
# })

# test_data = TRAINING_IMAGE.select(BANDS).sampleRegions(**{
#   'collection': TEST_SET,
#   'properties': [LABEL],
#   'scale': 1
# })

# # Train GEE RF model
# clf = ee.Classifier.smileRandomForest(numberOfTrees = 230, minLeafPopulation = 50, bagFraction= 0.6)\
#                    .train(train_data, LABEL, BANDS)

# # Classify image using GEE RF model
# training_image_classified = TRAINING_IMAGE.select(BANDS)\
#                                           .classify(clf)

# Point to the specific TF model to be used for inference
PROJECT = 'w210-351617'
MODEL_NAME = 'CNN_Nbands_model'
VERSION_NAME = 'v0'
input_dim = [12,12]

# Point to the model hosted on AI Platform.
tf_model = ee.Model.fromAiPlatformPredictor(
    projectName=PROJECT,
    modelName=MODEL_NAME,
    version=VERSION_NAME,
    # Can be anything, but don't make it too big.
    inputTileSize=input_dim,
    # Note the names here need to match what was specified in the
    # output dictionary passed to the EEifier originally
    outputBands={'output': {
        'type': ee.PixelType.float(),
        'dimensions': 1
      }
    },
)

# Classify the training image using TF model
training_image_classified = get_TF_classified_image(TRAINING_IMAGE, BANDS, tf_model, CLASSES)
assert(training_image_classified.bandNames().getInfo() == ['classification'])


