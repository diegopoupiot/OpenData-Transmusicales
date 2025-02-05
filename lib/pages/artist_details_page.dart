import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArtistDetailsPage extends StatelessWidget {
  final String name;
  final String origin;
  final String year;
  final String? style;
  final String? website;
  final String? spotify;

  const ArtistDetailsPage({
    super.key,
    required this.name,
    required this.origin,
    required this.year,
    this.style,
    this.website,
    this.spotify,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/artists'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/'),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoTile('Origine', origin),
            _buildInfoTile('Année', year),
            if (style != null) _buildInfoTile('Style', style!),
            if (website != null) _buildInfoTile('Site web', website!),
            if (spotify != null) _buildInfoTile('Spotify', spotify!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
