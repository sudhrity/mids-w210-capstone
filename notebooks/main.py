from fastapi import FastAPI, Request
import uvicorn
from pydantic import BaseModel

#custom imports
from areas import router1
from areas import router2


app = FastAPI()

#import router to output a classification with a tensorflow model
app.include_router(router1, prefix = '/predict_polygon')
app.include_router(router2, prefix = '/predict_region')

@app.get("/")
async def root():
    return ("WELCOME TO THE LAWN CONVERSION PROJECT")


if __name__=="__main__":
    uvicorn.run("main:app",host='0.0.0.0', port=5000, reload=True)
