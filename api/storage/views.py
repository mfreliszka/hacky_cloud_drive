from rest_framework import mixins, viewsets, permissions, generics
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


class FolderViewSet(mixins.RetrieveModelMixin, viewsets.GenericViewSet):
    queryset = Folder.objects.all()
    serializer_class = FolderSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = "uuid"

    def retrieve(self, request, uuid=None):
        if uuid == "default":
            folder = get_object_or_404(Folder, owner=request.user, name='root')
        else:
            folder = get_object_or_404(Folder, uuid=uuid, owner=request.user)
        serializer = self.serializer_class(folder, context={'request': request})
        return Response(serializer.data)


class FileViewSet(mixins.RetrieveModelMixin, viewsets.GenericViewSet):
    queryset = File.objects.all()
    serializer_class = FileSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = "uuid"

    def retrieve(self, request, uuid=None):
        file = get_object_or_404(File, owner=request.user, uuid=uuid)
        serializer = self.serializer_class(file, context={'request': request})
        return Response(serializer.data)
