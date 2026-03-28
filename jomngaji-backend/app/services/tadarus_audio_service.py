import os
from pathlib import Path

import numpy as np
from fastapi import UploadFile
from difflib import SequenceMatcher

from app.utils.audio_utils import AudioConversionError, save_upload, ensure_wav
from app.services.tadarus_asr_service import transcribe_tadarus
from app.services.tadarus_service import evaluate_tadarus, get_score_band

# =========================================================
SAMPLE_RATE = 16000

AYAT_WEIGHT = 0.8
AUDIO_WEIGHT = 0.2

_torch = None
_torchaudio = None
_processor = None
_model = None
_device = "cpu"


def _load_audio_dependencies():
    global _torch, _torchaudio
    if _torch is None or _torchaudio is None:
        try:
            import torch
            import torchaudio
            _torch, _torchaudio = torch, torchaudio
        except ModuleNotFoundError as exc:
            raise RuntimeError(
                "Dependency audio belum lengkap. Install `torch` dan `torchaudio`."
            ) from exc
    return _torch, _torchaudio




def _resolve_hf_cache_dir() -> Path:
    backend_root = Path(__file__).resolve().parents[2]
    default_cache_home = backend_root / ".cache" / "huggingface"

    configured_home = os.getenv("HF_HOME")
    candidates = [Path(configured_home)] if configured_home else []
    candidates.append(default_cache_home)

    for cache_home in candidates:
        try:
            cache_home.mkdir(parents=True, exist_ok=True)
            probe_file = cache_home / ".write_probe"
            probe_file.write_text("ok", encoding="utf-8")
            probe_file.unlink(missing_ok=True)
            return cache_home
        except OSError:
            continue

    raise RuntimeError(
        "Tidak menemukan cache directory Hugging Face yang writable. "
        "Atur HF_HOME ke path yang bisa ditulis user service."
    )


def _load_wav2vec_stack():
    global _processor, _model, _device
    torch, _ = _load_audio_dependencies()
    if _processor is None or _model is None:
        try:
            from transformers import Wav2Vec2Processor, Wav2Vec2Model
        except ModuleNotFoundError as exc:
            raise RuntimeError(
                "Dependency `transformers` belum terpasang."
            ) from exc
        _device = "cuda" if torch.cuda.is_available() else "cpu"
        cache_dir = _resolve_hf_cache_dir()
        os.environ.setdefault("HF_HOME", str(cache_dir))
        os.environ.setdefault("HF_HUB_CACHE", str(cache_dir / "hub"))
        os.environ.setdefault("TRANSFORMERS_CACHE", str(cache_dir / "transformers"))
        model_id = "facebook/wav2vec2-base-960h"

        try:
            _processor = Wav2Vec2Processor.from_pretrained(
                model_id,
                cache_dir=str(cache_dir),
            )
            _model = Wav2Vec2Model.from_pretrained(
                model_id,
                cache_dir=str(cache_dir),
            ).to(_device)
            _model.eval()
        except OSError as exc:
            raise RuntimeError(
                "Gagal memuat model wav2vec. Pastikan directory cache dapat ditulis "
                "oleh user service (HF_HOME) dan koneksi internet server tersedia. "
                f"Detail: {exc}"
            ) from exc
    return _processor, _model, _device, torch

# =========================================================
def load_audio_16k(path: str) -> np.ndarray:
    _, torchaudio = _load_audio_dependencies()
    wav, sr = torchaudio.load(path)

    if wav.numel() == 0:
        return np.array([])

    if wav.shape[0] > 1:
        wav = wav.mean(dim=0, keepdim=True)

    if sr != SAMPLE_RATE:
        wav = torchaudio.functional.resample(wav, sr, SAMPLE_RATE)

    return wav.squeeze().numpy()

def is_valid_audio(audio: np.ndarray, min_duration=1.2, min_rms=0.01) -> bool:
    if audio is None or len(audio) == 0:
        return False

    duration = len(audio) / SAMPLE_RATE
    if duration < min_duration:
        return False

    rms = np.sqrt(np.mean(audio ** 2))
    return rms >= min_rms

