import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

const bool useFirebaseEmulators =
    bool.fromEnvironment('USE_FIREBASE_EMULATORS', defaultValue: false);
const bool enableFirebaseAppCheck =
    bool.fromEnvironment('ENABLE_FIREBASE_APP_CHECK', defaultValue: false);
const bool enableAnonymousFirebaseAuth =
    bool.fromEnvironment('ENABLE_FIREBASE_ANON_AUTH', defaultValue: false);
const String firebaseAppCheckWebKey =
    String.fromEnvironment('FIREBASE_APP_CHECK_WEB_KEY');

class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static Future<void> initialize() async {
    final FirebaseOptions? options = optionsForCurrentPlatform();
    if (options == null) {
      return;
    }

    await Firebase.initializeApp(
      options: options,
    );

    if (useFirebaseEmulators) {
      final String host = _emulatorHost();
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
      FirebaseStorage.instance.useStorageEmulator(host, 9199);
    }

    if (enableFirebaseAppCheck) {
      if (kIsWeb && firebaseAppCheckWebKey.isEmpty) {
        throw StateError(
          'FIREBASE_APP_CHECK_WEB_KEY is required when App Check is enabled on web.',
        );
      }

      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleAppAttestWithDeviceCheckFallbackProvider(),
        providerWeb: kIsWeb && firebaseAppCheckWebKey.isNotEmpty
            ? ReCaptchaV3Provider(firebaseAppCheckWebKey)
            : null,
      );
    }

    if (enableAnonymousFirebaseAuth &&
        FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

  static FirebaseOptions? optionsForCurrentPlatform() {
    try {
      return DefaultFirebaseOptions.currentPlatform;
    } on UnsupportedError {
      // Keep local desktop testing usable even when FlutterFire is not
      // configured for that host platform yet.
      return null;
    }
  }

  static String _emulatorHost() {
    if (kIsWeb) {
      return '127.0.0.1';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return '10.0.2.2';
      default:
        return '127.0.0.1';
    }
  }
}
