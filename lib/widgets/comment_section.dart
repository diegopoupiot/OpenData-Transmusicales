import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CommentSection extends StatefulWidget {
  final String artistName;

  const CommentSection({super.key, required this.artistName});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, String>> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
    _loadRating();
  }

  Future<void> _loadComments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? commentsString = prefs.getString('comments_${widget.artistName}');
    if (commentsString != null) {
      final List<dynamic> decodedComments = json.decode(commentsString);
      setState(() {
        _comments.addAll(decodedComments.map((comment) => Map<String, String>.from(comment)).toList());
      });
    }
  }

  Future<void> _loadRating() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rating = prefs.getDouble('rating_${widget.artistName}') ?? 0;
    });
  }

  Future<void> _saveComments() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('comments_${widget.artistName}', json.encode(_comments));
  }

  Future<void> _saveRating() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('rating_${widget.artistName}', _rating);
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _comments.add({
          "user": "Utilisateur",
          "comment": _commentController.text,
        });
        _commentController.clear();
      });
      _saveComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Divider(color: textColor.withOpacity(0.1)),
        const SizedBox(height: 16),
        Text(
          "Notez cet artiste :",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        RatingBar.builder(
          initialRating: _rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: isDarkMode ? Colors.amber[300] : Colors.amber,
          ),
          onRatingUpdate: (rating) {
            setState(() => _rating = rating);
            _saveRating();
          },
        ),
        const SizedBox(height: 24),
        Text(
          "Commentaires :",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: "Ajoutez un commentaire...",
            hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
            suffixIcon: IconButton(
              icon: Icon(Icons.send, color: textColor),
              onPressed: _addComment,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: textColor.withOpacity(0.3)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._comments.map((comment) => Card(
          color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(comment["user"]!, 
                     style: TextStyle(color: textColor)),
            subtitle: Text(comment["comment"]!,
                        style: TextStyle(color: textColor.withOpacity(0.8))),
          ),
        )).toList(),
      ],
    );
  }
}