from rest_framework import serializers
from storage.models import File, Folder
from django.contrib.auth import get_user_model

User = get_user_model()


class RegisterSerializer(serializers.ModelSerializer):
    """Serializer for user registration."""
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['username', 'email', 'password']  # using username for authentication
    
    def create(self, validated_data):
        # Use Django's create_user method to create a new user (handles hashing the password)
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


class FolderSerializer(serializers.ModelSerializer):
    subfolders = serializers.PrimaryKeyRelatedField(many=True, read_only=True)
    #files = serializers.PrimaryKeyRelatedField(many=True, read_only=True)
    # automatically include the folder’s files in the serialized data. This uses the related_name='files' on the File model to pull in all files for the folder.
    files = FileSerializer(many=True, read_only=True)

    class Meta:
        model = Folder
        fields = ["id", "name", "parent", "subfolders", "files", "owner", "created_at"]



# Explanation:
# RegisterSerializer: Inherits from ModelSerializer for the User model. We include username, email, and password fields. We mark password as write-only (it will not be returned in API responses) and enforce a minimum length (optional). In the create method, we call create_user which will hash the password automatically. By using create_user, Django ensures the password is stored in a hashed format (using the password hasher configured, typically PBKDF2)​
# FileSerializer: Basic serializer for File model. This will allow representation of file objects (including the file URL if a file is uploaded, and the folder it belongs to by ID).
# FolderSerializer: Serializer for Folder that includes a nested list of files. We declare files = FileSerializer(many=True, read_only=True) to automatically include the folder’s files in the serialized data. This uses the related_name='files' on the File model to pull in all files for the folder.
# With these serializers, the dashboard endpoint can return a folder with an embedded list of file info.