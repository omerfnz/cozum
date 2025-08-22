# pytest tests for users app
import io

import pytest
from django.contrib.auth import get_user_model
from django.db import IntegrityError
from django.urls import reverse
from PIL import Image
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import AccessToken

from reports.models import Category, Report

User = get_user_model()


@pytest.mark.django_db
class TestUserModel:
    def test_create_user_with_email(self):
        user = User.objects.create_user(
            email="test@example.com", password="pass123", username="testuser"
        )
        assert user.email == "test@example.com"
        assert user.check_password("pass123") is True
        assert user.is_active is True

    def test_email_is_required(self):
        with pytest.raises(ValueError):
            User.objects.create_user(email="", password="pass123", username="u")

    def test_email_unique(self):
        User.objects.create_user(
            email="unique@example.com", password="pass123", username="u1"
        )
        with pytest.raises(IntegrityError):
            User.objects.create_user(
                email="unique@example.com", password="pass123", username="u2"
            )

    def test_create_superuser(self):
        su = User.objects.create_superuser(
            email="admin@example.com", password="adminpass", username="admin"
        )
        assert su.is_staff is True
        assert su.is_superuser is True
        assert su.role == "ADMIN"


@pytest.mark.django_db
class TestAuthAPI:
    def setup_method(self):
        self.client = APIClient()

    def test_register_and_login_flow(self):
        register_url = reverse("auth-register")
        login_url = reverse("auth-login")
        me_url = reverse("auth-me")

        # register
        payload = {
            "email": "new@example.com",
            "username": "newuser",
            "first_name": "New",
            "last_name": "User",
            "password": "StrongPass123!",
            "password_confirm": "StrongPass123!",
        }
        res = self.client.post(register_url, payload, format="json")
        assert res.status_code == 201
        assert User.objects.filter(email="new@example.com").exists()

        # login
        res2 = self.client.post(
            login_url,
            {"email": "new@example.com", "password": "StrongPass123!"},
            format="json",
        )
        assert res2.status_code == 200
        assert "access" in res2.data
        token = res2.data["access"]

        # me
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")
        res3 = self.client.get(me_url)
        assert res3.status_code == 200
        assert res3.data["email"] == "new@example.com"


# duplicate imports removed


def create_test_image(color=(155, 0, 0)):
    file = io.BytesIO()
    image = Image.new("RGB", (100, 100), color)
    image.save(file, "PNG")
    file.name = "test.png"
    file.seek(0)
    return file


