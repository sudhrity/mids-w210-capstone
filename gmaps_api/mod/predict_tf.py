from fastapi import APIRouter
import requests
import io
import numpy as np
from tensorflow import keras


#image imports
from skimage.transform import resize
from PIL import Image


#create API router to feed into main.py
router1 = APIRouter() #ROUTER PREFIX = /predict_tf


########## model parameters##############

MODELS_FOLDER = 'saved_models/'
MODEL_FILENAME = 'cnn200_model'
MODEL = keras.models.load_model(MODELS_FOLDER+MODEL_FILENAME)
DIM = 200

########## model parameters##############

def predict(model, array):
    prediction = (model.predict(array))
    if (prediction[0][0]<.5):
        return('NO LAWN DETECTED')
    else:
        return('LAWN DETECTED')


@router1.get("/coord={coordinates}&key={API_KEY}")
async def produce_image(coordinates, API_KEY):
    # base URL
    BASE_URL = "https://maps.googleapis.com/maps/api/staticmap?"

    ############ADJUSTABLE PARAMETERS FOR EXTENDED URL#############
    #coordinates of photo
    COORD = coordinates

    # zoom value (leave at 20 for now for training purposes)
    ZOOM = 20

    #pixels (leave at 500 for now for training purposes)
    SIZE = 500

    ######################################################

    # updating the URL
    URL = BASE_URL + "center=" + COORD + "&zoom=" + str(ZOOM) + f"&size={SIZE}x{SIZE}&key=" + API_KEY + "&maptype=satellite"

    # HTTP request
    response = requests.get(URL)
    imageStream = io.BytesIO(response.content)
    im = Image.open(imageStream).convert('RGB')
    arr = np.array(im)
    arr_resized = resize(arr, (DIM, DIM, 3))

    prediction = predict(MODEL, arr_resized.reshape(-1,DIM, DIM, 3))

    return {
            'URL': URL,
            'response': str(response),
            'image_array': str(arr),
            'prediction': str(prediction),
            'image_dimension': arr.shape[0]
           }
