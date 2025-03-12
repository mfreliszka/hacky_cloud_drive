import uuid
from django.db import models
from django.contrib.auth.models import AbstractUser



class CustomUser(AbstractUser):
    uuid = models.UUIDField(default=uuid.uuid4, editable=False, unique=True, primary_key=True)
    root_folder_uuid = models.UUIDField(null=True, blank=True, editable=False, verbose_name="root_folder_uuid")

    def __str__(self):
        return self.username


