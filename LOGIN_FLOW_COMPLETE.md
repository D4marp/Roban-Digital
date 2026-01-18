# Login Flow - Complete Implementation

## 📋 Overview
This document maps the complete login flow in the Roban Digital application, showing how data flows through each layer from UI to API.

---

## 🔄 Complete Login Flow

```
LoginPage (UI)
    ↓ (user clicks login)
LoginProvider (State Management)
    ↓ (calls login usecase)
LoginUseCase (Business Logic)
    ↓ (calls repository)
AuthRepositoryImpl (Repository)
    ↓ (calls remote datasource)
LoginRemoteDataSource (API)
    ↓ (HTTP POST /auth/login)
API Server (https://ptt-api.uptofive.my.id/api)
    ↓ (returns token + user)
LoginRemoteDataSource (parse response)
    ↓ (save token & set header)
AuthRepositoryImpl (store locally)
    ↓ (return AuthEntity)
LoginUseCase (return Either)
    ↓ (success case)
LoginProvider (update state)
    ↓ (navigate to home)
HomePage (new screen)
```

---

## 📁 File Structure & Components

### 1. **UI Layer** - User Interface
**File**: [lib/presentation/pages/auth/login_page.dart](lib/presentation/pages/auth/login_page.dart)
- **Responsible**: Display login form, collect email/password
- **Key Features**:
  - Email and password input fields
  - Show/hide password toggle
  - Validation on form submission
  - Loading indicator during request
  - Error message display
  - Navigation to home on success

```dart
Future<void> _login() async {
  if (_formKey.currentState?.validate() ?? false) {
    final loginProvider = context.read<LoginProvider>();
    
    await loginProvider.login(
      email: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      portal: 'MOBILE',
    );
    
    // Navigate on success
    if (mounted && loginProvider.state == LoginState.success) {
      NavigationService.pushReplacementNamed(AppRoutes.home);
    }
  }
}
```

---

### 2. **State Management** - Provider
**File**: [lib/presentation/providers/login_provider.dart](lib/presentation/providers/login_provider.dart)
- **Responsible**: Manage login state and call use case
- **States**: `initial`, `loading`, `success`, `error`
- **Key Methods**:
  - `login()` - initiate login process
  - `reset()` - reset provider state

```dart
Future<void> login({
  required String email,
  required String password,
  String portal = 'MOBILE',
}) async {
  _state = LoginState.loading;
  _errorMessage = null;
  notifyListeners();

  final result = await _loginUseCase(
    email: email,
    password: password,
    portal: portal,
  );

  result.fold(
    (failure) {
      _state = LoginState.error;
      _errorMessage = failure.message;
      notifyListeners();
    },
    (authEntity) {
      _state = LoginState.success;
      _authEntity = authEntity;
      notifyListeners();
    },
  );
}
```

---

### 3. **Use Case** - Business Logic
**File**: [lib/domain/usecases/login_usecase.dart](lib/domain/usecases/login_usecase.dart)
- **Responsible**: Encapsulate login business logic
- **Returns**: `Either<Failure, AuthEntity>`

```dart
class LoginUseCase implements UseCase<AuthEntity, LoginParams> {
  final AuthRepository _repository;

  LoginUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, AuthEntity>> call({
    required String email,
    required String password,
    String portal = 'MOBILE',
  }) async {
    return await _repository.login(
      email: email,
      password: password,
      portal: portal,
    );
  }
}
```

---

### 4. **Repository** - Data Access Layer
**File**: [lib/data/repositories/auth_repository_impl.dart](lib/data/repositories/auth_repository_impl.dart)
- **Responsible**: Coordinate between remote data source, local storage, and API client
- **Key Operations**:
  1. Call remote datasource to authenticate
  2. Save token to local storage
  3. Set token in API client headers
  4. Save user data locally
  5. Return AuthEntity

