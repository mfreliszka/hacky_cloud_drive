from django.contrib import admin

from api.storage.models import File, Folder
admin.site.register(File)
admin.site.register(Folder)