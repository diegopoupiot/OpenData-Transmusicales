class User {
  final String uid;
  final String email;
  final String displayName;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  factory User.fromFirebaseUser(User user) {
    return User(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
    );
  }
}