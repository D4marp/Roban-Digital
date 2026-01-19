# 403 Forbidden Error - Diagnosis & Solution

## Current Issue

**Status**: User is authenticated (Damar, damar@gmail.com) ✅  
**Problem**: 403 Forbidden when accessing `/channel` endpoint ❌

```
[ApiClient] 403 Forbidden - access denied
```

---

## Root Cause Analysis

### 403 Means: Permission Denied (Not Token Issue!)

When API returns **403 Forbidden**, it means:
- ✅ Token is valid
- ✅ User is authenticated
- ❌ User does NOT have permission to access this resource
- ❌ NOT a token expiration issue

### Possible Reasons

1. **User Role Restriction**
   - User role: `PERSONEL`
   - Endpoint `/channel` might require: `SUPER_ADMIN`, `ADMIN`, or specific role
   - Solution: Check backend for role-based access control

2. **Unit/Department Restriction**
   - User might only have access to channels in their specific unit
   - Endpoint might need `unitId` parameter
   - Solution: Pass `unitId` when calling getChannels()

3. **Feature Not Enabled**
   - Channel feature might be disabled for this user/unit
   - Solution: Contact administrator

---

## What Changed (Enhanced Error Handling)

### 1. **Channel Remote Datasource** - Better Error Messages
```dart
if (statusCode == 403) {
  throw Exception('Anda tidak memiliki akses ke channel. Hubungi administrator.');
}
```

✅ Now shows user-friendly error message instead of generic Dio error

### 2. **Channel Provider** - Added Logging
```dart
print('[ChannelProvider.getChannels] Loading channels...');
print('[ChannelProvider.getChannels] Error: ${failure.message}');
```

✅ Easier to debug what's happening

---

## Debug Flow

```
ChannelPage.initState()
    ↓
ChannelProvider.getChannels()
    ↓ [Log: Loading channels...]
    ↓
GetChannelsUsecase()
    ↓
ChannelRepository
    ↓
ChannelRemoteDatasource.getChannels()
    ↓ [Log: GET /channel with params]
    ↓
ApiClient.get('/channel')
    ↓
API returns 403
    ↓ [Log: statusCode: 403]
    ↓
Enhanced error: "Anda tidak memiliki akses ke channel. Hubungi administrator."
    ↓ [Log: Error: tidak memiliki akses...]
    ↓
ChannelProvider error state
    ↓
UI shows friendly error message
```

---

## Debugging Steps

### Step 1: Check User's Role & Permissions
```
User: Damar
Role: PERSONEL
UnitId: (check local storage or /auth/me response)
```

Contact backend team to verify:
- Can role `PERSONEL` access `/channel` endpoint?
- Does `/channel` require specific unitId?
- Are there any feature flags for this user?

### Step 2: Check Console Logs
After fix applied, console should show:
```
[ChannelProvider.getChannels] Loading channels...
  - page: 1
  - pageSize: 10

[ChannelRemoteDatasource.getChannels] GET /channel
  - page: 1
  - limit: 10

[ChannelRemoteDatasource.getChannels] DioException
  - statusCode: 403
  - message: Forbidden
  - error response: {...}

[ChannelProvider.getChannels] Error: Anda tidak memiliki akses ke channel. Hubungi administrator.
```

### Step 3: Possible Solutions

**Option A**: Pass unitId parameter
```dart
// In channel_page.dart
await _channelProvider.getChannels(
  unitId: userUnitId,  // Add this
);
```

**Option B**: Request admin to grant permission
- User role `PERSONEL` doesn't have channel access
- Need to upgrade to `ADMIN` or similar

**Option C**: Check if feature is enabled
- Backend admin needs to enable channel feature for this user

---

## Expected Behavior After Fix

**Before**: Generic Dio error message  
**After**: User-friendly error message explaining the permission issue

```
Error: Anda tidak memiliki akses ke channel. Hubungi administrator.
```

User knows exactly what to do (contact administrator) instead of seeing generic error.

---

## Files Modified

1. **[lib/data/datasources/remote/channel_remote_datasource.dart](lib/data/datasources/remote/channel_remote_datasource.dart)**
   - Added detailed logging
   - Enhanced error messages for 403/401
   - Better exception handling

2. **[lib/presentation/providers/channel_provider.dart](lib/presentation/providers/channel_provider.dart)**
   - Added provider-level logging
   - Shows loading/success/error flow

---

## Next Steps

### For Developer:
1. Check console logs and share them
2. Verify user's role and unitId
3. Try adding unitId parameter to getChannels()

### For Backend Team:
1. Verify role-based access control for `/channel`
2. Check if `PERSONEL` role should have channel access
3. Confirm endpoint response format for 403 errors

---

## Reference

- **HTTP 403**: Permission denied (user authenticated but not authorized)
- **HTTP 401**: Unauthorized (token invalid/expired) - handled separately with auto-refresh
- **HTTP 400**: Bad request (missing/invalid parameters)

**Status**: Enhanced error handling applied. Need backend confirmation on permissions. 🔍
