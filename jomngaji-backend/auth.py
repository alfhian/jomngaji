from datetime import datetime, timedelta
from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer

def _load_jwt_backend():
    """
    Lazy-load backend JWT library supaya aplikasi tetap bisa startup
    walau dependency JWT belum ter-install. Error baru dilempar saat
    endpoint auth benar-benar dipakai.
    """
    try:
        from jose import JWTError as JoseJWTError, jwt as jose_jwt
        return JoseJWTError, jose_jwt
    except ModuleNotFoundError:
        try:
            import jwt as pyjwt
            from jwt import PyJWTError
            return PyJWTError, pyjwt
        except ModuleNotFoundError:
            return None, None

SECRET_KEY = "supersecretkey123"  # ganti di production
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_DAYS = 30

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")


# ===============================
# CREATE TOKEN
# ===============================
def create_access_token(data: dict):
    _, jwt_backend = _load_jwt_backend()
    if jwt_backend is None:
        raise HTTPException(
            status_code=500,
            detail=(
                "JWT dependency belum terpasang. "
                "Install: python-jose[cryptography] atau PyJWT."
            ),
        )

    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=ACCESS_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire})
    return jwt_backend.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


# ===============================
# GET CURRENT USER
# ===============================
def get_current_user(token: str = Depends(oauth2_scheme)):
    jwt_error_cls, jwt_backend = _load_jwt_backend()
    if jwt_backend is None or jwt_error_cls is None:
        raise HTTPException(
            status_code=500,
            detail=(
                "JWT dependency belum terpasang. "
                "Install: python-jose[cryptography] atau PyJWT."
            ),
        )

    try:
        payload = jwt_backend.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")

        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")

        return int(user_id)

    except jwt_error_cls:
        raise HTTPException(status_code=401, detail="Token expired or invalid")
