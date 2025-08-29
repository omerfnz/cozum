import pytest
from django.contrib.auth import get_user_model
from rest_framework.test import APIRequestFactory
from users.serializers import PasswordChangeSerializer, UserUpdateSerializer

User = get_user_model()


@pytest.mark.django_db
class TestPasswordChangeSerializer:
    def setup_method(self):
        self.factory = APIRequestFactory()
        self.user = User.objects.create_user(
            email="test@example.com",
            password="OldPass123!",
            username="testuser"
        )

    def test_password_change_success(self):
        request = self.factory.post("/")
        request.user = self.user
        
        data = {
            "old_password": "OldPass123!",
            "new_password": "NewPass123!",
            "new_password_confirm": "NewPass123!"
        }
        
        serializer = PasswordChangeSerializer(
            instance=self.user,
            data=data,
            context={"request": request}
        )
        
        assert serializer.is_valid()
        updated_user = serializer.save()
        assert updated_user.check_password("NewPass123!")

    def test_password_change_unauthenticated_user(self):
        request = self.factory.post("/")
        request.user = None
        
        data = {
            "old_password": "OldPass123!",
            "new_password": "NewPass123!",
            "new_password_confirm": "NewPass123!"
        }
        
        serializer = PasswordChangeSerializer(
            data=data,
            context={"request": request}
        )
        
        assert not serializer.is_valid()
        assert "Kimlik doğrulaması gerekli" in str(serializer.errors)

    def test_password_change_mismatch(self):
        request = self.factory.post("/")
        request.user = self.user
        
        data = {
            "old_password": "OldPass123!",
            "new_password": "NewPass123!",
            "new_password_confirm": "DifferentPass123!"
        }
        
        serializer = PasswordChangeSerializer(
            instance=self.user,
            data=data,
            context={"request": request}
        )
        
        assert not serializer.is_valid()
        assert "Yeni şifreler eşleşmiyor" in str(serializer.errors)

    def test_password_change_wrong_old_password(self):
        request = self.factory.post("/")
        request.user = self.user
        
        data = {
            "old_password": "WrongPass123!",
            "new_password": "NewPass123!",
            "new_password_confirm": "NewPass123!"
        }
        
        serializer = PasswordChangeSerializer(
            instance=self.user,
            data=data,
            context={"request": request}
        )
        
        assert not serializer.is_valid()
        assert "Mevcut şifre hatalı" in str(serializer.errors["old_password"])

    def test_password_change_create_not_implemented(self):
        serializer = PasswordChangeSerializer()
        
        with pytest.raises(NotImplementedError):
            serializer.create({})


@pytest.mark.django_db
class TestUserUpdateSerializer:
    def test_user_update_serializer_fields(self):
        user = User.objects.create_user(
            email="update@example.com",
            username="updateuser",
            password="Pass123!"
        )
        
        data = {
            "username": "newusername",
            "first_name": "New",
            "last_name": "Name",
            "phone": "+90 555 123 45 67",
            "address": "New Address"
        }
        
        serializer = UserUpdateSerializer(instance=user, data=data)
        assert serializer.is_valid()
        
        updated_user = serializer.save()
        assert updated_user.username == "newusername"
        assert updated_user.first_name == "New"
        assert updated_user.last_name == "Name"
        assert updated_user.phone == "+90 555 123 45 67"
        assert updated_user.address == "New Address"

    def test_user_update_with_permissions(self):
        user = User.objects.create_user(
            email="permissions@example.com",
            username="permissionsuser",
            password="Pass123!"
        )
        
        permissions_data = {
            "can_create_reports": True,
            "can_edit_reports": False,
            "can_view_all_reports": True
        }
        
        data = {
            "username": "updatedpermissions",
            "user_permissions": permissions_data
        }
        
        serializer = UserUpdateSerializer(instance=user, data=data)
        assert serializer.is_valid()
        
        updated_user = serializer.save()
        assert updated_user.username == "updatedpermissions"
        assert updated_user.user_permissions == permissions_data
