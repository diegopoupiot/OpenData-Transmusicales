import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/logout_button.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';

class ArtistDetailsPage extends StatefulWidget {
  final String artistName;
  final String origin;
  final String year;
  final String? style;
  final String? website;
  final String? spotify;

  const ArtistDetailsPage({
    super.key,
    required this.artistName,
    required this.origin,
    required this.year,
    this.style,
    this.website,
    this.spotify,
  });

  @override
  State<ArtistDetailsPage> createState() => ArtistDetailsPageState();
}

class ArtistDetailsPageState extends State<ArtistDetailsPage> {
  Map<String, dynamic>? artist;
  bool isLoading = true;
  String? artistImageUrl;
  final Map<String, Map<String, dynamic>> _cache = {};

  @override
  void initState() {
    super.initState();
    fetchArtistData();
    fetchDeezerImage();
  }

  Future<void> fetchArtistData() async {
    if (_cache.containsKey(widget.artistName)) {
      setState(() {
        artist = _cache[widget.artistName];
        isLoading = false;
      });
      return;
    }

    final encodedName = Uri.encodeComponent('artistes="${widget.artistName}"');
    final url = Uri.parse(
      'https://data.rennesmetropole.fr/api/explore/v2.1/catalog/datasets/artistes_concerts_transmusicales/records?where=${encodedName}',
    );

    try {
      await Future.delayed(Duration(seconds: 1)); // Delay to prevent API spam
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["results"] != null && data["results"].isNotEmpty) {
          setState(() {
            artist = data["results"][0];
            _cache[widget.artistName] = artist!;
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchDeezerImage() async {
    try {
      await Future.delayed(Duration(seconds: 1)); // Delay to prevent API spam
      final response = await http.get(
        Uri.parse(
            'https://api.deezer.com/search/artist?q=${widget.artistName}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          setState(() {
            artistImageUrl = data['data'][0]['picture_big'];
          });
        }
      }
    } catch (e) {
      print('Error fetching Deezer image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final textColor = isDarkMode ? Colors.grey[100] : Colors.white;
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.white70;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryOrange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/artists'),
        ),
        title: Text(
          widget.artistName,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
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
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: isDarkMode ? Colors.white70 : AppTheme.primaryOrange,
                ),
              )
            : artist == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48,
                            color: isDarkMode ? Colors.red[300] : Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune information trouvée.',
                          style: TextStyle(color: textColor),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode
                                ? Colors.grey[800]
                                : AppTheme.primaryOrange,
                            foregroundColor:
                                isDarkMode ? Colors.white : Colors.white,
                          ),
                          onPressed: fetchArtistData,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchArtistData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          // Section Image et Nom
                          if (artistImageUrl != null)
                            Stack(
                              children: [
                                Container(
                                  height: 300,
                                  width: double.infinity,
                                  child: Image.network(
                                    artistImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image,
                                                size: 64),
                                  ),
                                ),
                                Container(
                                  height: 300,
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
                                  bottom: 20,
                                  left: 20,
                                  right: 20,
                                  child: Text(
                                    artist?['artistes'] ?? 'Nom non disponible',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          // Sections d'informations
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section Festival
                                _buildSection(
                                  'Informations Festival',
                                  [
                                    if (artist?[
                                            'edition_rencontres_trans_musicales'] !=
                                        null)
                                      _buildInfoSection(
                                        'Édition',
                                        artist!['edition_rencontres_trans_musicales']
                                            .toString(),
                                      ),
                                    if (artist?['annee'] != null)
                                      _buildInfoSection(
                                        'Année',
                                        artist!['annee'].toString(),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Section Origines
                                _buildSection(
                                  'Origines',
                                  [
                                    if (artist?['origines_pays_1'] != null)
                                      _buildInfoSection(
                                        'Pays',
                                        artist!['origines_pays_1'],
                                      ),
                                    if (artist?['origines_ville_1'] != null)
                                      _buildInfoSection(
                                        'Ville',
                                        artist!['origines_ville_1'],
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Section Première Performance
                                _buildSection(
                                  'Première Performance',
                                  [
                                    if (artist?['1ere_date'] != null)
                                      _buildInfoSection(
                                        'Date',
                                        artist!['1ere_date'],
                                      ),
                                    if (artist?['1ere_salle'] != null)
                                      _buildInfoSection(
                                        'Salle',
                                        artist!['1ere_salle'],
                                      ),
                                    if (artist?['1ere_ville'] != null)
                                      _buildInfoSection(
                                        'Ville',
                                        artist!['1ere_ville'],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final textColor = isDarkMode ? Colors.grey[100] : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey[800]!.withOpacity(0.5)
                : AppTheme.secondaryOrange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode
                  ? Colors.grey[700]!
                  : AppTheme.secondaryOrange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildInfoSection(String title, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final textColor = isDarkMode ? Colors.grey[100] : Colors.white;
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.white70;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey[850]!.withOpacity(0.5)
            : AppTheme.secondaryOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.grey[800]!
              : AppTheme.secondaryOrange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: secondaryTextColor,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
