from fastapi import FastAPI, Request
import uvicorn
from pydantic import BaseModel


#custom imports
from mod.api import router1
# from mod.zip import router2

# import ee
# ee.Initialize()



app = FastAPI()

#import router to output a classification with a tensorflow model
app.include_router(router1, prefix = '/polygon_areas')
# app.include_router(router2, prefix = '/test')

@app.get("/test")
async def root():
    return ("WELCOME TO THE LAWN CONVERSION PROJECT")


    
# @app.get('/test')
# async def test():
#     return( 'TEST IS WORKING')

if __name__=="__main__":
    uvicorn.run("main:app",host='0.0.0.0', port=5000, reload=True)
    
    
