
from django.urls import path, include

from rest_framework.routers import DefaultRouter
from api.storage.views import (
    FolderViewSet,
    FileViewSet,
)


router = DefaultRouter()
router.register(r'folder', FolderViewSet)
router.register(r'file', FileViewSet)

urlpatterns = [
    path('', include(router.urls)),
]