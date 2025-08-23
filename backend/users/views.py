from django.contrib.auth import get_user_model
from rest_framework import generics, permissions, viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.views import TokenObtainPairView

from .models import Team
from .serializers import UserDetailSerializer, UserRegistrationSerializer, TeamSerializer, UserUpdateSerializer, PasswordChangeSerializer

User = get_user_model()


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token["email"] = user.email
        token["role"] = user.role
        token["username"] = user.username
        return token


class LoginView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer


class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = [permissions.AllowAny]
    serializer_class = UserRegistrationSerializer


class MeView(generics.RetrieveAPIView):
    serializer_class = UserDetailSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user


class MeUpdateView(generics.UpdateAPIView):
    serializer_class = UserUpdateSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user


class ChangePasswordView(generics.UpdateAPIView):
    serializer_class = PasswordChangeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user

    def update(self, request, *args, **kwargs):
        serializer = self.get_serializer(instance=request.user, data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({"detail": "Şifreniz başarıyla güncellendi."})


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all().order_by('-date_joined')
    permission_classes = [permissions.IsAdminUser]
    serializer_class = UserDetailSerializer

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAdminUser])
    def set_role(self, request, pk=None):
        user = self.get_object()
        role = request.data.get('role')
        valid_roles = [choice[0] for choice in User.ROLE_CHOICES]
        if role not in valid_roles:
            return Response({'detail': 'Geçersiz rol.'}, status=status.HTTP_400_BAD_REQUEST)
        user.role = role
        user.save(update_fields=['role'])
        return Response(UserDetailSerializer(user).data)

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAdminUser])
    def set_team(self, request, pk=None):
        user = self.get_object()
        team_id = request.data.get('team')
        if team_id is None:
            user.team = None
            user.save(update_fields=['team'])
            return Response(UserDetailSerializer(user).data)
        try:
            team = Team.objects.get(pk=team_id)
        except Team.DoesNotExist:
            return Response({'detail': 'Takım bulunamadı.'}, status=status.HTTP_404_NOT_FOUND)
        user.team = team
        user.save(update_fields=['team'])
        return Response(UserDetailSerializer(user).data)


class TeamViewSet(viewsets.ModelViewSet):
    queryset = Team.objects.all().order_by('name')
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = TeamSerializer

    def get_queryset(self):
        # Listelemede sadece aktif takımları göster
        if getattr(self, 'action', None) == 'list':
            return Team.objects.filter(is_active=True).order_by('name')
        return Team.objects.all().order_by('name')

    def perform_create(self, serializer):
        # Sadece staff/admin kullanıcı takım oluşturabilir
        if not self.request.user.is_staff:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("Takım oluşturma yetkiniz yok.")
        serializer.save(created_by=self.request.user)

    def perform_update(self, serializer):
        # Sadece staff/admin kullanıcı düzenleyebilir
        if not self.request.user.is_staff:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("Takım düzenleme yetkiniz yok.")
        serializer.save()

    def perform_destroy(self, instance):
        # Sadece staff/admin kullanıcı silebilir (soft delete: pasif yap)
        if not self.request.user.is_staff:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("Takım silme yetkiniz yok.")
        instance.is_active = False
        instance.save()
