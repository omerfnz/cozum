import pytest
from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework.test import APIClient
from reports.models import Category, Report
from users.models import Team

User = get_user_model()


@pytest.mark.django_db
class TestReportViewSetEdgeCases:
    def setup_method(self):
        self.client = APIClient()
        self.admin = User.objects.create_superuser(
            email="reportadmin@example.com",
            password="AdminPass123!",
            username="reportadmin"
        )
        self.team_user = User.objects.create_user(
            email="teamuser@example.com",
            password="Pass123!",
            username="teamuser",
            role="EKIP"
        )
        self.normal_user = User.objects.create_user(
            email="normaluser@example.com",
            password="Pass123!",
            username="normaluser"
        )
        
        self.team = Team.objects.create(name="Test Team", created_by=self.admin)
        self.team_user.team = self.team
        self.team_user.save()
        
        self.category = Category.objects.create(name="Test Category")
        
        self.report = Report.objects.create(
            title="Test Report",
            description="Test Description",
            reporter=self.normal_user,
            category=self.category,
            assigned_team=self.team
        )

    def login_as_admin(self):
        res = self.client.post(
            reverse("auth-login"),
            {"email": "reportadmin@example.com", "password": "AdminPass123!"},
            format="json"
        )
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

    def login_as_team_user(self):
        res = self.client.post(
            reverse("auth-login"),
            {"email": "teamuser@example.com", "password": "Pass123!"},
            format="json"
        )
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

    def login_as_normal_user(self):
        res = self.client.post(
            reverse("auth-login"),
            {"email": "normaluser@example.com", "password": "Pass123!"},
            format="json"
        )
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

    def test_report_update_team_member_wrong_team(self):
        # Create another team and user
        other_team = Team.objects.create(name="Other Team", created_by=self.admin)
        User.objects.create_user(
            email="otherteam@example.com",
            password="Pass123!",
            username="otherteam",
            role="EKIP",
            team=other_team
        )
        
        # Login as user from different team
        res = self.client.post(
            reverse("auth-login"),
            {"email": "otherteam@example.com", "password": "Pass123!"},
            format="json"
        )
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")
        
        # This should fail at the view level, not serializer level
        # Try to update report assigned to different team
        res = self.client.patch(
            f"/api/reports/{self.report.id}/",
            {"status": "INCELENIYOR"},
            format="json"
        )
        
        assert res.status_code == 403

    def test_report_update_team_member_success(self):
        self.login_as_team_user()
        
        res = self.client.patch(
            f"/api/reports/{self.report.id}/",
            {"status": "INCELENIYOR"},
            format="json"
        )
        
        assert res.status_code == 200
        self.report.refresh_from_db()
        assert self.report.status == "INCELENIYOR"

    def test_report_update_normal_user_permission_denied(self):
        self.login_as_normal_user()
        
        res = self.client.patch(
            f"/api/reports/{self.report.id}/",
            {"status": "INCELENIYOR"},
            format="json"
        )
        
        assert res.status_code == 403

    def test_report_delete_permission_denied(self):
        self.login_as_normal_user()
        
        res = self.client.delete(f"/api/reports/{self.report.id}/")
        
        assert res.status_code == 405

    def test_report_create_unauthenticated(self):
        res = self.client.post(
            "/api/reports/",
            {
                "title": "Unauthorized Report",
                "description": "Test",
                "category": self.category.id
            },
            format="json"
        )
        
        assert res.status_code == 401


@pytest.mark.django_db
class TestCategoryViewSetEdgeCases:
    def setup_method(self):
        self.client = APIClient()
        self.admin = User.objects.create_superuser(
            email="categoryadmin@example.com",
            password="AdminPass123!",
            username="categoryadmin"
        )
        self.normal_user = User.objects.create_user(
            email="categoryuser@example.com",
            password="Pass123!",
            username="categoryuser"
        )

    def login_as_admin(self):
        res = self.client.post(
            reverse("auth-login"),
            {"email": "categoryadmin@example.com", "password": "AdminPass123!"},
            format="json"
        )
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

    def login_as_normal_user(self):
        res = self.client.post(
            reverse("auth-login"),
            {"email": "categoryuser@example.com", "password": "Pass123!"},
            format="json"
        )
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

    def test_category_create_permission_denied(self):
        self.login_as_normal_user()
        
        res = self.client.post(
            "/api/categories/",
            {"name": "Unauthorized Category"},
            format="json"
        )
        
        assert res.status_code == 403

    def test_category_update_permission_denied(self):
        self.login_as_admin()
        category = Category.objects.create(name="Update Test")
        
        # Switch to normal user
        self.login_as_normal_user()
        
        res = self.client.patch(
            f"/api/categories/{category.id}/",
            {"name": "Updated Name"},
            format="json"
        )
        
        assert res.status_code == 403

    def test_category_delete_permission_denied(self):
        self.login_as_admin()
        category = Category.objects.create(name="Delete Test")
        
        # Switch to normal user
        self.login_as_normal_user()
        
        res = self.client.delete(f"/api/categories/{category.id}/")
        
        assert res.status_code == 403

    def test_category_list_unauthenticated(self):
        res = self.client.get("/api/categories/")
        
        assert res.status_code == 401