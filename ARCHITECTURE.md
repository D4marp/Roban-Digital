# 🏗️ Roban Digital PPT Apps - Project Architecture

## 📋 Ringkasan Proyek
**Nama**: Roban Digital PPT Apps  
**Tipe**: Flutter Presentation Application  
**Deskripsi**: Aplikasi presentasi modern dengan kemampuan membuat, mengedit, dan menampilkan slide presentasi  
**Platform**: iOS, Android, Web, Windows, macOS  

---

## 🎯 Arsitektur Overview

### **Architecture Pattern: Clean Architecture + Provider State Management**

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                    │
│  (UI Widgets, Pages, Screens, State Management)         │
├─────────────────────────────────────────────────────────┤
│                    DOMAIN LAYER                          │
│  (Use Cases, Repositories Interfaces, Entities)         │
├─────────────────────────────────────────────────────────┤
│                    DATA LAYER                            │
│  (Data Sources, Repository Implementations)             │
├─────────────────────────────────────────────────────────┤
│                    INFRASTRUCTURE LAYER                  │
│  (API Services, Local Storage, Firebase, etc)           │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Struktur Folder Project

```
robandigital/
├── lib/
│   ├── config/                          # Konfigurasi aplikasi
│   │   ├── constants/
│   │   │   ├── app_constants.dart      # Konstanta aplikasi
│   │   │   ├── app_colors.dart         # Palet warna
│   │   │   ├── app_strings.dart        # String/text
│   │   │   └── app_dimens.dart         # Ukuran & spacing
│   │   ├── routes/
│   │   │   ├── app_routes.dart         # Route definitions
│   │   │   └── route_generator.dart    # Route generator
│   │   └── theme/
│   │       ├── app_theme.dart          # Theme config
│   │       └── text_theme.dart         # Typography
│   │
│   ├── core/                            # Core utilities
│   │   ├── errors/
│   │   │   ├── failures.dart           # Error handling
│   │   │   └── exceptions.dart         # Custom exceptions
│   │   ├── utils/
│   │   │   ├── logger_util.dart        # Logging
│   │   │   ├── date_util.dart          # Date utilities
│   │   │   ├── validators.dart         # Input validators
│   │   │   └── extensions.dart         # Dart extensions
│   │   └── widgets/
│   │       ├── app_bar_widget.dart     # Custom AppBar
│   │       ├── custom_button.dart      # Custom Button
│   │       ├── loading_widget.dart     # Loading indicator
│   │       └── error_widget.dart       # Error display
│   │
│   ├── data/                            # DATA LAYER
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   └── ppt_local_datasource.dart
│   │   │   └── remote/
│   │   │       └── ppt_remote_datasource.dart
│   │   ├── models/
│   │   │   ├── slide_model.dart
│   │   │   ├── presentation_model.dart
│   │   │   └── user_model.dart
│   │   └── repositories/
│   │       └── ppt_repository_impl.dart
│   │
│   ├── domain/                          # DOMAIN LAYER
│   │   ├── entities/
│   │   │   ├── slide.dart
│   │   │   ├── presentation.dart
│   │   │   └── user.dart
│   │   ├── repositories/
│   │   │   └── ppt_repository.dart     # Abstract repository
│   │   └── usecases/
│   │       ├── create_presentation.dart
│   │       ├── edit_slide.dart
│   │       ├── delete_presentation.dart
│   │       └── get_presentations.dart
│   │
│   ├── presentation/                   # PRESENTATION LAYER
│   │   ├── providers/                  # State Management (Provider)
│   │   │   ├── auth_provider.dart
│   │   │   ├── presentation_provider.dart
│   │   │   ├── slide_provider.dart
│   │   │   └── theme_provider.dart
│   │   │
│   │   ├── pages/                      # Full Pages/Screens
│   │   │   ├── splash/
│   │   │   │   ├── splash_page.dart
│   │   │   │   └── splash_provider.dart
│   │   │   ├── auth/
│   │   │   │   ├── login_page.dart
│   │   │   │   ├── register_page.dart
│   │   │   │   └── auth_provider.dart
│   │   │   ├── home/
│   │   │   │   ├── home_page.dart
│   │   │   │   └── widgets/
│   │   │   ├── presentation_list/
│   │   │   │   ├── presentation_list_page.dart
│   │   │   │   └── widgets/
│   │   │   ├── presentation_editor/
│   │   │   │   ├── editor_page.dart
│   │   │   │   ├── slide_editor_page.dart
│   │   │   │   └── widgets/
│   │   │   ├── presentation_viewer/
│   │   │   │   ├── viewer_page.dart
│   │   │   │   └── widgets/
│   │   │   └── settings/
│   │   │       ├── settings_page.dart
│   │   │       └── widgets/
│   │   │
│   │   └── widgets/                    # Reusable Widgets
│   │       ├── slide_thumbnail.dart
│   │       ├── slide_card.dart
│   │       ├── text_element.dart
│   │       └── shape_element.dart
│   │
│   ├── main.dart                        # Entry point
│   └── app.dart                         # App widget
│
├── assets/
│   ├── images/
│   │   ├── splash/
│   │   ├── logos/
│   │   └── icons/
│   ├── fonts/
│   └── lottie/
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml
├── analysis_options.yaml
├── ARCHITECTURE.md
└── README.md
```

