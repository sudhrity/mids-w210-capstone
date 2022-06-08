from fastapi import APIRouter
import requests
import io
import numpy as np
from PIL import Image

import joblib

#custom imports
from mod.apikey import get_api_key

#create API router to feed into main.py
router1 = APIRouter() #ROUTER PREFIX = /predict_image

#access api key from api_key.txt file
API_KEY = get_api_key('api_key.txt')

########## placeholder model ##############

model_filename = 'rf_model.sav'
MODEL = joblib.load(model_filename)



def predict(model, array):
    prediction = model.predict(array)
    if prediction[0] == 0:
        return('NO LAWN DETECTED')
    else:
        return('LAWN DETECTED')

 ##########################################

@router1.get("/{coordinates}&key={API_KEY}") #router prefix = 'predict_image/'
async def produce_image(coordinates, API_KEY):
    # base URL
    BASE_URL = "https://maps.googleapis.com/maps/api/staticmap?"

    ############ADJUSTABLE PARAMETERS FOR EXTENDED URL#############
    #coordinates of photo
    COORD = coordinates

    # zoom value (leave at 20 for now for training purposes)
    ZOOM = 20

    #pixels (leave at 500 for now for training purposes)
    SIZE = 200

    ######################################################

    # updating the URL
    URL = BASE_URL + "center=" + COORD + "&zoom=" + str(ZOOM) + f"&size={SIZE}x{SIZE}&key=" + API_KEY + "&maptype=satellite"

    # HTTP request
    response = requests.get(URL)
    imageStream = io.BytesIO(response.content)
    im = Image.open(imageStream).convert('P')
    arr = np.array(im).flatten()

    prediction = predict(MODEL, arr.reshape(1,-1))

    return {
            'URL': URL,
            'response': str(response),
            'image_array': str(arr),
            'prediction': str(prediction),
            'length': arr.shape[0]
           }
