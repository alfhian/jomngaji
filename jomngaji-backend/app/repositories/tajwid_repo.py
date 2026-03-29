from app.services.auth_service import get_db
import json

FEATURE_TYPE = "tajwid"
EVALUATIONS_TABLE = "learning_evaluations"

def save_tajwid_evaluation(
    user_id: int,
    lesson_id: int,
    transcript: str,
    score_final: int,
    feedback: str | None,
    issues: list | None,
):
    db = get_db()
    cursor = db.cursor()

    cursor.execute(
        f"""
        INSERT INTO {EVALUATIONS_TABLE}
            (user_id, feature_type, lesson_id, transcript, score_final, feedback, issues, evaluated_at, updated_at)
        VALUES (%s, %s, %s, %s, %s, %s, %s, NOW(), NOW())
        """,
        (user_id, FEATURE_TYPE, lesson_id, transcript, score_final, feedback, json.dumps(issues, ensure_ascii=False)),
    )

    db.commit()
    cursor.close()
    db.close()


def get_last_tajwid_evaluation(user_id: int, lesson_id: int):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    cursor.execute(
        f"""
        SELECT *
        FROM {EVALUATIONS_TABLE}
        WHERE user_id = %s AND lesson_id = %s
          AND feature_type = %s
        ORDER BY evaluated_at DESC
        LIMIT 1
        """,
        (user_id, lesson_id, FEATURE_TYPE),
    )

    row = cursor.fetchone()
    cursor.close()
    db.close()
    return row


def get_tajwid_progress(user_id: int, quiz_code: str, pass_threshold: int = 50):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    # ambil attempt terakhir (untuk detail)
    cursor.execute(
        f"""
        SELECT te.score_final
        FROM {EVALUATIONS_TABLE} te
        JOIN quizzes q ON q.id = te.lesson_id
        WHERE te.user_id = %s AND q.quiz_code = %s AND te.feature_type = %s
        ORDER BY te.evaluated_at DESC
        LIMIT 1
        """,
        (user_id, quiz_code, FEATURE_TYPE),
    )
    last_row = cursor.fetchone()
    cursor.close()
    db.close()

    # ambil skor tertinggi
    best_row = get_best_tajwid_score(user_id, quiz_code)

    if not last_row and not best_row:
        return {"progress": 0.0, "passed": False, "last_score": 0, "best_score": 0}

    best_score = best_row["best_score"] if best_row and best_row["best_score"] is not None else 0
    passed = best_score >= pass_threshold
    progress = 0.5 if passed else 0.0

    return {
        "progress": progress,          # ✅ progress dihitung dari skor tertinggi
        "passed": passed,
        "last_score": last_row["score_final"] if last_row else 0,
        "best_score": best_score,      # ✅ skor tertinggi
    }


def get_best_tajwid_score(user_id: int, quiz_code: str):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    cursor.execute(
        f"""
        SELECT MAX(te.score_final) AS best_score
        FROM {EVALUATIONS_TABLE} te
        JOIN quizzes q ON q.id = te.lesson_id
        WHERE te.user_id = %s AND q.quiz_code = %s AND te.feature_type = %s
        """,
        (user_id, quiz_code, FEATURE_TYPE),
    )
    row = cursor.fetchone()
    cursor.close()
    db.close()
    return row


from app.services.auth_service import get_db

def get_average_tajwid_score(user_id: int) -> float:
    """
    Hitung rata-rata skor tajwid untuk user tertentu langsung dari DB.
    Selalu mengembalikan float agar aman dipakai di perhitungan.
    """
    db = get_db()
    cursor = db.cursor(dictionary=True)

    cursor.execute(
        f"""
        SELECT AVG(score_final) AS avg_score
        FROM {EVALUATIONS_TABLE}
        WHERE user_id = %s AND feature_type = %s
        """,
        (user_id, FEATURE_TYPE),
    )
    row = cursor.fetchone()
    cursor.close()
    db.close()

    # Konversi ke float agar tidak bentrok dengan Decimal
    return float(row["avg_score"]) if row and row["avg_score"] is not None else 0.0
