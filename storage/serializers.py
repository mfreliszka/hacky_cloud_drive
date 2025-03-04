from rest_framework import serializers
from .models import File, Folder

class FolderSerializer(serializers.ModelSerializer):
    subfolders = serializers.PrimaryKeyRelatedField(many=True, read_only=True)
    files = serializers.PrimaryKeyRelatedField(many=True, read_only=True)

    class Meta:
        model = Folder
        fields = ['id', 'name', 'parent', 'subfolders', 'files']

class FileSerializer(serializers.ModelSerializer):
    class Meta:
        model = File
        fields = ['id', 'name', 'folder', 'owner', 'file', 'created_at']
        read_only_fields = ['owner', 'created_at']