```dart
@override
Future<Either<Failure, AuthEntity>> login({
  required String email,
  required String password,
  String portal = 'MOBILE',
}) async {
  try {
    final request = LoginRequestModel(
      email: email,
      password: password,
      portal: portal,
    );

    final response = await remoteDataSource.login(request);

    // Save token to local storage
    await localDataSource.saveToken(response.token);

    // Set token to API client for subsequent requests
    apiClient.setAuthToken(response.token);

    // Save user data to local storage
    await localDataSource.saveUserData(
      id: response.user.id,
      email: response.user.email,
      role: response.user.role,
    );

    return Right(
      AuthEntity(
        success: response.success,
        token: response.token,
        user: _mapUserModelToEntity(response.user),
      ),
    );
  } on BadRequestException catch (e) {
    return Left(BadRequestFailure(message: e.message));
  } on UnauthorizedException catch (e) {
    return Left(UnauthorizedFailure(message: e.message));
  } catch (e) {
    return Left(UnknownFailure(message: e.toString()));
  }
}
```

---

### 5. **Remote Data Source** - API Communication
**File**: [lib/data/datasources/remote/login_remote_datasource.dart](lib/data/datasources/remote/login_remote_datasource.dart)
- **Responsible**: Make HTTP requests to API
- **Endpoint**: `POST /auth/login`
- **Handles**: Error responses and exceptions

```dart
@override
Future<LoginResponseModel> login(LoginRequestModel request) async {
  try {
    final response = await apiClient.post(
      '/auth/login',
      data: request.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return LoginResponseModel.fromJson(response.data);
    } else {
      throw _handleErrorResponse(response);
    }
  } on DioException catch (e) {
    throw _handleDioException(e);
  }
}
```

**Error Handling**:
- 400 → BadRequestException
- 401 → UnauthorizedException
- 403 → ForbiddenException
- 404 → NotFoundException
- 409 → ConflictException
- 500 → ServerException
- Network/Timeout → TimeoutException, NetworkException

---

### 6. **Local Data Source** - Storage
**File**: [lib/data/datasources/local/auth_local_datasource.dart](lib/data/datasources/local/auth_local_datasource.dart)
- **Responsible**: Save/retrieve auth data from local storage
- **Storage**: SharedPreferences
- **Keys**:
  - `auth_token` - Bearer token
  - `user_id` - User ID
  - `user_email` - User email
  - `user_role` - User role

```dart
// Save token after login
Future<void> saveToken(String token) async {
  await _prefs.setString('auth_token', token);
}

// Get saved token
String? getToken() {
  return _prefs.getString('auth_token');
}

// Save user data
Future<void> saveUserData({
  required int id,
  required String email,
  required String role,
}) async {
  await _prefs.setInt('user_id', id);
  await _prefs.setString('user_email', email);
  await _prefs.setString('user_role', role);
}

// Clear all auth data (logout)
Future<void> clearAll() async {
  await _prefs.remove('auth_token');
  await _prefs.remove('user_id');
  await _prefs.remove('user_email');
  await _prefs.remove('user_role');
}
```

---

### 7. **API Client** - HTTP Configuration
**File**: [lib/data/datasources/api/api_client.dart](lib/data/datasources/api/api_client.dart)
- **Responsible**: Configure HTTP client and manage authorization header
- **Base URL**: `https://ptt-api.uptofive.my.id/api`
- **Timeout**: 30 seconds

```dart
void setAuthToken(String token) {
  _dio.options.headers['Authorization'] = 'Bearer $token';
}

void removeAuthToken() {
  _dio.options.headers.remove('Authorization');
}
```

---

### 8. **Models** - Data Transfer Objects
**File**: [lib/data/models/login_model.dart](lib/data/models/login_model.dart)

**LoginRequestModel**:
```dart
class LoginRequestModel {
  final String email;
  final String password;
  final String portal; // 'MOBILE', 'WEB', etc.
}
```

**LoginResponseModel**:
```dart
class LoginResponseModel {
  final bool success;
  final String token;      // JWT bearer token
  final UserModel user;    // User information
}
```

**UserModel**:
```dart
class UserModel {
  final int id;
  final String email;
  final String username;
  final String role;
  final int unitId;
  final String createdAt;
}
```

---

### 9. **Entities** - Domain Models
**File**: [lib/domain/entities/auth_entity.dart](lib/domain/entities/auth_entity.dart)
- Pure business logic representation (independent of data layer)

```dart
class AuthEntity extends Equatable {
  final bool success;
  final String token;
  final UserEntity user;
}

class UserEntity extends Equatable {
  final int id;
  final String email;
  final String username;
  final String role;
  final int unitId;
  final String createdAt;
}
```

---

