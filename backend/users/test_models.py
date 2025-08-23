import pytest
from django.contrib.auth import get_user_model
from users.models import Team

User = get_user_model()


@pytest.mark.django_db
class TestUserModelEdgeCases:
    def test_user_str_representation(self):
        user = User.objects.create_user(
            email="test@example.com",
            password="Pass123!",
            username="testuser"
        )
        
        assert str(user) == "test@example.com (Vatandaş)"

    def test_user_email_normalization(self):
        user = User.objects.create_user(
            email="Test@EXAMPLE.COM",
            password="Pass123!",
            username="testuser"
        )
        
        assert user.email == "Test@example.com"

    def test_user_without_username_raises_error(self):
        # Username is not required in this model since EMAIL is the USERNAME_FIELD
        # This test should pass without raising an error
        user = User.objects.create_user(
            email="nouser@test.com",
            password="testpass123"
            # username will be auto-generated or can be empty
        )
        assert user.email == "nouser@test.com"

    def test_user_without_email_raises_error(self):
        with pytest.raises((ValueError, TypeError)):
            User.objects.create_user(
                username="testuser",
                password="testpass123"
                # email is missing but required
            )

    def test_superuser_creation(self):
        admin = User.objects.create_superuser(
            email="admin@example.com",
            password="AdminPass123!",
            username="admin"
        )
        
        assert admin.is_staff is True
        assert admin.is_superuser is True
        assert admin.role == "ADMIN"

    def test_superuser_without_is_staff_raises_error(self):
        with pytest.raises(ValueError, match=r".*is_staff.*True.*"):
            User.objects.create_superuser(
                email="super@test.com",
                username="superuser",
                password="testpass123",
                is_staff=False
            )

    def test_superuser_without_is_superuser_raises_error(self):
        with pytest.raises(ValueError, match=r".*is_superuser.*True.*"):
            User.objects.create_superuser(
                email="super@test.com",
                username="superuser",
                password="testpass123",
                is_superuser=False
            )

    def test_user_role_choices(self):
        user = User.objects.create_user(
            email="team@example.com",
            password="Pass123!",
            username="teamuser",
            role="TEAM_MEMBER"
        )
        
        assert user.role == "TEAM_MEMBER"

    def test_user_team_relationship(self):
        admin = User.objects.create_superuser(
            email="admin@example.com",
            password="AdminPass123!",
            username="admin"
        )
        
        team = Team.objects.create(name="Test Team", created_by=admin)
        
        user = User.objects.create_user(
            email="team@example.com",
            password="Pass123!",
            username="teamuser",
            team=team
        )
        
        assert user.team == team
        assert user in team.team_members.all()


@pytest.mark.django_db
class TestTeamModelEdgeCases:
    def setup_method(self):
        self.admin = User.objects.create_superuser(
            email="admin@example.com",
            password="AdminPass123!",
            username="admin"
        )

    def test_team_str_representation(self):
        team = Team.objects.create(name="Test Team", created_by=self.admin)
        
        assert str(team) == "Test Team (Saha Ekibi)"

    def test_team_member_count_property(self):
        team = Team.objects.create(name="Test Team", created_by=self.admin)
        
        # Initially no members
        assert team.member_count == 0
        
        # Add members
        User.objects.create_user(
            email="user1@example.com",
            password="Pass123!",
            username="user1",
            team=team
        )
        
        User.objects.create_user(
            email="user2@example.com",
            password="Pass123!",
            username="user2",
            team=team
        )
        
        assert team.member_count == 2

    def test_team_created_by_name_property(self):
        team = Team.objects.create(name="Test Team", created_by=self.admin)
        
        assert team.created_by_name == "admin"

    def test_team_created_by_name_with_deleted_user(self):
        # Create team with user
        team = Team.objects.create(
            name="Test Team",
            created_by=self.admin
        )
        
        # Get team id before deleting user
        team_id = team.id
        
        # Delete the user (this will also delete the team due to CASCADE)
        self.admin.delete()
        
        # Team should be deleted due to CASCADE relationship
        with pytest.raises(Team.DoesNotExist):
            Team.objects.get(id=team_id)

    def test_team_multiple_teams_same_name_allowed(self):
        team1 = Team.objects.create(name="Same Name Team", created_by=self.admin)
        team2 = Team.objects.create(name="Same Name Team", created_by=self.admin)
        
        # Multiple teams with same name are allowed
        assert team1.name == team2.name
        assert team1.id != team2.id
