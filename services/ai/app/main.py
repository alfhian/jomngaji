from __future__ import annotations

import base64
import binascii
from typing import Tuple

import librosa
import numpy as np
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(title="JomNgaji Voice Scoring API")


class ScoreRequest(BaseModel):
    audio_base64: str = Field(..., description="Base64 encoded mono PCM16 audio stream")
    sample_rate: int = Field(16000, gt=0, le=48000)


class ScoreResponse(BaseModel):
    score: float
    energy: float
    clarity: float
    duration_seconds: float
    feedback: str


def _decode_audio(payload: ScoreRequest) -> np.ndarray:
    try:
        raw = base64.b64decode(payload.audio_base64)
    except (ValueError, binascii.Error) as exc:
        raise HTTPException(status_code=400, detail="Audio must be valid base64") from exc

    audio = np.frombuffer(raw, dtype=np.int16).astype(np.float32)
    if audio.size == 0:
        return audio
    return audio / np.iinfo(np.int16).max


def _extract_features(waveform: np.ndarray, sample_rate: int) -> Tuple[float, float, float]:
    if waveform.size == 0:
        return 0.0, 0.0, 0.0

    rms = float(np.mean(librosa.feature.rms(y=waveform)))
    zcr = float(np.mean(librosa.feature.zero_crossing_rate(y=waveform)))
    duration = waveform.size / sample_rate

    clarity = max(0.0, 1.0 - zcr)
    return rms, clarity, duration


def _compose_feedback(score: float) -> str:
    if score >= 85:
        return "Bacaan sangat baik, pertahankan konsistensinya!"
    if score >= 60:
        return "Bacaan cukup baik, perhatikan artikulasi pada beberapa bagian."
    return "Perlu latihan intensif untuk kestabilan suara dan tajwid."


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/v1/score", response_model=ScoreResponse)
def score_audio(payload: ScoreRequest) -> ScoreResponse:
    waveform = _decode_audio(payload)
    energy, clarity, duration = _extract_features(waveform, payload.sample_rate)

    if duration == 0:
        raise HTTPException(status_code=400, detail="Audio payload is empty")

    score = float(min(100.0, (energy * 120) + (clarity * 80)))
    feedback = _compose_feedback(score)

    return ScoreResponse(
        score=round(score, 2),
        energy=round(energy, 4),
        clarity=round(clarity, 4),
        duration_seconds=round(duration, 2),
        feedback=feedback,
    )
