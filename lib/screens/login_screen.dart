import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/error_formatter.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String _error = '';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 420,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  const Text('JANATA Log In', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(controller: _emailCtrl, decoration: const InputDecoration(hintText: 'Email')),
                  const SizedBox(height: 12),
                  TextField(controller: _passCtrl, decoration: const InputDecoration(hintText: 'Password'), obscureText: true),
                  const SizedBox(height: 18),
                  if (_error.isNotEmpty) Text(_error, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent[700]),
                      onPressed: _loading
                          ? null
                          : () async {
                              setState(() {
                                _loading = true;
                                _error = '';
                              });
                              try {
                                await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text);
                              } catch (e) {
                                setState(() {
                                  _error = FirebaseErrorFormatter.formatAuthError(e);
                                });
                              } finally {
                                setState(() {
                                  _loading = false;
                                });
                              }
                            },
                      child: _loading ? const CircularProgressIndicator() : const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Login', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                    child: const Text('Create New Account'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
