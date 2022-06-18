import mlapi.models
from mlapi.models import SentimentScore

from fastapi import FastAPI, Request, Response, Depends, BackgroundTasks
from fastapi.templating import Jinja2Templates
from mlapi.database import SessionLocal, engine
from pydantic import BaseModel 

from sqlalchemy.orm import Session

import logging
import os
from typing import Dict

from fastapi_redis_cache import FastApiRedisCache, cache_one_minute
from transformers import pipeline, AutoModelForSequenceClassification, AutoTokenizer


app = FastAPI()

mlapi.models.Base.metadata.create_all(bind=engine)

templates = Jinja2Templates(directory="templates")

@app.on_event("startup")
def startup():
    redis_cache = FastApiRedisCache()
    redis_cache.init(
        host_url=os.environ.get("REDIS_URL", LOCAL_REDIS_URL),
        prefix="mlapi-cache",
        response_header="X-MLAPI-Cache",
        ignore_arg_types=[Request, Response],
    )

class SentimentRequest(BaseModel):
    text: list[str]

class Sentiment(BaseModel):
    label: str
    score: float

class SentimentResponse(BaseModel):
    predictions: list[list[Sentiment]] 

class StockRequest(BaseModel):
    symbol: str

def get_db():
    try:
        db = SessionLocal()
        yield db
    finally:
        db.close()

@app.get("/")
def home(request: Request, positive_score = None, negative_score = None, db: Session = Depends(get_db)):

    sentiments = db.query(SentimentScore)

    if positive_score:
        sentiments = sentiments.filter(SentimentScore.positive_score > positive_score)

    if negative_score:
         sentiments = sentiments.filter(SentimentScore.negative_score < negative_score)
    
    sentiments = sentiments.all()

    return templates.TemplateResponse("home.html", {
        "request": request, 
        "sentiments": sentiments, 
        "positive_score": positive_score,
        "negative_score": negative_score
    })


def fetch_prediction(id: int):
    
    db = SessionLocal()

    sentiment = db.query(SentimentScore).filter(SentimentScore.id == id).first()

    response = classifier(sentiment.text)

#    print("sentiment:", sentiment.text, sentiment.positive_score, sentiment.negative_score)
    
    sentiment.negative_score = list(response[0][0].values())[1]
    sentiment.positive_score = list(response[0][1].values())[1]

    db.add(sentiment)
    db.commit()

model_path = "./distilbert-base-uncased-finetuned-sst2"
model = AutoModelForSequenceClassification.from_pretrained(model_path)
tokenizer = AutoTokenizer.from_pretrained(model_path)
classifier = pipeline(
    task="text-classification",
    model=model,
    tokenizer=tokenizer,
    device=-1,
    return_all_scores=True,
)

@app.post("/predict2")
async def create_text(sentiment_request: SentimentRequest, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
 
    sentiment = SentimentScore()
    sentiment.text = sentiment_request.text[0]
    db.add(sentiment)
    db.commit()

    background_tasks.add_task(fetch_prediction, sentiment.id)

    return {
        "code": "success",
        "message": "text was added to the database"
    }


logger = logging.getLogger(__name__)
LOCAL_REDIS_URL = "redis://redis:6379/0"

@app.get("/predict", response_model=SentimentResponse)
@cache_one_minute()
def predict(sentiments: SentimentRequest):
    return {"predictions": classifier(sentiments.text)}

@app.post("/predict", response_model=SentimentResponse)
@cache_one_minute()
def predict(sentiments: SentimentRequest):
    return {"predictions": classifier(sentiments.text)}


@app.get("/health")
async def health():
    return {"status": "healthy"}