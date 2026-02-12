# As-Built Wind Turbine Installation Management - Copilot Instructions

## Project Overview
**As-Built** is a professional Flutter application for managing wind turbine installation tracking across projects with 1-300+ turbines. It uses Firebase (Firestore, Auth, Storage) for backend and Riverpod for state management, supporting Windows desktop, web (Chrome), Android, and iOS platforms.

## Architecture & Key Components

### Technology Stack
- **Frontend**: Flutter 3.4.3+ (multi-platform: Windows, Web, Android, iOS)
- **State Management**: Flutter Riverpod 2.6+ with annotations
- **Backend**: Cloud Firestore + Firebase Auth/Storage
- **Localization**: Multi-language support (Portuguese primary) via `TranslationHelper`
- **OCR**: Google ML Kit + Tesseract (platform-specific via factory pattern)
- **Charts/UI**: fl_chart, percent_indicator, google_fonts, cached_network_image

### Directory Structure & Responsibilities
```
lib/
├── core/               # Framework-level utilities
│   ├── theme/         # app_colors.dart (Material 3 palettes), app_theme.dart
│   └── localization/  # translation_helper.dart
├── models/            # Firestore document models (Project, Turbina, Componente, ProjectPhase, etc.)
├── services/          # Firestore CRUD + business logic (ProjectService, TurbinaService, etc.)
├── providers/         # Riverpod providers: state, streams, async operations
│   ├── app_providers.dart        # Service instances, model streams/futures
│   ├── auth_providers.dart       # Firebase Auth (userId, currentUser, isAuthenticated)
│   ├── notification_providers.dart
│   └── torque_tensioning_providers.dart
├── screens/           # UI screens organized by feature/domain
│   ├── auth/          # Login/authentication
│   ├── dashboard/     # Main KPI dashboard
│   ├── turbinas/      # Turbine management
│   ├── installation/  # Installation phase tracking (multi-section tower handling)
│   ├── torque_tensioning/ # Bolt torque management
│   ├── project/       # Project planning & phase management
│   ├── mobile/        # Mobile-specific screens (logistica_form_screen.dart)
│   └── desktop/       # Desktop-specific layouts
└── widgets/           # Reusable UI components
```

### Critical Patterns & Conventions

#### 1. **Platform Detection & Responsive Design**
```dart
// Standard pattern in every screen that needs platform branching:
bool get _isMobile {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

// Use in build(): if (_isMobile) { /* mobile layout */ } else { /* desktop */ }
```
- Firebase credentials hardcoded in `main.dart` (line ~35) for Windows/Web
- Android/iOS use `google-services.json` / `GoogleService-Info.plist`
- Always check `kIsWeb` before `Platform.*` checks

#### 2. **Firestore Data Models & Serialization**
Models in `lib/models/` follow this pattern:
```dart
class MyModel {
  final String id;
  // ... fields
  
  Map<String, dynamic> toMap() { /* all fields including nested */ }
  
  factory MyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MyModel(
      id: doc.id,
      // ... parse fields (handle null with ??)
    );
  }
  
  factory MyModel.fromMap(Map<String, dynamic> data) { /* alternate constructor */ }
}
```
**Important**: 
- Timestamps: Use `Timestamp.fromDate(dateTime)` in `toMap()`, parse as `(data['field'] as Timestamp).toDate()`
- FieldValue.increment() for atomic counters (see `ProjectService.incrementTotalTurbinas()`)
- Nested objects: Convert to/from Map in toMap()

#### 3. **Service Layer Pattern**
Services (`lib/services/*.dart`) encapsulate all Firestore operations:
```dart
class MyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Stream<List<MyModel>> getAll(String userId) {
    return _firestore.collection('collection')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => MyModel.fromFirestore(doc)).toList());
  }
  
  Future<String> create(MyModel model) async {
    final docRef = await _firestore.collection('collection').add(model.toMap());
    return docRef.id;
  }
}
```

#### 4. **Riverpod Providers (app_providers.dart)**
- `FutureProvider` for one-time async operations
- `StreamProvider` for real-time Firestore streams
- `StateProvider` for simple state mutations (e.g., selectedPhase)
- `StateNotifierProvider` for complex state logic (e.g., NotificationSettings)
- Always provide services first: `final myServiceProvider = Provider((ref) => MyService())`

Example:
```dart
final myStreamProvider = StreamProvider<List<MyModel>>((ref) {
  final service = ref.watch(myServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return service.getAll(userId ?? '');
});
```

#### 5. **OCR Service Factory Pattern**
Platform-specific OCR implementations (`ocr_service.dart`, `ocr_service_mobile.dart`, `ocr_service_desktop.dart`):
```dart
// In ocr_factory.dart
static OcrService createOcrService() {
  if (kIsWeb) return OcrServiceDesktop();
  if (Platform.isWindows) return OcrServiceDesktop();
  return OcrServiceMobile(); // Android/iOS
}
```

#### 6. **Installation/Turbine Tracking (Complex Domain)**
Core models: `Turbina`, `Componente`, `FaseComponente`, `TipoFase`
- `FaseComponente`: Tracks sub-components (e.g., tower sections: base, 3x middle, top) with `status`, `completionDate`
- `TipoFase`: Installation phases (reception, foundation, assembly, etc.)
- Tower: Often has 5 sections: base (1) + middle (3) + top (1)
  - Handled via `numberOfMiddleSections` parameter in `TurbineInstallationDetailsScreen`
  - Dinamically creates FaseComponente entries for each section

