from django.contrib import admin
from django.urls import path
from strawberry.django.views import GraphQLView
from users.schema import schema
from django.views.decorators.csrf import csrf_exempt

urlpatterns = [
    path('admin/', admin.site.urls),
    # Esta es la ruta que usará la App Móvil: http://TU_IP:8000/graphql
    path('graphql/', csrf_exempt(GraphQLView.as_view(schema=schema))),
]