

from django.urls import path, include
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
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
    ## DOCS
    path('schema/', SpectacularAPIView.as_view(), name='schema'),
    # Optional UI:
    path('docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),

    path('', include(router.urls)), 
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),  # JWT login
    path('auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),       # JWT refresh
    path('dashboard/', UserDashboardView.as_view(), name='user_dashboard'),
    path('dashboard_v2/', dashboard_view, name='dashboard'),
]