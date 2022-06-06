from fastapi import FastAPI
import uvicorn

#custom imports
from mod.apikey import get_api_key
from mod.gmaps_image import router1
from mod.geom import router2

app = FastAPI()

#import router to download images via gmaps api
app.include_router(router1, prefix = '/get_image')
#import router to get square meters of coordinate space
app.include_router(router2, prefix = '/geometry')

@app.get("/")
async def root():
    return ("WELCOME TO THE LAWN CONVERSION PROJECT")

if __name__=="__main__":
    uvicorn.run("main:app",host='0.0.0.0', port=5000, reload=True)
