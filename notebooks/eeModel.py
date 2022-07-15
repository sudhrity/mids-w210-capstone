import ee
from eeImage import get_images

ee.Initialize()

counties = ee.FeatureCollection("TIGER/2018/Counties")
la_county = counties.filter(ee.Filter.eq('NAME', 'Los Angeles'))

PROJECT_DIR = 'projects/california-lawn-detection/assets/'

# water_training = ee.FeatureCollection("projects/california-lawn-detection/assets/water_training")
# trees_training = ee.FeatureCollection("projects/california-lawn-detection/assets/trees_training")
# grass_training = ee.FeatureCollection("projects/california-lawn-detection/assets/grass_training")
# turf_training = ee.FeatureCollection("projects/california-lawn-detection/assets/turf_training")
# pv_training = ee.FeatureCollection("projects/california-lawn-detection/assets/pv_training")
# impervious_training = ee.FeatureCollection("projects/california-lawn-detection/assets/impervious_training").limit(50)
# soil_training = ee.FeatureCollection("projects/california-lawn-detection/assets/soil_training").limit(50)

# LABELED_SET = water_training.merge(trees_training)\
#                             .merge(grass_training)\
#                             .merge(turf_training)\
#                             .merge(impervious_training)\
#                             .merge(soil_training)


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

# water_test = ee.FeatureCollection("projects/california-lawn-detection/assets/water_test")
# vegetation_trees_test = ee.FeatureCollection("projects/california-lawn-detection/assets/trees_test")
# vegetation_grass_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/grass_test")
# turf_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/turf_test")
# #pv_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/pv_test")
# impervious_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/impervious_test")
# soil_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/soil_test")

# TEST_SET = water_test.merge(vegetation_trees_test)\
#                      .merge(vegetation_grass_test)\
#                      .merge(turf_test)\
#                      .merge(impervious_test)\
#                      .merge(soil_test)

water_test = ee.FeatureCollection("projects/california-lawn-detection/assets/water_test")
vegetation_trees_test = ee.FeatureCollection("projects/california-lawn-detection/assets/trees_test")
vegetation_grass_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/grass_test")
turf_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/turf_test")
impervious_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/impervious_reduced_test")
soil_test  = ee.FeatureCollection("projects/california-lawn-detection/assets/soil_reduced_070222")



TEST_SET = water_test.merge(vegetation_trees_test).merge(vegetation_grass_test).merge(turf_test).merge(impervious_test).merge(soil_test)

training_image_params = {
        'source_image_collection' : 'USDA/NAIP/DOQQ',
        'years' : [2020],
        'counties': {'lacounty': la_county}
         }

TRAINING_IMAGE = get_images(training_image_params)['2020_la_county']



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


# clf = ee.Classifier.smileRandomForest(numberOfTrees = 200, minLeafPopulation = 5, bagFraction= 0.7)\
#                    .train(train_data, LABEL, BANDS)

clf = ee.Classifier.smileRandomForest(numberOfTrees = 230, minLeafPopulation = 50, bagFraction= 0.6)\
                   .train(train_data, LABEL, BANDS)


training_image_classified = TRAINING_IMAGE.select(BANDS)\
                                          .classify(clf)
