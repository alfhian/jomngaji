import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../config/router.dart';
import '../data/home_repository.dart';
import '../data/surah_repository.dart';
import '../services/audio_service.dart';
import '../services/record_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<GoRouter>()) {
    return;
  }

  getIt
    ..registerLazySingleton<AudioService>(AudioService.new)
    ..registerLazySingleton<RecordService>(RecordService.new)
    ..registerLazySingleton<SurahRepository>(InMemorySurahRepository.new)
    ..registerLazySingleton<HomeRepository>(HomeRepository.new);

  getIt.registerSingleton<GoRouter>(createRouter(getIt<SurahRepository>()));
}
