// 初始化音频背景处理

import 'package:get_it/get_it.dart';
import '../page_manager.dart';
import 'audio_handler.dart';
import 'playlist_repository.dart';

GetIt getIt = GetIt.instance;
Future<void> setupServiceLocator() async {
  getIt.registerSingleton<AudioPlayerHandler>(await initAudioService());
  getIt.registerLazySingleton<PlaylistRepository>(() => DemoPlaylist());
  getIt.registerLazySingleton<PageManager>(() => PageManager());
}
