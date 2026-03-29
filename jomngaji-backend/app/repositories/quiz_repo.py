from app.services.auth_service import get_db
from app.repositories.db_compat import has_unified_attempts

ATTEMPTS_TABLE = "learning_assessment_attempts"


# =========================================
# GET QUIZ BY CODE
# =========================================
def get_quiz_by_code(quiz_code: str):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    cursor.execute(
        "SELECT * FROM quizzes WHERE quiz_code = %s",
        (quiz_code,),
    )
    quiz = cursor.fetchone()

    cursor.close()
    db.close()

    return quiz


# =========================================
# GET QUESTIONS
# =========================================
def get_questions_by_quiz_id(quiz_id: int):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    cursor.execute(
        """
        SELECT id, question_text
        FROM quiz_questions
        WHERE quiz_id = %s
        ORDER BY id ASC
        """,
        (quiz_id,),
    )

    rows = cursor.fetchall()
    cursor.close()
    db.close()

    return rows


# =========================================
# GET OPTIONS
# =========================================
def get_options_by_question_id(question_id: int):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    cursor.execute(
        """
        SELECT option_text
        FROM quiz_options
        WHERE question_id = %s
        """,
        (question_id,),
    )

    rows = cursor.fetchall()
    cursor.close()
    db.close()

    return rows


# =========================================
# GET QUESTION (UNTUK CHECK JAWABAN)
# =========================================
def get_question_by_id(question_id: int):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    cursor.execute(
        "SELECT * FROM quiz_questions WHERE id = %s",
        (question_id,),
    )

    row = cursor.fetchone()
    cursor.close()
    db.close()

    return row


# =========================================
# SAVE ATTEMPT
# =========================================
def save_quiz_attempt(
    user_id: int,
    quiz_id: int,
    correct: int,
    total: int,
    score: float,
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
                quiz_id,
                quiz_code,
                total_questions,
                correct_answers,
                score,
                final_score,
                xp_earned,
                attempted_at,
                created_at
            )
        SELECT
            %s,
            CASE
                WHEN q.quiz_type IN ('iqra','tajwid','tilawah','tahfidz','tadarus')
                THEN q.quiz_type
                ELSE 'general'
            END,
            'quiz',
            q.id,
            q.quiz_code,
            %s,
            %s,
            %s,
            %s,
            %s,
            NOW(),
            NOW()
        FROM quizzes q
        WHERE q.id = %s
        """,
            (user_id, total, correct, score, score, xp, quiz_id),
        )
    else:
        cursor.execute(
            """
            INSERT INTO quiz_attempts
                (user_id, quiz_id, correct, total, score, xp, created_at)
            VALUES (%s, %s, %s, %s, %s, %s, NOW())
            """,
            (user_id, quiz_id, correct, total, score, xp),
        )

    db.commit()
    cursor.close()
    db.close()


def get_quiz_progress_by_quiz_id(user_id: int, quiz_id: int):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    if has_unified_attempts():
        cursor.execute(
            f"""
        SELECT
            correct_answers AS correct,
            total_questions AS total,
            score,
            xp_earned AS xp,
            attempted_at AS created_at
        FROM {ATTEMPTS_TABLE}
        WHERE user_id = %s AND quiz_id = %s AND assessment_kind = 'quiz'
        ORDER BY attempted_at DESC
        LIMIT 1
        """,
            (user_id, quiz_id),
        )
    else:
        cursor.execute(
            """
            SELECT correct, total, score, xp, created_at
            FROM quiz_attempts
            WHERE user_id = %s AND quiz_id = %s
            ORDER BY created_at DESC
            LIMIT 1
            """,
            (user_id, quiz_id),
        )

    row = cursor.fetchone()
    cursor.close()
    db.close()
    return row


def get_best_quiz_score(user_id: int, quiz_id: int):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    if has_unified_attempts():
        cursor.execute(
            f"""
        SELECT MAX(score) AS best_score
        FROM {ATTEMPTS_TABLE}
        WHERE user_id = %s AND quiz_id = %s AND assessment_kind = 'quiz'
        """,
            (user_id, quiz_id),
        )
    else:
        cursor.execute(
            """
            SELECT MAX(score) AS best_score
            FROM quiz_attempts
            WHERE user_id = %s AND quiz_id = %s
            """,
            (user_id, quiz_id),
        )
    row = cursor.fetchone()
    cursor.close()
    db.close()
    return row
