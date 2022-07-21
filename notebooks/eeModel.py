from enum import Enum

import ee
from eeImage import get_images

# Initialize GEE
ee.Initialize()

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
OLD_CLASSES = ['water_pools'] + CLASSES[1:]

# Change classes to include lakes
NEW_CLASSES = OLD_CLASSES + ['water_natural']
NEW_CLASSES[0] = 'water_pools'


def get_TF_classified_image(image, bands, tf_model, classes, name='classification'):
    
    '''
    Use a TF model hosted on Google AI Platform to classify an EE image.
    '''
    
    # Select bands from training image for classification
    selected_image = image.select(bands)

    # Get the predictions
    predictions = tf_model.predictImage(selected_image.float().toArray())
    probabilities = predictions.arrayFlatten([classes])
    classified_image = predictions.arrayArgmax().arrayGet([0]).rename(name)
    
    return classified_image, predictions, probabilities


def get_ensembled_classified_image(image, bands, model_dicts, combined_name='combined_classification'):
    
    """
    Get the ensembled classified image by getting the max prediction probability
    for each pixel across all models. 
    
    Each dict in model_dicts should contain at a minimum the following keys for a particular model:
        'model': the ee.Model object
        'classes': the classes that the model will try to predict
        'image_name': the name of the classified image from the model 
    """
    
    output_images = []
    combined_probs = None
    
    for model_dict in model_dicts:
        # Unpack the model metadata
        model = model_dict['model']
        classes = model_dict['classes']
        image_name = model_dict['image_name']
        
        # Predict on classified image
        temp_image, temp_preds, temp_probs = get_TF_classified_image(image, bands, model, classes, name=image_name)
        
        # If no combined_probs set, set it to temp_probs
        if combined_probs is None:
            combined_probs = temp_probs
        
        # Check if classes are not the same, then add missing bands 
        cur_prob_bands = set(combined_probs.bandNames().getInfo())
        add_cur_bands = list(cur_prob_bands - set(classes))
        add_new_bands = list(set(classes) - cur_prob_bands)
        
        if add_cur_bands:
            temp_probs = temp_probs.addBands(combined_probs, add_cur_bands)
        if add_new_bands:
            combined_probs = combined_probs.addBands(temp_probs, add_new_bands)
        
        # Get the max probs across the two images
        combined_probs = combined_probs.max(temp_probs)
        output_images.append(temp_image)
    
    # Get the final combined classification image based on maximum probabilities
    classified_image = combined_probs.toArray().arrayArgmax().arrayGet([0]).rename(combined_name)
    output_images.append(classified_image)
    
    return output_images


# Generate training image

counties = ee.FeatureCollection("TIGER/2018/Counties")
la_county = counties.filter(ee.Filter.eq('NAME', 'Los Angeles'))

training_image_params = {
        'source_image_collection' : 'USDA/NAIP/DOQQ',
        'years' : [2020],
        'counties': {'lacounty': la_county}
         }

TRAINING_IMAGE = get_images(training_image_params)['2020_la_county']


# Point to the TF model(s) to be used for inference
PROJECT = 'w210-351617'
VERSION_NAME = 'v0'
OLD_MODEL_NAME = 'CNN_Nbands_model'
NEW_MODEL_NAME = 'CNN_Nbands_sep_cls_wlake_model'

input_dim = [12,12]

# Point to the old model hosted on AI Platform.
old_tf_model = ee.Model.fromAiPlatformPredictor(
    projectName=PROJECT,
    modelName=OLD_MODEL_NAME,
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

# Point to the old model hosted on AI Platform.
new_tf_model = ee.Model.fromAiPlatformPredictor(
    projectName=PROJECT,
    modelName=NEW_MODEL_NAME,
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

# Create model dictionaries
model_dicts = [
    {'model': old_tf_model, 'model_name': 'old_model', 'classes': OLD_CLASSES, 'image_name':'old_classification'},
    {'model': new_tf_model, 'model_name': 'new_model', 'classes': NEW_CLASSES, 'image_name':'new_classification'},
]

# Classify the training image per model + ensembled
classified_images = get_ensembled_classified_image(TRAINING_IMAGE, BANDS, model_dicts)

# Remap the combined image so lakes are classified as pools together
fromList = [0, 1, 2, 3, 4, 5, 6]
toList = [0, 1, 2, 3, 4, 5, 0]

training_image_classified = classified_images[-1].remap(fromList, toList)
training_image_classified = training_image_classified.rename('classification')

assert(training_image_classified.bandNames().getInfo() == ['classification'])

