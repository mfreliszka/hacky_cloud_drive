from rest_framework import viewsets, permissions, generics, status
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.views import TokenObtainPairView
# We use MultiPartParser and FormParser for handling file uploads.
from rest_framework.parsers import MultiPartParser, FormParser
from storage.models import File, Folder
from storage.serializers import RegisterSerializer, FileSerializer, FolderSerializer

User = get_user_model()


# For login, we'll use DRF SimpleJWT's provided view (TokenObtainPairView) via URL configuration.
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
            "id": user.id,
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



# View Details:
# RegisterView: A generic CreateAPIView that uses the RegisterSerializer to create a new user. We set permission_classes = [AllowAny] so that new users can register without being authenticated. The create method is overridden to return a custom response (just the new user's info). (By default, it would return the serialized user including the write-only password field which we don't want). We could also integrate token creation here, but we'll keep it simple.
# Login: We will use the JWT login view provided by DRF SimpleJWT instead of writing our own. Specifically, TokenObtainPairView provides an endpoint to get an access and refresh token pair by username and password.
# UserDashboardView: A ListAPIView that returns the current user's folders (with nested files as defined in the serializer). We enforce IsAuthenticated, so only logged-in users can access. The get_queryset filters Folder objects by owner=self.request.user to ensure each user only sees their own folders and files. This is critical for security: users should not even retrieve objects that aren't theirs. By filtering at the queryset level, we ensure no other user's data is included.If we had detail views or allowed editing/deleting of folders/files, we would implement object-level permission checks (e.g., a custom permission ensuring obj.owner == request.user) to prevent accessing others' objects​
# . In this simple dashboard list, filtering the query by user is sufficient to enforce this restriction.