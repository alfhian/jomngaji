import 'package:flutter/material.dart';

import 'app.dart';
import 'di/service_locator.dart';

Future<void> bootstrap() async {
  await configureDependencies();
  runApp(const QuranApp());
}
