

from django.urls import path, include
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from storage.views import (
    RegisterView,
    UserDashboardView,
)

urlpatterns = [
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),  # JWT login
    path('auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),       # JWT refresh
    path('dashboard/', UserDashboardView.as_view(), name='user_dashboard'),
]