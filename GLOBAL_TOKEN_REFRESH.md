# Global Token Refresh Mechanism ✅

## Overview
Implementasi proactive token refresh yang terus memperbarui access token secara global di seluruh aplikasi. Token tidak pernah expired saat digunakan.

---

## Flow Diagram

### Token Lifecycle
```
LOGIN
  ↓
[Access Token: 15 min]
[Refresh Token: 30 days]
  ↓
After 2 minutes:
  ↓
🔄 PROACTIVE REFRESH (every 5 minutes)
  ↓
✅ New Access Token
✅ Token Valid untuk 15 menit ke depan
  ↓
Repeat every 5 minutes
  ↓
(Token never expires during normal usage)
```

---

## Implementation Details

### 1. **ApiClient Global Refresh Timer**

**File:** `lib/data/datasources/api/api_client.dart`

**Key Components:**

```dart
// Fields
Timer? _tokenRefreshTimer;
static const Duration _refreshInterval = Duration(minutes: 5);
static const Duration _bufferTime = Duration(minutes: 2);

// Start refresh timer when token set
void _startTokenRefreshTimer() {
  _tokenRefreshTimer?.cancel();
  
  // Refresh every 5 minutes
  _tokenRefreshTimer = Timer.periodic(_refreshInterval, (_) async {
    await _proactiveTokenRefresh();
  });
  
  // First refresh after 2 minute buffer
  Future.delayed(_bufferTime, () async {
    if (_cachedRefreshToken != null) {
      await _proactiveTokenRefresh();
    }
  });
}

// Proactive token refresh (doesn't wait for 401)
Future<void> _proactiveTokenRefresh() async {
  // 1. Check if already refreshing (prevent loops)
  if (_isRefreshing) return;
  
  _isRefreshing = true;
  
  // 2. Get refresh token from cache or storage
  final refreshToken = _cachedRefreshToken ?? 
                      prefs.getString(_refreshTokenKey);
  
  if (refreshToken == null) {
    _isRefreshing = false;
    return;
  }
  
  // 3. Call /auth/refresh endpoint
  final response = await dio.post('/auth/refresh', 
    data: {'refreshToken': refreshToken}
  );
  
  // 4. Update cached tokens
  _cachedToken = response.data['token'];
  _cachedRefreshToken = response.data['refreshToken'];
  
  // 5. Persist to storage
  await prefs.setString(_tokenKey, newToken);
  
  // 6. Update Dio headers
  _dio.options.headers['Authorization'] = 'Bearer $newToken';
  
  _isRefreshing = false;
}

// Stop timer on logout
void _stopTokenRefreshTimer() {
  _tokenRefreshTimer?.cancel();
  _tokenRefreshTimer = null;
}
```

### 2. **Cached Tokens Storage**

**File:** `lib/data/datasources/api/api_client.dart`

```dart
// In-memory cache (fast access)
String? _cachedToken;           // Current access token
String? _cachedRefreshToken;    // Current refresh token

// When token set:
void setAuthToken(String token, [String? refreshToken]) {
  _cachedToken = token;
  if (refreshToken != null) {
    _cachedRefreshToken = refreshToken;  // ← NEW
  }
  _dio.options.headers['Authorization'] = 'Bearer $token';
  _startTokenRefreshTimer();  // ← Start auto-refresh
}
```

### 3. **Integration with Login**

**File:** `lib/data/repositories/auth_repository_impl.dart`

```dart
Future<Either<Failure, AuthEntity>> login(...) async {
  try {
    final response = await remoteDataSource.login(request);
    
    // Save tokens to storage
    await localDataSource.saveTokens(
      token: response.token,
      refreshToken: response.refreshToken,
    );
    
    // ✅ Set BOTH tokens to ApiClient
    // This starts the global refresh timer automatically
    apiClient.setAuthToken(
      response.token, 
      response.refreshToken  // ← Pass refresh token
    );
    
    // Rest of login flow...
  }
}
```

### 4. **Integration with Token Refresh**

**File:** `lib/data/repositories/auth_repository_impl.dart`

