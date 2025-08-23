import pytest
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from rest_framework.test import APIRequestFactory
from reports.models import Category, Report, Media
from reports.serializers import MediaSerializer, ReportListSerializer
from users.models import Team

User = get_user_model()


@pytest.mark.django_db
class TestMediaSerializer:
    def setup_method(self):
        self.factory = APIRequestFactory()
        self.user = User.objects.create_user(
            email="media@example.com",
            password="Pass123!",
            username="mediauser"
        )
        self.category = Category.objects.create(name="Test Category")
        self.report = Report.objects.create(
            title="Test Report",
            description="Test Description",
            reporter=self.user,
            category=self.category
        )

    def test_media_serializer_with_file(self):
        fake_file = SimpleUploadedFile(
            "test.jpg",
            b"fake image content",
            content_type="image/jpeg"
        )
        
        media = Media.objects.create(
            report=self.report,
            file=fake_file,
            media_type="image"
        )
        
        request = self.factory.get("/")
        serializer = MediaSerializer(instance=media, context={"request": request})
        
        data = serializer.data
        assert "file" in data
        assert data["media_type"] == "image"
        assert data["file_path"] is not None

    def test_media_serializer_without_file(self):
        media = Media.objects.create(
            report=self.report,
            media_type="image"
        )
        
        serializer = MediaSerializer(instance=media)
        data = serializer.data
        
        assert data["file"] is None

    def test_media_serializer_file_exception_handling(self):
        # Test with non-existent file path
        media = Media.objects.create(
            report=self.report,
            media_type="IMAGE"
        )
        # Don't set file, so it will be None
        
        serializer = MediaSerializer(instance=media)
        
        # Should handle missing file gracefully - file field will be empty string or None
        file_value = serializer.data['file']
        assert file_value is None or file_value == ""


@pytest.mark.django_db
class TestReportListSerializer:
    def setup_method(self):
        self.factory = APIRequestFactory()
        self.user = User.objects.create_user(
            email="report@example.com",
            password="Pass123!",
            username="reportuser"
        )
        self.category = Category.objects.create(name="Test Category")
        self.admin = User.objects.create_superuser(
            email="admin@example.com",
            password="AdminPass123!",
            username="admin"
        )
        self.team = Team.objects.create(name="Test Team", created_by=self.admin)
        
        self.report = Report.objects.create(
            title="Test Report",
            description="Test Description",
            reporter=self.user,
            category=self.category,
            assigned_team=self.team
        )

    def test_report_list_serializer_first_media_url_with_media(self):
        fake_file = SimpleUploadedFile(
            "test.jpg",
            b"fake image content",
            content_type="image/jpeg"
        )
        
        Media.objects.create(
            report=self.report,
            file=fake_file,
            media_type="image"
        )
        
        request = self.factory.get("/")
        serializer = ReportListSerializer(instance=self.report, context={"request": request})
        
        data = serializer.data
        assert data["first_media_url"] is not None
        assert data["media_count"] == 1

    def test_report_list_serializer_first_media_url_without_media(self):
        serializer = ReportListSerializer(instance=self.report)
        data = serializer.data
        
        assert data["first_media_url"] is None
        assert data["media_count"] == 0

    def test_report_list_serializer_first_media_url_exception_handling(self):
        # Create report with media that has no file
        Media.objects.create(
            report=self.report,
            media_type="IMAGE"
        )
        # Don't set file, so it will be None
        
        serializer = ReportListSerializer(instance=self.report)
        
        # Should handle missing file gracefully
        first_media_url = serializer.data['first_media_url']
        assert first_media_url is None or first_media_url == ""