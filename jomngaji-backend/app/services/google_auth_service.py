from fastapi import HTTPException
from app.services.auth_service import get_db
import os

GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID")


def _load_google_auth_libs():
    """
    Lazy import supaya app tetap bisa startup walau package google-auth
    belum ter-install. Error akan muncul saat endpoint Google login dipakai.
    """
    try:
        from google.oauth2 import id_token as google_id_token
        from google.auth.transport import requests as google_requests
        return google_id_token, google_requests
    except ModuleNotFoundError:
        return None, None

def verify_google_token(token: str):
    google_id_token, google_requests = _load_google_auth_libs()
    if google_id_token is None or google_requests is None:
        raise HTTPException(
            status_code=500,
            detail=(
                "Dependency google-auth belum terpasang. "
                "Install package `google-auth`."
            ),
        )

    try:
        idinfo = google_id_token.verify_oauth2_token(
            token,
            google_requests.Request(),
            GOOGLE_CLIENT_ID
        )
        return idinfo
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid Google token")


def login_or_register_google(idinfo: dict):
    email = idinfo["email"]
    name = idinfo.get("name")
    google_id = idinfo["sub"]
    avatar = idinfo.get("picture")

    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
    user = cursor.fetchone()

    if user:
        # update google_id jika belum ada
        if not user.get("google_id"):
            cursor.execute("""
                UPDATE users
                SET google_id=%s, provider='google'
                WHERE id=%s
            """, (google_id, user["id"]))
            conn.commit()

        cursor.close()
        conn.close()
        return user

    # kalau belum ada → create
    cursor.execute("""
        INSERT INTO users (email, name, google_id, provider, avatar)
        VALUES (%s, %s, %s, 'google', %s)
    """, (email, name, google_id, avatar))

    conn.commit()
    user_id = cursor.lastrowid

    cursor.execute("SELECT * FROM users WHERE id=%s", (user_id,))
    user = cursor.fetchone()

    cursor.close()
    conn.close()

    return user
