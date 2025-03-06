from rest_framework import serializers
from storage.models import File, Folder
from django.contrib.auth import get_user_model

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["uuid", "username", "email", "date_joined"]


class RegisterSerializer(serializers.ModelSerializer):
    """Serializer for user registration."""
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['username', 'email', 'password']
    
    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password']
        )
        return user


class FileSerializer(serializers.ModelSerializer):
    class Meta:
        model = File
        fields = ["id", "name", "file", "folder", "owner", "created_at"]
        read_only_fields = ["owner", "created_at"]


class SubfolderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Folder
        fields = ["uuid", "name"]


class FolderSerializer(serializers.ModelSerializer):
    subfolders = SubfolderSerializer(many=True, read_only=True)
    files = FileSerializer(many=True, read_only=True)
    owner = serializers.UUIDField(source="owner.uuid", read_only=True)

    class Meta:
        model = Folder
        fields = ["id", "uuid", "name", "parent", "subfolders", "files", "owner", "created_at"]

    def get_subfolders(self, obj):
        return FolderSerializer(obj.subfolders.all(), many=True).data
