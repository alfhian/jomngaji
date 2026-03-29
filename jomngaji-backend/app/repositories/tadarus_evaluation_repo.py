import json
from app.services.auth_service import get_db
from app.repositories.db_compat import get_evaluations_table

FEATURE_TYPE = "tadarus"
EVALUATIONS_TABLE = "learning_evaluations"

# ======================================================
# GET AYAT YANG SUDAH DINILAI
# ======================================================
def get_evaluated_ayahs(user_id: int, surah: int) -> list[int]:
    db = get_db()
    cursor = db.cursor(dictionary=True)
    table_name = get_evaluations_table(FEATURE_TYPE)

    if table_name == EVALUATIONS_TABLE:
        cursor.execute(
            f"""
        SELECT ayah
        FROM {EVALUATIONS_TABLE}
        WHERE user_id = %s AND surah = %s AND feature_type = %s
        ORDER BY ayah
        """,
        (user_id, surah, FEATURE_TYPE),
        )
    else:
        cursor.execute(
            """
            SELECT ayah
            FROM tadarus_evaluations
            WHERE user_id = %s AND surah = %s
            ORDER BY ayah
            """,
            (user_id, surah),
        )

    rows = cursor.fetchall()

    cursor.close()
    db.close()

    return [row["ayah"] for row in rows]


# ======================================================
# UPSERT EVALUATION (ANTI TURUN SCORE)
# ======================================================
def upsert_evaluation(
    *,
    user_id: int,
    surah: int,
    ayah: int,
    score_final: int,
    score_ayat: int,
    score_audio: int,
    asr_user: str,
    asr_ref: str,
    issues: list,
    suggestions: list,
) -> bool:
    """
    Rules:
    - INSERT jika belum ada
    - UPDATE hanya jika score baru >= score lama
    - Jika score baru < score lama → SKIP
    """

    db = get_db()
    cursor = db.cursor(dictionary=True)
    table_name = get_evaluations_table(FEATURE_TYPE)

    # =========================
    # CEK DATA EXISTING
    # =========================
    if table_name == EVALUATIONS_TABLE:
        cursor.execute(
            f"""
        SELECT id, score_final
        FROM {EVALUATIONS_TABLE}
        WHERE user_id = %s AND surah = %s AND ayah = %s AND feature_type = %s
        """,
        (user_id, surah, ayah, FEATURE_TYPE),
        )
    else:
        cursor.execute(
            """
            SELECT id, score_final
            FROM tadarus_evaluations
            WHERE user_id = %s AND surah = %s AND ayah = %s
            """,
            (user_id, surah, ayah),
        )

    record = cursor.fetchone()

    # =========================
    # UPDATE (ANTI DOWNGRADE)
    # =========================
    if record:
        old_score = record["score_final"] or 0

        # ❌ Jangan update kalau score turun
        if score_final < old_score:
            cursor.close()
            db.close()
            return False

        update_table = EVALUATIONS_TABLE if table_name == EVALUATIONS_TABLE else "tadarus_evaluations"
        cursor.execute(
            f"""
            UPDATE {update_table}
            SET
                score_final = %s,
                score_ayat = %s,
                score_audio = %s,
                asr_user = %s,
                asr_ref = %s,
                issues = %s,
                suggestions = %s,
                updated_at = NOW()
            WHERE id = %s
            """,
            (
                score_final,
                score_ayat,
                score_audio,
                asr_user,
                asr_ref,
                json.dumps(issues, ensure_ascii=False),
                json.dumps(suggestions, ensure_ascii=False),
                record["id"],
            ),
        )

    # =========================
    # INSERT
    # =========================
    else:
        if table_name == EVALUATIONS_TABLE:
            cursor.execute(
                f"""
                INSERT INTO {EVALUATIONS_TABLE}
            (
                user_id,
                feature_type,
                surah,
                ayah,
                score_final,
                score_ayat,
                score_audio,
                asr_user,
                asr_ref,
                issues,
                suggestions,
                evaluated_at
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW())
            """,
            (
                user_id,
                FEATURE_TYPE,
                surah,
                ayah,
                score_final,
                score_ayat,
                score_audio,
                asr_user,
                asr_ref,
                json.dumps(issues, ensure_ascii=False),
                json.dumps(suggestions, ensure_ascii=False),
            ),
            )
        else:
            cursor.execute(
                """
                INSERT INTO tadarus_evaluations
                (
                    user_id,
                    surah,
                    ayah,
                    score_final,
                    score_ayat,
                    score_audio,
                    asr_user,
                    asr_ref,
                    issues,
                    suggestions,
                    evaluated_at
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW())
                """,
                (
                    user_id,
                    surah,
                    ayah,
                    score_final,
                    score_ayat,
                    score_audio,
                    asr_user,
                    asr_ref,
                    json.dumps(issues, ensure_ascii=False),
                    json.dumps(suggestions, ensure_ascii=False),
                ),
            )

    db.commit()
    cursor.close()
    db.close()

    return True
