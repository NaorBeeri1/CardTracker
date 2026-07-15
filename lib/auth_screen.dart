import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String _errorMessage = '';

  bool _validatePassword(String password) {
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters long.');
      return false;
    }
    return true;
  }

  Future<void> _submitAuthForm() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!_isLogin && username.isEmpty)) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }

    if (!_isLogin && !_validatePassword(password)) {
      return;
    }

    if (!_isLogin && username.length < 3) {
      setState(() => _errorMessage = 'Username must be at least 3 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_isLogin) {
        UserCredential userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).get();
        if (!userDoc.exists || userDoc.data()?['username'] == null || (userDoc.data()?['username'] as String).isEmpty) {
          await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
            'username': email.split('@')[0],
            'email': email,
            'profileIcon': 'album',
            'profileImageBase64': '',
            'friends': [],
          }, SetOptions(merge: true));
        }
      } else {
        final query = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .get();

        if (query.docs.isNotEmpty) {
          setState(() {
            _errorMessage = 'Username is already taken. Choose another.';
            _isLoading = false;
          });
          return;
        }

        UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
          'username': username,
          'email': email,
          'profileIcon': 'album',
          'profileImageBase64': '',
          'friends': [],
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AlbumScreen()),
      );
    } on FirebaseAuthException catch (error) {
      setState(() {
        _errorMessage = error.message ?? 'An authentication error occurred.';
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  // --- SMART GUEST MODE (Auto-creates and logs in instantly) ---
  Future<void> _loginAsGuest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    const guestEmail = 'guest@mjtracker.com';
    const guestPassword = 'password123';

    try {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: guestEmail,
          password: guestPassword,
        );
      } catch (_) {
        UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: guestEmail,
          password: guestPassword,
        );

        await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
          'username': 'GuestCollector',
          'email': guestEmail,
          'profileIcon': 'album',
          'profileImageBase64': '',
          'friends': [],
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AlbumScreen()),
      );
    } catch (error) {
      setState(() {
        _errorMessage = 'Guest login failed: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email above to reset password.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent! Please check your inbox and spam/junk folder.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
      setState(() => _errorMessage = '');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? 'Failed to send reset email.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.album, size: 80, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  _isLogin ? 'MJ Card Tracker' : 'Create Account',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 32),
                if (!_isLogin) ...[
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password (min 6 chars)',
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                if (_isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: const Text('Forgot Password?', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                  ),
                const SizedBox(height: 10),
                if (_errorMessage.isNotEmpty)
                  Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.amber)
                    : Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _submitAuthForm,
                            child: Text(_isLogin ? 'Login' : 'Sign Up', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 12),
                          // --- GUEST MODE BUTTON ---
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.amber,
                              side: const BorderSide(color: Colors.amber),
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _loginAsGuest,
                            child: const Text('View as Guest / Test App', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _errorMessage = '';
                    });
                  },
                  child: Text(
                    _isLogin ? 'Create a new account' : 'I already have an account',
                    style: const TextStyle(color: Colors.amber),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}