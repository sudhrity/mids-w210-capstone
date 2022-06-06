from fastapi import FastAPI, Request
import uvicorn
from pydantic import BaseModel

#custom imports
from mod.apikey import get_api_key
from mod.gmaps_image import router1
from mod.geom import router2

app = FastAPI()

ids = []
people = {'used_ids':[ids]}

class User(BaseModel):
    name: str
    age: int

#import router to download images via gmaps api
app.include_router(router1, prefix = '/get_image')
#import router to get square meters of coordinate space
app.include_router(router2, prefix = '/geometry')

@app.get("/")
async def root():
    return ("WELCOME TO THE LAWN CONVERSION PROJECT")

#https://security.stackexchange.com/questions/154462/why-cant-we-use-post-method-for-all-requests#:~:text=POST%20%3A%20can%20make%20changes%20server,typically%20set%20an%20account%20value

# https://stackoverflow.com/questions/64379089/fastapi-how-to-read-body-as-any-valid-json
# @app.post("/user/{user_id}")
# def get_body(user_id, user: User):
#     if user_id in people:
#         return {'ERROR':'USER ID ALREADY TAKEN'}
#     people[user_id] = user
#     return people

@app.post("/user/{user_id}")
async def get_body(user_id):
    if user_id in ids:
        return {'ERROR':'USER ID ALREADY TAKEN'}
    ids.append(user_id)
    people['used_ids'] = ids
    return people

if __name__=="__main__":
    uvicorn.run("main:app",host='0.0.0.0', port=5000, reload=True)
