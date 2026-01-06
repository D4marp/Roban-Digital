# Home Page Implementation

## Overview
This home page has been implemented based on the Figma design from PPT POLRES BATANG.

## Features Implemented

### 1. Header Section
- Custom status bar with time, signal, WiFi, and battery indicators
- User profile section with:
  - Profile picture (circular with white border)
  - User name: "Salsabila Khaliq"
  - Email: "salsabila123@gmail.com"
- Background color: `#1B3C53` (dark blue)

### 2. Navigation Grid (6 Menu Items)
- **Channel** - Communication channel access
- **Talk** - Voice communication
- **Chat** - Text messaging
- **Absensi** - Attendance tracking
- **Video Conference** - Video call feature
- **Riwayat** - History/Records

All menu items have:
- White background with shadow
- 90x90 size
- 10px border radius
- Custom icons from Figma

### 3. Attendance Summary Section
- **Month Selector**: Dropdown showing "Januari 2026"
- **4 Attendance Cards**:
  1. **Kehadiran (Present)**: 21 - Green theme with checkmark icon
  2. **Tidak Hadir (Absent)**: 21 - Red theme with close icon
  3. **Terlambat (Late)**: 21 - Yellow theme with clock icon
  4. **Izin (Leave)**: 21 - Blue theme with calendar icon

Each card displays:
- Label (12px font)
- Count (32px font)
- Colored icon badge in top-right corner

### 4. Floating Action Button
- Located in bottom-right corner
- Dark blue background (`#1B3C53`)
- Shows three-dot menu icon
- 50x50 size with shadow

## Assets Downloaded
All assets have been downloaded from Figma and stored in `assets/images/home/`:
- `profile_picture.png` - User profile photo
- `icon_channel.png` - Channel menu icon
- `icon_talk.png` - Talk menu icon
- `icon_chat.png` - Chat menu icon
- `icon_absensi.png` - Attendance menu icon
- `icon_video_conference.png` - Video conference icon
- `icon_riwayat.png` - History icon
- `icon_battery.png` - Battery status icon
- `icon_wifi.png` - WiFi status icon
- `icon_signal.png` - Signal status icon

## Color Scheme
- Primary Dark Blue: `#1B3C53`
- Header Status Bar: `#2F678F`
- Kehadiran (Present): `#D9FFD1` background, `#00FF2F` accent
- Tidak Hadir (Absent): `#FFEAEA` background, `#FF3030` accent
- Terlambat (Late): `#FFFDEA` background, `#FFD500` accent
- Izin (Leave): `#EAF8FF` background, `#57B5DA` accent

## File Structure
```
lib/presentation/pages/home/
└── home_page.dart (completely reimplemented)

assets/images/home/
├── profile_picture.png
├── icon_channel.png
├── icon_talk.png
├── icon_chat.png
├── icon_absensi.png
├── icon_video_conference.png
├── icon_riwayat.png
├── icon_battery.png
├── icon_wifi.png
└── icon_signal.png
```

## Usage
The HomePage widget is a StatefulWidget that can be used directly in your Flutter app:

```dart
import 'package:robandigital/presentation/pages/home/home_page.dart';

// Navigate to home page
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const HomePage()),
);
```

## Design Fidelity
The implementation closely matches the Figma design with:
- Exact colors from the design
- Proper spacing and padding
- Shadow effects on cards and buttons
- Responsive grid layout
- Clean and maintainable code structure
