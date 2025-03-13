from rest_framework import mixins, viewsets, permissions, generics, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated

from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from django.db.models.signals import post_save
from django.dispatch import receiver

from api.storage.models import File, Folder
from api.storage.serializers import RegisterSerializer, FileSerializer, FolderSerializer, UserSerializer



User = get_user_model()


class UserViewSet(mixins.RetrieveModelMixin, viewsets.GenericViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = "uuid"

    def retrieve(self, request, uuid=None):
        if uuid == "default":
            user = request.user
        else:
            user = get_object_or_404(User, uuid=uuid)
        serializer = self.get_serializer(user)
        return Response(serializer.data)

    

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]

    def create(self, request, *args, **kwargs):
        """
        Overriding CreateAPIView to customize response after creating a user.
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        # You could generate a token for the new user here if you want to auto-login upon registration.
        data = {
            "uuid": user.uuid,
            "username": user.username,
            "email": user.email
        }
        return Response(data, status=status.HTTP_201_CREATED)


class UserDashboardView(generics.ListAPIView):
    serializer_class = FolderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Return only the folders belonging to the logged-in user
        return Folder.objects.filter(uuid=self.request.user.root_folder_uuid).order_by('created_at')
    
    
@receiver(post_save, sender=User)
def create_root_folder(sender, instance, created, **kwargs):
    if created:
        root_folder = Folder.objects.create(name='root', owner=instance)
        User.objects.filter(pk=instance.pk).update(root_folder_uuid=root_folder.uuid)

