from fastapi import APIRouter
import requests

#custom imports
from mod.apikey import get_api_key

#create API router to feed into main.py
router1 = APIRouter()

#access api key from api_key.txt file
API_KEY = get_api_key('api_key.txt')


@router1.get("/{coordinates}")
async def produce_image(coordinates, key = API_KEY):
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
    URL = BASE_URL + "center=" + COORD + "&zoom=" + str(ZOOM) + f"&size={SIZE}x{SIZE}&key=" + key + "&maptype=satellite"

    # HTTP request
    response = requests.get(URL)

    # storing the response in a file (png image)
    with open(f'{COORD}.png', 'wb') as file:
       # writing data into the file
       file.write(response.content)

    if '200' in str(response):
        return {'RESPONSE': '200. REQUEST SUCCESSFUL. IMAGE SAVED.'}
    if '400' in str(response):
        return {'RESPONSE': '400. REQUEST NOT SUCCESSFUL.'}
