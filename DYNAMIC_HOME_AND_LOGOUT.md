# Dynamic Home AppBar & Logout Implementation

## 📋 Overview
Implementasi AppBar yang dinamis pada Home Page berdasarkan data user dari API, dan fitur logout dengan endpoint `/auth/logout`.

---

## ✨ Fitur yang Ditambahkan

### 1. **Dynamic Home AppBar**
- ✅ Nama user ditampilkan dinamis dari API
- ✅ Email user ditampilkan dinamis dari API
- ✅ Profile picture tetap dinamis
- ✅ Data diload otomatis saat home page dibuka

### 2. **Logout Functionality**
- ✅ Endpoint `POST /auth/logout` terdapat di API
- ✅ Confirmation dialog sebelum logout
- ✅ Clear semua data lokal
- ✅ Clear token dari API headers
- ✅ Redirect ke Login page

---

## 🏗️ Architecture & Implementation

### A. HomeProvider (New File)
```dart
// File: presentation/providers/home_provider.dart

class HomeProvider extends ChangeNotifier {
  // Load user data dari API
  Future<void> initializeUserData()
  
  // Get current user via GET /auth/me
  Future<void> loadCurrentUser()
  
  // Logout via POST /auth/logout
  Future<bool> logout()
  
  // Getters untuk UI
  String? get userName
  String? get userEmail
  HomeState get state
}
```

### B. Home Page Update
```dart
// File: presentation/pages/home/home_page.dart

void initState() {
  // Load user data on page initialization
  context.read<HomeProvider>().initializeUserData();
}

Widget _buildHeader() {
  // Dynamic UI using Consumer<HomeProvider>
  // userName dan userEmail dari provider
}
```

### C. Profile Page Logout
```dart
// File: presentation/pages/profile/profile_page.dart

void _showLogoutConfirmation() {
  // Show confirmation dialog
  // Call homeProvider.logout()
  // Navigate to Login page
}
```

### D. Login Remote DataSource Enhancement
```dart
// File: data/datasources/remote/login_remote_datasource.dart

// Added logout method
Future<void> logout() async {
  await apiClient.post('/auth/logout');
}
```

---

## 🔄 Data Flow

### Home Page Initialization
```
HomePage initState()
  ↓
HomeProvider.initializeUserData()
  ↓
Check stored token
  ↓
HomeProvider.loadCurrentUser()
  ↓
Call AuthRepository.getCurrentUser()
  ↓
Call GET /auth/me endpoint
  ↓
Parse response & store in provider
  ↓
UI rebuilds with dynamic data
```

### Logout Flow
```
User taps Logout button
  ↓
Show confirmation dialog
  ↓
User confirms
  ↓
HomeProvider.logout()
  ↓
AuthRepository.logout()
  ↓
LoginRemoteDataSource.logout()
  ↓
POST /auth/logout
  ↓
Clear local data
  ↓
Clear token from headers
  ↓
Navigate to Login page
```

---

## 📱 UI Changes

### Before
```
Home AppBar (Static)
┌─────────────────────┐
│ Salsabila Khaliq    │  ← Hardcoded
│ salsabila123@g.com  │  ← Hardcoded
└─────────────────────┘
```

### After
```
Home AppBar (Dynamic)
┌─────────────────────┐
│ [User Name from API]    │  ← Dynamic
│ [User Email from API]   │  ← Dynamic
└─────────────────────┘
```

### Logout Menu
```
Profile Page Menu
├── Account
├── Change Password
├── Notification
├── 2-Factor Auth
└── Logout ← NEW
    ├─ Confirmation dialog
    └─ Auto-redirect to Login
```

---

## 🔌 Endpoint Integration

### GET /auth/me
```
Purpose: Retrieve current authenticated user data
Headers: Authorization: Bearer {token}
Response:
{
  "success": true,
  "token": "...",
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

### POST /auth/logout
```
Purpose: Revoke all active refresh tokens
Headers: Authorization: Bearer {token}
Body: {}
Response:
{
  "success": true,
  "message": "Logged out successfully",
  "code": 200
}

Note: Returns 401 if token missing (which is expected after logout)
```

---

## 📝 Files Modified

| File | Changes |
|------|---------|
| [home_provider.dart](../../presentation/providers/home_provider.dart) | NEW - Provider untuk Home Page |
| [home_page.dart](../../presentation/pages/home/home_page.dart) | Updated - Dynamic AppBar dengan Consumer<HomeProvider> |
| [profile_page.dart](../../presentation/pages/profile/profile_page.dart) | Updated - Tambah logout button & confirmation |
| [login_remote_datasource.dart](../../data/datasources/remote/login_remote_datasource.dart) | Updated - Tambah logout() method |
| [app.dart](../../app.dart) | Updated - Register HomeProvider |
| [service_locator.dart](../../core/utils/service_locator.dart) | Updated - Register providers |

---

## 🚀 Usage Example

### Load Home Page with User Data
```dart
void main() {
  // HomeProvider akan otomatis load user data
  // saat initializeUserData() dipanggil di HomePage.initState()
}

// Di home_page.dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<HomeProvider>().initializeUserData();
  });
}
```

### Logout User
```dart
// Di profile_page.dart
void _showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Apakah Anda yakin ingin keluar?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            final success = await context.read<HomeProvider>().logout();
            if (success) {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            }
          },
          child: Text('Logout'),
        ),
      ],
    ),
  );
}
```

---

## ✅ Verification Checklist

- [x] HomeProvider created dan registered
- [x] Home AppBar menampilkan data user dari API
- [x] GET /auth/me endpoint terintegrasi
- [x] POST /auth/logout endpoint terintegrasi
- [x] Logout confirmation dialog
- [x] Token cleared setelah logout
- [x] Redirect ke login page
- [x] No compilation errors

---

## 🎯 Next Steps (Optional)

1. **Profile Picture Upload** - Implementasi upload profile picture
2. **User Preference Caching** - Cache user data untuk offline access
3. **Token Refresh** - Automatic token refresh sebelum expired
4. **User Settings** - Simpan user preferences

---

**Last Updated**: January 18, 2026  
**Status**: ✅ Complete & Ready for Testing