```dart
Future<Either<Failure, AuthEntity>> refreshToken() async {
  try {
    final response = await remoteDataSource.refreshToken();
    
    // Save new tokens
    await localDataSource.saveTokens(
      token: response.token,
      refreshToken: response.refreshToken,
    );
    
    // ✅ Update BOTH tokens (restarts timer)
    apiClient.setAuthToken(
      response.token,
      response.refreshToken
    );
    
    return Right(AuthEntity(...));
  }
}
```

### 5. **Initialization on App Startup**

**File:** `lib/main.dart`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  
  // Initialize authentication token from storage
  final apiClient = getIt<ApiClient>();
  await apiClient.initializeAuthToken();
  // ✅ This loads token and STARTS refresh timer
  
  runApp(const RobanDigitalApp());
}

// ApiClient.initializeAuthToken()
Future<void> initializeAuthToken() async {
  await _loadTokenFromPrefs();
  if (_cachedToken != null && _cachedToken!.isNotEmpty) {
    _dio.options.headers['Authorization'] = 'Bearer $_cachedToken';
    _startTokenRefreshTimer();  // ← Start timer
  }
}
```

---

## Token Refresh Timeline

### Scenario: Token Valid for 15 minutes, Refresh Every 5 Minutes

```
T=0min:   User logs in
          - Access Token: Valid (15 min)
          - Refresh Token: Saved
          - Timer: Started
          
T=2min:   First refresh triggered (buffer time)
          - Call POST /auth/refresh
          - Get new access token
          - Update cache & storage
          - Update Authorization header
          
T=7min:   Second refresh (every 5 min)
          - Call POST /auth/refresh
          - Update all tokens
          
T=12min:  Third refresh
          - Call POST /auth/refresh
          - Update all tokens
          
T=15min:  Original token would expire, but...
          - Already refreshed at T=12min
          - Token still valid!
          
T=17min:  Fourth refresh
          - Call POST /auth/refresh
          - Update all tokens
          
✅ Token NEVER expires during normal usage
```

---

## Error Handling

### What Happens When Refresh Fails?

1. **During Proactive Refresh (timer):**
   - Log error
   - Don't retry immediately
   - Will try again in 5 minutes
   - Continue with cached token
   - If next request fails with 401 → redirect to login

2. **During Reactive Refresh (401 interceptor):**
   - Try to refresh
   - If succeeds → retry request
   - If fails → clear tokens → redirect to login

```dart
// Proactive refresh failure (logged, but doesn't block)
Future<void> _proactiveTokenRefresh() async {
  try {
    // Attempt refresh
    final response = await dio.post('/auth/refresh', ...);
    // Update tokens
  } catch (e) {
    if (kDebugMode) {
      print('[ApiClient] Proactive refresh failed: $e');
    }
    // Will try again in 5 minutes
    _isRefreshing = false;
  }
}
```

---

## Key Features

### ✅ **Proactive Refresh**
- Refreshes BEFORE token expires
- Prevents 401 errors during normal usage
- Reduces unnecessary error handling

### ✅ **Global Coverage**
- Single timer for entire app
- All API calls use refreshed token
- No per-request refresh logic needed

### ✅ **Cached Tokens**
- Fast access (in-memory)
- Updated immediately after refresh
- Persisted to SharedPreferences

### ✅ **Graceful Failure**
- Timer continues if refresh fails
- Falls back to storage
- Reactive 401 handler as backup

### ✅ **Resource Efficient**
- Single timer (not one per request)
- Scheduled refresh (not on-demand)
- Configurable intervals

---

## Configuration

### Adjust Refresh Timing

**File:** `lib/data/datasources/api/api_client.dart`

```dart
// Refresh every X minutes
static const Duration _refreshInterval = Duration(minutes: 5);

