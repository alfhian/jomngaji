from datetime import datetime, timedelta
import base64
import json
import hmac
import hashlib
import time
from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer

class SimpleJWTError(Exception):
    pass


class SimpleJWTBackend:
    @staticmethod
    def _b64url_encode(data: bytes) -> str:
        return base64.urlsafe_b64encode(data).rstrip(b"=").decode()

    @staticmethod
    def _b64url_decode(data: str) -> bytes:
        padding = "=" * ((4 - len(data) % 4) % 4)
        return base64.urlsafe_b64decode(data + padding)

    def encode(self, payload: dict, key: str, algorithm: str = "HS256") -> str:
        if algorithm != "HS256":
            raise SimpleJWTError("Unsupported algorithm")
        header = {"alg": "HS256", "typ": "JWT"}
        header_b64 = self._b64url_encode(json.dumps(header, separators=(",", ":")).encode())

        normalized_payload = payload.copy()
        if isinstance(normalized_payload.get("exp"), datetime):
            normalized_payload["exp"] = int(normalized_payload["exp"].timestamp())
        payload_b64 = self._b64url_encode(
            json.dumps(normalized_payload, separators=(",", ":")).encode()
        )

        signing_input = f"{header_b64}.{payload_b64}".encode()
        signature = hmac.new(key.encode(), signing_input, hashlib.sha256).digest()
        signature_b64 = self._b64url_encode(signature)
        return f"{header_b64}.{payload_b64}.{signature_b64}"

    def decode(self, token: str, key: str, algorithms=None) -> dict:
        try:
            header_b64, payload_b64, signature_b64 = token.split(".")
        except ValueError as exc:
            raise SimpleJWTError("Malformed token") from exc

        signing_input = f"{header_b64}.{payload_b64}".encode()
        expected_sig = hmac.new(key.encode(), signing_input, hashlib.sha256).digest()
        token_sig = self._b64url_decode(signature_b64)
        if not hmac.compare_digest(expected_sig, token_sig):
            raise SimpleJWTError("Invalid signature")

        payload = json.loads(self._b64url_decode(payload_b64).decode())
        exp = payload.get("exp")
        if exp is not None and int(exp) < int(time.time()):
            raise SimpleJWTError("Token expired")
        return payload


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
            return SimpleJWTError, SimpleJWTBackend()

SECRET_KEY = "supersecretkey123"  # ganti di production
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_DAYS = 30

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")


# ===============================
# CREATE TOKEN
# ===============================
def create_access_token(data: dict):
    _, jwt_backend = _load_jwt_backend()

    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=ACCESS_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire})
    return jwt_backend.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


# ===============================
# GET CURRENT USER
# ===============================
def get_current_user(token: str = Depends(oauth2_scheme)):
    jwt_error_cls, jwt_backend = _load_jwt_backend()

    try:
        payload = jwt_backend.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")

        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")

        return int(user_id)

    except jwt_error_cls:
        raise HTTPException(status_code=401, detail="Token expired or invalid")
