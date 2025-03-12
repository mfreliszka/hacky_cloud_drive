import uuid
from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()


class Folder(models.Model):
    uuid = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
    name = models.CharField(max_length=255)
    parent = models.ForeignKey('self', null=True, blank=True, on_delete=models.CASCADE, related_name='subfolders')
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='folders')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.owner}:{self.name}"

class File(models.Model):
    uuid = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
    name = models.CharField(max_length=255)
    file = models.FileField(upload_to='files/', blank=True, null=True)  # This will place uploads in MEDIA_ROOT/files/
    folder = models.ForeignKey(Folder, null=True, blank=True, on_delete=models.SET_NULL, related_name='files')
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='files')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name