@pytest.mark.django_db
class TestReportsAPI:
    def setup_method(self):
        self.client = APIClient()
        self.category = Category.objects.create(name="Yol")

    def register_and_login(self, email="citizen@example.com", role="VATANDAS"):
        # register
        username = email.split("@")[0]
        res = self.client.post(
            reverse("auth-register"),
            {
                "email": email,
                "password": "Pass1234!!",
                "password_confirm": "Pass1234!!",
                "username": username,
                "role": role,
            },
            format="json",
        )
        assert res.status_code == 201, getattr(res, "data", res.content)
        # login
        res = self.client.post(
            reverse("auth-login"),
            {"email": email, "password": "Pass1234!!"},
            format="json",
        )
        assert res.status_code == 200
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

    def test_citizen_can_create_and_list_own_reports_with_media(self):
        self.register_and_login()
        img = create_test_image()
        res = self.client.post(
            "/api/reports/",
            {
                "title": "Çukur",
                "description": "Yolda büyük çukur var",
                "category": self.category.id,
                "media_files": [img],
            },
            format="multipart",
        )
        assert res.status_code == 201, res.data

        # Kendi raporlarını listeler
        res = self.client.get("/api/reports/")
        assert res.status_code == 200
        assert len(res.data) == 1
        assert res.data[0]["title"] == "Çukur"
        assert res.data[0]["media_count"] == 1

    def test_operator_sees_all_reports_and_can_update(self):
        # citizen bir rapor oluşturur
        self.register_and_login(email="c1@example.com")
        self.client.post(
            "/api/reports/",
            {
                "title": "Lamba bozuk",
                "description": "Sokak lambası yanmıyor",
                "category": self.category.id,
            },
            format="multipart",
        )

        # operator giriş yapar ve tüm raporları görür
        self.client = APIClient()
        self.register_and_login(email="op@example.com", role="OPERATOR")
        res = self.client.get("/api/reports/")
        assert res.status_code == 200
        assert len(res.data) == 1

        # raporu günceller
        report_id = Report.objects.first().id
        res = self.client.patch(
            f"/api/reports/{report_id}/",
            {"status": "INCELENIYOR"},
            format="json",
        )
        assert res.status_code == 200
        assert res.data["status"] == "INCELENIYOR"

    def test_team_user_sees_only_assigned_team_reports(self, django_user_model):
        # operator rapor oluşturur ve takıma atar
        operator = django_user_model.objects.create_user(
            email="op2@example.com",
            password="Pass1234!!",
            username="op2",
            role="OPERATOR",
        )
        team = django_user_model.objects.create_user(
            email="teamlead@example.com",
            password="Pass1234!!",
            username="tl",
            role="EKIP",
        ).team

        # Eğer ekip kullanıcısının team alanı boşsa basit bir şekilde set edelim
        if not team:
            from users.models import Team

            team = Team.objects.create(name="Ekip 1", created_by=operator)
            user = django_user_model.objects.get(email="teamlead@example.com")
            user.team = team
            user.save()

        report = Report.objects.create(
            title="Kaza",
            description="Maddi hasarlı kaza",
            reporter=operator,
            category=self.category,
            assigned_team=team,
        )

        # ekip kullanıcısı giriş yapar
        self.client = APIClient()
        self.register_and_login(email="ekip@example.com", role="EKIP")
        # test kullanıcısının team'i yoksa set edelim
        user = django_user_model.objects.get(email="ekip@example.com")
        if not user.team:
            user.team = team
            user.save()

        res = self.client.get("/api/reports/")
        assert res.status_code == 200
        # yalnızca kendi takımına atanmış raporlar listelenmeli
        assert len(res.data) == 1
        assert res.data[0]["id"] == report.id

    def test_comment_crud(self):
        self.register_and_login()
        # rapor oluştur
        res = self.client.post(
            "/api/reports/",
            {
                "title": "Köpek saldırgan",
                "description": "Parkta saldırgan köpek",
                "category": self.category.id,
            },
            format="multipart",
        )
        assert res.status_code == 201
        rid = Report.objects.first().id

        # yorum ekle
        res = self.client.post(
            f"/api/reports/{rid}/comments/",
            {"content": "Ekip yönlendirildi"},
            format="json",
        )
        assert res.status_code == 201
        # yorumları listele
        res = self.client.get(f"/api/reports/{rid}/comments/")
        assert res.status_code == 200
        assert len(res.data) == 1


