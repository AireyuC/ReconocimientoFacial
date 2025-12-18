from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, Asistencia

# Configuración para ver Nombres y Apellidos en la lista de Usuarios
@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    model = CustomUser
    # Estas son las columnas que se verán en la tabla azul
    list_display = ('matricula', 'first_name', 'last_name', 'email', 'is_staff')
    
    # Esto permite editar la matrícula en el panel
    fieldsets = UserAdmin.fieldsets + (
        (None, {'fields': ('matricula', 'biometria_activa')}),
    )
    add_fieldsets = UserAdmin.add_fieldsets + (
        (None, {'fields': ('matricula', 'biometria_activa')}),
    )

# Configuración de Asistencia (Ya la tenías, asegúrate que esté así)
@admin.register(Asistencia)
class AsistenciaAdmin(admin.ModelAdmin):
    list_display = ('estudiante_nombre', 'fecha') # <--- OJO AQUÍ
    list_filter = ('fecha',)

    # Truco para mostrar el nombre en vez del objeto en la tabla de asistencia
    def estudiante_nombre(self, obj):
        return f"{obj.estudiante.first_name} {obj.estudiante.last_name} ({obj.estudiante.matricula})"