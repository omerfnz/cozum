from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView

from .views import LoginView, MeView, RegisterView, UserViewSet, TeamViewSet, MeUpdateView, ChangePasswordView

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')
router.register(r'teams', TeamViewSet, basename='team')

urlpatterns = [
    path("auth/register/", RegisterView.as_view(), name="auth-register"),
    path("auth/login/", LoginView.as_view(), name="auth-login"),
    path("auth/refresh/", TokenRefreshView.as_view(), name="token-refresh"),
    path("auth/me/", MeView.as_view(), name="auth-me"),
    # Yeni profil güncelleme ve şifre değiştirme
    path("auth/me/update/", MeUpdateView.as_view(), name="auth-me-update"),
    path("auth/password/change/", ChangePasswordView.as_view(), name="auth-password-change"),
    path("", include(router.urls)),
]
