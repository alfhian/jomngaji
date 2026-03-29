from app.services.auth_service import get_db
from app.repositories.db_compat import has_unified_attempts

ATTEMPTS_TABLE = "learning_assessment_attempts"

def save_exam_attempt(
    user_id: int,
    total_questions: int,
    correct_answers: int,
    score_pg: int,       # skor pilihan ganda
    final_score: int,    # skor gabungan
    xp: int,
):
    db = get_db()
    cursor = db.cursor()

    if has_unified_attempts():
        cursor.execute(
            f"""
        INSERT INTO {ATTEMPTS_TABLE}
        (
            user_id,
            feature_type,
            assessment_kind,
            total_questions,
            correct_answers,
            score,
            final_score,
            xp_earned,
            attempted_at,
            created_at
        )
        VALUES (%s, 'iqra', 'exam', %s, %s, %s, %s, %s, NOW(), NOW())
        """,
            (
                user_id,
                total_questions,
                correct_answers,
                score_pg,
                final_score,
                xp,
            ),
        )
    else:
        cursor.execute(
            """
            INSERT INTO iqra_exam_results
            (user_id, total_questions, correct_answers, score, final_score, xp_earned, created_at)
            VALUES (%s,%s,%s,%s,%s,%s,NOW())
            """,
            (
                user_id,
                total_questions,
                correct_answers,
                score_pg,
                final_score,
                xp,
            ),
        )

    db.commit()
    cursor.close()
    db.close()


def get_last_exam(user_id: int):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    if has_unified_attempts():
        cursor.execute(
            f"""
        SELECT *
        FROM {ATTEMPTS_TABLE}
        WHERE user_id = %s AND assessment_kind = 'exam' AND feature_type = 'iqra'
        ORDER BY attempted_at DESC
        LIMIT 1
        """,
            (user_id,),
        )
    else:
        cursor.execute(
            """
            SELECT *
            FROM iqra_exam_results
            WHERE user_id = %s
            ORDER BY created_at DESC
            LIMIT 1
            """,
            (user_id,),
        )

    row = cursor.fetchone()
    cursor.close()
    db.close()

    return row


def get_best_exam_score(user_id: int):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    if has_unified_attempts():
        cursor.execute(
            f"""
        SELECT MAX(score) AS best_score
        FROM {ATTEMPTS_TABLE}
        WHERE user_id = %s AND assessment_kind = 'exam' AND feature_type = 'iqra'
        """,
            (user_id,),
        )
    else:
        cursor.execute(
            """
            SELECT MAX(score) AS best_score
            FROM iqra_exam_results
            WHERE user_id = %s
            """,
            (user_id,),
        )

    row = cursor.fetchone()
    cursor.close()
    db.close()

    return row
