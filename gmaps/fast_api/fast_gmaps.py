from fastapi import FastAPI
import requests

app = FastAPI()


#upload API key
try:
    with open('api_key.txt', 'r') as f:
        API_KEY = f.read().strip()
except:
    API_KEY = ''

@app.get("/")
async def root():
    return ("WELCOME TO THE LAWN PROJECT")


@app.get("/{coordinates}")
async def produce_image(coordinates, key = API_KEY):
    # base URL
    BASE_URL = "https://maps.googleapis.com/maps/api/staticmap?"

    ################## PARAMETERS ########################
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
        return {'RESPONSE 200. REQUEST SUCCESSFUL.'}
    if '400' in str(response):
        return {'RESPONSE 400. REQUEST NOT SUCCESSFUL.'}
