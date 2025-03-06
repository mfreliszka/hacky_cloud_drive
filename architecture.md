# Overall System Architecture
## Backend (Django + DRF)

### Framework & API:

- **Django 5.x** forms the foundation of the backend, while Django REST Framework (DRF) is used to build RESTful APIs.

- **JWT Authentication**: The backend leverages DRF SimpleJWT for token-based authentication. API endpoints include user registration, login (token obtain), token refresh, and a dashboard for retrieving a user’s folder/file structure.

### Data Models:

- **User**: The built-in Django ``User`` model is used (with secure password hashing).

- **Folder & File**: Custom models represent the cloud storage structure. Each folder belongs to a user and can contain files. Files may also store versioning information and metadata.

### Database:

- **PostgreSQL** is used to store all application metadata (users, folders, files). In production, this may be hosted on Google Cloud SQL, but for development/testing it can run in a Docker container managed via Docker Compose.

### File Storage:

- **Google Cloud Storage API Integration**: In production, file uploads and downloads would interact with Google Cloud Storage through Django’s storage backend (using libraries like django-storages).

- **Fake GCS Server for local and testing**: For local development and testing, the project uses a containerized Fake GCS Server, which emulates the Google Cloud Storage API. This allows you to test file operations locally without using real Google Cloud resources.

### Deployment & Scalability:

- The backend is containerized (via Docker) and can be deployed on Google Cloud services (such as Google Kubernetes Engine, Cloud Run, or App Engine) when moving to production.

- API endpoints enforce strict permissions so that only authenticated users can access their own data.

## Frontend (Flutter)

### User Interface & Navigation:

- The Flutter app provides screens for user login, registration, and a dashboard. Navigation is handled via named routes.

- The dashboard displays the user's file structure in a grid view by default, with options to switch to list or hierarchical tree views.

### State Management & Secure Storage:

- **Provider** is used for managing global authentication state.
flutter_secure_storage is employed to securely store JWT access and refresh tokens.

- The app automatically refreshes the access token using the ``/api/auth/refresh/`` endpoint, ensuring a seamless experience.

### API Integration:

- The app’s ApiService abstracts HTTP requests to the Django backend, automatically attaching the JWT to protected endpoints.

- Error handling is built in to display meaningful messages (for example, on login or registration failures).

## Data Flow & Interactions

### User Authentication & Registration:

- Users register and log in through the Flutter app. The Django backend processes these requests, returning JWT tokens that are stored securely on the client.

### Token Management:

- Every API call checks for a valid access token. If expired (or near expiry), the Flutter app automatically refreshes the token using the refresh endpoint.

### Dashboard Data Retrieval:

- The authenticated user retrieves their folder/file structure via the ``/api/dashboard/`` endpoint.

- The backend filters data to return only the authenticated user’s resources.

### File Storage & Testing:

- In production, files are stored in Google Cloud Storage. For local development, Fake GCS Server (running as a Docker container) emulates the GCS API so the Django app can upload/download files locally.

### Deployment:

- The overall system is containerized. Docker Compose can orchestrate PostgreSQL, the Django app, and Fake GCS Server for a complete local testing environment.

## Summary

- **Backend**: A Django/DRF-based REST API using JWT for secure authentication, with custom models for file and folder management. PostgreSQL stores metadata, and file storage is integrated with the Google Cloud Storage API.

- **File Storage for local and testing**: Instead of a real Google Cloud Storage instance, the project uses Fake GCS Server—an S3-compatible container that emulates the GCS API—making local testing and development easier.

- **Frontend**: A Flutter app that uses Provider for state management and flutter_secure_storage for secure JWT token handling. The app offers multiple UI views (grid, list, tree) for displaying user data, and interacts seamlessly with the Django API.

- **Deployment & Scalability**: The solution is fully containerized, ensuring that both backend and local storage (Fake GCS Server) can be managed and scaled via Docker. In production, all cloud services (database, storage, deployment) would be hosted exclusively on Google Cloud.

This design ensures a cohesive, secure, and scalable cloud storage application that integrates smoothly from the Flutter frontend to a Django-powered backend—all while using Google Cloud services (or their local emulators) exclusively.