### 10. **Repository Interface** - Contract
**File**: [lib/domain/repositories/auth_repository.dart](lib/domain/repositories/auth_repository.dart)
- Defines the contract that repository implementations must follow

```dart
abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
    String portal = 'MOBILE',
  });
}
```

---

## 🚀 Token Persistence

### On App Startup
**File**: [lib/main.dart](lib/main.dart)
```dart
void _initializeAuthToken() {
  final authLocalDataSource = getIt<AuthLocalDataSource>();
  final apiClient = getIt<ApiClient>();
  
  final token = authLocalDataSource.getToken();
  if (token != null && token.isNotEmpty) {
    apiClient.setAuthToken(token);
  }
}
```

**Process**:
1. Retrieve token from SharedPreferences
2. If token exists, set it in API client headers
3. Subsequent API calls automatically include Bearer token

### On Login Success
```dart
// 1. Save token to storage
await localDataSource.saveToken(response.token);

// 2. Set in API client (for current session)
apiClient.setAuthToken(response.token);

// 3. Save user info
await localDataSource.saveUserData(...);
```

---

## 🔐 API Response Structure

**Expected Login Response**:
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "fiqifalah17@gmail.com",
    "username": "fiqifalah17",
    "role": "user",
    "unitId": 1,
    "createdAt": "2024-01-17T10:00:00Z"
  }
}
```

---

## 📊 Error Handling

| Error Type | Status Code | Exception | Failure |
|-----------|------------|-----------|---------|
| Bad Request | 400 | BadRequestException | BadRequestFailure |
| Unauthorized | 401 | UnauthorizedException | UnauthorizedFailure |
| Forbidden | 403 | ForbiddenException | ForbiddenFailure |
| Not Found | 404 | NotFoundException | NotFoundFailure |
| Conflict | 409 | ConflictException | ConflictFailure |
| Server Error | 500 | ServerException | ServerFailure |
| Connection Timeout | - | TimeoutException | TimeoutFailure |
| Network Error | - | NetworkException | NetworkFailure |
| Unknown | - | Exception | UnknownFailure |

---

## 🔧 Service Locator Setup

**File**: [lib/core/utils/service_locator.dart](lib/core/utils/service_locator.dart)

```dart
// External Dependencies
final sharedPreferences = await SharedPreferences.getInstance();
getIt.registerSingleton<SharedPreferences>(sharedPreferences);

// API Client
getIt.registerSingleton<ApiClient>(ApiClient());

// Data Sources
getIt.registerSingleton<AuthLocalDataSource>(
  AuthLocalDataSource(prefs: getIt<SharedPreferences>()),
);

getIt.registerSingleton<LoginRemoteDataSource>(
  LoginRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
);

// Repositories
getIt.registerSingleton<AuthRepository>(
  AuthRepositoryImpl(
    remoteDataSource: getIt<LoginRemoteDataSource>(),
    localDataSource: getIt<AuthLocalDataSource>(),
    apiClient: getIt<ApiClient>(),
  ),
);

// Use Cases
getIt.registerSingleton<LoginUseCase>(
  LoginUseCase(repository: getIt<AuthRepository>()),
);
```

---

## ✅ Verified Fixes

1. ✅ **Null Safety Type Casting** - Fixed in error handling
   - Changed `data?['error']` → `(data?['error'] as String?)`
   - Both login and auth datasources updated

2. ✅ **Model Parsing** - Added fallback values in `LoginResponseModel.fromJson()`
   - Handles missing fields gracefully
   - Nested `data` wrapper support

3. ✅ **Token Persistence** - Implemented in `AuthRepositoryImpl`
   - Saves token after successful login
   - Sets token in API client
   - Initializes token on app startup

4. ✅ **User Data Storage** - Saves user info locally
   - User ID, email, role
   - Available for offline use

---

## 🧪 Test Login Credentials

```
Email: fiqifalah17@gmail.com
Password: fiqifalah17
Portal: MOBILE
```

---

## 📝 Next Steps

1. Implement logout functionality
   - Clear token from storage
   - Remove from API client
2. Add refresh token mechanism
3. Implement 401 unauthorized handler
4. Add biometric authentication
5. Add remember me functionality

---

**Last Updated**: January 17, 2026  
**Status**: ✅ Complete and Tested