#### 7. **Screen State Management**
`ConsumerStatefulWidget` pattern (using Riverpod watch):
```dart
class MyScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(myProviderProvider); // Watch Riverpod provider
    // Build UI
  }
}
```

#### 8. **Localization (Translation Helper)**
```dart
// In widgets/screens:
import '../../core/localization/translation_helper.dart';

Text(TranslationHelper.translate(context, 'key_name'))
// Supports: en, pt (Portuguese primary), other languages in i18n/
```

#### 9. **Theme & Color Constants**
Colors centralized in `lib/core/theme/app_colors.dart`:
```dart
static const Color primaryColor = Color(0xFF1976D2);
static const Color successColor = Color(0xFF4CAF50);
// Use in UI: Container(color: AppColors.primaryColor)
```

## Critical Developer Workflows

### Build & Run
```powershell
# Windows Desktop (primary dev target)
flutter run -d windows

# Web (Chrome)
flutter run -d chrome

# Get dependencies
flutter pub get

# Code generation (Riverpod + build_runner)
flutter pub run build_runner build --delete-conflicting-outputs

# Clean rebuild
flutter clean
flutter pub get
flutter run -d windows
```

### Common Issues
- **Firebase not initialized**: Check `main.dart` line ~35 has correct credentials for your platform
- **Riverpod generator errors**: Run `flutter pub run build_runner clean && build_runner build`
- **Hot reload issues**: Use `r` for hot reload, `R` for hot restart in terminal
- **Tesseract data not found**: Ensure `assets/tessdata/*.traineddata` files are included (see `pubspec.yaml` assets)

### Code Generation
After modifying providers with `@riverpod` annotation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Project-Specific Patterns & Conventions

### Naming & Structure
- **Models**: Singular noun (Project, Turbina, Componente)
- **Services**: `<Plural>Service` (TurbinasService, ComponenteService)
- **Providers**: `<name>Provider` or `<name>StreamProvider` (turbinasProvider, selectedTurbineProvider)
- **Screens**: `<Feature>Screen` (DashboardScreen, TurbineInstallationDetailsScreen)

### Multi-language Support
Portuguese is primary; add translations to `lib/i18n/` for new languages. Use `TranslationHelper.translate()` everywhere.

### Notifications
`NotificationSettings` manages user notification preferences (stored in SharedPreferences). Services check settings before triggering notifications.

### State Mutation Best Practices
- Prefer StreamProvider for Firestore real-time data (auto-updates)
- Use StateProvider for transient UI state (selectedPhase, filters)
- For complex logic: StateNotifierProvider with custom StateNotifier class
- Avoid mixing local setState + Riverpod watch (use one or the other)

### Error Handling
Most Firestore operations wrapped in try-catch; errors typically printed to console. Consider using `AsyncValue` from Riverpod for loading/error UI states.

### Testing
- Unit tests in `test/widget_test.dart`
- No widget tests currently; focus on service/model logic first
- Run: `flutter test`

## Integration Points & Dependencies

### Firebase Setup (Critical)
1. Project created: `asbuilt-app` (Google Cloud Console)
2. Collections: `projects`, `turbinas`, `componentes`, `project_phases`
3. Auth: Email/password enabled
4. Storage: For image uploads in installation tracking
5. Firestore Rules: User-scoped reads/writes (userId field)

### External APIs
- **Google ML Kit**: Text recognition (vision package)
- **Tesseract OCR**: Fallback for desktop platforms
- **Google Fonts**: Font loading (network)
- **Image Picker**: Camera/gallery access (mobile), file picker (desktop)

### Mobile-Specific Considerations
- `permission_handler`: Request camera/gallery permissions
- `image_picker`: Platform-specific implementation
- `shared_preferences`: Local caching of notification settings
- `flutter_screenutil`: Responsive UI scaling

## When Adding New Features

1. **New domain entity?** → Create model in `lib/models/`, implement toMap()/fromFirestore()
2. **Firestore operations?** → Add methods to existing service or create new service in `lib/services/`
3. **Real-time data?** → Add StreamProvider in `lib/providers/app_providers.dart`
4. **New screen?** → Create under `lib/screens/<feature>/` as ConsumerStatefulWidget
5. **Mobile vs Desktop?** → Use `_isMobile` getter to conditionally build UI; consider separate screen variant if major differences
6. **UI constants?** → Add to `lib/core/theme/app_colors.dart` or `lib/core/constants/` (if new file needed)
7. **Translations?** → Add key to `lib/i18n/` and use `TranslationHelper.translate(context, 'key')`

## Key Files for Quick Reference
- **Firebase Config**: [lib/main.dart](lib/main.dart#L35) (credentials hardcoded for Windows/Web)
- **Theme**: [lib/core/theme/app_colors.dart](lib/core/theme/app_colors.dart)
- **Providers**: [lib/providers/app_providers.dart](lib/providers/app_providers.dart)
- **Auth**: [lib/providers/auth_providers.dart](lib/providers/auth_providers.dart)
- **Installation Logic**: [lib/screens/installation/turbine_installation_details_screen.dart](lib/screens/installation/turbine_installation_details_screen.dart)
- **Project Model**: [lib/models/project.dart](lib/models/project.dart)
- **Assets**: [assets/master_template.json](assets/master_template.json) (20 base component templates)
