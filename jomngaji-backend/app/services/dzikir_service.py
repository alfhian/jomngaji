from typing import Any


_DZIKIR_BY_PERIOD: dict[str, list[dict[str, Any]]] = {
    "pagi": [
        {"id": "ayat_kursi", "title": "Ayat Kursi", "subtitle": "QS. Al-Baqarah ayat 255", "repeat": "Dibaca 1x"},
        {"id": "al_ikhlas", "title": "Al-Ikhlas", "subtitle": "QS. Al-Ikhlas ayat 1-4", "repeat": "Dibaca 3x"},
        {"id": "al_falaq", "title": "Al-Falaq", "subtitle": "QS. Al-Falaq ayat 1-5", "repeat": "Dibaca 3x"},
        {"id": "an_nas", "title": "An-Nas", "subtitle": "QS. An-Nas ayat 1-6", "repeat": "Dibaca 3x"},
    ],
    "petang": [
        {"id": "petang_istighfar", "title": "Istighfar", "subtitle": "Dzikir petang", "repeat": "Dibaca 100x"},
        {"id": "petang_shalawat", "title": "Shalawat", "subtitle": "Shalawat nabi", "repeat": "Dibaca 10x"},
    ],
    "setelah_sholat": [
        {"id": "tasbih", "title": "Tasbih", "subtitle": "Subhanallah", "repeat": "Dibaca 33x"},
        {"id": "tahmid", "title": "Tahmid", "subtitle": "Alhamdulillah", "repeat": "Dibaca 33x"},
        {"id": "takbir", "title": "Takbir", "subtitle": "Allahu Akbar", "repeat": "Dibaca 33x"},
    ],
}

_DZIKIR_DETAIL: dict[str, dict[str, Any]] = {
    "ayat_kursi": {
        "title": "Ayat Kursi",
        "subtitle": "QS. Al-Baqarah ayat 255",
        "repeat": "Dibaca 1x",
        "arabic": "اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ",
        "translation": "Allah, tidak ada Tuhan melainkan Dia, Yang Hidup kekal lagi terus menerus mengurus makhluk-Nya.",
    },
    "al_ikhlas": {
        "title": "Al-Ikhlas",
        "subtitle": "QS. Al-Ikhlas ayat 1-4",
        "repeat": "Dibaca 3x",
        "arabic": "قُلْ هُوَ اللَّهُ أَحَدٌ",
        "translation": "Katakanlah: Dialah Allah, Yang Maha Esa.",
    },
}


def get_dzikir_periods() -> list[dict[str, str]]:
    return [
        {"key": "pagi", "label": "Pagi"},
        {"key": "petang", "label": "Petang"},
        {"key": "setelah_sholat", "label": "Setelah Sholat"},
    ]


def get_dzikir_items(period: str) -> list[dict[str, Any]]:
    return _DZIKIR_BY_PERIOD.get(period, _DZIKIR_BY_PERIOD["pagi"])


def get_dzikir_detail(item_id: str) -> dict[str, Any] | None:
    return _DZIKIR_DETAIL.get(item_id)
