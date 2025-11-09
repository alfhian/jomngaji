import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'src/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('Firebase init skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
  await bootstrap();
}