// Wait X minutes before first refresh (buffer)
static const Duration _bufferTime = Duration(minutes: 2);
```

**Formula:**
```
Access Token TTL: 15 minutes
Buffer Time: 2 minutes → First refresh at T=2min
Refresh Interval: 5 minutes → Every 5 min after
Result: Token refreshed at T=2, 7, 12, 17, 22...
Token never expires (valid 15 min, refreshed every 5 min)
```

---

## Debug Logging

When debugging token refresh:

```
[ApiClient] Starting global token refresh timer (interval: 0:05:00)
[ApiClient] Global token refresh triggered
[ApiClient._proactiveTokenRefresh] Proactively refreshing access token...
[ApiClient._proactiveTokenRefresh] ✓ Token refreshed successfully (proactive)

[ApiClient] 401 Unauthorized - attempting token refresh...
[ApiClient] Token refreshed successfully, retrying request...
```

---

## Testing Checklist

- [ ] **Login** → Token refresh timer starts
- [ ] **Wait 2 minutes** → First refresh happens automatically
- [ ] **Check console** → See "Token refreshed successfully" messages
- [ ] **Make API call** → Uses refreshed token (no 401)
- [ ] **Switch to other page** → Refresh continues globally
- [ ] **Token never expires** during normal 30-minute session
- [ ] **Logout** → Timer stops, tokens cleared
- [ ] **App restart** → Reads stored token, restarts timer

---

## Flow Summary

```
┌─────────────────────────────────────────────────────────┐
│                   LOGIN PAGE                             │
│  User enters email/password → POST /auth/login          │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
           ✅ Response received:
           {token: "...", refreshToken: "..."}
                     │
                     ↓
         ┌───────────────────────────┐
         │ AuthRepository.login()    │
         │  - Save tokens to storage │
         │  - Call setAuthToken()    │ ← Sets both tokens
         └────────────┬──────────────┘
                      │
                      ↓
            ┌──────────────────────┐
            │ ApiClient.setAuthToken() NEW TOKENS │
            │ - Update cache       │
            │ - Update headers     │
            │ - Start timer        │ ← START GLOBAL TIMER
            └──────────┬───────────┘
                       │
                       ↓
         ┌─────────────────────────────┐
         │ GLOBAL REFRESH TIMER ACTIVE │
         │ Every 5 minutes:            │
         │  POST /auth/refresh         │
         │  - Get new token            │
         │  - Update cache             │
         │  - Update storage           │
         │  - Update headers           │
         └─────────────────────────────┘
                       │
                       ↓
         ┌─────────────────────────────┐
         │ ALL API CALLS NOW USE       │
         │ FRESH TOKENS ALWAYS         │
         │ ✅ No 401 errors            │
         │ ✅ No session timeouts      │
         └─────────────────────────────┘
```

---

## Files Modified

1. **lib/data/datasources/api/api_client.dart** ✅
   - Added `Timer? _tokenRefreshTimer`
   - Added `_startTokenRefreshTimer()`
   - Added `_stopTokenRefreshTimer()`
   - Added `_proactiveTokenRefresh()`
   - Updated `setAuthToken(String token, [String? refreshToken])`
   - Updated `removeAuthToken()` to stop timer

2. **lib/data/repositories/auth_repository_impl.dart** ✅
   - Updated `login()` to pass refresh token: `setAuthToken(token, refreshToken)`
   - Updated `refreshToken()` to pass refresh token: `setAuthToken(token, refreshToken)`

3. **lib/main.dart** ✅
   - `initializeAuthToken()` already starts timer

---

## Benefits

| Benefit | Before | After |
|---------|--------|-------|
| Token Expiration | ❌ Possible during use | ✅ Never expires |
| 401 Errors | ⚠️ Frequent | ✅ Rarely happens |
| User Experience | ❌ Session interrupted | ✅ Seamless |
| Error Recovery | ❌ Manual refresh | ✅ Automatic |
| Code Complexity | ⚠️ Complex 401 handling | ✅ Simplified |
| Performance | ✅ Only on 401 | ✅ Scheduled refresh |

---

## Next Steps

1. ✅ **Restart app** → Token refresh starts automatically
2. ✅ **Monitor console** → See refresh messages every 5 minutes
3. ✅ **Make API calls** → All use fresh tokens
4. ✅ **Switch pages** → Refresh continues globally
5. ✅ **Test error scenarios** → Verify graceful degradation

