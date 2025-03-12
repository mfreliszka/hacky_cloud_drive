from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from api.user.models import CustomUser

class CustomUserAdmin(UserAdmin):
    # Make root_folder_uuid read-only
    readonly_fields = ('root_folder_uuid',)
    
    # Include root_folder_uuid in the list display and fieldsets
    list_display = ('username', 'email', 'first_name', 'last_name', 'root_folder_uuid', 'is_staff')
    
    fieldsets = UserAdmin.fieldsets + (
        ("Folder Information", {'fields': ('root_folder_uuid',)}),
    )

admin.site.register(CustomUser, CustomUserAdmin)