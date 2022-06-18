from sqlalchemy import Boolean, Column, ForeignKey, Numeric, Integer, String
from sqlalchemy.orm import relationship

from mlapi.database import Base

class SentimentScore(Base):
    __tablename__ = "sentiment"

    id = Column(Integer, primary_key=True, index=True)
    text = Column(String, unique=True, index=True)
    positive_score = Column(Numeric(10, 6))
    negative_score = Column(Numeric(10, 6))
