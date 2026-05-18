# db_notes

Sleek Flutter note-taking app backed by **Firebase** (Firestore + Anonymous Auth).

## Features

- Dark, glassy Material 3 UI with DM Sans (via [google_fonts](https://pub.dev/packages/google_fonts))
- Real-time note list synced from Cloud Firestore
- Search, create, edit, delete; empty new notes are removed automatically
- Per-note accent color stored as `accentIndex`

## Firebase setup

1. Create a Firebase project and enable **Cloud Firestore** (production or test mode initially).
2. Enable **Anonymous** authentication: Firebase Console → Authentication → Sign-in method → Anonymous → Enable.
3. Install [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) and generate options:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   This overwrites `lib/firebase_options.dart` and adds platform config (`google-services.json`, `GoogleService-Info.plist`, etc.).

4. Add Firestore security rules so users only access their own notes:

   ```txt
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId}/notes/{noteId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

5. **Android:** place `google-services.json` under `android/app/` (FlutterFire does this). The project already applies the Google Services Gradle plugin.

6. **iOS:** open `ios/Runner.xcworkspace` once after `flutterfire configure` so Xcode picks up `GoogleService-Info.plist`.

## Run

```bash
flutter pub get
flutter run
```

## Project layout

| Path | Role |
|------|------|
| `lib/main.dart` | Firebase init, anonymous auth gate |
| `lib/theme/` | Dark theme + accent palette |
| `lib/models/note.dart` | Note model + Firestore mapping |
| `lib/services/notes_repository.dart` | `users/{uid}/notes` CRUD + stream |
| `lib/screens/` | Home list + editor |
| `lib/widgets/note_card.dart` | Card UI |
