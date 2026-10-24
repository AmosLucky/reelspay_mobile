import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';

abstract interface class StartupService {
  Future<void> ensureAnonymousSession();
  Future<void> requestNotificationPermission();
  Future<void> signOut();
}

class FirebaseStartupService implements StartupService {
  const FirebaseStartupService();

  @override
  Future<void> ensureAnonymousSession() async {
    await Firebase.initializeApp();
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  }

  @override
  Future<void> requestNotificationPermission() async {
    await Permission.notification.request();
  }

  @override
  Future<void> signOut() => FirebaseAuth.instance.signOut();
}
