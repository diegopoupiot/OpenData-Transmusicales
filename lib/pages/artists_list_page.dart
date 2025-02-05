import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/artist.dart';
import '../services/transmusicales_service.dart';

class ArtistsListPage extends StatefulWidget {
  const ArtistsListPage({super.key});

  @override
  State<ArtistsListPage> createState() => _ArtistsListPageState();
}

class _ArtistsListPageState extends State<ArtistsListPage> {
  final _transmusicalesService = TransmusicalesService();
  final _searchController = TextEditingController();
  List<Artist> _artists = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final artists = await _transmusicalesService.getArtists();
      setState(() {
        _artists = artists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchArtists(String query) async {
    if (query.isEmpty) {
      _loadArtists();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final artists = await _transmusicalesService.searchArtists(query);
      setState(() {
        _artists = artists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transmusicales'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un artiste...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadArtists();
                        },
                      )
                    : null,
              ),
              onChanged: _searchArtists,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_error!),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _artists.length,
                        itemBuilder: (context, index) {
                          final artist = _artists[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(artist.name),
                              subtitle: Text(
                                  '${artist.origin} - ${artist.year}${artist.style != null ? '\nStyle: ${artist.style}' : ''}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                context.go('/artist-details', extra: artist);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