---

## 🔄 Flow Diagram

### **User Journey Flow**
```
Splash Screen
     ↓
Authentication (Login/Register)
     ↓
Home Page (Dashboard)
     ↓
Presentation List
     ├→ View Presentation
     ├→ Create New Presentation
     └→ Edit Presentation
          ├→ Add/Edit Slide
          ├→ Add/Edit Elements
          └→ Save & Publish
```

---

## 📦 Dependencies & Libraries

### **State Management**
- `provider: ^6.0.0` - State management
- `riverpod: ^2.0.0` - Alternative (optional)

### **Local Storage**
- `hive: ^2.0.0` - Local database
- `shared_preferences: ^2.0.0` - Simple key-value storage

### **Network & API**
- `dio: ^5.0.0` - HTTP client
- `retrofit: ^4.0.0` - REST API

### **Database**
- `sqflite: ^2.0.0` - Local SQLite (if needed)

### **UI & Design**
- `google_fonts: ^4.0.0` - Google Fonts
- `lottie: ^2.0.0` - Animations
- `smooth_page_indicator: ^1.0.0` - Page indicator

### **Firebase (Optional)**
- `firebase_core: ^2.0.0`
- `firebase_auth: ^4.0.0`
- `cloud_firestore: ^4.0.0`
- `firebase_storage: ^11.0.0`

### **Utility**
- `intl: ^0.18.0` - Internationalization
- `get_it: ^7.0.0` - Service locator
- `dartz: ^0.10.0` - Functional programming

### **Development**
- `flutter_lints: ^2.0.0` - Linting
- `mockito: ^5.0.0` - Mocking for tests

---

## 🏛️ Layer Responsibilities

### **1. Presentation Layer**
- **Widgets**: UI components
- **Pages**: Full screens
- **Providers**: State management (Provider/Riverpod)
- **Responsibility**: Display UI, handle user interactions, update UI based on state

### **2. Domain Layer**
- **Entities**: Core business objects
- **Repositories (Interfaces)**: Define contract
- **Use Cases**: Business logic orchestration
- **Responsibility**: Define business rules, independent of implementation

### **3. Data Layer**
- **Models**: Extend entities with serialization
- **Data Sources**: Local & remote data access
- **Repositories (Implementation)**: Implement interfaces
- **Responsibility**: Manage data from various sources

### **4. Infrastructure Layer**
- **API Services**: Network calls
- **Local Storage**: Database, cache
- **Firebase**: Backend services
- **Responsibility**: Handle external services

---

## 🔧 Core Modules

### **1. Splash Module**
- Welcome screen dengan branding
- Initialize app data
- Check authentication status

### **2. Authentication Module**
- Login/Register
- Password reset
- OAuth integration (optional)

### **3. Presentation Management Module**
- Create presentation
- List presentations
- View details
- Delete/Archive presentations

### **4. Slide Editor Module**
- Add/edit slides
- Add text elements
- Add shapes & images
- Manage layers

### **5. Viewer/Player Module**
- Display presentation in full-screen
- Navigation between slides
- Presentation mode

### **6. Settings Module**
- User preferences
- Theme selection
- Language settings

---

## 🎨 Design Patterns Used

| Pattern | Usage | Location |
|---------|-------|----------|
| **MVC/MVVM** | UI state management | Presentation Layer |
| **Repository** | Abstract data access | Domain + Data |
| **Dependency Injection** | Service locator | main.dart, get_it |
| **Factory** | Create objects | Models, Entities |
| **Observer** | Listen to state changes | Provider |
| **Singleton** | Single instance | Services |

---

## 📱 Responsive Design

- **Mobile First** approach
- Breakpoints:
  - `< 600px`: Mobile
  - `600-900px`: Tablet (Portrait)
  - `> 900px`: Tablet/Desktop (Landscape)

---

## ✅ Best Practices

1. **Separation of Concerns**: Each layer has clear responsibility
2. **Dependency Inversion**: Depend on abstractions, not implementations
3. **Scalability**: Easy to add new features without touching existing code
4. **Testability**: Each layer can be tested independently
5. **Code Reusability**: Common widgets & utilities in core layer
6. **Naming Conventions**: Clear, descriptive names
7. **Documentation**: Code comments for complex logic
8. **Error Handling**: Proper exception & failure handling

---

## 🚀 Getting Started

1. Create folder structure
2. Setup pubspec.yaml with dependencies
3. Implement core utilities & widgets
4. Build domain layer (entities & usecases)
5. Implement data layer (models & repositories)
6. Create presentation layer (pages & providers)
7. Setup routing
8. Test each module

---

## 📝 Development Guidelines

- Use **immutable classes** for entities & models
- Follow **Flutter/Dart style guide**
- Write **unit tests** for business logic
- Use **meaningful commit messages**
- Review code before merging
- Keep **functions small & focused**
- Avoid **deep nesting**

---

**Last Updated**: January 2, 2026  
**Version**: 1.0.0
