from fastapi import FastAPI, Request
import uvicorn
from pydantic import BaseModel

#custom imports
from mod.predict_tf import router1
from mod.poly import router2


app = FastAPI()

#import router to output a classification with a tensorflow model
app.include_router(router1, prefix = '/predict_tf')
#import router to get square meters of coordinate space
app.include_router(router2, prefix = '/polygon')

@app.get("/")
async def root():
    return ("WELCOME TO THE LAWN CONVERSION PROJECT")


if __name__=="__main__":
    uvicorn.run("main:app",host='0.0.0.0', port=5000, reload=True)


##############################

### template just for reference
# people = {}
# class User(BaseModel):
#     name: str
#     age: int

# ## https://security.stackexchange.com/questions/154462/why-cant-we-use-post-method-for-all-requests#:~:text=POST%20%3A%20can%20make%20changes%20server,typically%20set%20an%20account%20value
# ## https://stackoverflow.com/questions/64379089/fastapi-how-to-read-body-as-any-valid-json
# @app.post("/user/{user_id}")
# def get_body(user_id, user: User):
#     if user_id in people:
#         return {'ERROR':'USER ID ALREADY TAKEN'}
#     people[user_id] = user
#     return people
################################
