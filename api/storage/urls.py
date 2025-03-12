
from django.urls import path, include

from rest_framework.routers import DefaultRouter
from api.storage.views import (
    #UserDashboardView,
    dashboard_view,
    FolderViewSet,
)
from api.user.views import(
    UserViewSet,
)


router = DefaultRouter()
router.register(r'folders', FolderViewSet)
router.register(r'user', UserViewSet, basename="user")

urlpatterns = [
    path('', include(router.urls)), 
]