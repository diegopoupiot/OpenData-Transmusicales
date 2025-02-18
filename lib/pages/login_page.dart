import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/theme/app_theme.dart';
import 'package:flutter_application/providers/theme_provider.dart';
import 'package:flutter_application/widgets/theme_toggle_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _usernameController.text,
        password: _passwordController.text,
      );
      
      if (mounted) {
        context.go('/artists');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'Aucun utilisateur trouvé pour cet email.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Mot de passe incorrect.';
        } else {
          _errorMessage = 'Erreur de connexion: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur s\'est produite: $e';
      });
    }
  }

  Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    await _auth.createUserWithEmailAndPassword(
      email: _usernameController.text,
      password: _passwordController.text,
    );
    
    if (mounted) {
      context.go('/artists');
    }
  } on FirebaseAuthException catch (e) {
    setState(() {
      if (e.code == 'weak-password') {
        _errorMessage = 'Le mot de passe fourni est trop faible.';
      } else if (e.code == 'email-already-in-use') {
        _errorMessage = 'Un compte existe déjà pour cet email.';
      } else {
        _errorMessage = 'Erreur d\'inscription: ${e.message}';
      }
    });
  } catch (e) {
    setState(() {
      _errorMessage = 'Une erreur s\'est produite: $e';
    });
  }

  setState(() {
    _isLoading = false;
  });
}


  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trans Musicales'),
        centerTitle: true,
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(isDark: isDarkMode),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 120,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.error,
                            size: 120,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Login Form
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Nom d\'utilisateur',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer un nom d\'utilisateur';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Mot de passe',
                                prefixIcon: Icon(Icons.lock),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer un mot de passe';
                                }
                                return null;
                              },
                            ),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Se connecter',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
