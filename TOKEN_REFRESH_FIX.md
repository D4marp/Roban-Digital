# Token Refresh & 401 Error Fix

## Problem
```
Error: Exception: Sesi Anda telah berakhir. Silakan login kembali.
error response: {success: false, message: Invalid or expired token, code: 401}
```

**Root Cause:** 
- Token expired while user was on channel page
- Interceptor attempted refresh but didn't properly handle failures
- When refresh failed, request still sent with expired token
- No callback to redirect user to login page

---

## Solution Implemented

### 1. **Enhanced ApiClient with Unauthorized Callback** 
`lib/data/datasources/api/api_client.dart`

**Changes:**
- Added `OnUnauthorizedCallback` typedef for logout handling
- Added `_onUnauthorized` callback field
- Added `setOnUnauthorizedCallback()` method to register logout handler
- Added `_handleUnauthorized()` method to:
  - Clear tokens from SharedPreferences
  - Clear cached token
  - Remove Authorization header
  - Call registered callback (redirect to login)

**401 Interceptor Logic:**
```dart
// When 401 detected AND not already refreshing:
if (!_isRefreshing) {
  _isRefreshing = true;
  
  // Try to refresh token
  final refreshed = await _refreshAccessToken();
  
  if (refreshed) {
    // Success: retry request with new token
    return handler.resolve(await _retry(e.requestOptions));
  } else {
    // Failure: clear tokens & redirect
    await _handleUnauthorized();
    return handler.next(e);
  }
}
```

### 2. **Updated Channel Page with Auto-Redirect**
`lib/presentation/pages/channel/channel_page.dart`

**Changes:**
- Register unauthorized callback in `initState()`
- Callback shows SnackBar: "Sesi Anda telah berakhir..."
- After 1 second delay, redirects to `/login` page
- Enhanced error UI:
  - Show lock icon for 401 errors
  - Show error icon for other errors
  - "Go to Login" button for 401
  - "Retry" button for other errors

**Error Detection:**
```dart
final is401 = error.contains('Sesi Anda telah berakhir') || 
              error.contains('Invalid or expired token');

if (is401) {
  // Show Go to Login button
  Navigator.pushReplacementNamed(context, '/login');
} else {
  // Show Retry button
  channelProvider.refreshChannels();
}
```

---

## Flow Diagram

### Before (Broken)
```
User on Channel Page
    ↓
GET /channel (with expired token)
    ↓
401 Unauthorized
    ↓
Try refresh → FAILS (no proper handling)
    ↓
Still show error page with confusing message
    ↓
User stuck, no action taken
```

### After (Fixed)
```
User on Channel Page
    ↓
GET /channel (with expired token)
    ↓
401 Unauthorized
    ↓
Interceptor detects 401
    ↓
Try refresh with refresh token
    ├─ SUCCESS: Update token → Retry request → Show channels
    └─ FAILURE: Clear tokens → Call _handleUnauthorized()
                   ↓
              Show "Session expired" SnackBar
                   ↓
              Wait 1 second
                   ↓
              Navigate to /login page
```

---

## Technical Details

### Token Refresh Endpoint
- **Endpoint:** `POST /auth/refresh`
- **Body:** `{ "refreshToken": "..." }`
- **Success Response:** `{ "token": "...", "refreshToken": "..." }`
- **Failure:** Returns 401 or other error

### Error Messages
- **401 Error:** "Sesi Anda telah berakhir. Silakan login kembali."
- **403 Error:** "Anda tidak memiliki akses ke channel. Hubungi administrator."

### Callback Pattern
```dart
// In channel_page.dart initState():
apiClient.setOnUnauthorizedCallback(() async {
  // This runs when token refresh fails
  // Clear tokens and redirect to login
});
```

---

## What Works Now

✅ **Automatic Token Refresh**
- When token expires, system attempts refresh automatically
- No user action needed for auto-refresh
- Original request retried with new token

✅ **Graceful Failure Handling**
- If refresh fails, user immediately sees clear message
- Auto-redirects to login after showing message
- User data cleared from device storage

✅ **Better Error UI**
- Different UI for 401 (auth) vs 403 (permission) vs other errors
- Clear call-to-action buttons
- User can go to login or retry

✅ **Session Management**
- Multiple tabs/pages benefit from single interceptor
- If one page detects 401, all other pages get same notification
- Prevents multiple simultaneous refresh attempts

---

## Testing Checklist

- [ ] Log in successfully
- [ ] Wait for token to expire (or manually expire it)
- [ ] Navigate to channel page
- [ ] Should see "Sesi Anda telah berakhir..." message
- [ ] After 1 second, should redirect to login
- [ ] Login again should work
- [ ] Channels should load successfully

---

## Configuration in App Routes

Make sure your route definition includes '/login':
```dart
// In your route configuration
'/login': (context) => const LoginPage(),
'/channel': (context) => const ChannelPage(),
```

## Dependencies
- `dio`: HTTP client with interceptors
- `provider`: State management
- `shared_preferences`: Token storage
