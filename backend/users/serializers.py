from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers

from .models import Team

User = get_user_model()


class UserRegistrationSerializer(serializers.ModelSerializer):
    """Kullanıcı kayıt serileştirici"""

    password = serializers.CharField(
        write_only=True,
        validators=[validate_password],
        style={"input_type": "password"},
    )
    password_confirm = serializers.CharField(
        write_only=True, style={"input_type": "password"}
    )

    class Meta:
        model = User
        fields = (
            "email",
            "username",
            "first_name",
            "last_name",
            "password",
            "password_confirm",
            "role",
            "phone",
            "address",
        )

    def validate(self, attrs):
        if attrs["password"] != attrs["password_confirm"]:
            raise serializers.ValidationError("Şifreler eşleşmiyor.")
        return attrs

    def create(self, validated_data):
        validated_data.pop("password_confirm")
        user = User.objects.create_user(**validated_data)
        return user


class UserDetailSerializer(serializers.ModelSerializer):
    """Kullanıcı detay serileştirici"""

    team_name = serializers.CharField(source="team.name", read_only=True)
    role_display = serializers.CharField(source="get_role_display", read_only=True)

    class Meta:
        model = User
        fields = (
            "id",
            "email",
            "username",
            "first_name",
            "last_name",
            "role",
            "role_display",
            "team",
            "team_name",
            "phone",
            "address",
            "date_joined",
            "last_login",
        )
        read_only_fields = ("id", "date_joined", "last_login")


class TeamSerializer(serializers.ModelSerializer):
    """Takım serileştirici"""

    created_by_name = serializers.CharField(
        source="created_by.username", read_only=True
    )
    members_count = serializers.SerializerMethodField()

    class Meta:
        model = Team
        fields = (
            "id",
            "name",
            "description",
            "team_type",
            "created_by",
            "created_by_name",
            "members",
            "members_count",
            "created_at",
            "is_active",
        )
        read_only_fields = ("id", "created_at", "created_by")

    def get_members_count(self, obj):
        return obj.members.count()


# Yeni: Profil güncelleme serileştirici
class UserUpdateSerializer(serializers.ModelSerializer):
    """Kullanıcının kendi profilini güncellemesi için alanlar"""

    class Meta:
        model = User
        fields = (
            "username",
            "first_name",
            "last_name",
            "phone",
            "address",
        )


# Yeni: Şifre değiştirme serileştirici
class PasswordChangeSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True, style={"input_type": "password"})
    new_password = serializers.CharField(write_only=True, validators=[validate_password], style={"input_type": "password"})
    new_password_confirm = serializers.CharField(write_only=True, style={"input_type": "password"})

    def validate(self, attrs):
        request = self.context.get("request")
        user = getattr(request, "user", None)
        if user is None or not user.is_authenticated:
            raise serializers.ValidationError("Kimlik doğrulaması gerekli.")
        if attrs["new_password"] != attrs["new_password_confirm"]:
            raise serializers.ValidationError("Yeni şifreler eşleşmiyor.")
        if not user.check_password(attrs["old_password"]):
            raise serializers.ValidationError({"old_password": "Mevcut şifre hatalı."})
        return attrs

    def update(self, instance, validated_data):
        # instance: User
        new_password = validated_data["new_password"]
        instance.set_password(new_password)
        instance.save(update_fields=["password"])
        return instance

    def create(self, validated_data):
        raise NotImplementedError
