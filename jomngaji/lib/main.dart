import 'package:flutter/material.dart';

import 'core/localization/app_localization.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/services/auth_service.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final loggedIn = await AuthService.isLoggedIn();
  final languageController = AppLanguageController();
  await languageController.load();

  runApp(
    AppLocalizationScope(
      controller: languageController,
      child: JomNgajiApp(isLoggedIn: loggedIn),
    ),
  );
}

class JomNgajiApp extends StatelessWidget {
  final bool isLoggedIn;

  const JomNgajiApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MaterialApp(
      title: l10n.text('app.title'),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final clampedScale = media.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: media.copyWith(textScaler: clampedScale),
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: isLoggedIn ? AppRoutes.home : AppRoutes.login,
      onGenerateInitialRoutes: (initialRouteName) {
        final routeName = isLoggedIn ? AppRoutes.home : AppRoutes.login;
        final builder = AppRoutes.routes[routeName];
        if (builder == null) {
          return <Route<dynamic>>[];
        }
        return <Route<dynamic>>[
          MaterialPageRoute<void>(
            settings: RouteSettings(name: routeName),
            builder: builder,
          ),
        ];
      },
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
