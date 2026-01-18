# Token Management & Authentication Implementation

## Overview
Dokumentasi lengkap tentang implementasi penyimpanan token user dan authentication flow di aplikasi Roban Digital.

---

## ✅ Alur Penyimpanan Token (Login Flow)

### 1. **User Login**
```
POST /auth/login
Request:
{
  "email": "user@example.com",
  "password": "password123",
  "portal": "MOBILE"
}

Response:
{
  "success": true,
  "token": "eyJhbGc...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "username": "john_doe",
    "role": "USER",
    "unitId": 1,
    "createdAt": "2025-01-18"
  }
}
```

### 2. **Token Storage Path**
```
LoginRemoteDataSourceImpl.login()
  ↓
AuthRepositoryImpl.login()
  ├→ saveToken(token) to SharedPreferences [auth_token]
  ├→ saveUserData() to SharedPreferences
  └→ setAuthToken(token) to ApiClient headers
  ↓
LoginProvider updates state
```

### 3. **Local Storage Keys**
Semua token dan user data disimpan di `SharedPreferences` dengan keys:
- `auth_token` - JWT token untuk API calls
- `user_id` - ID user
- `user_email` - Email user
- `user_role` - Role/permission user

---

## 🔑 Implementasi Token Management

### A. Penyimpanan Token (`AuthLocalDataSource`)
```dart
class AuthLocalDataSource {
  static const String _tokenKey = 'auth_token';
  
  // Save token after login
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }
  
  // Retrieve token
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }
  
  // Check if logged in
  bool isLoggedIn() {
    return getToken() != null;
  }
  
  // Clear on logout
  Future<void> clearAll() async {
    await _prefs.remove(_tokenKey);
    // ... clear other keys
  }
}
```

### B. API Client Token Management (`ApiClient`)
```dart
class ApiClient {
  // Load token on app startup
  Future<void> initializeAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      setAuthToken(token);
    }
  }
  
  // Set token to request headers
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  // Remove token on logout
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
```

### C. App Initialization (`main.dart`)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup dependency injection
  await setupServiceLocator();
  
  // Initialize stored token on app startup
  final apiClient = getIt<ApiClient>();
  await apiClient.initializeAuthToken();
  
  runApp(const RobanDigitalApp());
}
```

---

## 📡 API Endpoints

### 1. **POST /auth/login** - User Login
Authenticate user dan dapatkan token
- **Request**: email, password, portal
- **Response**: token + user data
- **Storage**: Token disimpan di SharedPreferences

### 2. **GET /auth/me** - Get Current User
Retrieve data user yang sedang login (requires token)
- **Headers**: `Authorization: Bearer {token}`
- **Response**: user data
- **Usage**: Verify token & get updated user data

### 3. **POST /auth/refresh** - Refresh Token
Refresh access token menggunakan stored token
- **Response**: new token
- **Storage**: New token disimpan & update API headers

---

## 🔄 Complete Authentication Flow

```
┌─────────────────────────────────────────────────────┐
│          1. APP START (main.dart)                    │
│  - setupServiceLocator()                             │
│  - apiClient.initializeAuthToken() ← Load token      │
└───────────────────┬─────────────────────────────────┘
                    │
        ┌───────────▼──────────────┐
        │   Token dari disk?       │
        │   (SharedPreferences)    │
        └───┬──────────────┬───────┘
            │ YES          │ NO
            │              │
    ┌───────▼────┐   ┌────▼──────────┐
    │ Load token │   │ Navigate to   │
    │ to headers │   │ Login Page    │
    └─────┬──────┘   └────┬──────────┘
          │               │
          └───────┬───────┘
                  │
        ┌─────────▼──────────────┐
        │  2. USER LOGIN         │
        │  POST /auth/login      │
        │  - email & password    │
        │  - portal: MOBILE      │
        └───────┬────────────────┘
                │
        ┌───────▼──────────────────┐
        │  3. SAVE TOKEN & DATA    │
        │  - saveToken()           │
        │  - saveUserData()        │
        │  - setAuthToken()        │
        └───────┬──────────────────┘
                │
        ┌───────▼──────────────────┐
        │  4. SET HEADERS          │
        │  Authorization:          │
        │  Bearer {token}          │
        └───────┬──────────────────┘
                │
        ┌───────▼──────────────────┐
        │  5. APP READY            │
        │  Navigate to Home        │
        └──────────────────────────┘
```

---

## 🛡️ Logout Implementation

```dart
// AuthRepository
Future<void> logout() async {
  await localDataSource.clearAll();      // Remove from SharedPreferences
  apiClient.removeAuthToken();            // Remove from headers
  // Navigate to Login page
}
```

---

## 🔍 Troubleshooting: Token Not Saved

### ✅ Verification Checklist
- [x] Token disimpan ke SharedPreferences setelah login
- [x] Token diload dari SharedPreferences saat app startup
- [x] Token ditambahkan ke request headers otomatis
- [x] Token dihapus saat logout
- [x] API client diinisialisasi dengan stored token

### ⚠️ Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Token not persisted | `saveToken()` tidak dipanggil | Pastikan `AuthRepositoryImpl.login()` memanggil `localDataSource.saveToken()` |
| Token lost after restart | `initializeAuthToken()` not called | Pastikan `main()` memanggil `apiClient.initializeAuthToken()` |
| API 401 Unauthorized | Token tidak di header | Pastikan `ApiClient.setAuthToken()` memanggil dengan format `Bearer {token}` |
| Token not updated | `refreshToken()` tidak used | Implement token refresh mechanism |
| Can't access protected endpoints | No Bearer format | Check header format: `Authorization: Bearer {token}` |

---

## 📝 Implementation Summary

### Files Modified/Created:
1. ✅ [auth_repository.dart](../../domain/repositories/auth_repository.dart) - Added methods
2. ✅ [auth_repository_impl.dart](../../data/repositories/auth_repository_impl.dart) - Implemented methods
3. ✅ [login_remote_datasource.dart](../../data/datasources/remote/login_remote_datasource.dart) - Added GET /auth/me
4. ✅ [api_client.dart](../../data/datasources/api/api_client.dart) - Added `initializeAuthToken()`
5. ✅ [main.dart](../../main.dart) - Call `initializeAuthToken()`
6. ✅ [auth_local_datasource.dart](../../data/datasources/local/auth_local_datasource.dart) - Token persistence

### Key Features:
- ✅ Token auto-persisted to SharedPreferences
- ✅ Token auto-loaded on app startup
- ✅ Token auto-added to API headers
- ✅ Support for GET /auth/me endpoint
- ✅ Support for POST /auth/refresh endpoint
- ✅ Logout clears all stored data

---

## 🚀 Usage Example

```dart
// Login
final result = await loginProvider.login(
  email: 'user@example.com',
  password: 'password123',
  portal: 'MOBILE',
);

// Token automatically:
// 1. Saved to disk
// 2. Added to API headers
// 3. Loaded on next app start

// Logout
await authRepository.logout();  // Clears token & data
```

---

**Last Updated**: January 18, 2026
**Status**: ✅ Complete & Tested
