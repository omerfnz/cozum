import pytest
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from reports.models import Category, Report, Media
from users.models import Team

User = get_user_model()


@pytest.mark.django_db
class TestCategoryModelEdgeCases:
    def test_category_str_representation(self):
        category = Category.objects.create(name="Test Category")
        
        assert str(category) == "Test Category"

    def test_category_multiple_categories_same_name_allowed(self):
        cat1 = Category.objects.create(name="Same Name Category")
        cat2 = Category.objects.create(name="Same Name Category")
        
        # Multiple categories with same name are allowed
        assert cat1.name == cat2.name
        assert cat1.id != cat2.id

    def test_category_default_ordering(self):
        cat_b = Category.objects.create(name="B Category")
        cat_a = Category.objects.create(name="A Category")
        cat_c = Category.objects.create(name="C Category")
        
        categories = list(Category.objects.all())
        
        # Default ordering is by id (creation order)
        assert categories[0] == cat_b
        assert categories[1] == cat_a
        assert categories[2] == cat_c


@pytest.mark.django_db
class TestReportModelEdgeCases:
    def setup_method(self):
        self.user = User.objects.create_user(
            email="reporter@example.com",
            password="Pass123!",
            username="reporter"
        )
        self.admin = User.objects.create_superuser(
            email="admin@example.com",
            password="AdminPass123!",
            username="admin"
        )
        self.category = Category.objects.create(name="Test Category")
        self.team = Team.objects.create(name="Test Team", created_by=self.admin)

    def test_report_str_representation(self):
        report = Report.objects.create(
            title="Test Report",
            description="Test Description",
            reporter=self.user,
            category=self.category
        )
        
        assert str(report) == "Test Report - Beklemede"

    def test_report_default_status(self):
        report = Report.objects.create(
            title="Test Report",
            description="Test Description",
            reporter=self.user,
            category=self.category
        )
        
        assert report.status == "BEKLEMEDE"

    def test_report_default_priority(self):
        report = Report.objects.create(
            title="Test Report",
            description="Test Description",
            reporter=self.user,
            category=self.category
        )
        
        assert report.priority == "ORTA"

    def test_report_with_all_fields(self):
        report = Report.objects.create(
            title="Complete Report",
            description="Complete Description",
            reporter=self.user,
            category=self.category,
            assigned_team=self.team,
            status="INCELENIYOR",
            priority="YUKSEK",
            location="Test Location"
        )
        
        assert report.title == "Complete Report"
        assert report.description == "Complete Description"
        assert report.reporter == self.user
        assert report.category == self.category
        assert report.assigned_team == self.team
        assert report.status == "INCELENIYOR"
        assert report.priority == "YUKSEK"
        assert report.location == "Test Location"

    def test_report_ordering(self):
        # Create reports with different creation times
        report1 = Report.objects.create(
            title="First Report",
            description="First Description",
            reporter=self.user,
            category=self.category
        )
        # Small delay to ensure different created_at times
        import time
        time.sleep(0.01)
        report2 = Report.objects.create(
            title="Second Report",
            description="Second Description",
            reporter=self.user,
            category=self.category
        )
        
        reports = list(Report.objects.all())
        
        # Should be ordered by -created_at (newest first)
        assert reports[0] == report2
        assert reports[1] == report1

    def test_report_reporter_relationship(self):
        report = Report.objects.create(
            title="Test Report",
            description="Test Description",
            reporter=self.user,
            category=self.category
        )
        
        assert report.reporter == self.user
        assert report in self.user.reported_issues.all()

    def test_report_category_relationship(self):
        report = Report.objects.create(
            title="Test Report",
            description="Test Description",
            reporter=self.user,
            category=self.category
        )
        
        assert report.category == self.category
        assert report in self.category.reports.all()

    def test_report_team_relationship(self):
        report = Report.objects.create(
            title="Test Report",
            description="Test Description",
            reporter=self.user,
            category=self.category,
            assigned_team=self.team
        )
        
        assert report.assigned_team == self.team
        assert report in self.team.assigned_reports.all()


@pytest.mark.django_db
class TestMediaModelEdgeCases:
    def setup_method(self):
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

    def test_media_str_representation(self):
        fake_file = SimpleUploadedFile(
            "test.jpg",
            b"fake image content",
            content_type="image/jpeg"
        )
        
        media = Media.objects.create(
            report=self.report,
            file=fake_file,
            media_type="IMAGE"
        )
        
        expected_str = f"{self.report.title} - Resim"
        assert str(media) == expected_str

    def test_media_default_media_type(self):
        media = Media.objects.create(
            report=self.report
        )
        
        assert media.media_type == "IMAGE"

    def test_media_with_video_type(self):
        fake_file = SimpleUploadedFile(
            "test.mp4",
            b"fake video content",
            content_type="video/mp4"
        )
        
        media = Media.objects.create(
            report=self.report,
            file=fake_file,
            media_type="VIDEO"
        )
        
        assert media.media_type == "VIDEO"

    def test_media_report_relationship(self):
        media = Media.objects.create(
            report=self.report,
            media_type="image"
        )
        
        assert media.report == self.report
        assert media in self.report.media_files.all()

    def test_media_default_ordering(self):
        media1 = Media.objects.create(
            report=self.report,
            media_type="IMAGE"
        )
        
        media2 = Media.objects.create(
            report=self.report,
            media_type="VIDEO"
        )
        
        media_files = list(Media.objects.all())
        
        # Default ordering is by id (creation order)
        assert media_files[0] == media1
        assert media_files[1] == media2

    def test_media_file_path_property(self):
        fake_file = SimpleUploadedFile(
            "test.jpg",
            b"fake image content",
            content_type="image/jpeg"
        )
        
        media = Media.objects.create(
            report=self.report,
            file=fake_file,
            media_type="IMAGE"
        )
        
        assert media.file_path is not None
        assert "test" in media.file_path

    def test_media_file_path_without_file(self):
        media = Media.objects.create(
            report=self.report,
            media_type="IMAGE"
        )
        
        # file_path is empty string when no file is provided
        assert media.file_path == ""
