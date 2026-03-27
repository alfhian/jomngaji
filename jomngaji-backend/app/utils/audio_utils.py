import os
import subprocess
import tempfile
from pathlib import Path

def ensure_wav(path: str) -> str:
    # kalau sudah wav, langsung return
    if path.lower().endswith(".wav"):
        return path
    # convert ke wav standar
    new_path = os.path.splitext(path)[0] + ".wav"
    cmd = ["ffmpeg", "-y", "-i", path, "-ar", "16000", "-ac", "1", new_path]
    subprocess.run(cmd, check=True)
    return new_path

def convert_to_wav(path: str) -> str:
    new_path = os.path.splitext(path)[0] + "_conv.wav"
    cmd = ["ffmpeg", "-y", "-i", path, "-ar", "16000", "-ac", "1", new_path]
    subprocess.run(cmd, check=True)
    return new_path


def _resolve_upload_dir(folder: str = "temp") -> Path:
    """
    Resolve folder upload yang writable untuk service user (mis. www-data).

    Urutan prioritas:
    1) UPLOAD_TMP_DIR (jika diset di environment)
    2) folder relatif yang diberikan (backward compatible)
    3) fallback ke /tmp/jomngaji_uploads
    """
    env_dir = os.getenv("UPLOAD_TMP_DIR", "").strip()
    candidates = [
        Path(env_dir) if env_dir else None,
        Path(folder),
        Path(tempfile.gettempdir()) / "jomngaji_uploads",
    ]

    for candidate in candidates:
        if candidate is None:
            continue
        try:
            candidate.mkdir(parents=True, exist_ok=True)
            probe = candidate / ".write_test"
            probe.write_text("ok", encoding="utf-8")
            probe.unlink(missing_ok=True)
            return candidate
        except OSError:
            continue

    raise PermissionError("Tidak ada direktori upload yang writable.")


def save_upload(file, folder="temp") -> str:
    target_dir = _resolve_upload_dir(folder)
    filename = os.path.basename(file.filename or "audio_upload")
    path = target_dir / filename
    with open(path, "wb") as f:
        f.write(file.file.read())
    return str(path)
