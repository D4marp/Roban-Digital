# Data Not Saving After Login - Debug Guide

## Problem
Setelah login berhasil, data user (username, email) tidak tersimpan ke local storage. HomeProvider menampilkan data kosong.

```
[HomeProvider] Loaded from local storage: username=, email=, role=
```

## Root Cause Analysis

Ada beberapa kemungkinan penyebab:

### Possibility 1: API Response tidak include user data
API endpoint `/auth/login` mungkin tidak return field `user` atau field user kosong.

Expected response:
```json
{
  "success": true,
  "token": "jwt_token",
  "refreshToken": "refresh_token",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "username": "john_doe",
    "role": "USER",
    "unitId": 1,
    "createdAt": "2024-01-19T00:00:00Z"
  }
}
```

Actual response might be (missing user):
```json
{
  "success": true,
  "token": "jwt_token",
  "refreshToken": "refresh_token"
}
```

### Possibility 2: Response structure different
API might wrap response differently:
```json
{
  "success": true,
  "data": {
    "token": "jwt_token",
    "user": {...}
  }
}
```

### Possibility 3: username field doesn't exist in API
API might return different field name: `name`, `fullName`, `displayName` instead of `username`

---

## Debug Steps to Check

### Step 1: Check Raw API Response
Enable the enhanced logging we added:

**File**: `lib/data/datasources/remote/login_remote_datasource.dart`

```dart
print('[LoginRemoteDataSource] Raw response data: ${response.data}');
```

This will print the exact JSON response from server.

### Step 2: Check Parsing
The parsing debug logs will show:

```dart
print('[LoginResponseModel.fromJson] Parsing data keys: ${data.keys.toList()}');
print('[LoginResponseModel.fromJson] User data: ${data['user']}');
```

### Step 3: Check Local Storage Save
```dart
print('[AuthRepository.login] User data saved successfully');
```

---

## Solutions

### Solution 1: Fix Response Parsing (if user is nested)

If API returns:
```json
{
  "success": true,
  "data": {
    "token": "...",
    "user": {...}
  }
}
```

Modify `LoginResponseModel.fromJson()`:
```dart
factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
  // Handle various response structures
  var data = json;
  
  // Try to get from 'data' field first
  if (json['data'] is Map) {
    data = json['data'] as Map<String, dynamic>;
  }
  
  return LoginResponseModel(
    success: data['success'] as bool? ?? json['success'] as bool? ?? true,
    token: data['token'] as String? ?? json['token'] as String? ?? '',
    refreshToken: data['refreshToken'] as String? ?? json['refreshToken'] as String? ?? '',
    user: UserModel.fromJson(data['user'] as Map<String, dynamic>? ?? {}),
  );
}
```

### Solution 2: Handle Different Field Names

If API uses `name` instead of `username`:
```dart
class UserModel {
  final int id;
  final String email;
  final String username;  // This might be 'name' from API
  ...
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      // Try multiple field names
      username: (json['username'] as String?) ?? 
                (json['name'] as String?) ?? 
                (json['fullName'] as String?) ??
                '',
      role: json['role'] as String? ?? '',
      unitId: json['unitId'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
```

### Solution 3: Fetch User Data Immediately After Login

If API doesn't return user in login response, fetch it immediately:

```dart
// In AuthRepositoryImpl.login()
Future<Either<Failure, AuthEntity>> login({...}) async {
  try {
    final response = await remoteDataSource.login(request);
    
    // Save tokens first
    await localDataSource.saveTokens(
      token: response.token,
      refreshToken: response.refreshToken,
    );
    
    // Set token for API client
    apiClient.setAuthToken(response.token);
    
    // If user data is empty, fetch from /auth/me
    if (response.user.username.isEmpty || response.user.email.isEmpty) {
      print('[AuthRepository] User data incomplete from login, fetching from /auth/me');
      final userResult = await remoteDataSource.getCurrentUser();
      
      // Use fresh user data from /auth/me
      await localDataSource.saveUserData(
        id: userResult.user.id,
        email: userResult.user.email,
        role: userResult.user.role,
        unitId: userResult.user.unitId,
        username: userResult.user.username,
      );
      
      return Right(AuthEntity(
        success: true,
        token: response.token,
        user: _mapUserModelToEntity(userResult.user),
      ));
    }
    
    // Normal flow - user data is complete
    await localDataSource.saveUserData(
      id: response.user.id,
      email: response.user.email,
      role: response.user.role,
      unitId: response.user.unitId,
      username: response.user.username,
    );
    
    return Right(AuthEntity(...));
  } catch (e) {...}
}
```

---

## Testing

After applying fix, run the app and check console for:

```
[LoginRemoteDataSource] Response status: 200
[LoginRemoteDataSource] Raw response data: {...}
[LoginRemoteDataSource] Parsed LoginResponseModel:
  - user.username: john_doe
  - user.email: john@example.com

[AuthRepository.login] Response received:
  - user.username: john_doe
  - user.email: john@example.com

[AuthRepository.login] User data saved successfully

[HomeProvider] Loaded from local storage:
  - username: "john_doe"
  - email: "john@example.com"
```

If you see the debug logs, share them and I can identify the exact issue!

---

## Files Modified for Debugging

1. `lib/data/datasources/remote/login_remote_datasource.dart` - Added detailed logging
2. `lib/data/models/login_model.dart` - Added parsing debug info
3. `lib/data/repositories/auth_repository_impl.dart` - Added response logging
4. `lib/presentation/providers/home_provider.dart` - Enhanced local storage logging

These debug logs will help identify where data is getting lost!
