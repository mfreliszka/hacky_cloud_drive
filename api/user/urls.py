
from django.urls import path, include

from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from api.user.views import (
    RegisterView,
    UserDashboardView,
    UserViewSet
)

router = DefaultRouter()
router.register(r'user', UserViewSet, basename="user")


urlpatterns = [
    # auth
    path('user/register/', RegisterView.as_view(), name='register'),
    path('user/login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),  # JWT login
    path('user/token-refresh/', TokenRefreshView.as_view(), name='token_refresh'),  # JWT refresh
    # user
    path('user/dashboard/', UserDashboardView.as_view(), name='user_dashboard'),

    path('', include(router.urls)), 
]