// Safe stub for a public repository — no API keys checked in.
//
// Generate real config locally (also creates gitignored platform files):
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Do not commit regenerated firebase_options.dart or the plist/json files.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase client config is missing.\n\n'
      'From the project root run:\n'
      '  dart pub global activate flutterfire_cli\n'
      '  flutterfire configure\n\n'
      'That writes lib/firebase_options.dart plus google-services.json and '
      'GoogleService-Info.plist (ignored by git). See README.md.',
    );
  }
}