@pytest.mark.django_db
class TestUsersAdminViews:
    def setup_method(self):
        self.client = APIClient()

    def login_as_admin(self):
        admin = User.objects.create_superuser(
            email="admin2@example.com", password="AdminPass123!", username="admin2"
        )
        res = self.client.post(
            reverse("auth-login"),
            {"email": "admin2@example.com", "password": "AdminPass123!"},
            format="json",
        )
        assert res.status_code == 200
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")
        return admin

    def login_as_user(self, email="u@example.com"):
        User.objects.create_user(email=email, password="Pass1234!!", username="userx")
        res = self.client.post(
            reverse("auth-login"), {"email": email, "password": "Pass1234!!"}, format="json"
        )
        assert res.status_code == 200
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

    def test_users_list_permission(self):
        # normal user -> 403
        self.login_as_user()
        res = self.client.get("/api/users/")
        assert res.status_code == 403
        # admin -> 200
        self.client = APIClient()
        self.login_as_admin()
        res = self.client.get("/api/users/")
        assert res.status_code == 200

    def test_team_list_and_create_permissions(self):
        # list aktif takımlar (normal kullanıcı)
        # önce iki takım oluşturalım (doğrudan model ile)
        admin = User.objects.create_superuser(
            email="admin3@example.com", password="AdminPass123!", username="admin3"
        )
        from users.models import Team

        t1 = Team.objects.create(name="Aktif Takım", created_by=admin, is_active=True)
        t2 = Team.objects.create(name="Pasif Takım", created_by=admin, is_active=False)
        assert t1.is_active and not t2.is_active

        self.login_as_user(email="normal@example.com")
        res = self.client.get("/api/teams/")
        assert res.status_code == 200
        # yalnızca aktif takım listelenmeli
        assert len(res.data) == 1
        assert res.data[0]["name"] == "Aktif Takım"

        # create -> normal kullanıcı 403
        res = self.client.post("/api/teams/", {"name": "Yeni Takım"}, format="json")
        assert res.status_code == 403

        # create -> admin 201 ve created_by admin olmalı
        self.client = APIClient()
        admin = self.login_as_admin()
        res = self.client.post("/api/teams/", {"name": "Admin Takımı"}, format="json")
        assert res.status_code == 201, getattr(res, "data", res.content)
        assert res.data["created_by"] == admin.id

    def test_team_update_and_soft_delete_require_staff(self):
        admin = User.objects.create_superuser(
            email="admin4@example.com", password="AdminPass123!", username="admin4"
        )
        from users.models import Team

        team = Team.objects.create(name="Düzenlenecek", created_by=admin)

        # normal kullanıcı update 403
        self.login_as_user(email="nu@example.com")
        res = self.client.patch(f"/api/teams/{team.id}/", {"name": "X"}, format="json")
        assert res.status_code == 403

        # admin update 200
        self.client = APIClient()
        self.login_as_admin()
        res = self.client.patch(f"/api/teams/{team.id}/", {"name": "Güncellendi"}, format="json")
        assert res.status_code == 200
        assert res.data["name"] == "Güncellendi"

        # admin delete -> soft delete
        res = self.client.delete(f"/api/teams/{team.id}/")
        assert res.status_code == 204
        team.refresh_from_db()
        assert team.is_active is False

    def test_user_set_role_and_team_actions(self):
        # hedef kullanıcı
        target = User.objects.create_user(
            email="target@example.com", password="Pass1234!!", username="target"
        )
        # admin login
        self.login_as_admin()

        # invalid role -> 400
        res = self.client.post(f"/api/users/{target.id}/set_role/", {"role": "FOO"}, format="json")
        assert res.status_code == 400

        # valid role -> 200
        res = self.client.post(
            f"/api/users/{target.id}/set_role/", {"role": "EKIP"}, format="json"
        )
        assert res.status_code == 200
        assert res.data["role"] == "EKIP"

        # create team and assign
        from users.models import Team

        admin_user = User.objects.get(email="admin2@example.com")
        team = Team.objects.create(name="Atanacak", created_by=admin_user)
        res = self.client.post(
            f"/api/users/{target.id}/set_team/", {"team": team.id}, format="json"
        )
        assert res.status_code == 200
        assert res.data["team"] == team.id

        # clear team
        res = self.client.post(
            f"/api/users/{target.id}/set_team/", {"team": None}, format="json"
        )
        assert res.status_code == 200
        assert res.data["team"] is None

        # invalid team id -> 404
        res = self.client.post(
            f"/api/users/{target.id}/set_team/", {"team": 99999}, format="json"
        )
        assert res.status_code == 404


@pytest.mark.django_db
class TestJWTClaims:
    def setup_method(self):
        self.client = APIClient()

    def test_login_token_contains_custom_claims(self):
        User.objects.create_user(
            email="claim@example.com", password="Pass1234!!", username="claimuser", role="OPERATOR"
        )
        res = self.client.post(
            reverse("auth-login"), {"email": "claim@example.com", "password": "Pass1234!!"}, format="json"
        )
        assert res.status_code == 200
        token = res.data["access"]
        at = AccessToken(token)
        assert at["email"] == "claim@example.com"
        assert at["role"] == "OPERATOR"
        assert at["username"] == "claimuser"


