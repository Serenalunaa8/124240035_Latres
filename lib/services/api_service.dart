import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/episode.dart';

// Layanan untuk mengambil data dari Rick and Morty API
class ApiService {
  static const String baseUrl = 'https://rickandmortyapi.com/api';

  // Mengambil daftar karakter dengan filter status atau pencarian nama
  static Future<List<Character>> getCharacters({
    String? status,
    String? name,
  }) async {
    final queryParameters = <String, String>{};

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParameters['status'] = status.toLowerCase();
    }
    if (name != null && name.trim().isNotEmpty) {
      queryParameters['name'] = name.trim();
    }

    final uri = Uri.parse('$baseUrl/character').replace(
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'] ?? [];
      return results.map((item) => Character.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Gagal memuat data karakter (Error: ${response.statusCode})');
    }
  }

  // Mengambil detail satu karakter berdasarkan ID
  static Future<Character> getCharacterDetail(int id) async {
    final uri = Uri.parse('$baseUrl/character/$id');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Character.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail karakter (Error: ${response.statusCode})');
    }
  }

  // Mengambil daftar episode
  static Future<List<Episode>> getEpisodes({String? name}) async {
    try {
      final List<Episode> allEpisodes = [];
      for (int page = 1; page <= 3; page++) {
        final queryParams = <String, String>{'page': page.toString()};
        if (name != null && name.trim().isNotEmpty) {
          queryParams['name'] = name.trim();
        }
        final uri = Uri.parse('$baseUrl/episode').replace(queryParameters: queryParams);
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List results = data['results'] ?? [];
          allEpisodes.addAll(results.map((item) => Episode.fromJson(item)));
          final info = data['info'];
          if (info != null && info['next'] == null) {
            break;
          }
        } else {
          break;
        }
      }
      return allEpisodes;
    } catch (e) {
      final uri = Uri.parse('$baseUrl/episode');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'] ?? [];
        return results.map((item) => Episode.fromJson(item)).toList();
      }
      throw Exception('Gagal memuat data episode: $e');
    }
  }
}
