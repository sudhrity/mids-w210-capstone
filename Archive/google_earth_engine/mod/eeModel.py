import ee
from mod.eeImage import get_images

ee.Initialize()

counties = ee.FeatureCollection("TIGER/2018/Counties")
la_county = counties.filter(ee.Filter.eq('NAME', 'Los Angeles'))

PROJECT_DIR = 'projects/california-lawn-detection/assets/'

water_training = ee.FeatureCollection("projects/california-lawn-detection/assets/water_training")
trees_training = ee.FeatureCollection("projects/california-lawn-detection/assets/trees_training")
grass_training = ee.FeatureCollection("projects/california-lawn-detection/assets/grass_training")
turf_training = ee.FeatureCollection("projects/california-lawn-detection/assets/turf_training")
# pv_training = ee.FeatureCollection("projects/california-lawn-detection/assets/pv_training")
impervious_training = ee.FeatureCollection("projects/california-lawn-detection/assets/impervious_training").limit(50)
soil_training = ee.FeatureCollection("projects/california-lawn-detection/assets/soil_training").limit(50)

LABELED_SET = water_training.merge(trees_training)\
                            .merge(grass_training)\
                            .merge(turf_training)\
                            .merge(impervious_training)\
                            .merge(soil_training)


water_test = ee.FeatureCollection("projects/california-lawn-detection/assets/water_test")
vegetation_trees_test = ee.FeatureCollection("projects/california-lawn-detection/assets/trees_test")
vegetation_grass_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/grass_test")
turf_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/turf_test")
#pv_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/pv_test")
impervious_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/impervious_test")
soil_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/soil_test")

TEST_SET = water_test.merge(vegetation_trees_test)\
                     .merge(vegetation_grass_test)\
                     .merge(turf_test)\
                     .merge(impervious_test)\
                     .merge(soil_test)


training_image_params = {
        'source_image_collection' : 'USDA/NAIP/DOQQ',
        'years' : [2020],
        'counties': {'la_county': la_county}
         }

TRAINING_IMAGE = get_images(training_image_params)['2020_la_county']



# Overlay the points on the imagery to get training.
LABEL = 'landcover'
BANDS = ['R',
         'G',
         'B',
         'N',
         'NDVI',
         'R_Entropy',
         'R_Contrast',
         'R_Gearys',
         'G_Entropy',
         'G_Contrast',
         'G_Gearys',
         'B_Entropy',
         'B_Contrast',
         'B_Gearys',
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


clf = ee.Classifier.smileRandomForest(numberOfTrees = 200, minLeafPopulation = 5, bagFraction= 0.7)\
                   .train(train_data, LABEL, BANDS)



training_image_classified = TRAINING_IMAGE.select(BANDS)\
                                          .classify(clf)
