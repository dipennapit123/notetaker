import 'package:db_notes/firebase_options.dart';
import 'package:db_notes/screens/notes_home_screen.dart';
import 'package:db_notes/services/notes_repository.dart';
import 'package:db_notes/theme/app_theme.dart';
import 'package:db_notes/theme/theme_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final themeController = await ThemeController.load();
  runApp(NotesApp(themeController: themeController));
}

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class NotesApp extends StatefulWidget {
  const NotesApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  @override
  void initState() {
    super.initState();
    widget.themeController.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    widget.themeController.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: widget.themeController.mode,
      home: _AuthGate(themeController: widget.themeController),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate({required this.themeController});

  final ThemeController themeController;

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  String? _authError;
  bool _signingIn = false;

  @override
  void initState() {
    super.initState();
    _ensureSignedIn();
  }

  Future<void> _ensureSignedIn() async {
    if (FirebaseAuth.instance.currentUser != null) {
      if (mounted) setState(() => _authError = null);
      return;
    }

    setState(() {
      _signingIn = true;
      _authError = null;
    });

    try {
      await FirebaseAuth.instance.signInAnonymously();
      if (mounted) setState(() => _authError = null);
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase auth failed: ${e.code} ${e.message}');
      if (mounted) setState(() => _authError = _messageForAuthError(e));
    } catch (e) {
      debugPrint('Firebase auth failed: $e');
      if (mounted) setState(() => _authError = e.toString());
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  String _messageForAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'admin-restricted-operation':
      case 'operation-not-allowed':
        return 'Anonymous sign-in is disabled for project notetaker-953d5.\n\n'
            'In Firebase Console → Authentication → Sign-in method, '
            'open Anonymous, turn it ON, and tap Save. Then tap Retry below.';
      default:
        return '${e.code}: ${e.message ?? 'Sign-in failed'}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Prefer stream user; fall back to currentUser so we don't swap the home
        // subtree during transient ConnectionState.waiting (breaks Navigator if a
        // route like NoteEditor is pushed).
        final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
        final uid = user?.uid;

        if (uid != null) {
          return NotesHomeScreen(
            repo: NotesRepository(uid),
            themeController: widget.themeController,
          );
        }

        if (_signingIn || snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sign-in required',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (_signingIn)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    Text(
                      _authError ??
                          'Could not sign in anonymously. Check Firebase Authentication settings.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _ensureSignedIn,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry sign-in'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
