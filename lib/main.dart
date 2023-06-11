import 'package:flutter/material.dart';
import 'package:free_aac/composeSentencePage.dart';
import 'package:free_aac/savedSentencesPage.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoRouter _createRouter() {
    final List<GoRoute> routes = [
      GoRoute(
        path: "/composeSentence",
        builder: (context, state) => const ComposeSentencePage(),
      ),
      GoRoute(
        path: "/savedSentences",
        builder: (context, state) => const SavedSentencesPage(),
      ),
      GoRoute(
        path: "/settings",
        builder: (context, state) => const Placeholder(),
      ),
    ];

    return GoRouter(
      initialLocation: '/savedSentences',
      routes: [
        ShellRoute(
          routes: routes,
          builder: (context, state, child) {
            int selectedIndex = routes
                .indexWhere((r) => GoRouter.of(context).location == r.path);

            return Scaffold(
              bottomNavigationBar: NavigationBar(
                selectedIndex: selectedIndex,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.speaker_notes),
                    label: "Compose Sentence",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.home),
                    label: "Saved Sentences",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings),
                    label: "Settings",
                  ),
                ],
                onDestinationSelected: (index) =>
                    GoRouter.of(context).go(routes[index].path),
              ),
              body: child,
            );
          },
        )
      ],
    );
    ;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final router = _createRouter();

    return MaterialApp.router(
      routerConfig: router,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
    );
  }
}
