# pytest tests for reports app
import pytest
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from django.urls import reverse
from rest_framework.test import APIClient

from reports.models import Category, Comment, Media, Report
from users.models import Team

User = get_user_model()


@pytest.mark.django_db
class TestReportsModels:
    def test_create_category(self):
        cat = Category.objects.create(
            name="Yol", description="Yol ile ilgili problemler"
        )
        assert cat.name == "Yol"
        assert cat.is_active is True

    def test_create_report_and_comment(self):
        user = User.objects.create_user(
            email="r@example.com", password="pass123", username="ruser"
        )
        category = Category.objects.create(name="Aydınlatma")
        report = Report.objects.create(
            title="Lamba bozuk",
            description="Sokak lambası yanmıyor",
            reporter=user,
            category=category,
        )
        assert report.status == "BEKLEMEDE"
        assert report.priority == "ORTA"

        comment = Comment.objects.create(
            report=report, user=user, content="İnceliyoruz"
        )
        assert comment.report_id == report.id
        assert comment.user_id == user.id
        assert comment.content == "İnceliyoruz"


@pytest.mark.django_db
class TestMediaModel:
    def test_media_file_save_sets_path_and_size(self):
        user = User.objects.create_user(email="mr@example.com", password="pass", username="mr")
        cat = Category.objects.create(name="Test Cat")
        report = Report.objects.create(title="Test", description="Test", reporter=user, category=cat)

        # Fake image file
        fake_image = SimpleUploadedFile(
            name="test.jpg",
            content=b"fake image content",
            content_type="image/jpeg"
        )

        media = Media(report=report, file=fake_image, media_type="IMAGE")
        media.save()

        assert media.file_path
        assert media.file_size == len(b"fake image content")
        assert media.media_type == "IMAGE"


@pytest.mark.django_db
class TestReportModelChoices:
    def test_report_status_choices(self):
        user = User.objects.create_user(email="st@example.com", password="pass", username="st")
        cat = Category.objects.create(name="Status")

        report = Report.objects.create(
            title="Status Test",
            description="Test",
            reporter=user,
            category=cat,
            status="COZULDU"
        )
        assert report.status == "COZULDU"
        assert report.get_status_display() == "Çözüldü"

    def test_report_priority_choices(self):
        user = User.objects.create_user(email="pr@example.com", password="pass", username="pr")
        cat = Category.objects.create(name="Priority")

        report = Report.objects.create(
            title="Priority Test",
            description="Test",
            reporter=user,
            category=cat,
            priority="ACIL"
        )
        assert report.priority == "ACIL"
        assert report.get_priority_display() == "Acil"


