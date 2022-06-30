import ee
from eeImage import get_images

ee.Initialize()

counties = ee.FeatureCollection("TIGER/2018/Counties")
la_county = counties.filter(ee.Filter.eq('NAME', 'Los Angeles'))

PROJECT_DIR = 'projects/california-lawn-detection/assets/'

water = ee.FeatureCollection(f"{PROJECT_DIR}water_torrance_0610")
vegetation_trees = ee.FeatureCollection(f"{PROJECT_DIR}trees_torrance")
vegetation_grass = ee.FeatureCollection(f"{PROJECT_DIR}grass_torrance").limit(400)
turf_1 = ee.FeatureCollection(f"{PROJECT_DIR}turf_torrance1")
turf_2 = ee.FeatureCollection(f"{PROJECT_DIR}turf_torrance2")
pv = ee.FeatureCollection(f"{PROJECT_DIR}pv_torrance")
impervious_1 = ee.FeatureCollection(f"{PROJECT_DIR}impervious_torrance1").limit(40)
impervious_2 = ee.FeatureCollection(f"{PROJECT_DIR}impervious_torrance2").limit(40)
soil = ee.FeatureCollection(f"{PROJECT_DIR}soil_torrance").limit(40)

turf = turf_1.merge(turf_2)
impervious= impervious_1.merge(impervious_2)

LABELED_SET = water.merge(vegetation_trees)\
                   .merge(vegetation_grass)\
                   .merge(turf)\
                   .merge(impervious)\
                   .merge(soil)
    
training_image_params = {
        'source_image_collection' : 'USDA/NAIP/DOQQ',
        'years' : [2020]
         }

TRAINING_IMAGE = get_images(training_image_params)['2020_la_county']


# Overlay the points on the imagery to get training.
LABEL = 'landcover'
BANDS = ['R', 'G', 'B', 'N', 'NDVI',
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

training_set = TRAINING_IMAGE.select(BANDS).sampleRegions(**{
  'collection': LABELED_SET,
  'properties': [LABEL],
  'scale': 1
})


def training_area(image, training_class):
    
    area = image.reduceRegion(
           reducer = ee.Reducer.count(), 
           geometry = training_class.geometry(), 
           scale = 2, 
           maxPixels = 1e13
                )

    return(area.getInfo().get('B'))


def training_polygons(training_class):
    return(training_class.aggregate_count('label').getInfo())


# training information
training_classes = [water,
                         vegetation_trees,
                         vegetation_grass,
                         turf,
                         pv,
                         impervious,
                         soil]

class_names = ['water',
                         'vegetation_trees',
                         'vegetation_grass',
                         'turf',
                         'pv',
                         'impervious',
                         'soil']
def polygon_areas():
    try:
        for i in range(len(training_classes)):
            area_i = training_area(TRAINING_IMAGE, training_classes[i])
            polygons_i = training_polygons(training_classes[i])
            print(class_names[i],"pixels:", area_i ,", polygons", polygons_i)
    except:
        print('ERROR. POSSIBLE MISMATCH IN CLASSES LIST AND NAMES LIST SIZES')
    
    return


#Split Training and Test Set Randomly - there might be a better way to do this

sample = training_set.randomColumn()
trainingSample = sample.filter('random <= 0.8')
validationSample = sample.filter('random > 0.8')

def sample_sizes():
    print("Labeled Set Size in Pixels", training_set.aggregate_count('R').getInfo())
    print("Training Set Size in Pixels", trainingSample.aggregate_count('R').getInfo())
    print("Test Set Size in Pixels", validationSample.aggregate_count('R').getInfo())
    return

clf = ee.Classifier.smileRandomForest(numberOfTrees = 100).train(trainingSample, LABEL, BANDS)

training_image_classified = TRAINING_IMAGE.select(BANDS).classify(clf)

