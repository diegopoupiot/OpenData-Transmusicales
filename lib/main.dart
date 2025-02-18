import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/pages/login_page.dart';
import 'package:flutter_application/pages/artists_list_page.dart';
import 'package:flutter_application/pages/artist_details_page.dart';
import 'package:flutter_application/theme/app_theme.dart';
import 'package:flutter_application/providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final goRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/artists',
          builder: (context, state) => const ArtistsListPage(),
        ),
        GoRoute(
          path: '/artist-details',
          builder: (context, state) {
            final artist = state.extra as Map<String, dynamic>;
            return ArtistDetailsPage(
                artistName: artist['artistes'] ?? 'Unknown Artist');
          },
        ),
      ],
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'Trans Musicales',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: goRouter,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr'),
            Locale('en'),
          ],
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  // ... existing code ...

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int currentLikes;

  @override
  void initState() {
    super.initState();
    currentLikes = 0;
  }

  void _incrementLikes() {
    setState(() {
      currentLikes++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... existing AppBar code ...
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ... existing image and other widgets ...
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: _incrementLikes,
                ),
                Text('$currentLikes likes'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
