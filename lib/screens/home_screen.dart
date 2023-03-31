import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:peliculas/widgets/widgets.dart';
import 'package:peliculas/providers/movies_prover.dart';
import 'package:peliculas/search/search_delegate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener instancia de movie provider
    final moviesProvider = Provider.of<MoviesProvider>(context);
    // print(moviesProvider.onDisplayMovies);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peliculas en cines'),
        elevation: 0,
        actions: [
          IconButton(
            // Implementar search
            onPressed: () => showSearch(
              context: context,
              delegate: MovieSearchDelegate(),
            ),
            icon: const Icon(Icons.search_outlined),
          ),
        ],
      ),
      // Para evitar el error de sobre pasar los pixeles
      body: SingleChildScrollView(
        child: Column(
          children: [
            // CardSwiper Tarjetas principales
            CardSwiper(movies: moviesProvider.onDisplayMovies),

            // Listado horizontal de peliculas carrusel
            MovieSlider(
              movies: moviesProvider.popularMovies,
              title: 'Populares',
              onNextPage: () => moviesProvider.getPopularMovies(),
            ),
          ],
        ),
      ),
    );
  }
}
