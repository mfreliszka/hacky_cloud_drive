from rest_framework import viewsets, permissions, generics, status
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated

from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404

from api.storage.models import File, Folder
from api.storage.serializers import RegisterSerializer, FileSerializer, FolderSerializer, UserSerializer


User = get_user_model()


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def dashboard_view(request):
    user = request.user
    # The user has exactly one "root" folder, created on user signup.
    root_folder = user.folders.filter(parent__isnull=True).first()
    return Response({
        'user': {
            'uuid': user.uuid,
            'username': user.username,
        },
        'root_folder_uuid': str(root_folder.uuid) if root_folder else None
    })


class FolderViewSet(viewsets.ReadOnlyModelViewSet):
    permission_classes = [IsAuthenticated]
    queryset = Folder.objects.all()
    serializer_class = FolderSerializer
    lookup_field = "uuid"

    def get_queryset(self):
        return super().get_queryset().filter(owner=self.request.user)
