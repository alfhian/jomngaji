from __future__ import annotations

import base64
import binascii
from typing import List

import librosa
import numpy as np
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(title="JomNgaji Voice Intelligence API")


class VoiceAssessmentRequest(BaseModel):
    audio_base64: str = Field(..., description="Base64 encoded mono PCM16 audio stream")
    sample_rate: int = Field(16000, gt=0, le=48000)
    script: str | None = Field(None, description="Optional ayat or potongan bacaan")
    target_focus: List[str] = Field(default_factory=list, description="Specific focus areas requested by the coach")


class RecommendedMission(BaseModel):
    title: str
    mission_type: str
    focus: str
    description: str


class VoiceAssessmentResponse(BaseModel):
    overall_score: float
    tajwid: float
    fluency: float
    makhraj: float
    pacing: float
    duration_seconds: float
    ai_summary: str
    focus_areas: List[str]
    recommended_missions: List[RecommendedMission]


def _decode_audio(payload: VoiceAssessmentRequest) -> np.ndarray:
    try:
        raw = base64.b64decode(payload.audio_base64)
    except (ValueError, binascii.Error) as exc:
        raise HTTPException(status_code=400, detail="Audio must be valid base64") from exc

    audio = np.frombuffer(raw, dtype=np.int16).astype(np.float32)
    if audio.size == 0:
        raise HTTPException(status_code=400, detail="Audio payload is empty")
    return audio / np.iinfo(np.int16).max


def _extract_features(waveform: np.ndarray, sample_rate: int) -> dict[str, float]:
    rms = float(np.sqrt(np.mean(np.square(waveform))))
    zcr = float(np.mean(librosa.feature.zero_crossing_rate(y=waveform)))
    duration = waveform.size / sample_rate
    spectral_flatness = float(np.mean(librosa.feature.spectral_flatness(y=waveform)))
    pitch = librosa.yin(waveform, fmin=80, fmax=500, sr=sample_rate)
    pitch = np.nan_to_num(pitch, nan=0.0)
    pitch_variance = float(np.var(pitch)) if pitch.size else 0.0
    tempo_series = librosa.beat.tempo(y=waveform, sr=sample_rate, aggregate=None)
    tempo = float(np.nan_to_num(tempo_series.mean(), nan=95.0))

    return {
      'rms': rms,
      'zcr': zcr,
      'duration': duration,
      'spectral_flatness': spectral_flatness,
      'pitch_variance': pitch_variance,
      'tempo': tempo,
    }


def _score_features(features: dict[str, float]) -> dict[str, float]:
    energy = min(1.0, features['rms'] * 120)
    clarity = max(0.0, 1.0 - features['zcr'])
    stability = max(0.0, 1.0 - min(1.0, features['spectral_flatness'] * 2))
    pitch_control = max(0.0, 1.0 - min(1.0, features['pitch_variance'] / 50))
    pace_target = 95.0
    pace_delta = abs(features['tempo'] - pace_target)
    pacing = max(0.0, 1.0 - min(1.0, pace_delta / 60))

    tajwid = (clarity * 0.5 + pitch_control * 0.5) * 100
    fluency = (pacing * 0.6 + stability * 0.4) * 100
    makhraj = (clarity * 0.6 + energy * 0.4) * 100
    pacing_score = pacing * 100
    overall = (tajwid * 0.4 + fluency * 0.3 + makhraj * 0.2 + pacing_score * 0.1)

    return {
        'overall': round(overall, 2),
        'tajwid': round(tajwid, 2),
        'fluency': round(fluency, 2),
        'makhraj': round(makhraj, 2),
        'pacing': round(pacing_score, 2),
    }


def _derive_focus_areas(scores: dict[str, float], payload: VoiceAssessmentRequest) -> list[str]:
    focus: list[str] = []
    if scores['tajwid'] < 80:
        focus.append('Perkuat tajwid pada mad dan idgham yang terdengar kurang mulus.')
    if scores['makhraj'] < 78:
        focus.append('Latih artikulasi makhraj huruf-huruf tebal dan tipis secara konsisten.')
    if scores['fluency'] < 75:
        focus.append('Jaga kesinambungan bacaan dan hindari jeda yang terlalu panjang.')
    if scores['pacing'] < 72:
        focus.append('Stabilkan tempo mendekati 95 bpm agar tarikan nafas lebih seimbang.')

    for item in payload.target_focus:
        if item not in focus:
            focus.append(item)
    return focus or ['Pertahankan konsistensi bacaan pada sesi berikutnya.']


def _compose_summary(scores: dict[str, float], focus: list[str], payload: VoiceAssessmentRequest) -> str:
    base = (
        f"Skor keseluruhan {scores['overall']} dengan tajwid {scores['tajwid']} dan "
        f"kelancaran {scores['fluency']}. "
    )
    script_hint = f"Pada potongan '{payload.script[:40]}...' " if payload.script else ''
    focus_hint = focus[0]
    return f"{base}{script_hint}Fokus utama sesi berikutnya: {focus_hint}"


def _craft_recommendations(focus: list[str]) -> list[RecommendedMission]:
    missions: list[RecommendedMission] = []
    if any('tajwid' in item.lower() for item in focus):
        missions.append(
            RecommendedMission(
                title='Drill Tajwid Mad & Idgham',
                mission_type='AI_PRACTICE',
                focus='Tajwid',
                description='Latihan mandiri 10 menit dengan penekanan pada mad thabi\'i dan idgham billaghunnah.',
            )
        )
    if any('tempo' in item.lower() or 'tempo' in item for item in focus):
        missions.append(
            RecommendedMission(
                title='Metronome Tilawah',
                mission_type='REFLECTION',
                focus='Pacing',
                description='Gunakan metronom 95 bpm untuk menjaga alur nafas pada 2 halaman pilihan.',
            )
        )
    if any('artikulas' in item.lower() or 'makhraj' in item.lower() for item in focus):
        missions.append(
            RecommendedMission(
                title='Clinic Makhraj Bersama Coach',
                mission_type='LIVE_SESSION',
                focus='Artikulasi',
                description='Sesi 30 menit dengan coach untuk mengulangi huruf shod, dhod, dan qof.',
            )
        )
    if not missions:
        missions.append(
            RecommendedMission(
                title='Murajaah Terbimbing',
                mission_type='AI_PRACTICE',
                focus='Konsistensi',
                description='Review dua halaman terakhir dengan highlight otomatis dari AI.',
            )
        )
    return missions


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/v1/assessments/voice", response_model=VoiceAssessmentResponse)
def assess_voice(payload: VoiceAssessmentRequest) -> VoiceAssessmentResponse:
    waveform = _decode_audio(payload)
    features = _extract_features(waveform, payload.sample_rate)
    scores = _score_features(features)
    focus = _derive_focus_areas(scores, payload)
    summary = _compose_summary(scores, focus, payload)
    missions = _craft_recommendations(focus)

    return VoiceAssessmentResponse(
        overall_score=scores['overall'],
        tajwid=scores['tajwid'],
        fluency=scores['fluency'],
        makhraj=scores['makhraj'],
        pacing=scores['pacing'],
        duration_seconds=round(features['duration'], 2),
        ai_summary=summary,
        focus_areas=focus,
        recommended_missions=missions,
    )
