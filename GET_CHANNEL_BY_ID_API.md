# GET /channel/{id} - Channel Detail API Documentation

## Endpoint Overview
This endpoint retrieves a specific channel by its ID. Access is restricted based on user role and unit.

**URL**: `GET /channel/{id}`  
**Base URL**: `https://ptt-api.uptofive.my.id/api`  
**Authentication**: Required (Bearer Token)  
**Authorization**: Role & Unit-based access control

---

## Access Control

| Role | Can Access |
|------|-----------|
| SUPER_ADMIN | All channels |
| UNIT_ADMIN | Channels in their unit |
| PERSONEL | Only assigned channels |

---

## Request

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | integer | Yes | Unique identifier of the channel |

### Example Request
```bash
curl -X GET \
  'https://ptt-api.uptofive.my.id/api/channel/1' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'accept: application/json'
```

---

## Response

### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Channel retrieved successfully",
  "data": {
    "id": 1,
    "unitId": 1,
    "name": "Operasional",
    "code": "OPS-001",
    "isActive": true,
    "createdBy": 5,
    "createdAt": "2026-01-16T17:19:54.598Z",
    "updatedAt": "2026-01-16T17:19:54.598Z"
  },
  "code": 200
}
```

### Response Fields
| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Always true for successful requests |
| `message` | string | Success message |
| `data` | object | Channel object (see Channel Model below) |
| `code` | integer | HTTP status code (200) |

### Channel Model (data)
| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Channel ID |
| `unitId` | integer | Unit ID channel belongs to |
| `name` | string | Channel name |
| `code` | string | Channel code/identifier |
| `isActive` | boolean | Channel active status |
| `createdBy` | integer | User ID who created channel |
| `createdAt` | string | ISO 8601 timestamp of creation |
| `updatedAt` | string | ISO 8601 timestamp of last update |

---

## Error Responses

### 400 - Bad Request
**Occurs when:**
- Invalid channel ID format
- Missing required parameters

```json
{
  "success": false,
  "error": "Invalid channel ID",
  "code": 400
}
```

### 401 - Unauthorized
**Occurs when:**
- No Authorization header
- Invalid or expired token

```json
{
  "success": false,
  "error": "Missing or invalid Authorization header",
  "code": 401
}
```

### 403 - Forbidden
**Occurs when:**
- User lacks permission to access this channel
- PERSONEL trying to access non-assigned channel
- UNIT_ADMIN trying to access channel from other unit

```json
{
  "success": false,
  "error": "Insufficient permissions to access this channel",
  "code": 403
}
```

### 404 - Not Found
**Occurs when:**
- Channel with given ID doesn't exist

```json
{
  "success": false,
  "error": "Channel not found",
  "code": 404
}
```

### 500 - Internal Server Error
```json
{
  "success": false,
  "error": "Internal server error",
  "code": 500
}
```

---

## Implementation Files

### Data Layer
- **Remote DataSource**: `lib/data/datasources/remote/channel_remote_datasource.dart`
  - `getChannelById(int id)` method
  - Handles GET `/channel/{id}` API call
  - Parses response to ChannelModel

### Domain Layer
- **Repository**: `lib/domain/repositories/channel_repository.dart`
  - `getChannelById(int id)` interface method
  - Returns `Either<Failure, ChannelEntity>`

- **UseCase**: `lib/domain/usecases/get_channel_by_id_usecase.dart`
  - `GetChannelByIdUsecase` business logic
  - `call(int id)` method

### Data Repositories
- **Repository Implementation**: `lib/data/repositories/channel_repository_impl.dart`
  - `getChannelById()` implementation
  - Error handling and entity mapping

---

## Usage Example

### 1. Basic Usage
```dart
// Inject dependencies
final usecase = GetChannelByIdUsecase(repository: repository);

// Call with channel ID
final result = await usecase.call(1);

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (channel) => print('Channel: ${channel.name}'),
);
```

### 2. With Error Handling
```dart
Future<void> fetchChannelDetail(int channelId) async {
  final result = await usecase.call(channelId);
  
  result.fold(
    (failure) {
      if (failure is UnauthorizedFailure) {
        // Token expired - redirect to login
        redirectToLogin();
      } else if (failure is ForbiddenFailure) {
        // User doesn't have access
        showError('You don\'t have access to this channel');
      } else if (failure is NotFoundFailure) {
        // Channel doesn't exist
        showError('Channel not found');
      } else {
        showError(failure.message);
      }
    },
    (channel) {
      // Update UI with channel data
      setState(() => currentChannel = channel);
    },
  );
}
```

### 3. In Provider Pattern
```dart
class ChannelDetailProvider extends ChangeNotifier {
  final GetChannelByIdUsecase usecase;
  
  ChannelEntity? channel;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadChannelDetail(int channelId) async {
    isLoading = true;
    notifyListeners();

    final result = await usecase.call(channelId);

    result.fold(
      (failure) {
        errorMessage = failure.message;
      },
      (fetchedChannel) {
        channel = fetchedChannel;
        errorMessage = null;
      },
    );

    isLoading = false;
    notifyListeners();
  }
}
```

### 4. Display Channel Details
```dart
class ChannelDetailPage extends StatelessWidget {
  final int channelId;

