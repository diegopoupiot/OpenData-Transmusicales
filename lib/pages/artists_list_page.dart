import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/logout_button.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';

class ArtistsListPage extends StatefulWidget {
  const ArtistsListPage({super.key});

  @override
  State<ArtistsListPage> createState() => _ArtistsListPageState();
}

class _ArtistsListPageState extends State<ArtistsListPage> {
  List<Map<String, dynamic>> _artists = [];
  List<Map<String, dynamic>> _filteredArtists = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final Map<String, String> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    try {
      final response = await http.get(Uri.parse(
          'https://data.rennesmetropole.fr/api/explore/v2.1/catalog/datasets/artistes_concerts_transmusicales/records?select=artistes&limit=20'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final artists = List<Map<String, dynamic>>.from(data['results']);

        setState(() {
          _artists = artists;
          _filteredArtists = artists;
          _isLoading = false;
        });

        // Charger les images en arrière-plan
        _loadArtistImages(artists);
      } else {
        throw Exception('Failed to load artists');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des artistes: $e')),
        );
      }
    }
  }

  Future<void> _loadArtistImages(List<Map<String, dynamic>> artists) async {
    for (var artist in artists) {
      final artistName = artist['artistes']?.toString() ?? 'Unknown';
      if (!_imageCache.containsKey(artistName)) {
        final imageUrl = await _getArtistImageFromDeezer(artistName);
        if (imageUrl != null && mounted) {
          setState(() {
            _imageCache[artistName] = imageUrl;
          });
        }
      }
    }
  }

  Future<String?> _getArtistImageFromDeezer(String artistName) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.deezer.com/search/artist?q=$artistName'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0]['picture_big'];
        }
      }
    } catch (e) {
      print('Error fetching Deezer image: $e');
    }
    return null;
  }

  Widget _buildArtistCard(Map<String, dynamic> artist) {
    final artistName = artist['artistes']?.toString() ?? 'Unknown';
    final imageUrl = _imageCache[artistName];

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () => _onArtistTap(artist, imageUrl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultImage(),
                    )
                  else
                    _buildDefaultImage(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Text(
                      artistName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3.0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.music_note,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _filterArtists(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredArtists = _artists;
      } else {
        _filteredArtists = _artists.where((artist) {
          final name = artist['artistes']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return name.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _onArtistTap(
      Map<String, dynamic> artist, String? imageUrl) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final details = await _loadArtistDetails(artist['artistes']);
      Navigator.pop(context);

      if (details != null) {
        // Si l'image n'est pas déjà disponible, essayez de la récupérer
        if (imageUrl == null) {
          imageUrl = await _getArtistImageFromDeezer(artist['artistes']);
        }

        context.go('/artist-details', extra: {'artistes': artist['artistes']});
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Impossible de charger les détails de l\'artiste')),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur lors du chargement des détails')),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _loadArtistDetails(String artistName) async {
    try {
      final encodedName = Uri.encodeComponent('"$artistName"');
      final response = await http.get(Uri.parse(
          'https://data.rennesmetropole.fr/api/explore/v2.1/catalog/datasets/artistes_concerts_transmusicales/records?where=artistes=$encodedName&limit=1'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0];
        }
      }
      return null;
    } catch (e) {
      print('Error loading artist details: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des artistes'),
        centerTitle: true,
        actions: const [
          ThemeToggleButton(),
          LogoutButton(),
          SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(isDark: isDarkMode),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Rechercher un artiste',
                  hintText: 'Nom de l\'artiste',
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filterArtists('');
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _filterArtists,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredArtists.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun artiste trouvé',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                          ),
                          itemCount: _filteredArtists.length,
                          itemBuilder: (context, index) =>
                              _buildArtistCard(_filteredArtists[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
