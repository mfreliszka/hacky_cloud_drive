from rest_framework import viewsets, permissions, generics, status
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.views import TokenObtainPairView
# We use MultiPartParser and FormParser for handling file uploads.
from rest_framework.parsers import MultiPartParser, FormParser
from storage.models import File, Folder
from django.shortcuts import get_object_or_404
from storage.serializers import RegisterSerializer, FileSerializer, FolderSerializer, UserSerializer
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated

User = get_user_model()


class UserViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = "uuid"  # ✅ Use 'uuid' instead of 'id'

    def retrieve(self, request, uuid=None):
        if uuid == "default":
            user = request.user
        else:
            user = get_object_or_404(User, uuid=uuid)  # ✅ Filter by 'uuid'
        serializer = self.get_serializer(user)
        return Response(serializer.data)


class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]  # Allow anyone (even not logged in) to register

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
        return Folder.objects.filter(owner=self.request.user).order_by('created_at')



@api_view(['GET'])
#@permission_classes([IsAuthenticated])
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
