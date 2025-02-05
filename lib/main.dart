import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/login_page.dart';
import 'pages/artists_list_page.dart';
import 'pages/artist_details_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
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
        final extra = state.extra as Map<String, dynamic>;
        return ArtistDetailsPage(
          name: extra['name'],
          origin: extra['origin'],
          year: extra['year'],
          style: extra['style'],
          website: extra['website'],
          spotify: extra['spotify'],
        );
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Trans Musicales',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
