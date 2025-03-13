import pytest
from django.contrib.auth import get_user_model
from rest_framework import status

@pytest.mark.django_db
def test_user_can_register_successfully(client, user_data):
    response = client.post("/api/user/register/", user_data, format="json")
    assert response.status_code == status.HTTP_201_CREATED
    assert response.data["username"] == user_data["username"]
    assert "email" in response.data

@pytest.mark.django_db
def test_user_registration_missing_fields(client):
    response = client.post("/api/user/register/", {"username": "testuser"}, format="json")
    assert response.status_code == status.HTTP_400_BAD_REQUEST

@pytest.mark.django_db
def test_user_registration_weak_password(client):
    data = {
        "username": "userweak",
        "email": "weak@example.com",
        "password": "123"
    }
    response = client.post("/api/user/register/", data, format="json")
    assert response.status_code == status.HTTP_400_BAD_REQUEST

@pytest.mark.django_db
def test_user_registration_duplicate_username(client, create_user, user_data):
    response = client.post("/api/user/register/", user_data, format="json")
    assert response.status_code == status.HTTP_400_BAD_REQUEST

@pytest.mark.django_db
def test_user_registration_invalid_email(client):
    data = {
        "username": "userinvalidemail",
        "email": "notanemail",
        "password": "securepass123"
    }
    response = client.post("/api/user/register/", data, format="json")
    assert response.status_code == status.HTTP_400_BAD_REQUEST