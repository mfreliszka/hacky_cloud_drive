

from django.urls import path, include

from rest_framework.routers import DefaultRouter
from storage.views import (
    RegisterView,
    UserDashboardView,
    dashboard_view,
    FolderViewSet,
    UserViewSet,
)
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView

router = DefaultRouter()
router.register(r'folders', FolderViewSet)
router.register(r'user', UserViewSet, basename="user")

urlpatterns = [
    path('', include(router.urls)), 

    path('dashboard/', UserDashboardView.as_view(), name='user_dashboard'),
    path('dashboard_v2/', dashboard_view, name='dashboard'),
]