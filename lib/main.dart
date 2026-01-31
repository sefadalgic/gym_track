import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gym_track/core/cache/cache_manager.dart';
import 'package:gym_track/core/constants/app/app_constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_track/product/routes/go_routes.dart';
import 'firebase_options.dart';

//TODO Firebase configuration for IOS

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure Firebase Auth persistence for web
  // This ensures the user session persists across browser restarts
  if (!(Platform.isAndroid || Platform.isIOS)) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  // Register Hive type adapters
  CacheManager.instance.registerAdapters();

  // Initialize cache manager
  await CacheManager.instance.init();

  // Configure Firestore for aggressive caching
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter,
      title: AppConstants.APP_NAME,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}
