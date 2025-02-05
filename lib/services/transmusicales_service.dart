import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/artist.dart';

class TransmusicalesService {
  static const String _baseUrl =
      'https://data.rennesmetropole.fr/api/records/1.0/search/';
  static const String _dataset = 'artistes_concerts_transmusicales';

  Future<List<Artist>> getArtists({int start = 0, int rows = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?dataset=$_dataset&start=$start&rows=$rows'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final records = data['records'] as List;

        return records.map((record) {
          final fields = record['fields'] as Map<String, dynamic>;
          return Artist.fromJson(fields);
        }).toList();
      } else {
        throw Exception('Failed to load artists');
      }
    } catch (e) {
      throw Exception('Error fetching artists: $e');
    }
  }

  Future<List<Artist>> searchArtists(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?dataset=$_dataset&q=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final records = data['records'] as List;

        return records.map((record) {
          final fields = record['fields'] as Map<String, dynamic>;
          return Artist.fromJson(fields);
        }).toList();
      } else {
        throw Exception('Failed to search artists');
      }
    } catch (e) {
      throw Exception('Error searching artists: $e');
    }
  }
}
