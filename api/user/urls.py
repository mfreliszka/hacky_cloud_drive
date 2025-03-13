
from django.urls import path, include

from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from api.user.views import (
    RegisterView,
    UserDashboardView,
    UserViewSet
)

router = DefaultRouter()
router.register(r"", UserViewSet, basename="user")


urlpatterns = [
    # auth
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),  # JWT login
    path('token-refresh/', TokenRefreshView.as_view(), name='token_refresh'),  # JWT refresh
    # user
    path('dashboard/', UserDashboardView.as_view(), name='user_dashboard'),

    path('', include(router.urls)), 
]