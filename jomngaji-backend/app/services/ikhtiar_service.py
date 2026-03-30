from typing import Any


_IKHTIAR_ITEMS: list[dict[str, Any]] = [
    {
        "id": "amanah_lisan",
        "title": "Amanah dalam Menjaga Lisan",
        "category": "bertumbuh",
        "days": 7,
        "cover_image": "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=1200",
        "summary": "Melatih diri berkata baik, menahan komentar sia-sia, dan memperbanyak doa.",
        "steps": [
            {
                "day": 1,
                "title": "Diam Lebih Baik",
                "kind": "renungan",
                "content": "Menahan lisan dari ucapan yang tidak perlu adalah awal menjaga hati.",
            },
            {
                "day": 2,
                "title": "Doa Memohon Penjagaan Lisan",
                "kind": "doa",
                "arabic": "اللَّهُمَّ اغْفِرْ لِي مَا قُلْتُ وَمَا لَمْ أَقُلْ",
                "latin": "Allahumma-ghfir li ma qultu wa ma lam aqul",
                "translation": "Ya Allah, ampunilah apa yang telah aku ucapkan dan yang tidak aku ucapkan.",
                "source": "HR. Ahmad no. 23408",
            },
            {
                "day": 3,
                "title": "Tantangan Menahan Komentar",
                "kind": "tantangan",
                "content": "Cobalah tidak berkomentar pada hal yang tidak penting selama satu hari.",
            },
            {
                "day": 4,
                "title": "Kutipan Hari Ini",
                "kind": "kutipan",
                "content": "Barangsiapa beriman kepada Allah dan hari akhir, hendaklah ia berkata baik atau diam.",
                "source": "HR. Bukhari",
            },
        ],
    },
    {
        "id": "muslim_qanaah",
        "title": "Menjadi Muslim yang Qana'ah",
        "category": "keluarga",
        "days": 10,
        "cover_image": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1200",
        "summary": "Belajar bersyukur, tidak mudah membandingkan, dan tenang dalam rezeki.",
        "steps": [],
    },
    {
        "id": "disiplin_ibadah",
        "title": "Disiplin Ibadah Harian",
        "category": "muhasabah",
        "days": 7,
        "cover_image": "https://images.unsplash.com/photo-1609599006353-e629aaabfeae?q=80&w=1200",
        "summary": "Membangun kebiasaan ibadah yang konsisten dan bertahap.",
        "steps": [],
    },
]


def list_ikhtiar_items(category: str | None = None) -> list[dict[str, Any]]:
    if not category or category == "semua":
        return _IKHTIAR_ITEMS
    return [item for item in _IKHTIAR_ITEMS if item.get("category") == category]


def get_ikhtiar_item(item_id: str) -> dict[str, Any] | None:
    return next((item for item in _IKHTIAR_ITEMS if item["id"] == item_id), None)
