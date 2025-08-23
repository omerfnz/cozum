import pytest
from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework.test import APIClient
from users.models import Team

User = get_user_model()


@pytest.mark.django_db
class TestChangePasswordView:
    def setup_method(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email="password@example.com",
            password="OldPass123!",
            username="passworduser"
        )

    def test_change_password_success(self):
        # Login first
        res = self.client.post(
            reverse("auth-login"),
            {"email": "password@example.com", "password": "OldPass123!"},
            format="json"
        )
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")
        
        # Change password
        res = self.client.patch(
            "/api/auth/password/change/",
            {
                "old_password": "OldPass123!",
                "new_password": "NewPass123!",
                "new_password_confirm": "NewPass123!"
            },
            format="json"
        )
        
        assert res.status_code == 200
        assert "Şifreniz başarıyla güncellendi" in res.data["detail"]
        
        # Verify password changed
        self.user.refresh_from_db()
        assert self.user.check_password("NewPass123!")

    def test_change_password_unauthenticated(self):
        res = self.client.patch(
            "/api/auth/password/change/",
            {
                "old_password": "OldPass123!",
                "new_password": "NewPass123!",
                "new_password_confirm": "NewPass123!"
            },
            format="json"
        )
        
        assert res.status_code == 401


@pytest.mark.django_db
class TestUserViewSetEdgeCases:
    def setup_method(self):
        self.client = APIClient()
        self.admin = User.objects.create_superuser(
            email="admin@example.com",
            password="AdminPass123!",
            username="admin"
        )
        self.team = Team.objects.create(name="Test Team", created_by=self.admin)

    def login_as_admin(self):
        res = self.client.post(
            reverse("auth-login"),
            {"email": "admin@example.com", "password": "AdminPass123!"},
            format="json"
        )
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

    def test_set_role_invalid_role(self):
        self.login_as_admin()
        
        target_user = User.objects.create_user(
            email="target@example.com",
            password="Pass123!",
            username="target"
        )
        
        res = self.client.post(
            f"/api/users/{target_user.id}/set_role/",
            {"role": "INVALID_ROLE"},
            format="json"
        )
        
        assert res.status_code == 400

    def test_set_team_nonexistent_team(self):
        self.login_as_admin()
        
        target_user = User.objects.create_user(
            email="target2@example.com",
            password="Pass123!",
            username="target2"
        )
        
        res = self.client.post(
            f"/api/users/{target_user.id}/set_team/",
            {"team": 99999},  # Non-existent team ID
            format="json"
        )
        
        assert res.status_code == 404


@pytest.mark.django_db
class TestTeamViewSetEdgeCases:
    def setup_method(self):
        self.client = APIClient()
        self.admin = User.objects.create_superuser(
            email="teamadmin@example.com",
            password="AdminPass123!",
            username="teamadmin"
        )
        self.normal_user = User.objects.create_user(
            email="normal@example.com",
            password="Pass123!",
            username="normal"
        )

    def login_as_admin(self):
        res = self.client.post(
            reverse("auth-login"),
            {"email": "teamadmin@example.com", "password": "AdminPass123!"},
            format="json"
        )
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

    def login_as_normal(self):
        res = self.client.post(
            reverse("auth-login"),
            {"email": "normal@example.com", "password": "Pass123!"},
            format="json"
        )
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

    def test_team_create_permission_denied(self):
        self.login_as_normal()
        
        res = self.client.post(
            "/api/teams/",
            {"name": "Unauthorized Team"},
            format="json"
        )
        
        assert res.status_code == 403

    def test_team_update_permission_denied(self):
        self.login_as_admin()
        team = Team.objects.create(name="Update Test", created_by=self.admin)
        
        # Switch to normal user
        self.login_as_normal()
        
        res = self.client.patch(
            f"/api/teams/{team.id}/",
            {"name": "Updated Name"},
            format="json"
        )
        
        assert res.status_code == 403

    def test_team_delete_permission_denied(self):
        self.login_as_admin()
        team = Team.objects.create(name="Delete Test", created_by=self.admin)
        
        # Switch to normal user
        self.login_as_normal()
        
        res = self.client.delete(f"/api/teams/{team.id}/")
        
        assert res.status_code == 403