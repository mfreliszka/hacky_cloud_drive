from django.contrib import admin

from storage.models import File, Folder
admin.site.register(File)
admin.site.register(Folder)