import strawberry
import jwt
from datetime import datetime, timedelta, timezone
from django.contrib.auth import authenticate
from django.conf import settings
from .types import UserType
from .models import CustomUser, Asistencia

# --- 1. Definimos qué devuelve el Login ---
@strawberry.type
class LoginResult:
    token: str
    user: UserType | None
    error: str | None

# --- 2. Definimos la Clase de Mutaciones (Acciones) ---
@strawberry.type
class Mutation:
    @strawberry.mutation
    def login_estudiante(self, matricula: str, password: str) -> LoginResult:
        print(f"--- INTENTO DE LOGIN: {matricula} ---") 

        # A. Autenticación
        user = authenticate(username=matricula, password=password)

        if user is None:
            print("--- ERROR: Credenciales incorrectas ---")
            return LoginResult(token="", user=None, error="Credenciales incorrectas")

        # B. Registro Automático de Asistencia
        try:
            nueva_asistencia = Asistencia.objects.create(estudiante=user)
            print(f"--- ÉXITO: Asistencia guardada ID: {nueva_asistencia.id} ---")
        except Exception as e:
            print(f"--- ERROR AL GUARDAR ASISTENCIA: {e} ---")

        # C. Generación del Token
        expiration_time = datetime.now(timezone.utc) + timedelta(days=7)
        issued_at = datetime.now(timezone.utc)

        payload = {
            "id": user.id,
            "exp": expiration_time,
            "iat": issued_at,
        }
        
        token = jwt.encode(payload, settings.SECRET_KEY, algorithm="HS256")

        return LoginResult(token=token, user=user, error=None)

# --- 3. Definimos la Clase Query (Consultas de lectura) ---
# Strawberry SIEMPRE necesita al menos una Query, aunque no la uses
@strawberry.type
class Query:
    @strawberry.field
    def hola(self) -> str:
        return "¡API del Sistema Universitario funcionando!"

# --- 4. LA LÍNEA QUE TE FALTABA (EL SCHEMA) ---
# Esta variable es la que busca 'core/urls.py'
schema = strawberry.Schema(query=Query, mutation=Mutation)