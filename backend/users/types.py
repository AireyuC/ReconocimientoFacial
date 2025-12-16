import strawberry
from .models import CustomUser

@strawberry.django.type(CustomUser)
class UserType:
    id: strawberry.ID
    matricula: str
    username: str
    email: str
    biometria_activa: bool