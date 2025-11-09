import base64

import numpy as np
from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def _fake_audio() -> tuple[str, int]:
    """Generate a short synthetic waveform and return it as base64."""
    sample_rate = 16000
    t = np.linspace(0, 0.5, int(sample_rate * 0.5), endpoint=False)
    waveform = 0.3 * np.sin(2 * np.pi * 440 * t)
    pcm16 = (waveform * np.iinfo(np.int16).max).astype(np.int16)
    return base64.b64encode(pcm16.tobytes()).decode(), sample_rate


def test_health_endpoint() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_score_endpoint_returns_score() -> None:
    audio, sample_rate = _fake_audio()
    response = client.post(
        "/v1/score",
        json={"audio_base64": audio, "sample_rate": sample_rate},
    )

    assert response.status_code == 200
    data = response.json()
    assert "score" in data
    assert data["score"] > 0
    assert data["energy"] > 0
