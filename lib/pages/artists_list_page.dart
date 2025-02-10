import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/artist.dart';
import '../services/transmusicales_service.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../widgets/theme_toggle_button.dart';

class ArtistsListPage extends StatefulWidget {
  const ArtistsListPage({super.key});

  @override
  State<ArtistsListPage> createState() => _ArtistsListPageState();
}

class _ArtistsListPageState extends State<ArtistsListPage> {
  final TransmusicalesService _service = TransmusicalesService();
  final TextEditingController _searchController = TextEditingController();
  List<Artist> _artists = [];
  List<Artist> _filteredArtists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    try {
      final artists = await _service.getArtists();
      setState(() {
        _artists = artists;
        _filteredArtists = artists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du chargement des artistes'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _searchArtists(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredArtists = _artists;
      } else {
        _filteredArtists = _artists
            .where((artist) =>
                artist.name.toLowerCase().contains(query.toLowerCase()) ||
                artist.origin.toLowerCase().contains(query.toLowerCase()) ||
                (artist.style?.toLowerCase() ?? '').contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artistes'),
        centerTitle: true,
        actions: [
          const ThemeToggleButton(),
          const SizedBox(width: 8),
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
                onChanged: _searchArtists,
                decoration: InputDecoration(
                  hintText: 'Rechercher un artiste...',
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : _filteredArtists.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun artiste trouvé',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _filteredArtists.length,
                          itemBuilder: (context, index) {
                            final artist = _filteredArtists[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16.0),
                                title: Text(
                                  artist.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text('Origine: ${artist.origin}'),
                                    Text('Style: ${artist.style ?? "Non spécifié"}'),
                                    Text('Année: ${artist.year}'),
                                  ],
                                ),
                                onTap: () {
                                  context.go('/artist-details', extra: {
                                    'name': artist.name,
                                    'origin': artist.origin,
                                    'year': artist.year,
                                    'style': artist.style,
                                    'website': artist.website,
                                    'spotify': artist.spotify,
                                  });
                                },
                              ),
                            );
                          },
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
