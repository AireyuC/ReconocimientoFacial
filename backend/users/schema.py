import strawberry
import jwt
from datetime import datetime, timedelta, timezone # <--- CAMBIO AQUÍ: Importamos timezone
from django.contrib.auth import authenticate
from django.conf import settings
from .types import UserType

# --- 1. Definimos qué devuelve el Login ---
@strawberry.type
class LoginResult:
    token: str
    user: UserType | None
    error: str | None

# --- 2. La lógica de las Acciones (Mutations) ---
@strawberry.type
class Mutation:
    @strawberry.mutation
    def login_estudiante(self, matricula: str, password: str) -> LoginResult:
        # A. Intentamos autenticar
        user = authenticate(username=matricula, password=password)

        if user is None:
            return LoginResult(token="", user=None, error="Credenciales incorrectas")

        # B. Si existe, creamos el Token (La llave digital)
        # CORRECCIÓN: Usamos 'now(timezone.utc)' en lugar de 'utcnow()'
        expiration_time = datetime.now(timezone.utc) + timedelta(days=7)
        issued_at = datetime.now(timezone.utc)

        payload = {
            "id": user.id,
            "exp": expiration_time,
            "iat": issued_at,
        }
        
        # Firmamos el token
        token = jwt.encode(payload, settings.SECRET_KEY, algorithm="HS256")

        return LoginResult(token=token, user=user, error=None)

@strawberry.type
class Query:
    @strawberry.field
    def hola(self) -> str:
        return "¡API del Sistema Universitario funcionando!"

schema = strawberry.Schema(query=Query, mutation=Mutation)