  const ChannelDetailPage({required this.channelId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelDetailProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const CircularProgressIndicator();
        }

        if (provider.errorMessage != null) {
          return Center(child: Text('Error: ${provider.errorMessage}'));
        }

        final channel = provider.channel;
        if (channel == null) return const SizedBox();

        return ListView(
          children: [
            ListTile(
              title: const Text('Channel Name'),
              subtitle: Text(channel.name),
            ),
            ListTile(
              title: const Text('Channel Code'),
              subtitle: Text(channel.code),
            ),
            ListTile(
              title: const Text('Unit ID'),
              subtitle: Text('${channel.unitId}'),
            ),
            ListTile(
              title: const Text('Status'),
              subtitle: Text(channel.isActive ? 'Active' : 'Inactive'),
            ),
            ListTile(
              title: const Text('Created'),
              subtitle: Text(channel.createdAt.toString()),
            ),
          ],
        );
      },
    );
  }
}
```

---

## Integration with Other Features

### With Channel List
```
1. Show list of channels (GET /channel)
2. User tap on channel item
3. Navigate to channel detail page
4. Call GET /channel/{id}
5. Display full channel information
```

### With Messages/Chat
```
1. Fetch channel detail
2. Get channel.id for messages API
3. Call GET /channel/{id}/messages
4. Display messages in that channel
```

### With Participants
```
1. Fetch channel detail
2. Show channel info
3. Fetch participants (GET /channel/{id}/participants)
4. Display member list
```

---

## Best Practices

### 1. Permission Checking
```dart
// Always handle 403 Forbidden
if (failure is ForbiddenFailure) {
  // Show appropriate message
  // Don't allow further actions on this channel
}
```

### 2. Caching Strategy
```dart
// Cache channel detail to reduce API calls
Future<ChannelEntity> getChannelWithCache(int id) async {
  // Check cache first
  final cached = _channelCache[id];
  if (cached != null && !_isCacheExpired(id)) {
    return cached;
  }

  // Fetch from API
  final result = await usecase.call(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (channel) {
      _channelCache[id] = channel;
      _cacheTimes[id] = DateTime.now();
      return channel;
    },
  );
}
```

### 3. Navigation Handling
```dart
Future<void> navigateToChannelDetail(BuildContext context, int channelId) async {
  final result = await usecase.call(channelId);
  
  result.fold(
    (failure) {
      if (failure is ForbiddenFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You don\'t have access')),
        );
      } else {
        Navigator.pushNamed(context, '/channel/$channelId');
      }
    },
    (channel) {
      Navigator.pushNamed(context, '/channel/$channelId');
    },
  );
}
```

### 4. Error User Feedback
```dart
String getErrorMessage(Failure failure) {
  if (failure is UnauthorizedFailure) {
    return 'Your session has expired. Please login again.';
  } else if (failure is ForbiddenFailure) {
    return 'You don\'t have permission to access this channel.';
  } else if (failure is NotFoundFailure) {
    return 'This channel no longer exists.';
  } else if (failure is NetworkFailure) {
    return 'Network connection error. Please check your connection.';
  } else if (failure is TimeoutFailure) {
    return 'Request took too long. Please try again.';
  }
  return 'An error occurred. Please try again.';
}
```

---

## Testing

### Unit Test Example
```dart
test('GetChannelByIdUsecase returns ChannelEntity on success', () async {
  // Arrange
  final mockChannel = ChannelEntity(
    id: 1,
    unitId: 1,
    name: 'Test Channel',
    code: 'TEST-001',
    isActive: true,
    createdBy: 5,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  when(mockRepository.getChannelById(1)).thenAnswer(
    (_) async => Right(mockChannel),
  );

  // Act
  final result = await usecase.call(1);

  // Assert
  expect(result, Right(mockChannel));
  verify(mockRepository.getChannelById(1)).called(1);
});
```

### Integration Test Example
```dart
testWidgets('Display channel details after fetching', (tester) async {
  await tester.pumpWidget(const RobanDigitalApp());
  
  // Navigate to channel detail
  await tester.tap(find.byType(ChannelListItem).first);
  await tester.pumpAndSettle();
  
  // Verify channel data displayed
  expect(find.text('Operasional'), findsOneWidget);
  expect(find.text('OPS-001'), findsOneWidget);
});
```

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| 403 Forbidden | Insufficient permissions | Check user role and unit |
| 404 Not Found | Channel ID doesn't exist | Verify channel ID |
| 401 Unauthorized | Invalid token | Re-authenticate |
| Null pointer | Channel not fetched | Call usecase before accessing |
| Network timeout | Slow connection | Increase timeout or retry |

---

## Related Endpoints

- **GET /channel** - List all channels with pagination
- **GET /auth/me** - Get current user info
- **GET /channel/{id}/messages** - Get channel messages
- **GET /channel/{id}/participants** - Get channel members

---

## API Changelog

### v1.0 (Current)
- Initial implementation
- Returns single channel detail
- Role-based access control

