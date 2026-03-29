from sqlalchemy import Column, Integer, Text, JSON, DateTime, UniqueConstraint
from sqlalchemy.sql import func
from app.db.base import Base

class TadarusEvaluation(Base):
    __tablename__ = "learning_evaluations"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, nullable=False)
    feature_type = Column(Text, nullable=False, default="tadarus")
    surah = Column(Integer, nullable=True)
    ayah = Column(Integer, nullable=True)

    score_final = Column(Integer, nullable=True)
    score_ayat = Column(Integer, nullable=True)
    score_audio = Column(Integer, nullable=True)

    asr_user = Column(Text)
    asr_ref = Column(Text)

    issues = Column(JSON)
    suggestions = Column(JSON)

    evaluated_at = Column(DateTime, server_default=func.now())
    updated_at = Column(
        DateTime,
        server_default=func.now(),
        onupdate=func.now()
    )

    __table_args__ = (
        UniqueConstraint("user_id", "feature_type", "surah", "ayah"),
    )