@pytest.mark.django_db
class TestCategoryAPI:
    def setup_method(self):
        self.client = APIClient()

    def test_list_active_categories_authenticated(self):
        # setup users
        user = User.objects.create_user(email="ca@example.com", password="pass", username="ca")
        User.objects.create_user(email="cas@example.com", password="pass", username="cas", is_staff=True)

        # categories
        Category.objects.create(name="Active Cat", is_active=True)
        Category.objects.create(name="Inactive Cat", is_active=False)

        # login
        res = self.client.post(reverse("auth-login"), {"email": user.email, "password": "pass"})
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

        res2 = self.client.get("/api/categories/")
        assert res2.status_code == 200
        # should only see active
        assert len(res2.data) == 1
        assert res2.data[0]["name"] == "Active Cat"

    def test_create_category_staff_only(self):
        staff = User.objects.create_user(email="cs@example.com", password="pass", username="cs", is_staff=True)
        normal = User.objects.create_user(email="cn@example.com", password="pass", username="cn")

        # normal user cannot create
        res = self.client.post(reverse("auth-login"), {"email": normal.email, "password": "pass"})
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

        res2 = self.client.post("/api/categories/", {"name": "New Cat"})
        assert res2.status_code == 403

        # staff can create
        res3 = self.client.post(reverse("auth-login"), {"email": staff.email, "password": "pass"})
        staff_token = res3.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {staff_token}")

        res4 = self.client.post("/api/categories/", {"name": "Staff Cat", "description": "Created by staff"})
        assert res4.status_code == 201
        assert res4.data["name"] == "Staff Cat"

    def test_update_category_staff_only(self):
        staff = User.objects.create_user(email="cu@example.com", password="pass", username="cu", is_staff=True)
        normal = User.objects.create_user(email="cnu@example.com", password="pass", username="cnu")
        cat = Category.objects.create(name="Update Me")

        # normal user cannot update
        res = self.client.post(reverse("auth-login"), {"email": normal.email, "password": "pass"})
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

        res2 = self.client.patch(f"/api/categories/{cat.id}/", {"name": "Updated by Normal"})
        assert res2.status_code == 403

        # staff can update
        res3 = self.client.post(reverse("auth-login"), {"email": staff.email, "password": "pass"})
        staff_token = res3.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {staff_token}")

        res4 = self.client.patch(f"/api/categories/{cat.id}/", {"name": "Updated by Staff"})
        assert res4.status_code == 200
        assert res4.data["name"] == "Updated by Staff"

    def test_delete_category_soft_delete(self):
        staff = User.objects.create_user(email="cd@example.com", password="pass", username="cd", is_staff=True)
        cat = Category.objects.create(name="Delete Me")

        res = self.client.post(reverse("auth-login"), {"email": staff.email, "password": "pass"})
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

        res2 = self.client.delete(f"/api/categories/{cat.id}/")
        assert res2.status_code == 204

        # Check soft delete
        cat.refresh_from_db()
        assert cat.is_active is False


@pytest.mark.django_db
class TestReportAPI:
    def setup_method(self):
        self.client = APIClient()

    def test_create_report_as_citizen(self):
        user = User.objects.create_user(email="rc@example.com", password="pass", username="rc", role="VATANDAS")
        cat = Category.objects.create(name="Çukur")

        res = self.client.post(reverse("auth-login"), {"email": user.email, "password": "pass"})
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

        res2 = self.client.post("/api/reports/", {
            "title": "Büyük çukur",
            "description": "Yolda büyük bir çukur var",
            "category": cat.id,
            "location": "Ankara"
        })
        assert res2.status_code == 201

        report = Report.objects.get(id=res2.data["id"])
        assert report.reporter == user
        assert report.title == "Büyük çukur"

    def test_citizen_sees_only_own_reports(self):
        user1 = User.objects.create_user(email="r1@example.com", password="pass", username="r1", role="VATANDAS")
        user2 = User.objects.create_user(email="r2@example.com", password="pass", username="r2", role="VATANDAS")
        cat = Category.objects.create(name="Test")

        Report.objects.create(title="User1 Report", description="test", reporter=user1, category=cat)
        Report.objects.create(title="User2 Report", description="test", reporter=user2, category=cat)

        res = self.client.post(reverse("auth-login"), {"email": user1.email, "password": "pass"})
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

        res2 = self.client.get("/api/reports/")
        assert res2.status_code == 200
        assert len(res2.data) == 1
        assert res2.data[0]["title"] == "User1 Report"

    def test_operator_sees_all_reports(self):
        operator = User.objects.create_user(email="op@example.com", password="pass", username="op", role="OPERATOR")
        user = User.objects.create_user(email="usr@example.com", password="pass", username="usr", role="VATANDAS")
        cat = Category.objects.create(name="All")

        Report.objects.create(title="User Report", description="test", reporter=user, category=cat)
        Report.objects.create(title="Another Report", description="test", reporter=user, category=cat)

        res = self.client.post(reverse("auth-login"), {"email": operator.email, "password": "pass"})
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

        res2 = self.client.get("/api/reports/")
        assert res2.status_code == 200
        assert len(res2.data) == 2

    def test_team_member_sees_assigned_reports(self):
        admin = User.objects.create_superuser(email="ta@example.com", password="pass", username="ta")
        team = Team.objects.create(name="Field Team", created_by=admin)
        team_user = User.objects.create_user(email="tu@example.com", password="pass", username="tu", role="EKIP", team=team)
        user = User.objects.create_user(email="uu@example.com", password="pass", username="uu", role="VATANDAS")
        cat = Category.objects.create(name="Team")

        # assigned to team
        Report.objects.create(title="Assigned", description="test", reporter=user, category=cat, assigned_team=team)
        # not assigned
        Report.objects.create(title="Not Assigned", description="test", reporter=user, category=cat)

        res = self.client.post(reverse("auth-login"), {"email": team_user.email, "password": "pass"})
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

        res2 = self.client.get("/api/reports/")
        assert res2.status_code == 200
        assert len(res2.data) == 1
        assert res2.data[0]["title"] == "Assigned"


