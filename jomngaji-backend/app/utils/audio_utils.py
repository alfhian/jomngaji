import os
import shutil
import subprocess
import tempfile
from pathlib import Path

class AudioConversionError(RuntimeError):
    """Raised when uploaded audio cannot be converted to WAV."""


def _resolve_ffmpeg_binary() -> str:
    env_binary = os.getenv("FFMPEG_BINARY", "").strip()
    if env_binary:
        # dukung format .env dengan kutip:
        # FFMPEG_BINARY='/usr/bin/ffmpeg' atau "..."
        env_binary = env_binary.strip("'\"")

        # jika user isi nama command (mis. "ffmpeg"), resolve via PATH
        if "/" not in env_binary:
            resolved_cmd = shutil.which(env_binary)
            if resolved_cmd:
                return resolved_cmd

        if Path(env_binary).exists():
            return env_binary
        raise AudioConversionError(
            f"FFMPEG_BINARY diset ke '{env_binary}', tetapi file tidak ditemukan."
        )

    detected = shutil.which("ffmpeg")
    if detected:
        return detected

    for candidate in ("/usr/bin/ffmpeg", "/usr/local/bin/ffmpeg", "/bin/ffmpeg"):
        if Path(candidate).exists():
            return candidate

    raise AudioConversionError(
        "Konversi audio membutuhkan ffmpeg, tetapi ffmpeg belum terpasang "
        "atau belum ada di PATH service. Install ffmpeg sistem dan/atau set "
        "environment variable FFMPEG_BINARY."
    )


def ensure_wav(path: str) -> str:
    # kalau sudah wav, langsung return
    if path.lower().endswith(".wav"):
        return path
    # convert ke wav standar
    new_path = os.path.splitext(path)[0] + ".wav"
    ffmpeg_bin = _resolve_ffmpeg_binary()
    cmd = [ffmpeg_bin, "-y", "-i", path, "-ar", "16000", "-ac", "1", new_path]
    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True)
    except FileNotFoundError as exc:
        raise AudioConversionError(
            "Binary ffmpeg tidak bisa dieksekusi. Pastikan path ffmpeg valid "
            "dan bisa diakses oleh user service."
        ) from exc
    except subprocess.CalledProcessError as exc:
        err_msg = (exc.stderr or exc.stdout or "").strip()
        raise AudioConversionError(
            "Gagal mengonversi audio ke format WAV. "
            f"Detail ffmpeg: {err_msg or 'unknown error'}"
        ) from exc
    return new_path

def convert_to_wav(path: str) -> str:
    new_path = os.path.splitext(path)[0] + "_conv.wav"
    ffmpeg_bin = _resolve_ffmpeg_binary()
    cmd = [ffmpeg_bin, "-y", "-i", path, "-ar", "16000", "-ac", "1", new_path]
    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True)
    except FileNotFoundError as exc:
        raise AudioConversionError(
            "Binary ffmpeg tidak bisa dieksekusi. Pastikan path ffmpeg valid "
            "dan bisa diakses oleh user service."
        ) from exc
    except subprocess.CalledProcessError as exc:
        err_msg = (exc.stderr or exc.stdout or "").strip()
        raise AudioConversionError(
            "Gagal mengonversi audio ke format WAV. "
            f"Detail ffmpeg: {err_msg or 'unknown error'}"
        ) from exc
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
