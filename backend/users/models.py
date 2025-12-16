from django.db import models
from django.contrib.auth.models import AbstractUser

class CustomUser(AbstractUser):
    # En la UAGRM usan matrícula (ej: 215034821), así que ese será nuestro ID
    matricula = models.CharField(max_length=20, unique=True, verbose_name="Matrícula Universitaria")
    
    # Este campo nos dirá si el estudiante ya activó su seguridad en el celular
    biometria_activa = models.BooleanField(default=False, help_text="¿El usuario activó FaceID en su móvil?")
    
    # Configuraciones obligatorias de Django para usar otro campo de login
    USERNAME_FIELD = 'matricula'   # Ahora pediremos matrícula para entrar
    REQUIRED_FIELDS = ['username', 'email'] # Campos extra obligatorios al crear admin

    def __str__(self):
        return self.matricula