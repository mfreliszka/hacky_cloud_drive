from django.apps import AppConfig


class StorageConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'api.storage'

    def ready(self):
        # Import your signal handlers or other initialization code here.
        # import api.storage.signals
        pass
