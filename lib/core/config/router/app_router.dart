import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/main_shell.dart';
import '../../../features/splash/presentation/splash_screen.dart';
import '../../../features/home/presentation/home_screen.dart';
import '../../../features/keystores/presentation/keystores_screen.dart';
import '../../../features/details/presentation/details_screen.dart';
import '../../../features/about/presentation/about_screen.dart';
import '../../../features/scanner/presentation/scanner_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/keystores',
            name: 'keystores',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const KeystoresScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/about',
            name: 'about',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const AboutScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/details/:id',
        name: 'details',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DetailsScreen(keystoreId: id);
        },
      ),
      GoRoute(
        path: '/scanner',
        name: 'scanner',
        builder: (context, state) => const ScannerScreen(),
      ),
    ],
  );
});