# =========================================================
def wav2vec_embedding(path: str) -> np.ndarray:
    processor, model, device, torch = _load_wav2vec_stack()
    audio = load_audio_16k(path)
    if len(audio) == 0:
        return np.zeros(768)

    inputs = processor(
        audio,
        sampling_rate=SAMPLE_RATE,
        return_tensors="pt"
    ).input_values.to(device)

    with torch.no_grad():
        outputs = model(inputs)
        emb = outputs.last_hidden_state.mean(dim=1)

    return emb.squeeze().cpu().numpy()

def audio_similarity(ref_path: str, user_path: str) -> float:
    ref = wav2vec_embedding(ref_path)
    usr = wav2vec_embedding(user_path)

    denom = np.linalg.norm(ref) * np.linalg.norm(usr)
    return float(np.dot(ref, usr) / denom) if denom != 0 else 0.0

# =========================================================
def normalize_arabic(text: str) -> str:
    harakat = "ًٌٍَُِّْـ"
    for h in harakat:
        text = text.replace(h, "")
    return text.replace(" ", "").strip()

def ayat_similarity(ref: str, user: str) -> float:
    r = normalize_arabic(ref)
    u = normalize_arabic(user)
    if not r or not u:
        return 0.0
    return SequenceMatcher(None, r, u).ratio()

# =========================================================
def evaluate_audio_only(
    *,
    user_audio: UploadFile,
    reference_audio: UploadFile,
    ayat_text: str,
) -> dict:

    print("\n========== [TADARUS EVALUATION] ==========")

    user_path = ensure_wav(save_upload(user_audio))
    ref_raw_path = save_upload(reference_audio)
    ref_path = ref_raw_path
    reference_conversion_unavailable = False

    try:
        ref_path = ensure_wav(ref_raw_path)
    except AudioConversionError as exc:
        reference_conversion_unavailable = True
        print(f"[REFERENCE CONVERSION FALLBACK] {exc}")

    try:
        audio_data = load_audio_16k(user_path)
        if not is_valid_audio(audio_data):
            print("[INVALID AUDIO]")
            return {"valid": False, "reason": "invalid_audio"}
    except Exception as exc:
        # Jangan gagalkan evaluasi tadarus jika stack audio embedding tidak siap.
        # Tetap lanjutkan penilaian berbasis teks (ASR).
        print(f"[AUDIO VALIDATION FALLBACK] {exc}")

    # =========================
    # ASR
    # =========================
    user_text = transcribe_tadarus(user_path)

    print("---------- [TEXT MATCHING] ----------")
    print(f"[AYAT TEXT] {ayat_text}")
    print(f"[USER TEXT] {user_text}")

    ayat_score = ayat_similarity(ayat_text, user_text) * 100
    audio_model_unavailable = False
    try:
        if reference_conversion_unavailable:
            raise RuntimeError("Reference audio conversion unavailable")
        audio_score = audio_similarity(ref_path, user_path) * 100
    except Exception as exc:
        audio_model_unavailable = True
        print(f"[AUDIO MODEL FALLBACK] {exc}")
        audio_score = ayat_score

    # Detail kesalahan pengucapan huruf dari evaluator tadarus
    text_scores, text_issues, text_suggestions = evaluate_tadarus(ayat_text, user_text)

    print(f"[AYAT SCORE ] {ayat_score:.2f}")
    print(f"[AUDIO SCORE] {audio_score:.2f}")

    final_score = round(
        ayat_score * AYAT_WEIGHT +
        audio_score * AUDIO_WEIGHT
    )

    final_score = max(0, min(100, final_score))

    print("---------- [FINAL SCORE] ----------")
    print(f"[FINAL] {final_score}")
    print("===================================\n")

    fallback_note = (
        [
            "Penilaian kemiripan audio sedang tidak tersedia di server, "
            "sementara skor akhir menggunakan penilaian teks bacaan."
        ]
        if audio_model_unavailable
        else []
    )

    return {
        "valid": True,
        "texts": {
            "user": user_text,
            "reference": ayat_text,
        },
        "scores": {
            "final": final_score,
            "ayat": int(ayat_score),
            "audio": int(audio_score),
            "band": get_score_band(final_score),
            "ayat_band": text_scores.get("band", get_score_band(int(ayat_score))),
            "audio_band": get_score_band(int(audio_score)),
        },
        "issues": text_issues,
        "suggestions": [*text_suggestions, *fallback_note],
    }
