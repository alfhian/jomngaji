import base64

import numpy as np
from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def _fake_audio() -> tuple[str, int]:
    """Generate a short synthetic waveform and return it as base64."""
    sample_rate = 16000
    t = np.linspace(0, 0.8, int(sample_rate * 0.8), endpoint=False)
    waveform = 0.35 * np.sin(2 * np.pi * 220 * t)
    pcm16 = (waveform * np.iinfo(np.int16).max).astype(np.int16)
    return base64.b64encode(pcm16.tobytes()).decode(), sample_rate


def test_health_endpoint() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_assessment_endpoint_returns_recommendations() -> None:
    audio, sample_rate = _fake_audio()
    response = client.post(
        "/v1/assessments/voice",
        json={
            "audio_base64": audio,
            "sample_rate": sample_rate,
            "script": "Al-Fatihah 1-5",
            "target_focus": ["Perkuat ghunnah"],
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert set(["overall_score", "tajwid", "fluency", "makhraj", "pacing"]).issubset(data.keys())
    assert isinstance(data["focus_areas"], list)
    assert data["focus_areas"], "Focus areas should not be empty"
    assert data["recommended_missions"], "Recommended missions should not be empty"
