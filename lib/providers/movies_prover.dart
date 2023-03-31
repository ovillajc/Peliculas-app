import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/helpers/debouncer.dart';

import 'package:peliculas/models/models.dart';

class MoviesProvider extends ChangeNotifier {
  final String _baseUrl = 'api.themoviedb.org';
  final String _apiKey = 'a22d98f6ffda4e4186a63ec59654764c';
  final String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> movieCast = {};

  int _popularPage = 0;

  // ?Debouncer: esperara a que el usuario escribia para enviar la info al stream y hacer la peticion http
  final debouncer = Debouncer(
    duration: const Duration(milliseconds: 300),
    // onValue: (value) {}
  );

  // ?StreamController que estara pendiente del search input
  final StreamController<List<Movie>> _suggestionsStreamController =
      StreamController.broadcast();

  // ?Stream que recibira los datos
  Stream<List<Movie>> get suggestionStream =>
      _suggestionsStreamController.stream;

  MoviesProvider() {
    getOnNowPlayingMovies();

    getPopularMovies();
  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endpoint, {
      'api_key': _apiKey,
      'language': _language,
      'page': '$page',
    });

    // Await the http get response, then decode the json-formatted response.
    final response = await http.get(url);
    return response.body;
  }

  getOnNowPlayingMovies() async {
    const String endpoint = '/3/movie/now_playing';
    // Llamado del metodo que solicita la data a los endpoints
    final jsonData = await _getJsonData(endpoint);

    // Llamar a la instancia del modelo now playing
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);

    onDisplayMovies = nowPlayingResponse.results;
    // Metodo para redibujar widgets, indica a los widgets que sucedio un cambion en la data para que los redibujen
    notifyListeners();
  }

  getPopularMovies() async {
    _popularPage++;

    const String endpoint = '/3/movie/popular';
    final jsonData = await _getJsonData(endpoint, _popularPage);

    // Llamar a la instancia del modelo now playing
    final popularResponse = PopularResponse.fromJson(jsonData);

    // Resultados de la peticion con las peliculas
    popularMovies = [...popularMovies, ...popularResponse.results];

    // Metodo para redibujar widgets, indica a los widgets que sucedio un cambion en la data para que los redibujen
    notifyListeners();
  }

  Future<List<Cast>> getMoieCast(int movieId) async {
    // Mantener en memoria los actores para no volver a hacer la petición
    if (movieCast.containsKey(movieId)) return movieCast[movieId]!;
    // print('pidiendo Información al servidor');

    // Todo: revisar el mapa
    final jsonData = await _getJsonData('/3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);

    movieCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;
  }

  // Realizar la petición del search
  Future<List<Movie>> searchMovies(String query) async {
    const endpoint = '/3/search/movie';

    final url = Uri.https(_baseUrl, endpoint, {
      'api_key': _apiKey,
      'language': _language,
      'query': query,
    });

    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;
  }

  // Metodo que ingresa el valor del query al stream
  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await searchMovies(value);
      _suggestionsStreamController.add(results);
    };

    // Establecer un timer que mandara el debouncer con el valor escrito por el usuario
    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    // Cancerlar el timer si se vuelve a recibir un valor
    Future.delayed(const Duration(milliseconds: 301))
        .then((_) => timer.cancel());
  }
}
