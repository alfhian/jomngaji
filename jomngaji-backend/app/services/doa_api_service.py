from __future__ import annotations

import os
import time
from dataclasses import dataclass
from typing import Any
from urllib.parse import urlparse

import httpx


DEFAULT_DOA_SOURCE_URL = "https://www.hisnmuslim.com/api/en/husn_en.json"
_CACHE_TTL_SECONDS = 60 * 10
_DOA_CACHE: dict[str, Any] = {"expires_at": 0.0, "items": []}


@dataclass
class DoaItem:
    doa_id: str
    title: str
    arabic: str
    latin: str
    translation: str
    audio_url: str | None
    source: str = "hisnmuslim"

    def to_dict(self) -> dict[str, Any]:
        return {
            "id": self.doa_id,
            "title": self.title,
            "arabic": self.arabic,
            "latin": self.latin,
            "translation": self.translation,
            "audio_url": self.audio_url,
            "source": self.source,
        }


def _pick_text(obj: dict[str, Any], keys: list[str]) -> str:
    for key in keys:
        val = obj.get(key)
        if val is None:
            continue
        text = str(val).strip()
        if text:
            return text
    return ""


def _collect_objects(payload: Any) -> list[dict[str, Any]]:
    out: list[dict[str, Any]] = []

    def walk(node: Any) -> None:
        if isinstance(node, dict):
            out.append(node)
            for v in node.values():
                walk(v)
        elif isinstance(node, list):
            for x in node:
                walk(x)

    walk(payload)
    return out


def _normalize_items(payload: Any) -> list[DoaItem]:
    objects = _collect_objects(payload)
    items: list[DoaItem] = []
    seen_ids: set[str] = set()

    for idx, obj in enumerate(objects):
        title = _pick_text(obj, ["TITLE", "title", "name", "DOA_NAME"])
        arabic = _pick_text(
            obj,
            [
                "ARABIC_TEXT",
                "ARABIC",
                "AR_TEXT",
                "TEXT",
                "text",
            ],
        )
        latin = _pick_text(
            obj,
            [
                "LATIN",
                "TRANSLITERATION",
                "READING",
                "latin",
            ],
        )
        translation = _pick_text(
            obj,
            [
                "TRANSLATION",
                "TRANSLATED_TEXT",
                "MEANING",
                "translation",
            ],
        )
        audio_url = _pick_text(obj, ["AUDIO_URL", "audio_url", "AUDIO", "audio"]) or None

        if not (title or arabic):
            continue

        raw_id = _pick_text(obj, ["ID", "id", "SLUG", "slug"])
        doa_id = raw_id or f"doa_{idx + 1}"
        if doa_id in seen_ids:
            doa_id = f"{doa_id}_{idx + 1}"
        seen_ids.add(doa_id)

        items.append(
            DoaItem(
                doa_id=doa_id,
                title=title or doa_id.replace("_", " ").title(),
                arabic=arabic,
                latin=latin,
                translation=translation,
                audio_url=audio_url,
            )
        )

    return items


def _resolve_source_url(source_url: str | None) -> str:
    env_url = os.getenv("DOA_SOURCE_URL", "").strip()
    if source_url:
        return source_url
    if env_url:
        return env_url
    return DEFAULT_DOA_SOURCE_URL


def fetch_doa_items(*, force_refresh: bool = False, source_url: str | None = None) -> list[dict[str, Any]]:
    now = time.time()
    if not force_refresh and _DOA_CACHE["items"] and _DOA_CACHE["expires_at"] > now:
        return _DOA_CACHE["items"]

    url = _resolve_source_url(source_url)
    with httpx.Client(timeout=20.0, follow_redirects=True) as client:
        resp = client.get(url, headers={"User-Agent": "jomngaji-backend/1.0"})
        resp.raise_for_status()
        payload = resp.json()

    normalized = [item.to_dict() for item in _normalize_items(payload)]
    _DOA_CACHE["items"] = normalized
    _DOA_CACHE["expires_at"] = now + _CACHE_TTL_SECONDS
    return normalized


def get_doa_item(doa_id: str, *, source_url: str | None = None) -> dict[str, Any] | None:
    items = fetch_doa_items(source_url=source_url)
    for item in items:
        if str(item.get("id")) == str(doa_id):
            return item
    return None


def validate_audio_proxy_url(url: str) -> None:
    parsed = urlparse(url)
    if parsed.scheme not in {"http", "https"}:
        raise ValueError("URL audio harus http/https.")

    host = (parsed.hostname or "").lower()
    allowed_hosts = {
        "hisnmuslim.com",
        "www.hisnmuslim.com",
        "cdn.islamic.network",
        "everyayah.com",
    }
    if host not in allowed_hosts:
        raise ValueError("Host audio tidak diizinkan untuk proxy.")