@pytest.mark.django_db
class TestUserRegistrationValidation:
    def setup_method(self):
        self.client = APIClient()

    def test_password_mismatch_validation(self):
        url = reverse("auth-register")
        payload = {
            "email": "mm@example.com",
            "username": "mmuser",
            "first_name": "M",
            "last_name": "M",
            "password": "StrongPass123!",
            "password_confirm": "StrongPass123!!",  # farklı
        }
        res = self.client.post(url, payload, format="json")
        assert res.status_code == 400
        assert "Şifreler eşleşmiyor" in str(getattr(res, "data", res.content))


@pytest.mark.django_db
class TestTeamSerializerComputedFields:
    def test_members_count_and_created_by_name(self, django_user_model):
        admin = django_user_model.objects.create_superuser(
            email="adm@example.com", password="AdminPass123!", username="adm"
        )
        from users.models import Team
        from users.serializers import TeamSerializer

        u1 = django_user_model.objects.create_user(
            email="m1@example.com", password="Pass1234!!", username="m1"
        )
        u2 = django_user_model.objects.create_user(
            email="m2@example.com", password="Pass1234!!", username="m2"
        )

        team = Team.objects.create(name="Seri Takım", created_by=admin)
        team.members.add(u1, u2)

        data = TeamSerializer(instance=team).data
        assert data["members_count"] == 2
        assert data["created_by_name"] == "adm"


@pytest.mark.django_db
class TestJWTRefresh:
    def setup_method(self):
        self.client = APIClient()

    def test_refresh_token_flow(self):
        # register & login
        self.client.post(
            reverse("auth-register"),
            {
                "email": "rf@example.com",
                "username": "rf",
                "password": "Pass1234!!",
                "password_confirm": "Pass1234!!",
            },
            format="json",
        )
        res = self.client.post(
            reverse("auth-login"),
            {"email": "rf@example.com", "password": "Pass1234!!"},
            format="json",
        )
        assert res.status_code == 200
        refresh = res.data["refresh"]

        res2 = self.client.post(reverse("token-refresh"), {"refresh": refresh}, format="json")
        assert res2.status_code == 200
        assert "access" in res2.data


@pytest.mark.django_db
class TestUserPatchByAdmin:
    def setup_method(self):
        self.client = APIClient()

    def test_admin_can_patch_user_fields(self):
        admin = User.objects.create_superuser(
            email="ap@example.com", password="AdminPass123!", username="ap"
        )
        target = User.objects.create_user(
            email="tp@example.com", password="Pass1234!!", username="tp"
        )
        # login as admin
        res = self.client.post(
            reverse("auth-login"), {"email": admin.email, "password": "AdminPass123!"}, format="json"
        )
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

        res2 = self.client.patch(
            f"/api/users/{target.id}/",
            {"phone": "+90 555 000 00 00", "address": "Adres X"},
            format="json",
        )
        assert res2.status_code == 200
        assert res2.data["phone"] == "+90 555 000 00 00"
        assert res2.data["address"] == "Adres X"

    def test_non_admin_cannot_patch_user(self):
        normal = User.objects.create_user(
            email="np@example.com", password="Pass1234!!", username="np"
        )
        target = User.objects.create_user(
            email="tp2@example.com", password="Pass1234!!", username="tp2"
        )
        res = self.client.post(
            reverse("auth-login"), {"email": normal.email, "password": "Pass1234!!"}, format="json"
        )
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

        res2 = self.client.patch(
            f"/api/users/{target.id}/",
            {"phone": "+90 555 111 11 11"},
            format="json",
        )
        assert res2.status_code == 403


@pytest.mark.django_db
class TestTeamPermissionsExtra:
    def setup_method(self):
        self.client = APIClient()

    def test_non_staff_delete_forbidden(self):
        admin = User.objects.create_superuser(
            email="td@example.com", password="AdminPass123!", username="td"
        )
        from users.models import Team

        team = Team.objects.create(name="Silinecek", created_by=admin)

        # login as normal user
        User.objects.create_user(email="nn@example.com", password="Pass1234!!", username="nn")
        res = self.client.post(
            reverse("auth-login"), {"email": "nn@example.com", "password": "Pass1234!!"}, format="json"
        )
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

        res2 = self.client.delete(f"/api/teams/{team.id}/")
        assert res2.status_code == 403