@pytest.mark.django_db
class TestCommentAPI:
    def setup_method(self):
        self.client = APIClient()

    def test_create_comment_on_report(self):
        user = User.objects.create_user(email="co@example.com", password="pass", username="co")
        cat = Category.objects.create(name="Comment")
        report = Report.objects.create(title="Commented", description="test", reporter=user, category=cat)

        res = self.client.post(reverse("auth-login"), {"email": user.email, "password": "pass"})
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

        res2 = self.client.post(f"/api/reports/{report.id}/comments/", {"content": "Test comment"})
        assert res2.status_code == 201
        assert res2.data["content"] == "Test comment"

        comment = Comment.objects.get(id=res2.data["id"])
        assert comment.user == user
        assert comment.report == report

    def test_list_comments_for_report(self):
        user1 = User.objects.create_user(email="c1@example.com", password="pass", username="c1")
        user2 = User.objects.create_user(email="c2@example.com", password="pass", username="c2")
        cat = Category.objects.create(name="Comments")
        report = Report.objects.create(title="Many Comments", description="test", reporter=user1, category=cat)

        Comment.objects.create(report=report, user=user1, content="First comment")
        Comment.objects.create(report=report, user=user2, content="Second comment")

        res = self.client.post(reverse("auth-login"), {"email": user1.email, "password": "pass"})
        token = res.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

        res2 = self.client.get(f"/api/reports/{report.id}/comments/")
        assert res2.status_code == 200
        assert len(res2.data) == 2


@pytest.mark.django_db
class TestReportSerializerValidation:
    def test_report_create_serializer_with_media(self):
        from reports.serializers import ReportCreateSerializer

        user = User.objects.create_user(email="rs@example.com", password="pass", username="rs")
        cat = Category.objects.create(name="Serial")

        fake_image = SimpleUploadedFile("test.jpg", b"fake content", content_type="image/jpeg")

        data = {
            "title": "With Media",
            "description": "Test with media",
            "category": cat.id,
            "location": "Test Location",
            "media_files": [fake_image]
        }

        serializer = ReportCreateSerializer(data=data)
        assert serializer.is_valid()

        report = serializer.save(reporter=user)
        assert report.title == "With Media"
        assert report.media_files.count() == 1

    def test_report_update_serializer_validation(self):
        from reports.serializers import ReportUpdateSerializer
        from rest_framework.request import Request
        from django.test import RequestFactory

        admin = User.objects.create_superuser(email="rsu@example.com", password="pass", username="rsu")
        team = Team.objects.create(name="Test Team", created_by=admin)
        team_user = User.objects.create_user(email="rsut@example.com", password="pass", username="rsut", role="EKIP", team=team)

        # Different team
        other_team = Team.objects.create(name="Other Team", created_by=admin)

        user = User.objects.create_user(email="rsuv@example.com", password="pass", username="rsuv")
        cat = Category.objects.create(name="Update Validation")
        report = Report.objects.create(title="Validate Update", description="test", reporter=user, category=cat, assigned_team=other_team)

        # Mock request
        factory = RequestFactory()
        request = factory.patch("/")
        request.user = team_user

        data = {"status": "COZULDU"}
        serializer = ReportUpdateSerializer(instance=report, data=data, context={"request": request})

        assert not serializer.is_valid()
        assert "Bu bildirimi güncelleme yetkiniz yok" in str(serializer.errors)
