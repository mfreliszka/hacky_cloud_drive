import pytest
from django.contrib.auth import get_user_model

User = get_user_model()

@pytest.fixture
def user_data():
    return {
        "username": "testuser",
        "email": "testuser@example.com",
        "password": "strongpassword123"
    }

@pytest.fixture
def create_user(db, user_data):
    return User.objects.create_user(**user_data)


@pytest.fixture
def login_url():
    return "/api/user/login/"

@pytest.fixture
def registered_user(client, user_data):
    User.objects.create_user(**user_data)
