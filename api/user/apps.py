from django.apps import AppConfig


class UserConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'api.user'

    def ready(self):
        # Import your signal handlers or other initialization code here.
        # import api.user.signals
        pass
