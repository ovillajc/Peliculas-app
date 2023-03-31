import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:peliculas/screens/screens.dart';
import 'package:peliculas/providers/movies_prover.dart';

void main() => runApp(const AppState());

// !Matener el estado del MovieProvider para que toda la app tenga acceso a su instancia
class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Inicializamos la instancia de movie provider
        ChangeNotifierProvider(create: (_) => MoviesProvider(), lazy: false),
      ],
      // Llamamos a MyApp para poder generar la app
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peliculas',
      initialRoute: 'home',
      routes: {
        'home': (_) => const HomeScreen(),
        'details': (_) => const DetailsScreen()
      },
      theme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(
          color: Colors.blue,
        ),
      ),
    );
  }
}
