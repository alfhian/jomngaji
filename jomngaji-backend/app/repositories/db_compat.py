from app.services.auth_service import get_db


def table_exists(table_name: str) -> bool:
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute(
        """
        SELECT 1 AS ok
        FROM information_schema.tables
        WHERE table_schema = DATABASE() AND table_name = %s
        LIMIT 1
        """,
        (table_name,),
    )
    row = cursor.fetchone()
    cursor.close()
    db.close()
    return bool(row)


def get_evaluations_table(feature_type: str) -> str:
    if table_exists("learning_evaluations"):
        return "learning_evaluations"

    legacy_map = {
        "tajwid": "tajwid_evaluations",
        "tilawah": "tilawah_evaluations",
        "tahfidz": "tahfidz_evaluations",
        "tadarus": "tadarus_evaluations",
        "iqra": "hijaiyah_evaluations",
    }
    return legacy_map.get(feature_type, "learning_evaluations")


def get_attempts_table() -> str:
    if table_exists("learning_assessment_attempts"):
        return "learning_assessment_attempts"
    return "quiz_attempts"


def has_unified_attempts() -> bool:
    return table_exists("learning_assessment_attempts")
