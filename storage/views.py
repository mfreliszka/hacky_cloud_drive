from rest_framework import viewsets, permissions
# We use MultiPartParser and FormParser for handling file uploads.
from rest_framework.parsers import MultiPartParser, FormParser
from .models import File, Folder
from .serializers import FileSerializer, FolderSerializer

class FolderViewSet(viewsets.ModelViewSet):
    queryset = Folder.objects.all()
    serializer_class = FolderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        # The owner is the current user
        serializer.save(owner=self.request.user)

    def get_queryset(self):
        # Return only folders that belong to the user
        return super().get_queryset().filter(owner=self.request.user)

class FileViewSet(viewsets.ModelViewSet):
    queryset = File.objects.all()
    serializer_class = FileSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

    def get_queryset(self):
        return super().get_queryset().filter(owner=self.request.user)
