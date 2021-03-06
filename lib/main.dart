import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:youtube_clone/core/constants/configs.dart';
import 'package:youtube_clone/core/services/posts_service.dart';
import 'package:youtube_clone/core/services/image_picker_service.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_clone/cubits/posts_cubit/posts_cubit.dart';
import 'package:youtube_clone/cubits/theme_cubit/theme_cubit.dart';

import 'package:device_preview/device_preview.dart';
import 'package:youtube_clone/ui/styles/styles.dart';

import 'package:youtube_clone/ui/pages/bottom_nav_page/bottom_nav_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => PostsService()),
        RepositoryProvider(create: (_) => ImagePickerService()),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) => PostsCubit(
            postsService: context.read<PostsService>(),
          )..watchPosts(),
        ),
      ],
      child: DevicePreview(
        enabled: Platform.isWindows,
        storage: FileDevicePreviewStorage(
          file: File('./temp/device_preview.json'),
        ),
        builder: (context) => BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: themeMode,
              theme: AppThemes.light,
              darkTheme: AppThemes.dark,
              title: AppConfig.appName,
              builder: DevicePreview.appBuilder,
              locale: DevicePreview.locale(context),
              home: const BottomNavPage(),
            );
          },
        ),
      ),
    );
  }
}
